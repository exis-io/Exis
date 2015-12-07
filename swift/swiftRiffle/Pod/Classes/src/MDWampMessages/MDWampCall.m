//
//  MDWampCall.m
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
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

#import "MDWampCall.h"

@implementation MDWampCall

- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        // [CALL, Request|id, Options|dict, Procedure|uri, Arguments|list, ArgumentsKw|dict]
        self.request    = [tmp shift];
        self.options    = [tmp shift];
        self.procedure        = [tmp shift];
        if ([tmp count] > 0) self.arguments     = [tmp shift];
        if ([tmp count] > 0) self.argumentsKw   = [tmp shift];
    }
    return self;
}

- (NSArray *)marshall
{
    NSNumber *code = [[MDWampMessageFactory sharedFactory] codeFromObject:self];
    if (self.arguments && self.argumentsKw) {
        return @[code, self.request, self.options, self.procedure, self.arguments, self.argumentsKw ];
    } else if(self.arguments) {
        return @[code, self.request, self.options, self.procedure, self.arguments ];
    } else if(self.argumentsKw) {
        return @[code, self.request, self.options, self.procedure, @[], self.argumentsKw ];
    } else {
        return @[code,self.request, self.options, self.procedure];
    }
}

@end
