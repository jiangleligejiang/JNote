
## 前言
> 本小节主要介绍```AppDelegate```的生命周期方法，以及launch screen的启动和```AppDelegate```模块化处理。

### Life Cycle
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
```
> 该方法表示程序已经启动，并准备允许，通常在该方法中进行一些初始化操作,比如root viewcontroller的定义，以及相关manager的初始化配置。可以通过launchOptions来获取到一些标志，比如可以根据```UIApplicationLaunchOptionsRemoteNotificationKey```来判断是否通过远程通知打开。

```objc
- (void)applicationDidBecomeActive:(UIApplication *)application
```
> 该方法表示从```inactive```转换为```active```状态，通常会做一些检查或刷新操作。

```objc
- (void)applicationDidEnterBackground:(UIApplication *)application
```
> 该方法表示程序进入到background状态下，通常会在该方法中进行释放资源或存储相关数据操作，可以通过```beginBackgroundTaskWithExpirationHandler```方法申请一些运行时间去做一些额外的操作。

```objc
- (void)applicationWillTerminate:(UIApplication *)application
```
> 该方法表示程序将要退出，通常会在该方法中进行一些释放或记录状态操作。

```objc
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
```
> 该方法表示程序的内存使用紧张，因此，该方法一般会进行一些释放内存操作，比如删除内存缓存等。

```objc
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
```
> 该方法表示程序通过```openURL```方式被打开。

### Launch Screen
- 通过xib的形式，创建静态的launch screen
> 这种方式会在```didFinishLaunchingWithOptions```之前就将launch screen加载完毕。但要注意替换launchscreen.xib中的图片时，需要重命名文件。

- 使用代码实现
> 这种方式会在```didFinishLaunchingWithOptions```中创建对应的launch screen视图。

### AppDelegate模块化
- 使用Category形式模块化

- 通过建立一个Mediator的形式，模块分别实现```UIApplicationDelegate```，然后注册到Mediator中，在```AppDelegate```中通过Mediator调用所有注册过的模块```UIApplicationDelegate```。

