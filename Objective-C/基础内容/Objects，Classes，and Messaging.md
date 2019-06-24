\## 前言 

\> 本小节主要总结概括OC中object、Class和Message相关的[知识点](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocObjectsClasses.html#//apple_ref/doc/uid/TP30001163-CH11-SW1)。 

\### Objects 

\- id 

\> id在OC中可以看为一种通用类型，可以代表任何Class类型的object，当然不包括int、double等C语言类型。 

\```objc 

typedef struct objc_object { 

Class isa; 

} *id; 

typedef struct objc_class *Class; 

\``` 

在Runtime系统中，可以将其看作为指向"isa"的一个指针。 

\- Dynamic Typing 

\> 在OC中类型是动态可变的，并不会在编译期就决定，可以在动态运行期中进行修改。比如我们的声明对象为id，那么可以通过强制转换为其他类型。当然一些具备继承关系的对象，比如子类对象可以强制转换为父类对象。 

\### Messaging 

\- send message to nil 

\> 若一个nil对象调用方法，通常会返回为nil。```A message to nil does nothing and returns nil, Nil, NULL, 0, or 0.0.```但反过来，作为参数传入nil对象，比如```[NSObject equalTo]```方法，以及加入到```NSArray```或```NSDictionary```等集合中，都可能会导致crash。 

\```objc 

// Each member of the path is an object. 

x = person.address.street.name; 

x = [[[person address] street] name]; 

// The path contains a C struct. 

// This will crash if window is nil or -contentView returns nil. 

y = window.contentView.bounds.origin.y; 

y = [[window contentView] bounds].origin.y; 

\``` 

这里有个比较坑的点是```nil```对象去调用OC方法是OK的，但去调用C中的方法却可能会导致Crash。 

\- Polymorphism 

\> 在OC中，多态性一般体现在继承类中，对于同一个方法，根据传入不同的对象，系统会调用对象中所对应的方法，而不是由编译期间所决定。 

[A Simple Example](https://www.tutorialspoint.com/objective_c/objective_c_polymorphism.htm) 

\- Dynamic Binding 

\> 动态绑定即方法的调用是在运行期所决定的，而不是在编译期。真因为有了动态绑定，所以才能支持多态性的实现。 

\### Classes 

\- initializing a method 

\> 在实例化一个对象之前，若我们需要做一些额外的操作，通常是一些```swizzle method```等runtime操作，我们便可以在```initialize```方法中处理。 

\- +load vs +initialize 

![](https://user-gold-cdn.xitu.io/2019/6/24/16b899d3747821f7) 

引用自：[Objective-C +load vs +initialize](http://blog.leichunfeng.com/blog/2015/05/02/objective-c-plus-load-vs-plus-initialize/) 