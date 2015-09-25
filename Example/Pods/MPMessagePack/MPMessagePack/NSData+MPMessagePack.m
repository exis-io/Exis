//
//  NSData+MPMessagePack.m
//  MPMessagePack
//
//  Created by Gabriel on 1/5/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "NSData+MPMessagePack.h"

#import <GHODictionary/GHODictionary.h>

@implementation NSData (MPMessagePack)

- (NSString *)mp_hexString {
  if ([self length] == 0) return nil;
  NSMutableString *hexString = [NSMutableString stringWithCapacity:[self length] * 2];
  for (NSUInteger i = 0; i < [self length]; ++i) {
    [hexString appendFormat:@"%02X", *((uint8_t *)[self bytes] + i)];
  }
  return [hexString lowercaseString];
}

- (NSDictionary *)mp_dict:(NSError **)error {
  return [self mp_dict:0 error:error];
}

- (id)mp_dict:(MPMessagePackReaderOptions)options error:(NSError **)error {
  id obj = [MPMessagePackReader readData:self options:options error:error];
  if (!obj) return nil;
  if (![obj isKindOfClass:NSDictionary.class] && ![obj isKindOfClass:GHODictionary.class]) {
    if (error) *error = [NSError errorWithDomain:@"MPMessagePack" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Object was not of type NSDictionary or GHODictionary", @"MPObject": obj}];
    return nil;
  }
  return obj;
}

- (NSArray *)mp_array:(NSError **)error {
  return [self mp_array:0 error:error];
}

- (NSArray *)mp_array:(MPMessagePackReaderOptions)options error:(NSError **)error {
  id obj = [MPMessagePackReader readData:self error:error];
  if (!obj) return nil;
  if (![obj isKindOfClass:NSArray.class]) {
    if (error) *error = [NSError errorWithDomain:@"MPMessagePack" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Object was not of type NSArray", @"MPObject": obj}];
    return nil;
  }
  return obj;
}

- (id)mp_object:(NSError **)error {
  return [MPMessagePackReader readData:self error:error];
}

@end
