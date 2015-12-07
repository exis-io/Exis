//
//  MDWampChallenge.m
//  MDWamp
//
//  Created by Niko Usai on 26/08/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampChallenge.h"

@implementation MDWampChallenge
- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        // [CHALLENGE, AuthMethod|string, Extra|dict]
        self.authMethod    = [tmp shift];
        self.extra    = [tmp shift];
    }
    return self;
}

- (NSArray *)marshall
{
    NSNumber *code = [[MDWampMessageFactory sharedFactory] codeFromObject:self];
    return @[code, self.authMethod, self.extra ];
}
@end
