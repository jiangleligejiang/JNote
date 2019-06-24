# 精简initialize与load的实现代码
> 在OC中，绝大部分类都继承自NSObject这个根类，而该类有initialize和load两个方法，可以用来实现初始化操作。

## load方法
> 对于加入运行期系统中的每个类及分类来说，必定会调用此方法，而且仅调用一次。当包含类或分类的程序库载入系统时，就会执行该方法。

### load方法注意事项
- load方法的执行顺序：父类-->子类-->父类类别-->子类类别

```objc
//.h文件
#import <Foundation/Foundation.h>
@interface QYBaseClass : NSObject
@end

@interface QYBaseClass (load)
@end

@interface QYSubClass : QYBaseClass
@end

@interface QYSubClass (load)
@end

//.m文件
#import "QYBaseClass.h"
@implementation QYBaseClass

+ (void)load {
    NSLog(@"%s", __FUNCTION__);
}

@end

@implementation QYBaseClass (load)

+ (void)load {
    NSLog(@"%s", __FUNCTION__);
}

@end

@implementation QYSubClass

+ (void)load {
    NSLog(@"%s", __FUNCTION__);
}

@end


@implementation QYSubClass (load)

+ (void)load {
    NSLog(@"%s", __FUNCTION__);
}

@end

//运行程序结果：
2018-09-18 11:22:43.200518+0800 YQDemo[7881:91590] +[QYBaseClass load]
2018-09-18 11:22:43.201906+0800 YQDemo[7881:91590] +[QYSubClass load]
2018-09-18 11:22:43.202644+0800 YQDemo[7881:91590] +[QYBaseClass(load) load]
2018-09-18 11:22:43.202822+0800 YQDemo[7881:91590] +[QYSubClass(load) load]
```
- 不能在load方法中使用其他类

> 在执行load方法时，运行期系统处于“脆弱状态”。对于某个给定的程序库，无法判断出其中各个类的载入顺序。因此，在load方法中使用其他类是不安全的。

```objc
#import "EOCClassB.h"
#import "EOCClassA.h"

@implementation EOCClassB

+ (void)load {
    NSLog(@"%s",__FUNCTION__);
    EOCClassA *obj = [[EOCClassA alloc] init];
}

@end

//输出结果:
2018-09-18 10:44:43.676041+0800 YQDemo[7372:56713] +[EOCClassB load]
2018-09-18 10:44:43.676631+0800 YQDemo[7372:56713] +[EOCClassA load]
```
### load方法的原则
> load方法务必精简些，尽量减少所要执行的操作，因为整个应用在执行load方法时都会被阻塞。如果load方法中包含复杂的代码，那么应用程序会在执行期间变得无响应。

### load方法的使用场景
- 在load方法中加入日志信息，便于调试，查看该类是否被应用所加载

```objc
#import "QYBaseClass.h"
@implementation QYBaseClass

+ (void)load {
    NSLog(@"%s", __FUNCTION__); //用于查看该类是否被加载
}

@end
```

- 在load方法中使用Method Swizzle

```objc
#import "UIViewController+Tracking.h"
#import <objc/runtime.h>
@implementation UIViewController (Tracking)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(xxx_viewWillAppear:);
        struct objc_method *originalMethod = class_getInstanceMethod(class, originalSelector);
        struct objc_method *swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}
#pragma mark - Method Swizzling
- (void)xxx_viewWillAppear:(BOOL)animated {
    [self xxx_viewWillAppear:animated];
    NSLog(@"viewWillAppear: %@", self);
}
@end
```

## initialize方法
> 对于每个类来说，该方法会在程序首次用该类之前调用，且只调用一次。如果某个类一直没有被调用，则其initialize方法也不会被调用。

### initialize方法注意事项
- 如果某个类没有实现initalize方法，但其超类实现了，那么就会运行其超类的方法

```objc
//.h文件
@interface EOCBaseClass : NSObject
@end

@interface EOCSubClass : EOCBaseClass
@end

//.m文件
@implementation EOCBaseClass

+ (void)initialize {
    NSLog(@"%@ initialize", self);
}

@end

@implementation EOCSubClass

@end

//调用EOCSubClass
- (void)viewDidLoad {
    [super viewDidLoad];
    EOCSubClass *sub = [[EOCSubClass alloc] init];
}

//输出结果:
2018-09-18 11:31:59.085924+0800 YQDemo[8057:100735] EOCBaseClass initialize
2018-09-18 11:31:59.086059+0800 YQDemo[8057:100735] EOCSubClass initialize

为了避免出现子类未覆盖父类方法，但依旧会再执行父类方法一遍问题，可以做以下处理：
+ (void)initialize {
    if (self == [EOCBaseClass class]) {
        NSLog(@"%@ initialize", self);
    }
}
//输出结果：
2018-09-18 11:36:22.258525+0800 YQDemo[8132:104918] EOCBaseClass initialize
```

- initialize方法只应该用于设置内部数据，不应该在其中调用其他方法，即便是本类自己的方法，也最好不要调用

### initialize方法的原则
> initialize方法精简的原因与load方法相似，initialize方法会阻塞当前初始化它的线程，如果刚好是使用UI线程来初始化，那么会一直阻塞UI线程，导致程序无法响应。

### initialize的应用场景
- 在initialize方法中初始化全局变量或静态变量

```objc
//.h文件
#import <Foundation/Foundation.h>
static const int kInterval = 10;
static NSMutableArray *data;
@interface QYInternalClassA : NSObject

@end

//.m文件
#import "QYInternalClassA.h"
@implementation QYInternalClassA

+ (void)initialize {
    if (self == [QYInternalClassA class]) {
        data = [NSMutableArray array];
    }
}
```

#### 参考资料
- Effective Objective-C 2.0

- [Method Swizzling](http://www.tanhao.me/code/160723.html/) 

- [load vs initialize](https://www.jianshu.com/p/3414b4853c50)