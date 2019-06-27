
### 1.属性和成员变量
> 两者之间的关系为：```@property = 成员变量 + getter + setter```。```@property```是在iOS5之后为了减少重复对```setter```和```getter```方法的定义，所以引入了它。
```objc
@interface Person :NSObject{
    int_age;
}

-(void)setAge:(int)age{
   _age = age;
}

-(int)age{
   return  _age;
}

等同于

@interface Person : NSObject 
@property (nonatomic, assign) int age;
@end
```

### 2.private,protected和public
> 在OC中method都是public的，只有```ivar```才存在访问权限，```property```都是public的。并且```ivar```只能通过```->```来进行访问，不能使用dot操作符。

### 3.synthesize和dynamic
> ```@synthesize```：如果属性没有手动实现setter和getter方法，编译器会自动加上，一般用于变量重命名。通常对于```@property```等同于```@synthesize var = _var```。
> ```@dynamic```：告诉编译器不用生成setter和getter，由用户实现。
```objc
@interface Person
@property (nonatomic, assign) int age;
@end

@implementation person
@synthesize age = _myAge;

@end
```

### 4.对象关联
> a. 使用```@selector()```来作为key
> b. 不管是OC对象还是C类型，都应该使用```OBJC_ASSOCIATION_RETAIN_NONATOMIC```,避免使用```OBJC_ASSOCIATION_ASSIGN```,因为它非常容易被释放而导致获取为nil.
> c. 移除对象时，传入nil值，并使用```OBJC_ASSOCIATION_ASSIGN```

```objc
@implementation NSObject (AssociatedObject)
@dynamic associatedObject;

- (void)setAssociatedObject:(id)object {
     objc_setAssociatedObject(self, @selector(associatedObject), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObject {
    return objc_getAssociatedObject(self, @selector(associatedObject));
}

- (void)removeAssociatedObject {
    objc_setAssociatedObject(self, @selector(associatedObject), nil, OBJC_ASSOCATION_ASSIGN);
}

@end
```