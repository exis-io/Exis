//
//  MPMessagePackRPClient.h
//  MPMessagePack
//
//  Created by Gabriel on 12/12/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MPDefines.h"

typedef NS_ENUM (NSInteger, MPMessagePackClientStatus) {
  MPMessagePackClientStatusClosed = 1,
  MPMessagePackClientStatusOpening,
  MPMessagePackClientStatusOpen,
};

typedef NS_OPTIONS (NSInteger, MPMessagePackOptions) {
  MPMessagePackOptionsNone = 0,
  MPMessagePackOptionsFramed = 1 << 0,
};

@protocol MPMessagePackCoder
- (id)encodeObject:(id)obj;
@end

@class MPMessagePackClient;

typedef void (^MPErrorHandler)(NSError *error);
// Callback after we send request
typedef void (^MPRequestCompletion)(NSError *error, id result);
typedef void (^MPRequestHandler)(NSNumber *messageId, NSString *method, NSArray *params, MPRequestCompletion completion);


@protocol MPMessagePackClientDelegate <NSObject>
- (void)client:(MPMessagePackClient *)client didError:(NSError *)error fatal:(BOOL)fatal;
- (void)client:(MPMessagePackClient *)client didChangeStatus:(MPMessagePackClientStatus)status;
- (void)client:(MPMessagePackClient *)client didReceiveNotificationWithMethod:(NSString *)method params:(NSArray *)params;
@end

@interface MPMessagePackClient : NSObject <NSStreamDelegate, MPMessagePackCoder>

@property (weak) id<MPMessagePackClientDelegate> delegate;
@property (copy) MPRequestHandler requestHandler;
@property (readonly, nonatomic) MPMessagePackClientStatus status;
@property id<MPMessagePackCoder> coder;

- (instancetype)initWithName:(NSString *)name options:(MPMessagePackOptions)options;

- (void)openWithHost:(NSString *)host port:(UInt32)port completion:(MPCompletion)completion;

- (BOOL)openWithSocket:(NSString *)unixSocket completion:(MPCompletion)completion;

- (void)setInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;

- (void)close;

/*!
 Send RPC request.
 
 @param method Method name
 @param params Params Method params. If coder is set on client will encode params.
 @param messageId Unique message identifier
 @param completion Response
 */
- (NSArray *)sendRequestWithMethod:(NSString *)method params:(NSArray *)params messageId:(NSInteger)messageId completion:(MPRequestCompletion)completion;

/*!
 If you are using the requestHandler, use this method to send a response.

 @param result Result
 @param error Error
 @param messageId Message id (should match request message id)
 */
- (void)sendResponseWithResult:(id)result error:(id)error messageId:(NSInteger)messageId;

@end


