## 一、视Objective-C为一门动态语言
### 1.Objective-C、C和C++的关系
> Objective-C和C++都是在C基础上加上面向对象特性扩充而成的程序设计语言。**Objective-C是基于动态运行时类型，而C++基于静态类型。即Objective-C编写的程序不是直接翻译成二进制，而是在程序运行时，通过运行时把程序转译为二进制。而C++是在编译时，直接编译成二进制。**

### 2.静态语言和动态语言的不同
- 执行效率问题
> 静态语言执行效率通常比动态语言要高，因为一部分CPU计算耗损在运行时系统过程中。

- 安全性问题
> 动态语言由于运行时系统环境的需求，会保留一些源码级别的程序结构。这样可能会存在一些安全隐患。**因此，若需要编写涉及到安全性较高的代码，应该使用C替换Objective-C。**

## 二、在头文件中尽量减少其他头文件的引用
### 1. `@class`使用
> 使用`@class`代替`#import`，以降低类之间的耦合度，以及避免循环引用问题。

## 三、尽量使用`const`、`enum`来替换预处理`#define`
### 1. `#define`的弊端
> `#define`预处理命令不包含任何类型信息，仅仅在编译前做替换操作。它们在重复定义时，不会发出警告，容易导致不一致的值出现。

### 2. 常量命名规范
> 若需要在`.h`文件中定义常量，则应该使用它们的类名作为命名前缀。

## 四、尽量使用模块方式与多类建立复合关系
### 1.`#include`和`#import`的区别
> `#include`方法是直接将头文件内容复制到当前文件，存在重复引用的问题，而`#import`会通过`#ifndef`的方式对头文件进行标志判断，从而避免了重复引用问题。