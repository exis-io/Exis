//
//  MPRPCProtocol.h
//  MPMessagePack
//
//  Created by Gabriel on 8/30/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MPMessagePackWriter.h"
#import "MPMessagePackReader.h"

extern NSString *const MPErrorInfoKey;

typedef NS_ENUM (NSInteger, MPRPCError) {
  MPRPCErrorSocketCreateError = -3,
  MPRPCErrorSocketOpenError = -6,
  MPRPCErrorSocketOpenTimeout = -7,
  MPRPCErrorInvalidRequest = -20,
};

@interface MPRPCProtocol : NSObject

- (NSData *)encodeRequestWithMethod:(NSString *)method params:(NSArray *)params messageId:(NSInteger)messageId options:(MPMessagePackWriterOptions)options framed:(BOOL)framed error:(NSError **)error;

- (NSData *)encodeResponseWithResult:(id)result error:(id)error messageId:(NSInteger)messageId options:(MPMessagePackWriterOptions)options framed:(BOOL)framed encodeError:(NSError **)encodeError;

- (NSArray *)decodeMessage:(NSData *)data framed:(BOOL)framed error:(NSError **)error;

@end


// Verify the object is a valid msgpack rpc message
BOOL MPVerifyMessage(id request, NSError **error);

// Verify the object is a valid msgpack rpc request
BOOL MPVerifyRequest(NSArray *request, NSError **error);

// Verify the object is a valid msgpack rpc response
BOOL MPVerifyResponse(NSArray *response, NSError **error);

// NSError from error dict
NSError *MPErrorFromErrorDict(NSString *domain, NSDictionary *dict);