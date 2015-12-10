//
//  MDWampInterrupt.m
//  MDWamp
//
//  Created by Niko Usai on 26/08/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampInterrupt.h"

@implementation MDWampInterrupt
- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        // [INTERRUPT, INVOCATION.Request|id, Options|dict]
        self.request    = [tmp shift];
        self.options    = [tmp shift];
    }
    return self;
}

- (NSArray *)marshall
{
    NSNumber *code = [[MDWampMessageFactory sharedFactory] codeFromObject:self];
    return @[code, self.request, self.options];
}

@end
