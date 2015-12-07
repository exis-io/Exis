//
//  MDWampClient.m
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

#include <stdlib.h>
#import <CommonCrypto/CommonCrypto.h>

#import "MDWamp.h"
#import "NSString+MDString.h"
#import "NSMutableArray+MDStack.h"
#import "MDWampTransports.h"
#import "MDWampSerializations.h"
#import "MDWampMessageFactory.h"

//#import <Riffle/Riffle-Swift.h>


@interface MDWamp () <MDWampTransportDelegate, NSURLConnectionDelegate>

@property (nonatomic, assign) BOOL explicitSessionClose;
@property (nonatomic, strong) id<MDWampTransport> transport;
@property (nonatomic, strong) id<MDWampSerialization> serializator;
@property (nonatomic, strong) NSString *realm;
@property (nonatomic, assign) BOOL sessionEstablished;
@property (nonatomic, assign) BOOL goodbyeSent;

@property (nonatomic, strong) NSMutableDictionary *subscriptionRequests;
@property (nonatomic, strong) NSMutableDictionary *subscriptionEvents;
@property (nonatomic, strong) NSMutableDictionary *subscriptionID;

@property (nonatomic, strong) NSMutableDictionary *publishRequests;

@property (nonatomic, strong) NSMutableDictionary *rpcCallbackMap;

@property (nonatomic, strong) NSMutableDictionary *rpcRegisterRequests;
@property (nonatomic, strong) NSMutableDictionary *rpcUnregisterRequests;
@property (nonatomic, strong) NSMutableDictionary *rpcRegisteredUri;
@property (nonatomic, strong) NSMutableDictionary *rpcRegisteredProcedures;

@property (nonatomic, strong) NSMutableDictionary *rpcPendingInvocation;

@property (nonatomic, strong) NSTimer *hbTimer;
@property (nonatomic, assign) int hbIncomingSeq;
@property (nonatomic, assign) int hbOutgoingSeq;

@end


@implementation MDWamp

- (id)initWithTransport:(id<MDWampTransport>)transport realm:(NSString *)realm delegate:(id<MDWampClientDelegate>)delegate {
    self = [super init];
    if (self) {
        
        self.explicitSessionClose = NO;
        self.sessionEstablished   = NO;
        self.goodbyeSent          = NO;
        
        self.realm      = realm;
        self.delegate   = delegate;
        self.transport  = transport;
        [self.transport setDelegate:self];
        
        self.subscriptionRequests   = [[NSMutableDictionary alloc] init];
        self.rpcCallbackMap         = [[NSMutableDictionary alloc] init];
        self.rpcRegisterRequests    = [[NSMutableDictionary alloc] init];
        self.rpcUnregisterRequests  = [[NSMutableDictionary alloc] init];
        self.rpcRegisteredProcedures= [[NSMutableDictionary alloc] init];
        self.rpcRegisteredUri       = [[NSMutableDictionary alloc] init];
        self.rpcPendingInvocation   = [[NSMutableDictionary alloc] init];
        self.subscriptionEvents     = [[NSMutableDictionary alloc] init];
        self.subscriptionID         = [[NSMutableDictionary alloc] init];
        self.publishRequests        = [[NSMutableDictionary alloc] init];
        
        self.config = [[MDWampClientConfig alloc] init];
        
    }
    return self;
}


#pragma mark Utils
- (NSNumber *) generateID {
    unsigned int r = arc4random_uniform(exp2(32)-1);
    return [NSNumber numberWithDouble:r];
    //    return [NSNumber numberWithInt:r];
}

- (void) cleanUp {
    [self.subscriptionRequests   removeAllObjects];
    [self.rpcCallbackMap         removeAllObjects];
    [self.rpcRegisterRequests    removeAllObjects];
    [self.rpcUnregisterRequests  removeAllObjects];
    [self.rpcRegisteredProcedures removeAllObjects];
    [self.rpcRegisteredUri       removeAllObjects];
    [self.subscriptionEvents     removeAllObjects];
    [self.subscriptionID         removeAllObjects];
    [self.publishRequests        removeAllObjects];
}


#pragma mark Connection
- (void) connect {
    [self.transport open];
}

- (void) disconnect {
    _explicitSessionClose = YES;
    
    if (self.hbTimer) {
        [self.hbTimer invalidate];
        self.hbTimer = nil;
        self.hbIncomingSeq = 0;
        self.hbOutgoingSeq = 0;
    }
    
    [self.transport close];
    
    if (self.onSessionClosed) {
        self.onSessionClosed(self, MDWampConnectionClosed, @"MDWamp.session.explicit_closed", nil);
    }
    
    if (self.onSessionClosed) {
        self.onSessionClosed(self, MDWampConnectionClosed, @"MDWamp.session.explicit_closed", nil);
    }
    
    if (_delegate) {
        if (_delegate && [_delegate respondsToSelector:@selector(mdwamp:closedSession:reason:details:)]) {
            [_delegate mdwamp:self closedSession:MDWampConnectionClosed reason:@"MDWamp.session.explicit_closed" details:nil];
        }
    }
}

- (BOOL) isConnected {
    return [self.transport isConnected];
}


#pragma mark MDWampTransport Delegate
- (void) transportDidOpenWithSerialization:(NSString*)serialization {
    MDWampDebugLog(@"websocket connection opened");
    
    _serialization = serialization;
    
    // Init the serializator
    Class ser = NSClassFromString(self.serialization);
    NSAssert(ser != nil, @"Serialization %@ doesn't exists", ser);
    self.serializator = [[ser alloc] init];
    
    NSMutableDictionary *helloDetails = [NSMutableDictionary dictionaryWithDictionary:[self.config getHelloDetails]];
    
    if (self.token != nil) {
        [helloDetails setObject:@[@"token"] forKey:@"authmethods"];
    }
    
    // send hello message
    MDWampHello* hello = [[MDWampHello alloc] initWithPayload:@[ self.realm, helloDetails ]];
    hello.realm = self.realm;
    [self sendMessage:hello];
    
}

- (void) transportDidReceiveMessage:(NSData *)message {
    NSMutableArray *unpacked = [[self.serializator unpack:message] mutableCopy];
    NSNumber *code = [unpacked shift];
    
    if (!unpacked || [unpacked count] < 1) {
#ifdef DEBUG
        [NSException raise:@"it.mogui.mdwamp" format:@"Wrong message recived"];
#else
        MDWampDebugLog(@"Invalid message code received !!");
#endif
    }
    id<MDWampMessage> msg;
    @try {
        msg = [[MDWampMessageFactory sharedFactory] objectFromCode:code withPayload:unpacked];
    }
    @catch (NSException *exception) {
#ifdef DEBUG
        [exception raise];
#else
        MDWampDebugLog(@"Invalid message code received !!");
#endif
    }
    
    [self receivedMessage:msg];
}

- (void) transportDidFailWithError:(NSError *)error {
    MDWampDebugLog(@"DID FAIL reason %@", error.localizedDescription);
    if (self.onSessionClosed) {
        self.onSessionClosed(self, error.code, error.localizedDescription, error.userInfo);
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(mdwamp:closedSession:reason:details:)]) {
        [_delegate mdwamp:self closedSession:error.code reason:error.localizedDescription details:error.userInfo];
    }
}

- (void) transportDidCloseWithError:(NSError *)error {
    MDWampDebugLog(@"DID CLOSE reason %@", error.localizedDescription);
    _sessionId = nil;
    [self cleanUp];
    
    if (!_explicitSessionClose) {
        if (self.onSessionClosed) {
            self.onSessionClosed(self, error.code, error.localizedDescription, error.userInfo);
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(mdwamp:closedSession:reason:details:)]) {
            [_delegate mdwamp:self closedSession:error.code reason:error.localizedDescription details:error.userInfo];
        }
        
    }
    self.sessionEstablished = NO;
    
}


#pragma mark Message Management
- (void) receivedMessage:(id<MDWampMessage>)message {
    
    if ([message isKindOfClass:[MDWampWelcome class]]) {
        
        MDWampWelcome *welcome = (MDWampWelcome *)message;
        _sessionId = [welcome.session stringValue];
        
        NSDictionary *details = welcome.details;
        // TODO: maybe do something with details? save some auth related stuff??
        self.sessionEstablished = YES;
        
        if (_delegate && [_delegate respondsToSelector:@selector(mdwamp:sessionEstablished:)]) {
            [_delegate mdwamp:self sessionEstablished:details];
        }
        
        if (self.onSessionEstablished) {
            self.onSessionEstablished(self, details);
        }
        
    } else if ([message isKindOfClass:[MDWampAbort class]]) {
#pragma mark MDWampAbort
        MDWampAbort *abort = (MDWampAbort *)message;
        _explicitSessionClose = YES;
        [self.transport close];
        
        if (_delegate && [_delegate respondsToSelector:@selector(mdwamp:closedSession:reason:details:)]) {
            [_delegate mdwamp:self closedSession:MDWampConnectionAborted reason:abort.reason details:abort.details];
        }
        
        if (self.onSessionClosed) {
            self.onSessionClosed(self, MDWampConnectionAborted, abort.reason, abort.details);
        }
        
    } else if ([message isKindOfClass:[MDWampGoodbye class]]) {
        
        // Received Goodbye message
        MDWampGoodbye *goodbye = (MDWampGoodbye *)message;
        
        // if we initiated the disconnection we don't send the goddbye back
        if (!self.goodbyeSent) {
            MDWampGoodbye *goodbyeResponse = [[MDWampGoodbye alloc] initWithPayload:@[@{}, @"wamp.error.goodbye_and_out"]];
            [self sendMessage:goodbyeResponse];
        }
        
        // close either way
        [self.transport close];
        
        if (_delegate && [_delegate respondsToSelector:@selector(mdwamp:closedSession:reason:details:)]) {
            [_delegate mdwamp:self closedSession:MDWampConnectionClosed reason:goodbye.reason details:goodbye.details];
        }
        
        if (self.onSessionClosed) {
            self.onSessionClosed(self, MDWampConnectionClosed, goodbye.reason, goodbye.details);
        }
        
    } else if ([message isKindOfClass:[MDWampError class]]) {
#pragma mark MDWampError
        // Manage different errors based on the type code
        // that relates to message classes
        
        MDWampError *error = (MDWampError *)message;
        
        NSString *errorType = [[MDWampMessageFactory sharedFactory] nameFromCode:error.type];
        if ([errorType isEqual:kMDWampSubscribe]) {
            // It's a subscribe error
            NSArray *callbacks = self.subscriptionRequests[error.request];
            
            if (!callbacks) {
                return;
            }
            
            void(^resultCallback)(NSError *)  = callbacks[0];
            
            resultCallback([error makeError]);
            
            // clean subscriber structures
            [self.subscriptionRequests removeObjectForKey:error.request];
            
        } else if ([errorType isEqual:kMDWampUnsubscribe]) {
            NSArray *callbacks = self.subscriptionRequests[error.request];
            
            if (!callbacks) {
                return;
            }
            
            void(^resultCallback)(NSError *)  = callbacks[0];
            resultCallback([error makeError]);
            
            // cleanup
            [self.subscriptionRequests removeObjectForKey:error.request];
            
        } else if ([errorType isEqual:kMDWampPublish ]) {
            
            void(^resultCallback)(NSError *) = [self.publishRequests objectForKey:error.request];
            
            if (resultCallback) {
                resultCallback([error makeError]);
            }
            
            // cleanup
            [self.publishRequests removeObjectForKey:error.request];
            
        } else if ([errorType isEqual:kMDWampCall]) {
            
            void(^resultcallback)(MDWampResult *, NSError *) = self.rpcCallbackMap[error.request];
            if (resultcallback) {
                resultcallback(nil, [error makeError]);
            }
            
            [self.rpcCallbackMap removeObjectForKey:error.request];
            
        } else if ([errorType isEqual:kMDWampRegister]) {
            NSArray *registrationRequest = [self.rpcRegisterRequests objectForKey:error.request];
            if (!registrationRequest) {
                MDWampDebugLog(@"registration not present ignore");
                return;
            }
            
            // remove payload of the request
            [self.rpcRegisterRequests removeObjectForKey:error.request];
            
            void(^resultCallback)(NSError *) = registrationRequest[0];
            resultCallback([error makeError]);
            
        } else if ([errorType isEqual:kMDWampUnregister]) {
            NSArray *unregistrationRequest = [self.rpcUnregisterRequests objectForKey:error.request];
            if (!unregistrationRequest) {
                MDWampDebugLog(@"request not present ignoring");
                return;
            }
            
            // remove unregister request
            [self.rpcUnregisterRequests removeObjectForKey:error.request];
            
            void(^resultCallback)(NSError *) = unregistrationRequest[1];
            if (resultCallback) {
                resultCallback([error makeError]);
            }
        }
        
    } else if ([message isKindOfClass:[MDWampSubscribed class]]) {
        
        MDWampSubscribed *subscribed = (MDWampSubscribed *)message;
        NSArray *callbacks = self.subscriptionRequests[subscribed.request];
        
        // retrieve list of subscribers
        NSMutableArray *subscribers = [self.subscriptionEvents objectForKey:subscribed.subscription];
        if (subscribers == nil) {
            subscribers = [[NSMutableArray alloc] init];
            [self.subscriptionEvents setObject:subscribers forKey:subscribed.subscription];
        }
        [subscribers addObject:callbacks[1]];
        
        // add mapping of topic subscribedID
        [self.subscriptionID setObject:subscribed.subscription forKey:callbacks[2]];
        
        // clean subscriptionRequest map once called the callback
        [self.subscriptionRequests removeObjectForKey:subscribed.request];
        
        void(^resultCallback)(NSError *)  = callbacks[0];
        resultCallback(nil);
        
        
    } else if ([message isKindOfClass:[MDWampUnsubscribed class]]) {
        MDWampUnsubscribed *unsub = (MDWampUnsubscribed *)message;
        NSArray *infos = self.subscriptionRequests[unsub.request];
        
        NSNumber *subscription = self.subscriptionID[infos[1]];
        [self.subscriptionEvents removeObjectForKey:subscription];
        [self.subscriptionID removeObjectForKey:infos[1]];
        
        [self.subscriptionRequests removeObjectForKey:unsub.request];
        
        void(^resultCallback)(NSError *) = infos[0];
        resultCallback(nil);
        
    } else if ([message isKindOfClass:[MDWampPublished class]]) {
        MDWampPublished *pub = (MDWampPublished *)message;
        
        void(^resultCallback)(NSError *) = [self.publishRequests objectForKey:pub.request];
        if (resultCallback) {
            resultCallback(nil);
            
            [self.publishRequests removeObjectForKey:pub.request];
        }
    } else if ([message isKindOfClass:[MDWampEvent class]]) {
        MDWampEvent *event = (MDWampEvent *)message;
        NSArray *events = [self.subscriptionEvents objectForKey:event.subscription];
        
        for (void(^eventCallback)(MDWampEvent *) in events) {
            if (eventCallback) {
                eventCallback(event);
            }
        }
        
        
    } else if ([message isKindOfClass:[MDWampResult class]]) {
        MDWampResult *result = (MDWampResult *)message;
        
        void(^resultcallback)(MDWampResult *, NSError *) = self.rpcCallbackMap[result.request];
        
        if (resultcallback) {
            resultcallback(result, nil);
        }
        
        if (!result.progress) {
            // remove callback only if it is not a progress
            [self.rpcCallbackMap removeObjectForKey:result.request];
        }
        
    } else if ([message isKindOfClass:[MDWampRegistered class]]) {
#pragma mark MDWampRegistered
        
        MDWampRegistered *registered = (MDWampRegistered *)message;
        
        NSArray *registrationRequest = self.rpcRegisterRequests[registered.request];
        if (!registrationRequest) {
            MDWampDebugLog(@"request is not present, ignoring it");
            return;
        }
        
        NSArray *procedures = nil;
        // store the procedure and cancel handler
        if ([registrationRequest count] == 4) {
            // we have the cancelation handler
            procedures = @[registrationRequest[2], registrationRequest[3]];
        } else {
            procedures = @[registrationRequest[2]];
        }
        
        [self.rpcRegisteredProcedures setObject:procedures forKey:registered.registration];
        
        // map uri to registrationID
        [self.rpcRegisteredUri setObject:registered.registration forKey:registrationRequest[1]];
        
        void(^resultcallback)(NSError *) = registrationRequest[0];
        
        // cleanup, remove the request
        [self.rpcRegisterRequests removeObjectForKey:registered.request];
        
        if (resultcallback) {
            // call the resutl callback
            resultcallback(nil);
        }
        
    } else if ([message isKindOfClass:[MDWampUnregistered class]]) {
        MDWampUnregistered *unregistered    = (MDWampUnregistered *)message;
        NSArray *unregistrationRequest      = self.rpcUnregisterRequests[unregistered.request];
        void(^resultcallback)(NSError *)    = unregistrationRequest[1];
        NSNumber *registrationID            = unregistrationRequest[0];
        
        if (resultcallback) {
            resultcallback(nil);
        }
        
        // remove registered procedure
        [self.rpcRegisteredProcedures removeObjectForKey:registrationID];
        
        // remove uri mapping
        [self.rpcRegisteredUri enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isEqual:registrationID]) {
                [self.rpcRegisteredUri removeObjectForKey:key];
                *stop = YES;
            }
        }];
        
        // cleanup request
        [self.rpcUnregisterRequests removeObjectForKey:unregistered.request];
        
    } else if ([message isKindOfClass:[MDWampInvocation class]]) {
#pragma mark MDWampInvocation
        MDWampInvocation *invocation = (MDWampInvocation *)message;
        
        if (invocation.arguments == nil)
            invocation.arguments = [NSArray array];
        
        // Store association between this invocation.request to the generic registration
        [self.rpcPendingInvocation setObject:invocation.registration forKey:invocation.request];
        
        NSArray *procedures = [self.rpcRegisteredProcedures objectForKey:invocation.registration];
        
        void(^procedure)(MDWamp *client, MDWampInvocation* invocation) = procedures[0];
        
        // exec procedure
        procedure(self, invocation);
        
        /**
         * ADvanced Protocol
         */
    } else if ([message isKindOfClass:[MDWampInterrupt class]]) {
        MDWampInterrupt *interrupt = (MDWampInterrupt *)message;
        NSNumber *registration = [self.rpcPendingInvocation objectForKey:interrupt.request];
        NSArray *procedures = [self.rpcRegisteredProcedures objectForKey:registration];
        
        if ([procedures count]==2) {
            // we've got a cancel handler
            void(^cancelHandler)(void) = procedures[1];
            
            // execute the cancel Handler
            cancelHandler();
        }
        
        // removing pending invocation
        [self.rpcPendingInvocation removeObjectForKey:interrupt.request];
        
        // send an error
        NSNumber *invocationCode = [[MDWampMessageFactory sharedFactory] codeFromClassName:kMDWampInvocation];
        MDWampError *error = [[MDWampError alloc] initWithPayload:@[invocationCode, interrupt.request, @{}, @"mdwamp.error.invocation_interrupted"]];
        [self sendMessage:error];
        
#pragma mark MDWampChallenge
    } else if ([message isKindOfClass:[MDWampChallenge class]]) {
        MDWampChallenge *challenge = (MDWampChallenge *)message;
        
        // Token based authentication
        if ([challenge.authMethod isEqualToString:@"token"] &&  self.token) {
            //NSLog(@"Recieved challenge for token based authentication ");
            
            MDWampAuthenticate *auth = [[MDWampAuthenticate alloc] initWithPayload:@[self.token, @{}]];
            [self sendMessage:auth];
            
        } else if ([challenge.authMethod isEqualToString:kMDWampAuthMethodCRA] &&  self.config && self.config.sharedSecret) {
            
            // deferred challenge signing
            if (self.config && self.config.deferredWampCRASigningBlock) {
                
                self.config.deferredWampCRASigningBlock(challenge.extra[@"challenge"], ^(NSString *signature) {
                    // Sending auth message
                    MDWampAuthenticate *auth = [[MDWampAuthenticate alloc] initWithPayload:@[signature, @{}]];
                    [self sendMessage:auth];
                    
                });
                
            } else {
                // calculate the signature
                NSData *key = nil;
                
                // if we have salt, keylen, iterations
                // we calculate the  PBKDF2
                if (challenge.extra[@"salt"] && challenge.extra[@"keylen"] && challenge.extra[@"iterations"]) {
                    NSMutableData *hash = [NSMutableData dataWithLength:[challenge.extra[@"keylen"] integerValue] ];
                    NSData *pass = [self.config.sharedSecret dataUsingEncoding:NSUTF8StringEncoding];
                    NSData *salt = [challenge.extra[@"salt"] dataUsingEncoding:NSUTF8StringEncoding];
                    CCKeyDerivationPBKDF(kCCPBKDF2, pass.bytes, pass.length, salt.bytes, salt.length, kCCPRFHmacAlgSHA256, [challenge.extra[@"iterations"] intValue], hash.mutableBytes, [challenge.extra[@"keylen"] integerValue]);
                    key = hash;
                } else {
                    key = [self.config.sharedSecret dataUsingEncoding:NSUTF8StringEncoding];
                    
                }
                
                NSData *data = [challenge.extra[@"challenge"] dataUsingEncoding:NSUTF8StringEncoding];
                NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH ];
                CCHmac(kCCHmacAlgSHA256, key.bytes, key.length, data.bytes, data.length, hash.mutableBytes);
                NSString *signature = [hash base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                
                // Sending auth message
                MDWampAuthenticate *auth = [[MDWampAuthenticate alloc] initWithPayload:@[signature, @{}]];
                [self sendMessage:auth];
            }
            
            // Ticket Based Auth
        } else if ([challenge.authMethod isEqualToString:kMDWampAuthMethodTicket] &&  self.config && self.config.ticket) {
            MDWampAuthenticate *auth = [[MDWampAuthenticate alloc] initWithPayload:@[self.config.ticket, @{}]];
            [self sendMessage:auth];
        }
    }
}

- (void) sendMessage:(id<MDWampMessage>)message {
    MDWampDebugLog(@"Sending %@", message);
    if ([message isKindOfClass:[MDWampGoodbye class]]) {
        
        self.goodbyeSent = YES;
    }
    NSArray *marshalled = [message marshall];
    id packed = [self.serializator pack:marshalled];
    [self.transport send:packed];
}


#pragma mark Pub/Sub
- (void) subscribe:(NSString *)topic onEvent:(void(^)(MDWampEvent *payload))eventBlock result:(void(^)(NSError *error))result {
    NSNumber *request = [self generateID];
    MDWampSubscribe *subscribe = [[MDWampSubscribe alloc] initWithPayload:@[request, @{}, topic]];
    
    // we have to wait Subscribed message before add event
    [self.subscriptionRequests setObject:@[result, eventBlock, topic] forKey:request];
    
    [self sendMessage:subscribe];
}

- (void) unsubscribe:(NSString *)topic result:(void(^)(NSError *error))result {
    if (!self.subscriptionID[topic]) {
        // inexistent sunscription we abort
        MDWampError *error = [[MDWampError alloc] initWithPayload:@[@-12, @0, @{}, @"mdwamp.error.no_such_subscription"]];
        result([error makeError]);
        return;
    }
    
    NSNumber *request = [self generateID];
    NSNumber *subscription = self.subscriptionID[topic];
    NSArray *payload = @[request, subscription];
    // storing callback for unsubscription result
    [self.subscriptionRequests setObject:@[result, topic] forKey:request];
    MDWampUnsubscribe *unsubscribe = [[MDWampUnsubscribe alloc] initWithPayload:payload];
    [self sendMessage:unsubscribe];
}

- (void) publishTo:(NSString *)topic args:(NSArray*)args kw:(NSDictionary *)argsKw options:(NSDictionary *)options result:(void(^)(NSError *error))result {
    NSNumber *request = [self generateID];
    
    NSMutableDictionary *opts = nil;
    if (options == nil) {
        opts = [[NSMutableDictionary alloc] init];
    } else {
        opts = [options mutableCopy];
    }
    
    // Use defaults advanced features if not expressed in options
    if(opts[MDWampOption_acknowledge] == nil && self.config.publisher_acknowledge){
        opts[MDWampOption_acknowledge] = @YES;
    }
    
    if(opts[MDWampOption_exclude_me] == nil && !self.config.publisher_exclude_me){
        opts[MDWampOption_exclude_me] = @NO;
    }
    
    if(opts[MDWampOption_disclose_me] == nil && self.config.publisher_identification){
        opts[MDWampOption_disclose_me] = @YES;
    }
    
    MDWampPublish *msg = [[MDWampPublish alloc] initWithPayload:@[request, opts, topic]];
    if (args)
        msg.arguments = args;
    
    if (argsKw)
        msg.argumentsKw = argsKw;
    
    if (opts[MDWampOption_acknowledge]) {
        // store callback to later use if acknowledge is TRUE
        [self.publishRequests setObject:result forKey:request];
    }
    
    [self sendMessage:msg];
}

- (void) publishTo:(NSString *)topic exclude:(NSArray*)exclude eligible:(NSArray*)eligible payload:(id)payload result:(void(^)(NSError *error))result {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    
    if (exclude)
        options[MDWampOption_exclude] = exclude;
    if (eligible)
        options[MDWampOption_eligible] = eligible;
    
    if ([payload isKindOfClass:[NSDictionary class]]) {
        [self publishTo:topic args:nil kw:payload options:options result:result];
    } else if ([payload isKindOfClass:[NSArray class]]) {
        [self publishTo:topic args:payload kw:nil options:options result:result];
    } else {
        [self publishTo:topic args:@[payload] kw:nil options:options result:result];
    }
}

- (void) publishTo:(NSString *)topic payload:(id)payload result:(void(^)(NSError *error))result {
    [self publishTo:topic exclude:nil eligible:nil payload:payload result:result];
}


#pragma mark Remote Procedure Call
- (NSNumber *) call:(NSString*)procUri args:(NSArray*)args kwArgs:(NSDictionary*)argsKw options:(NSDictionary*)options complete:(void(^)(MDWampResult *result, NSError *error))completeBlock {
    NSNumber *request = [self generateID];
    NSMutableDictionary *opts = nil;
    
    if (options == nil) {
        opts = [[NSMutableDictionary alloc] init];
    } else {
        opts = [options mutableCopy];
    }
    
    if(opts[MDWampOption_exclude_me] == nil && !self.config.caller_exclude_me){
        opts[MDWampOption_exclude_me] = @NO;
    }
    
    if(opts[MDWampOption_disclose_me] == nil && self.config.caller_identification){
        opts[MDWampOption_disclose_me] = @YES;
    }
    
    if(opts[MDWampOption_receive_progress] == nil && self.config.caller_progressive_result){
        opts[MDWampOption_receive_progress] = @YES;
    }
    
    MDWampCall *msg = [[MDWampCall alloc] initWithPayload:@[request, opts, procUri]];
    if (args)
        msg.arguments = args;
    
    if (argsKw)
        msg.argumentsKw = argsKw;
    
    [self.rpcCallbackMap setObject:completeBlock forKey:msg.request];
    
    [self sendMessage:msg];
    
    return request;
}

- (NSNumber *) call:(NSString*)procUri payload:(id)payload exclude:(NSArray*)exclude eligible:(NSArray*)eligible complete:(void(^)(MDWampResult *result, NSError *error))completeBlock {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    
    if (exclude)
        options[MDWampOption_exclude] = exclude;
    if (eligible)
        options[MDWampOption_eligible] = eligible;
    
    if ([payload isKindOfClass:[NSDictionary class]]) {
        return [self call:procUri args:nil kwArgs:payload options:options complete:completeBlock];
    } else if ([payload isKindOfClass:[NSArray class]]) {
        return [self call:procUri args:payload kwArgs:nil options:options complete:completeBlock];
    } else {
        return [self call:procUri args:@[payload] kwArgs:nil options:options complete:completeBlock];
    }
}

- (NSNumber *) call:(NSString*)procUri payload:(id)payload complete:(void(^)(MDWampResult *result, NSError *error))completeBlock {
    return [self call:procUri payload:payload exclude:nil eligible:nil complete:completeBlock];
}

- (void) cancelCallProcedure:(NSNumber*)requestID {
    MDWampCancel *msg = [[MDWampCancel alloc] initWithPayload:@[requestID,@{}]];
    [self sendMessage:msg];
}

- (void) registerRPC:(NSString *)procUri procedure:(void(^)(MDWamp *client, MDWampInvocation* invocation))procedureBlock cancelHandler:(void(^)(void))cancelBlock registerResult:(void(^)(NSError *error))resultCallback {
    NSNumber *request = [self generateID];
    
    MDWampRegister *msg = [[MDWampRegister alloc] initWithPayload:@[request, @{}, procUri]];
    
    // TODO resultCallback now cannot be nil
    
    // cancel Block could be nil
    if (cancelBlock) {
        [self.rpcRegisterRequests setObject:@[resultCallback, procUri, procedureBlock, cancelBlock] forKey:request];
    } else {
        [self.rpcRegisterRequests setObject:@[resultCallback, procUri, procedureBlock] forKey:request];
    }
    
    [self sendMessage:msg];
}

- (void)resultForInvocation:(MDWampInvocation*)invocation arguments:(NSArray*)arguments argumentsKw:(NSDictionary*)argumentsKw {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    
    // Handle progressive results
    if (invocation.options && invocation.options[MDWampOption_receive_progress]) {
        options[MDWampOption_progress] = @YES;
    }
    
    // creating the yield message
    MDWampYield *yield = [[MDWampYield alloc] initWithPayload:@[invocation.request, options]];
    
    if(arguments)
        yield.arguments = arguments;
    
    if (argumentsKw)
        yield.argumentsKw = argumentsKw;
    
    [self sendMessage:yield];
    [self.rpcPendingInvocation removeObjectForKey:invocation.request];
}

- (void) unregisterRPC:(NSString *)procUri result:(void(^)(NSError *error))resultCallback {
    NSNumber *request = [self generateID];
    NSNumber *registrationID = [self.rpcRegisteredUri objectForKey:procUri];
    if (registrationID == nil) {
        resultCallback([NSError errorWithDomain:kMDWampErrorDomain code:12 userInfo:@{NSLocalizedDescriptionKey: @"wamp.error.no_such_registration"}]);
        return;
    }
    MDWampUnregister *msg = [[MDWampUnregister alloc] initWithPayload:@[request, registrationID]];
    [self.rpcUnregisterRequests setObject:@[registrationID, resultCallback] forKey:request];
    [self sendMessage:msg];
}

@end
