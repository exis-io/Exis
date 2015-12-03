//
//  MDWampInterrupt.h
//  MDWamp
//
//  Created by Niko Usai on 26/08/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"
@interface MDWampInterrupt : NSObject <MDWampMessage>
@property (nonatomic, strong) NSNumber *request;
@property (nonatomic, strong) NSDictionary *options;
@end
