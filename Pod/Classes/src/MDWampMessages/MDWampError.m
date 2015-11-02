//
//  MDWampError.m
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
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

#import "MDWampError.h"

@implementation MDWampError
- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        self.type = [tmp shift];
        self.request = [tmp shift];
        self.details = [tmp shift];
        self.error = [tmp shift];
        if ([tmp count] > 0) self.arguments = [tmp shift];
        if ([tmp count] > 0) self.argumentsKw = [tmp shift];
    }
    return self;
}


- (NSArray *)marshall
{
    NSNumber *code = [[MDWampMessageFactory sharedFactory] codeFromObject:self];
    
    if (self.arguments && self.argumentsKw) {
        return @[code, self.type, self.request, self.details, self.error,
                 self.arguments, self.argumentsKw ];
    } else if(self.arguments) {
        return @[code, self.type, self.request, self.details, self.error,
                 self.arguments ];
    } else if(self.argumentsKw) {
        return @[code, self.type, self.request, self.details, self.error, @[], self.argumentsKw ];
    } else {
        return @[code, self.type, self.request, self.details, self.error ];
    }
}

- (NSError *) makeError
{
    NSDictionary *info;
    if (self.details != nil && ![self.details isEqual: [NSNull null]]) {
        info = [self.details mutableCopy];
        [(NSMutableDictionary*)info setObject:self.error forKey:NSLocalizedDescriptionKey];
    } else {
        info = @{NSLocalizedDescriptionKey: self.error};
    }
    return [NSError errorWithDomain:kMDWampErrorDomain code:[self.type integerValue] userInfo:info];
}

@end
