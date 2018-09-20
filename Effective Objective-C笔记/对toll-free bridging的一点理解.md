# 对toll-free bridging的一点理解
##toll-free bridging的定义

- Foundation VS CoreFoundation

> 在理解toll-free bridging之前，我们先了解一下Foundation和CoreFoundation两个框架。我们在开发中比较常用到的是Foundation框架，它提供了像NSObject、NSArray、NSDictionary等常用类。而CoreFoundation框架，则比较少使用，它是由C语言实现的，如果使用CoreFoundation框架，即使是在ARC情况下，也需要手动管理内存。

- toll-free bridging

> toll-free bridging指的是有一些数据类型可以在Foundation与CoreFoundation框架之间进行无缝转换。

- [TFB中可以互相转换的类型](https://developer.apple.com/library/archive/documentation/General/Conceptual/CocoaEncyclopedia/Toll-FreeBridgin/Toll-FreeBridgin.html)

##toll-free bridging的使用
- __bridge的使用

> __bridge只是单纯地进行OC指针与CF指针之间的转换，不涉及到生命周期管理权的转换。因此，对于OC转换为CF之后，我们不需要在CF指针使用完后进行释放操作，因为它依旧由于OC中的ARC进行管理。同理，对于CF转换为OC之后，我们必须在OC指针使用完之后，对CF进行释放操作，因为CF只能MRC。

```objc
- (void)objcToCF_bridge {
    NSString *string = @"objcToCF_bridge";
    CFStringRef cfStr = (__bridge CFStringRef)string;
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"string:%s", CFStringGetCStringPtr(cfStr, kCFStringEncodingUTF8));
    NSLog(@"length:%ld", (long)CFStringGetLength(cfStr));
    //无需进行释放cfStr
}

- (void)cfToObjc_bridge {
    CFStringRef cfStr = CFStringCreateWithCString(kCFAllocatorDefault, "cfToObjc_bridge", kCFStringEncodingUTF8);
    NSString *str = (__bridge NSString *)cfStr;
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"str:%@", str);
    NSLog(@"length:%ld", str.length);
    CFRelease(cfStr);
    //必须释放cfStr
}
```
- __bridge _retain的使用

> __bridge _retain是将一个OC指针转换为CF指针，并将OC的生命周期管理权转移给CF指针管理。因此，我们在使用完CF指针后，需要对CF指针进行释放操作。

```objc
- (void)objcToCF_bridge_retain {
    NSString *string = @"objcToCF_bridge_retain";
    CFStringRef cfStr = (__bridge_retained CFStringRef)string; //转移管理权
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"string:%s", CFStringGetCStringPtr(cfStr, kCFStringEncodingUTF8));
    NSLog(@"length:%ld", (long)CFStringGetLength(cfStr));
    CFRelease(cfStr); //必须释放cfStr
}
```

- __bridge _transfer的使用

> __bridge _transfer是将一个CF指针转换为OC指针，并将CF的生命周期管理权转移到OC指针中。由于OC是使用ARC，因此，使用完之后无需对OC和CF进行释放操作。

```obcj
- (void)cfToObjc_bridge_transfer {
    CFStringRef cfStr = CFStringCreateWithCString(kCFAllocatorDefault, "cfToObjc_bridge_transfer", kCFStringEncodingUTF8);
    NSString *str = (__bridge_transfer NSString *)cfStr;
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"string:%@", str);
    NSLog(@"length:%ld", str.length);
}
```

## toll-free bridging的应用场景

- 关联对象时，对key的转换

> 我们知道关联对象时，key所对应的类型为const void*。因此，如果我们需要将一个NSString作为key,则需要通过toll-free进行转换。通常是使用__bridge来进行两者之间的转换。

```objc
static NSString *const kStringKey = @"kStringKey";

- (void)objc_setString:(NSString *)string {
    objc_setAssociatedObject(self, (__bridge const void*)kStringKey, string,  OBJC_ASSOCIATION_COPY);
}

- (NSString *)objc_getString {
    return objc_getAssociatedObject(self, (__bridge const void*)kStringKey);
}
```

- 使用CFMutableDictionary来避免key未实现NSCopying协议

> 我们知道NSMutableDictionary要求key必须实现了NSCopying协议，否则会报错。为了避免出现这种情况，我们可以使用CFMutableDictionary来替换它。其中[YYCache](https://github.com/ibireme/YYCache/blob/master/YYCache/YYMemoryCache.m)中的使用的数据结构就是CFMutableDictionary。

```objc
//定义一个未实现NSCopying协议的Key对象
@interface Customkey : NSObject
@property (nonatomic, strong) NSString *key;
@end

@interface TBFDemo () {
    CFMutableDictionaryRef _cfDict; //注意Core Foundation中变量的定义方式
}
@property (nonatomic, strong) NSMutableDictionary *nsDict;
@end

- (instancetype)init {
    if (self = [super init]) {
        _nsDict = [NSMutableDictionary dictionary];
        _cfDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (void)dealloc {
    CFRelease(_cfDict); //对象销毁时，需要主动释放
}

- (void)cf_addObject:(NSString *)obj key:(Customkey *)key {
    CFDictionarySetValue(_cfDict, (__bridge const void*)key, (__bridge const void*)obj); //添加
}

- (void)cf_removeForKey:(Customkey *)key {
    CFDictionaryRemoveValue(_cfDict, (__bridge const void *)key); //删除
}

- (NSString *)cf_objectForKey:(Customkey *)key {
    return CFDictionaryGetValue(_cfDict, (__bridge const void*)key); //获取
}

- (BOOL)cf_containsForKey:(Customkey *)key {
    return CFDictionaryContainsKey(_cfDict, (__bridge const void*)key); //判断是否含有
}

```

##参考资料

- Effective objective-C 

- [深入理解Toll-Free Bridging](https://blog.csdn.net/Hello_Hwc/article/details/80094632)

- [Toll-Free Bridging](http://gracelancy.com/blog/2014/04/21/toll-free-bridging/)