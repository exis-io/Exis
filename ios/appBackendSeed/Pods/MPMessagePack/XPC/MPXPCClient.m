//
//  MPXPCClient.m
//  MPMessagePack
//
//  Created by Gabriel on 5/5/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "MPXPCClient.h"

#import "MPDefines.h"
#import "NSArray+MPMessagePack.h"
#import "NSData+MPMessagePack.h"
#import "MPXPCProtocol.h"
#import "MPRPCProtocol.h"


@interface MPXPCClient ()
@property NSString *serviceName;
@property BOOL privileged;
@property MPMessagePackReaderOptions readOptions;

@property xpc_connection_t connection;
@property NSInteger messageId;
@end

@implementation MPXPCClient

- (instancetype)initWithServiceName:(NSString *)serviceName privileged:(BOOL)privileged {
  return [self initWithServiceName:serviceName privileged:privileged readOptions:0];
}

- (instancetype)initWithServiceName:(NSString *)serviceName privileged:(BOOL)privileged readOptions:(MPMessagePackReaderOptions)readOptions {
  if ((self = [super init])) {
    _serviceName = serviceName;
    _privileged = privileged;
    _timeout = 2.0;
    _readOptions = readOptions;
  }
  return self;
}

- (BOOL)connect:(NSError **)error {
  _connection = xpc_connection_create_mach_service([_serviceName UTF8String], NULL, _privileged ? XPC_CONNECTION_MACH_SERVICE_PRIVILEGED : 0);

  if (!_connection) {
    if (error) *error = MPMakeError(MPXPCErrorCodeInvalidConnection, @"Failed to create connection");
    return NO;
  }

  MPWeakSelf wself = self;
  xpc_connection_set_event_handler(_connection, ^(xpc_object_t event) {
    xpc_type_t type = xpc_get_type(event);
    if (type == XPC_TYPE_ERROR) {
      if (event == XPC_ERROR_CONNECTION_INTERRUPTED) {
        // Interrupted
      } else if (event == XPC_ERROR_CONNECTION_INVALID) {
        dispatch_async(dispatch_get_main_queue(), ^{
          wself.connection = nil;
        });
      } else {
        // Unknown error
      }
    } else {
      // Unexpected event
    }
  });

  xpc_connection_resume(_connection);
  return YES;
}

- (void)close {
  if (_connection) {
    xpc_connection_cancel(_connection);
    _connection = nil;
  }
}

- (void)sendRequest:(NSString *)method params:(NSArray *)params completion:(void (^)(NSError *error, id value))completion {
  [self sendRequest:method params:params attempt:0 completion:completion];
}

- (void)sendRequest:(NSString *)method params:(NSArray *)params attempt:(NSInteger)attempt completion:(void (^)(NSError *error, id value))completion {
  if (!_connection) {
    NSError *error = nil;
    if (![self connect:&error]) {
      completion(error, nil);
      return;
    }
  }

  NSError *error = nil;
  xpc_object_t message = [MPXPCProtocol XPCObjectFromRequestWithMethod:method messageId:++_messageId params:params error:&error];
  if (!message) {
    completion(error, nil);
    return;
  }

  // For timeout (TODO cancelable block?)
  __block BOOL replied = NO;
  if (_timeout > 0) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _timeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      if (!replied) {
        completion(MPMakeError(MPXPCErrorCodeTimeout, @"Timeout"), nil);
      }
    });
  }

  if (!_connection) {
    completion(MPMakeError(MPXPCErrorCodeInvalidConnection, @"No connection"), nil);
    return;
  }

  xpc_connection_send_message_with_reply(_connection, message, dispatch_get_main_queue(), ^(xpc_object_t event) {
    replied = YES;
    if (xpc_get_type(event) == XPC_TYPE_ERROR) {

      // If we failed on retry, return error, otherwise retry
      if (attempt == 1) {
        const char *description = xpc_dictionary_get_string(event, "XPCErrorDescription");
        NSString *errorMessage = [NSString stringWithCString:description encoding:NSUTF8StringEncoding];
        completion(MPMakeError(MPXPCErrorCodeInvalidConnection, @"XPC Error: %@", errorMessage), nil);
      } else {
        [self sendRequest:method params:params attempt:attempt+1 completion:completion];
      }

    } else if (xpc_get_type(event) == XPC_TYPE_DICTIONARY) {
      NSError *error = nil;
      size_t length = 0;
      const void *buffer = xpc_dictionary_get_data(event, "data", &length);
      NSData *dataResponse = [NSData dataWithBytes:buffer length:length];

      id response = [dataResponse mp_array:_readOptions error:&error];

      if (!response) {
        completion(error, nil);
        return;
      }
      if (!MPVerifyResponse(response, &error)) {
        completion(error, nil);
        return;
      }
      NSDictionary *errorDict = MPIfNull(response[2], nil);
      if (errorDict) {
        error = MPErrorFromErrorDict(_serviceName, errorDict);
        completion(error, nil);
      } else {
        completion(nil, MPIfNull(response[3], nil));
      }
    }
  });
}

@end