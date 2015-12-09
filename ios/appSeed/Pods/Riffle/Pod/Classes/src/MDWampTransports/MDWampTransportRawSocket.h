//
//  RawSocketTransport.h
//  MDWamp
//
//  Created by Niko Usai on 05/07/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampTransport.h"
@interface MDWampTransportRawSocket : NSObject <MDWampTransport>
- (id)initWithHost:(NSString*)host port:(NSInteger)port;
@property id<MDWampTransportDelegate>delegate;
@property (nonatomic, strong) NSString *serialization;
@end
