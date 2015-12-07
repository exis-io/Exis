GHODictionary
===========

Ordered dictionary. Enumeration occurs in the order that entries were added. If an item is overwritten, the order is unchanged.

For example,

```objc
#import <GHODictionary/GHODictionary.h>

GHODictionary *dict = [GHODictionary dictionary];
dict[@"key1"] = @(1);
dict[@"key2"] = @(2);
dict[@"key1"] = @(3);

for (id key in dict) ... // @"key1", @"key2" 

[dict allKeys]; // The same as enumeration, @"key1", @"key2"

[dict map:^(id key, id value) { ... }]; // (@"key1", @(3)), (@"key2", @(2))
```

If you want to overwrite a value and have it moved to the end of the ordering, then remove it and re-add:

```objc
dict[@"key1"] = nil;
dict[@"key1"] = @(3);
[dict allKeys]; // @"key2", @"key1"
```

Because it is ordered, it is also sortable:

```objc
dict[@"b"] = @(2);
dict[@"c"] = @(3);
dict[@"a"] = @(1);
[dict sortKeysUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

[dict allKeys]; // @"a", @"b", @"c"
```


# Podfile

```
pod "GHODictionary"
```

# Cartfile

```
github "gabriel/GHODictionary"
```
