//
//  MDWampTransportProtocol.h
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
#import "MDWampTransportDelegate.h"
#import "MDWampConstants.h"

@class MDWampMessage;
@protocol MDWampTransport <NSObject>

/**
 *  The transport delegate
 */
@property id<MDWampTransportDelegate>delegate;



/**
 *  Method used to open a connection to the transport
 */
- (void) open;

/**
 *  Method used to close a connection with the transport
 */
- (void) close;
/**
 *  Test the connection with the transport
 *
 *  @return connection status
 */
- (BOOL) isConnected;

/**
 *  Method to send data on the transport
 */
- (void)send:(NSData *)data;

@end
