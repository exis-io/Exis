//
//  MDWampSerializationJSON.m
//  MDWamp
//
//  Created by Niko Usai on 09/03/14.
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

#import "MDWampSerializationJSON.h"

@implementation MDWampSerializationJSON

- (id) pack:(NSArray*)arguments
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arguments options:0 error:&error];
    if (error) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
}

- (NSArray*) unpack:(NSData *)data
{
    NSData *d = data;
    if (![data isKindOfClass:[NSData class]]) {
        d = [(NSString*)data dataUsingEncoding:NSUTF8StringEncoding];
    }
	return [NSJSONSerialization JSONObjectWithData:d  options:NSJSONReadingAllowFragments error:nil];
}


@end
