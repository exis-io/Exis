//
//  MDWampClientDelegate.h
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

@class MDWamp;

@protocol MDWampClientDelegate <NSObject>

@optional

/**
 *  Called when client connect to the server
 *
 *  @param wamp wamp client
 *  @param info dictionary with additional info
 */
- (void) mdwamp:(MDWamp*)wamp sessionEstablished:(NSDictionary*)info;

/**
 *  Called when client disconnect from the server
 * it gives code of the error / reason of disconnect and a description of the reason
 *
 *  @param wamp    wamp client
 *  @param code
 *  @param reason
 *  @param details 
 */
- (void) mdwamp:(MDWamp *)wamp closedSession:(NSInteger)code reason:(NSString*)reason details:(NSDictionary *)details;
///*
// * Auth req finished
// *
// * @param answer		authreq answer
// */
//- (void) onAuthReqWithAnswer:(NSString *)answer;
//
///*
// * Signed authentification challenge
// *
// * @param signature		HmacSHA256(challenge, secret)
// */
//- (void) onAuthSignWithSignature:(NSString *)signature;
//
///*
// * Handshake finished
// *
// * @param answer		auth call answer
// */
//- (void) onAuthWithAnswer:(NSString *)answer;
//
///*
// * Auth failed
// *
// * @param procCall		auth procedure that failed: authreq or auth
// * @param error         the error returned by the failed call
// */
//- (void) onAuthFailForCall:(NSString *)procCall withError:(NSString *)errorDetails;
//
@end

