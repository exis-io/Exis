//
//  MDWampMessageFactory.h
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

#import <Foundation/Foundation.h>
#import "MDWampConstants.h"
@protocol MDWampMessage;

FOUNDATION_EXPORT NSString *const kMDWampHello        ;
FOUNDATION_EXPORT NSString *const kMDWampWelcome      ;
FOUNDATION_EXPORT NSString *const kMDWampAbort        ;
FOUNDATION_EXPORT NSString *const kMDWampChallenge    ;
FOUNDATION_EXPORT NSString *const kMDWampAuthenticate ;
FOUNDATION_EXPORT NSString *const kMDWampGoodbye      ;
FOUNDATION_EXPORT NSString *const kMDWampError        ;
FOUNDATION_EXPORT NSString *const kMDWampPublish      ;
FOUNDATION_EXPORT NSString *const kMDWampPublished    ;
FOUNDATION_EXPORT NSString *const kMDWampSubscribe    ;
FOUNDATION_EXPORT NSString *const kMDWampSubscribed   ;
FOUNDATION_EXPORT NSString *const kMDWampUnsubscribe  ;
FOUNDATION_EXPORT NSString *const kMDWampUnsubscribed ;
FOUNDATION_EXPORT NSString *const kMDWampEvent        ;
FOUNDATION_EXPORT NSString *const kMDWampCall         ;
FOUNDATION_EXPORT NSString *const kMDWampCancel       ;
FOUNDATION_EXPORT NSString *const kMDWampResult       ;
FOUNDATION_EXPORT NSString *const kMDWampRegister     ;
FOUNDATION_EXPORT NSString *const kMDWampRegistered   ;
FOUNDATION_EXPORT NSString *const kMDWampUnregister   ;
FOUNDATION_EXPORT NSString *const kMDWampUnregistered ;
FOUNDATION_EXPORT NSString *const kMDWampInvocation   ;
FOUNDATION_EXPORT NSString *const kMDWampInterrupt    ;
FOUNDATION_EXPORT NSString *const kMDWampYield        ;

@interface MDWampMessageFactory : NSObject

/**
 *  Singleton
 *
 */
+ (instancetype) sharedFactory;

/**
 *  return an MDWampMessage instance, given the code
 *  and inited with the payload
 *
 *  @param code    protocol code
 *  @param payload array of parameters to init the message with
 *
 *  @return an instance of the right message
 */
- (id<MDWampMessage>)objectFromCode:(NSNumber*)code withPayload:(NSArray*)payload;

/**
 *  Gives the class name as a string given the right code
 *
 *  @param code protocol code
 *
 *  @return Class string name
 */
- (NSString *)nameFromCode:(NSNumber*)code;

/**
 *  Gives the protocol code for a class Name
 *
 *  @param NSString         class name
 *
 *  @return code
 */
- (NSNumber *)codeFromClassName:(NSString*)className;

/**
 *  Gives the protocol code for a given object
 *
 *  @param object an MDWampMessage ninstance
 *
 *  @return protocol code
 */
- (NSNumber *)codeFromObject:(id<MDWampMessage>)object;

@end
