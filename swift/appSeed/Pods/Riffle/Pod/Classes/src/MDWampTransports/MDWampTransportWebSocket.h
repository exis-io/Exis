//
//  MDWampTransportWebSocket.h
//  MDWamp
//
//  Created by Niko Usai on 11/03/14.
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
#import "MDWampTransport.h"

FOUNDATION_EXPORT NSString *const kMDWampProtocolWamp2json;
FOUNDATION_EXPORT NSString *const kMDWampProtocolWamp2msgpack;

@interface MDWampTransportWebSocket : NSObject <MDWampTransport>
@property id<MDWampTransportDelegate>delegate;

/**
 *  Default initializer
 *  By restricting the array of protocol versions we force to use a given protocol
 *  they are in the form of wamp, wamp.2.json, wamp.2.msgpack
 *
 *  @param request   request representing a server
 *
 *  @return intsance of the transport
 */
- (id)initWithServer:(NSURL *)request protocolVersions:(NSArray *)protocols;

@end
