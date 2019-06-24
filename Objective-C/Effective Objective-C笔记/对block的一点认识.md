# 对block的一点认识
## block的定义
> 官方文档是这么定义block：<br>
> Blocks are a language-level feature added to C, Objective-C and C++, which allow you to create distinct segments of code that can be passed around to methods or functions as if they were values. Blocks are Objective-C objects, which means they can be added to collections like NSArray or NSDictionary. They also have the ability to capture values from the enclosing scope, making them similar to closures or lambdas in other programming languages. <br>
> 简单来说，就是block在OC中也是属于一个对象，可以用collection去存储，也可以在block内部获取外部变量，还可以作为一个变量作为函数参数等。

### block的声明和使用
> block的声明方式：<br>
> 返回类型(^block名称)(参数类型) = ^(参数类型) {};

```objc
- (void)blockDeclare {
    int multiplier = 7;
    int (^myBlock) (int) = ^ (int num) {
        return num * multiplier;
    };
    
    int result = myBlock(3);
    NSLog(@"block-value:%d", result);
}
```
- block作为函数变量使用

```objc
- (void)functionBlock {
    NSArray *arr = @[@"Tom", @"John", @"Mary"];
    NSArray *sortedArr = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSLog(@"arr:%@", sortedArr);
}

其中^NSComparisonResult(id _Nonnull obj1, id _Nonnull ojb2)便是作为函数的一个参数。
我们查看sortedArrayUsingComparator方法定义如下：
- (NSArray<ObjectType> *)sortedArrayUsingComparator:(NSComparator NS_NOESCAPE)cmptr;

而这里的NSComparator便为一个block定义：
typedef NSComparisonResult (^NSComparator)(id obj1, id obj2);
```
- block作为成员变量使用

> 使用block作为成员变量时，注意typedef和直接定义两种不同方式的使用

```objc
typedef void (^RegisterSuccessBlock)(NSString *msg); 
@interface AccountManager : NSObject
//定义
@property (nonatomic, copy) void(^loginSuccessBlock)(void);
@property (nonatomic, copy) RegisterSuccessBlock registerSuccessBlock;
- (void)login;
- (void)registerAccount;
@end

@implementation AccountManager
- (void)login {
    sleep(3.0f);
    self.loginSuccessBlock(); //调用
}

- (void)registerAccount {
    sleep(3.0f);
    self.registerSuccessBlock(@"success"); //调用
}
@end

//使用
AccountManager *manager = [[AccountManager alloc] init];
manager.loginSuccessBlock = ^{
  //do something
};
[manager login];
    
manager.registerSuccessBlock = ^(NSString *msg) {
  //do something
};
[manager registerAccount];
```

- 为常用的块类型创建typedef

>typedef的使用：```typedef 返回类型(^block名称)(block参数)```

```objc
typedef int(^EOCSomeBlock)(BOOL flag, int value);
EOCSomeBlock block = ^(BOOL flag, int value) {
	//implementation
}
```

- 使用__block来修改外部变量

>对于block外的变量，block是默认将变量复制到其数据结构来实现访问的，即默认情况下，内外部变量的状态是不一致的。为了保证内外部变量状态保证一致，可以通过__block来实现。 

```objc
int num = 10;
void(^NumBlock)(void) = ^ {
	NSLog("%d",num);
};
num = 12;
NumBlock();
//输出：10

__block int num = 10;
void(^NumBlock)(void) = ^ {
	NSLog("%d",num);
};
num = 12;
NumBlock();
//输出：12
```

