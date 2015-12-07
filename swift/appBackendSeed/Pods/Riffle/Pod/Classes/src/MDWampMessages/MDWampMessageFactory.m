//
//  MDWampMessageFactory.m
//  MDWamp
//
//  Created by Niko Usai on 01/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
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

#import "MDWampMessageFactory.h"
#import "MDWampMessage.h"

NSString *const kMDWampHello        = @"MDWampHello";
NSString *const kMDWampWelcome      = @"MDWampWelcome";
NSString *const kMDWampAbort        = @"MDWampAbort";
NSString *const kMDWampChallenge    = @"MDWampChallenge";
NSString *const kMDWampAuthenticate = @"MDWampAuthenticate";
NSString *const kMDWampGoodbye      = @"MDWampGoodbye";
NSString *const kMDWampError        = @"MDWampError";
NSString *const kMDWampPublish      = @"MDWampPublish";
NSString *const kMDWampPublished    = @"MDWampPublished";
NSString *const kMDWampSubscribe    = @"MDWampSubscribe";
NSString *const kMDWampSubscribed   = @"MDWampSubscribed";
NSString *const kMDWampUnsubscribe  = @"MDWampUnsubscribe";
NSString *const kMDWampUnsubscribed = @"MDWampUnsubscribed";
NSString *const kMDWampEvent        = @"MDWampEvent";
NSString *const kMDWampCall         = @"MDWampCall";
NSString *const kMDWampCancel       = @"MDWampCancel";
NSString *const kMDWampResult       = @"MDWampResult";
NSString *const kMDWampRegister     = @"MDWampRegister";
NSString *const kMDWampRegistered   = @"MDWampRegistered";
NSString *const kMDWampUnregister   = @"MDWampUnregister";
NSString *const kMDWampUnregistered = @"MDWampUnregistered";
NSString *const kMDWampInvocation   = @"MDWampInvocation";
NSString *const kMDWampInterrupt    = @"MDWampInterrupt";
NSString *const kMDWampYield        = @"MDWampYield";

@interface MDWampMessageFactory ()
    @property (nonatomic, strong) NSDictionary *messageMapping;
@end

@implementation MDWampMessageFactory

+ (instancetype) sharedFactory {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MDWampMessageFactory alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.messageMapping = @{
                                @1  : kMDWampHello,
                                @2  : kMDWampWelcome,
                                @3  : kMDWampAbort,
                                @4  : kMDWampChallenge,
                                @5  : kMDWampAuthenticate,
                                @6  : kMDWampGoodbye,
                                @8  : kMDWampError,
                                @16 : kMDWampPublish,
                                @17 : kMDWampPublished,
                                @32 : kMDWampSubscribe,
                                @33 : kMDWampSubscribed,
                                @34 : kMDWampUnsubscribe,
                                @35 : kMDWampUnsubscribed,
                                @36 : kMDWampEvent,
                                @48 : kMDWampCall,
                                @49 : kMDWampCancel,
                                @50 : kMDWampResult,
                                @64 : kMDWampRegister,
                                @65 : kMDWampRegistered,
                                @66 : kMDWampUnregister,
                                @67 : kMDWampUnregistered,
                                @68 : kMDWampInvocation,
                                @69 : kMDWampInterrupt,
                                @70 : kMDWampYield };
    }
    return self;
}

- (NSString *)nameFromCode:(NSNumber*)code
{
    return self.messageMapping[code];
}

- (id<MDWampMessage>)objectFromCode:(NSNumber*)code withPayload:(NSArray*)payload
{
    NSString *className = self.messageMapping[code];
    if (!className) {
        [NSException raise:kMDWampErrorDomain format:@"No registered Message for given code: %@", code];
    }
    Class messageClass = NSClassFromString(className);
    if (!messageClass) {
        [NSException raise:kMDWampErrorDomain format:@"Class %@ is not implemented", className];
    }
    return [(id<MDWampMessage>)[messageClass alloc] initWithPayload:payload];
}

- (NSNumber *)codeFromObject:(id)object
{
    NSString *className = NSStringFromClass([object class]);

    return [self codeFromClassName:className];
}

- (NSNumber *)codeFromClassName:(NSString*)className
{
    NSArray *keys = [self.messageMapping allKeysForObject:className];
    if ([keys count] != 1) {
        [NSException raise:kMDWampErrorDomain format:@"Class %@ is not a registered message in the protocol", className];
    }
    return keys[0];
}


@end
