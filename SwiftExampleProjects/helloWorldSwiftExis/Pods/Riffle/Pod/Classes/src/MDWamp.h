//
//  MDWampClient.h
//  MDWamp
//
//  Created by Niko Usai on 13/12/13.
//  Copyright (c) 2013 mogui.it. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MDWampConstants.h"
#import "MDWampTransports.h"
#import "MDWampClientDelegate.h"
#import "MDWampMessages.h"
#import "MDWampClientConfig.h"

/**
 *  Wamp - Roles
 */

typedef NS_ENUM(NSInteger, MDWampConnectionCloseCode) {
    MDWampConnectionAborted,
    MDWampConnectionClosed
};

/**
 *  Main client class
 */
@interface MDWamp : NSObject

/**
 * The server generated sessionId, readonly
 */
@property (nonatomic, copy, readonly) NSString *sessionId;

/**
 * Serialization choosed by the transport, readonly
 */
@property (nonatomic, readonly) NSString *serialization;

@property (strong, nonatomic) NSString *token;

/**
 * The delegate must implement the MDWampClientDelegate
 * it is not retained
 */
@property (nonatomic, unsafe_unretained) id<MDWampClientDelegate> delegate;

/**
 * If implemented gets called when client connects
 */
@property (nonatomic, copy) void (^onSessionEstablished)(MDWamp *client, NSDictionary *info);

/**
 * If implemented gets called when client close the connection, or fails to connect
 */
@property (nonatomic, copy) void (^onSessionClosed)(MDWamp *client, NSInteger code, NSString *reason, NSDictionary *details);

/**
 *  Client configuration object, it's optional, you may use it to adjust some advanced protocol configurations
 */
@property (nonatomic, strong) MDWampClientConfig *config;

#pragma mark -
#pragma mark Init methods
/**
 *  Returns a new istance with connection configured with given server
 *  it does not automatically connect to the ws server
 *
 *  @param aServer  an url request with full protocol
 *  @param realm    a WAMP routing and administrative domain
 *  @param delegate The connection delegate for this instance
 *
 *  @return client instance
 */
- (id)initWithTransport:(id<MDWampTransport>)transport realm:(NSString *)realm delegate:(id<MDWampClientDelegate>)delegate;


#pragma mark -
#pragma mark Connection

/**
 * Start the connection with the server
 */
- (void) connect;

/**
 * Disconnect from the server
 */
- (void) disconnect;

/**
 * Returns whether or not we are connected to the server
 * @return BOOL yes if connected
 */
- (BOOL) isConnected;

#pragma mark -
#pragma mark Commands

#pragma mark -
#pragma mark Pub/Sub

/**
 * Subscribe for a given topic
 *
 *  @param topic      the URI of the topic to which subscribe
 *  @param onError    result of subscription (called only from version 2)
 *  @param eventBlock The Block invoked when an event on the topic is received
 */
- (void) subscribe:(NSString *)topic
           onEvent:(void(^)(MDWampEvent *payload))eventBlock
            result:(void(^)(NSError *error))result;


/**
 * Unsubscribe for a given topic
 *
 * @param topicUri		the URI of the topic to which unsubscribe
 * @param result    result of subscription (called only from version 2)
 */
- (void)unsubscribe:(NSString *)topic
             result:(void(^)(NSError *error))result;


/**
 *  Complete Publish
 *
 *  @param topic   is the topic published to.
 *  @param args    is a list of application-level event payload elements.
 *  @param argsKw  is a an optional dictionary containing application-level event payload
 *  @param options is a dictionary that allows to provide additional publication request details in an extensible way
 *  @param result    block to execute on completion
 */
- (void) publishTo:(NSString *)topic
              args:(NSArray*)args
                kw:(NSDictionary *)argsKw
           options:(NSDictionary *)options
            result:(void(^)(NSError *error))result;

/**
 * Shortand for publishing a generic payload
 * Could be Dictionary, array, or object
 * you can specify advanced feature to exclude or elige specific peers
 *
 *  @param topic     the topic
 *  @param exclude   array of session id to exclude
 *  @param eligible  Array of session id to elige
 *  @param payload   teh payload (array, dictionary or object)
 *  @param result    block to execute on completion
 */

- (void) publishTo:(NSString *)topic
           exclude:(NSArray*)exclude
          eligible:(NSArray*)eligible
           payload:(id)payload
            result:(void(^)(NSError *error))result;

/**
 * Shortand for publishing a generic payload
 * Could be Dictionary, array, or object
 *
 *  @param topic   is the topic published to.
 *  @param payload is a generic payload
 *  @param result    block to execute on completion
 */
- (void) publishTo:(NSString *)topic
           payload:(id)payload
            result:(void(^)(NSError *error))result;


#pragma mark -
#pragma mark RPC
/**
 * Call a Remote Procedure on the server
 *
 *
 * @param procUri		the URI of the remote procedure to be called
 * @param args			arguments array to the procedure
 * @param kwArgs		keyword arguments array to the procedure
 * @param options		options dictionary
 * @param completeBlock block to be executed on complete if success error is nil, if failure result is nil
 * @return NSNUmber     the requestID of the call (usable for a cancel request)
 */
- (NSNumber *) call:(NSString*)procUri
               args:(NSArray*)args
             kwArgs:(NSDictionary*)argsKw
            options:(NSDictionary*)options
           complete:(void(^)(MDWampResult *result, NSError *error))completeBlock;

/**
 *  Call a remote procedure with an arbitrary payload, you can specify an array of session id to exclude or include
 *
 *  @param procUri       the URI of the remote procedure to be called
 *  @param payload       array, dictioanry or object
 *  @param exclude       array of session to exclude
 *  @param eligible      array of sesison to include
 *  @param completeBlock block to be executed on complete if success error is nil, if failure result is nil
 * @return NSNUmber     the requestID of the call (usable for a cancel request)
 */
- (NSNumber *) call:(NSString*)procUri
            payload:(id)payload
            exclude:(NSArray*)exclude
           eligible:(NSArray*)eligible
           complete:(void(^)(MDWampResult *result, NSError *error))completeBlock;

/**
 *  Call a remote procedure with an arbitrary payload
 *
 *  @param procUri       the URI of the remote procedure to be called
 *  @param payload       array, dictioanry or object
 *  @param completeBlock block to be executed on complete if success error is nil, if failure result is nil
 * @return NSNUmber     the requestID of the call (usable for a cancel request)
 */
- (NSNumber *) call:(NSString*)procUri
            payload:(id)payload
           complete:(void(^)(MDWampResult *result, NSError *error))completeBlock;

/**
 *  Cancel the given request call
 *
 *  @param requestID call requestID
 */
- (void) cancelCallProcedure:(NSNumber*)requestID;

/**
 * Register in the router a procedure defined by the procedure block
 *
 * @param procUri		the URI of the remote procedure to be registered
 * @param procedureBlock the block that is called when the procedure is invoked from the router
 * @param resultCallback a callback to give a result of the registration process OK if error is nil
 */


/**
 * Resgister in the router a procedure defined by the procedure block
 * th eprocedure block is called Syncronous but you can do asyncronous stuff and to get the result back to wamp client by calling:
 *      - (void)resultForInvocation:(MDWampInvocation*)invocation arguments:(NSArray*)arguments argumentsKw:(NSDictionary*)argumentsKw;
 * on MDwamp object inside the procedure block
 *
 *  @param procUri        the URI of the procedure UNique identifier
 *  @param procedureBlock procedure Block
 *  @param cancelBlock    a block used to stop the procedure, called when client gets an INTERRUPT msg (advanced profile)
 *  @param resultCallback callback to comunicate the result of the registration process ok if error is null
 */
- (void) registerRPC:(NSString *)procUri
           procedure:(void(^)(MDWamp *client, MDWampInvocation* invocation))procedureBlock
       cancelHandler:(void(^)(void))cancelBlock
      registerResult:(void(^)(NSError *error))resultCallback;

/**
 *  Gives back a result from inside a registered procedure block
 *
 *  @param invocation  invocation to wich give result
 *  @param arguments   result array
 *  @param argumentsKw result dictioanry
 */
- (void)resultForInvocation:(MDWampInvocation*)invocation arguments:(NSArray*)arguments argumentsKw:(NSDictionary*)argumentsKw;

/**
 * Unregister a registered procedure
 *
 * @param procUri		the URI of the remote procedure to be registered
 * @param resultCallback a callback to give a result of the registration process OK if error is nil
 */
- (void) unregisterRPC:(NSString *)procUri
                result:(void(^)(NSError *error))result;

@end
