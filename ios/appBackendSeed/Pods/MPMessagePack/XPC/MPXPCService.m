//
//  MPMessagePackXPC.m
//  MPMessagePack
//
//  Created by Gabriel on 5/5/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "MPXPCService.h"

#import "NSData+MPMessagePack.h"
#import "NSArray+MPMessagePack.h"
#import "MPXPCProtocol.h"
#import "MPDefines.h"

@interface MPXPCService () <NSXPCListenerDelegate>
@property xpc_connection_t connection;
@end

#import <syslog.h>

void MPSysLog(NSString *msg, ...) {
  va_list args;
  va_start(args, msg);

  NSString *string = [[NSString alloc] initWithFormat:msg arguments:args];

  va_end(args);

  NSLog(@"%@", string);
  syslog(LOG_NOTICE, "%s", [string UTF8String]);
}


@implementation MPXPCService

- (void)listen:(xpc_connection_t)service {
  xpc_connection_set_event_handler(service, ^(xpc_object_t connection) {

    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {

      xpc_type_t type = xpc_get_type(event);

      if (type == XPC_TYPE_ERROR) {
        MPSysLog(@"Error: %@", event);
        if (event == XPC_ERROR_CONNECTION_INVALID) {
          // The client process on the other end of the connection has either
          // crashed or cancelled the connection. After receiving this error,
          // the connection is in an invalid state, and you do not need to
          // call xpc_connection_cancel(). Just tear down any associated state
          // here.
        } else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
          // Handle per-connection termination cleanup.
        }
      } else {
        xpc_connection_t remote = xpc_dictionary_get_remote_connection(event);
        [self handleEvent:event completion:^(NSError *error, NSData *data) {
          if (error) {
            xpc_object_t reply = xpc_dictionary_create_reply(event);
            xpc_dictionary_set_string(reply, "error", [[error localizedDescription] UTF8String]);
            xpc_connection_send_message(remote, reply);
          } else {
            xpc_object_t reply = xpc_dictionary_create_reply(event);
            xpc_dictionary_set_data(reply, "data", [data bytes], [data length]);
            xpc_connection_send_message(remote, reply);
          }
        }];
      }
    });

    xpc_connection_resume(connection);
  });

  xpc_connection_resume(service);
}

- (void)handleEvent:(xpc_object_t)event completion:(void (^)(NSError *error, NSData *data))completion {
  [MPXPCProtocol requestFromXPCObject:event completion:^(NSError *error, NSNumber *messageId, NSString *method, NSArray *params) {
    if (error) {
      MPSysLog(@"Request error: %@", error);
      completion(error, nil);
    } else {
      [self handleRequestWithMethod:method params:params messageId:messageId completion:^(NSError *error, id value) {
        if (error) {
          NSDictionary *errorDict = @{@"code": @(error.code), @"desc": error.localizedDescription};
          NSArray *response = @[@(1), messageId, errorDict, NSNull.null];
          NSData *dataResponse = [response mp_messagePack];
          completion(nil, dataResponse);
        } else {
          NSArray *response = @[@(1), messageId, NSNull.null, (value ? value : NSNull.null)];
          NSData *dataResponse = [response mp_messagePack];
          completion(nil, dataResponse);
        }
      }];
    }
  }];
}

- (void)handleRequestWithMethod:(NSString *)method params:(NSArray *)params messageId:(NSNumber *)messageId completion:(void (^)(NSError *error, id value))completion {
  completion(MPMakeError(MPXPCErrorCodeUnknownRequest, @"Unkown request"), nil);
}

@end
