# Collection的几种遍历方式
## for循环

> for循环是最原始的遍历方式，常用于NSArray，但对于set和dictionary的遍历操作比较繁琐。

```objc
- (void)for_transverse {
    NSLog(@"%s", __FUNCTION__);
    NSArray *arr = @[@"1", @"2", @"2", @"3", @"4", @"5"];
    for (int i = 0; i < arr.count; i ++) {
        NSLog(@"arr[%d] = %@", i , arr[i]);
    }
    
    NSSet *set = [NSSet setWithArray:arr];
    NSArray *objs = [set allObjects];
    for (int i = 0; i < objs.count; i ++) {
        NSLog(@"set[%d] = %@", i , objs[i]);
    }
    
    NSDictionary *dict = @{@"key1" : @"value1",
                           @"key2" : @"value2",
                           @"key3" : @"value3"};
    NSArray *keys = [dict allKeys];
    for (int i = 0; i < keys.count; i ++) {
        NSLog(@"dict[%@] = %@", keys[i], dict[keys[i]]);
    }
}
```

## NSEnumerator的遍历
> Foundation框架中的Collection都实现这种遍历方式，这种遍历方式操作方式较为相似，同时也支持逆序遍历。

```objc
- (void)enumerator_transverse {
    NSLog(@"%s", __FUNCTION__);
    NSArray *arr = @[@"1", @"2", @"2", @"3", @"4", @"5"];
    NSEnumerator *arrEnumerator = [arr objectEnumerator];
    id obj;
    while ((obj = [arrEnumerator nextObject]) != nil) {
        NSLog(@"%@", obj);
    }
    NSEnumerator *arrReverseEnumerator = [arr reverseObjectEnumerator];
    while ((obj = [arrReverseEnumerator nextObject]) != nil) {
        NSLog(@"%@", obj);
    }
    
    NSSet *set = [NSSet setWithArray:arr];
    NSEnumerator *setEnumerator = [set objectEnumerator];
    while ((obj = [setEnumerator nextObject]) != nil) {
        NSLog(@"%@", obj);
    }
    
    NSDictionary *dict = @{@"key1" : @"value1",
                           @"key2" : @"value2",
                           @"key3" : @"value3"};
    NSEnumerator *dictEnumerator = [dict keyEnumerator];
    id key;
    while ((key = [dictEnumerator nextObject]) != nil) {
        NSLog(@"dict[%@] = %@", key, dict[key]);
    }
}
```

## 快速遍历

> 这种遍历方式可以说是既简洁也快速。

```objc
- (void)fast_in_transverse {
    NSLog(@"%s", __FUNCTION__);
    NSArray *arr = @[@"1", @"2", @"2", @"3", @"4", @"5"];
    for (NSString *str in arr) {
        NSLog(@"%@", str);
    }
    for (NSString *str in [arr reverseObjectEnumerator]) {
        NSLog(@"%@", str);
    }
    
    NSSet *set = [NSSet setWithArray:arr];
    for (NSString *str in set) {
        NSLog(@"%@", str);
    }
    
    NSDictionary *dict = @{@"key1" : @"value1",
                           @"key2" : @"value2",
                           @"key3" : @"value3"};
    for (id key in dict) {
        NSLog(@"dict[%@] = %@", key, dict[key]);
    }
}
```

## 基于块的遍历

> 它对比起快速遍历的优势是可以获取到对应的index，但它的主动退出循环的方式比较麻烦，需要通过设置stop变量来退出。要注意的是，设置完stop为YES之后，依旧会执行下面的语句，只是不会执行后面的遍历而已。

```objc
- (void)block_transverse {
    NSLog(@"%s", __FUNCTION__);
    NSArray *arr = @[@"1", @"2", @"2", @"3", @"4", @"5"];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"3"]) {
            *stop = YES; //注意：设置完之后，依旧会执行下面的语句，只是不会再执行后面的遍历
        }
        NSLog(@"arr[%ld] = %@", idx, obj);
    }];
    
    [arr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"3"]) {
            *stop = YES; 
        }
        NSLog(@"arr[%ld] = %@", idx, obj);
    }];
    
    //并发遍历
    [arr enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"arr[%ld] = %@", idx, obj);
    }];
    
    NSSet *set = [NSSet setWithArray:arr];
    [set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"3"]) {
            *stop = YES;
        }
        NSLog(@"%@", obj);
    }];
    
    NSDictionary *dict = @{@"key1" : @"value1",
                           @"key2" : @"value2",
                           @"key3" : @"value3"};
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:@"key2"]) {
            *stop = YES;
        }
        NSLog(@"dict[%@] = %@", key, obj);
    }];
}
```

## 总结

- 优先选择fast-in遍历方式，如果遍历过程中需要用到index，则退而选择block遍历方式。
