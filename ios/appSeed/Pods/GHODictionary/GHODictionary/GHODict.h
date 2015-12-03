//
//  GHODict.h
//  GHODictionary
//
//  Created by Gabriel on 5/13/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHODictionary : NSObject <NSFastEnumeration>

- (instancetype)initWithCapacity:(NSUInteger)capacity;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)dictionary;
+ (instancetype)dictionaryWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)dictionaryWithCapacity:(NSUInteger)capacity;
// Shorthand when using literal
+ (instancetype)d:(NSDictionary *)dictionary;

- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;

- (void)removeObjectForKey:(id)key;

- (NSInteger)count;

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id)key;

- (void)sortKeysUsingSelector:(SEL)selector deepSort:(BOOL)deepSort;
- (NSArray *)allKeys;

/*!
 Add dictionary entries.

 @param dictionary Dictionary, can be NSDictionary or GHODictionary
 */
- (void)addEntriesFromDictionary:(id)dictionary;

- (NSEnumerator *)keyEnumerator;
- (NSEnumerator *)reverseKeyEnumerator;

- (NSDictionary *)toDictionary;

- (NSArray *)map:(id (^)(id key, id value))block;
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block;

/*!
 Add object to key entry.
 This is to make it easier to create a dictionary of key to array values.
 */
- (void)addObject:(id)object forKey:(id)key;

// Deprecated; Use addEntriesFromDictionary
- (void)addEntriesFromOrderedDictionary:(GHODictionary *)dictionary;

@end

#define GHODict(DICT) ([GHODictionary dictionaryWithDictionary:DICT])
