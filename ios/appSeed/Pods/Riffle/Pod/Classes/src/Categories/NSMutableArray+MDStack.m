//
//  NSMutableArray+MDStack.m
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

#import "NSMutableArray+MDStack.h"

@implementation NSMutableArray (MDStack)

- (id) shift 
{
    id obj = [self objectAtIndex:0];
    [self removeObjectAtIndex:0];
    return obj;
}

- (void) unshift:(id)object
{
    [self insertObject:object atIndex:0];
}

- (id) pop
{
    id obj = [self lastObject];
    [self removeLastObject];
    return obj;
}

- (void) push:(id)object
{
    [self addObject:object];
}

@end
