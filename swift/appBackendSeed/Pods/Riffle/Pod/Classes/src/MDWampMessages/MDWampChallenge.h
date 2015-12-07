//
//  MDWampChallenge.h
//  MDWamp
//
//  Created by Niko Usai on 26/08/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"
@interface MDWampChallenge : NSObject <MDWampMessage>
@property (nonatomic, strong) NSString *authMethod;
@property (nonatomic, strong) NSDictionary *extra;
@end
