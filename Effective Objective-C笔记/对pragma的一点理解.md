## 对pragma的一点理解
> pragma在OC开发中是非常常用的，它主要包括两大功能：使用pragma mark组织代码和忽略一些编译器中不必要的警告.

### pragma mark 使用
> 通常我们会将代码划分为一个个组来进行管理，比如与UIViewController生命周期相关、Button点击事件、UITableView的委托方法等等。

```objc
#import "PragmaDemo.h"
#define CellIdentifier  @"CellIdentifier"

@interface PragmaDemo() <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *data;
@end

@implementation PragmaDemo

#pragma mark - VC生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = @[@"cell1", @"cell2", @"cell3"];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView;
    });
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - Button点击事件
- (void)buttonDidClick:(UIButton *)sender {
    NSLog(@"btn was clicked");
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = self.data[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell %ld did click.", indexPath.row);
}

@end
```
我们可以在x-code非常便捷地查看该类方法

![image](http://note.youdao.com/yws/res/2304/WEBRESOURCE1c910f1ac2a9f04777731c52a1f56901)

### 使用pragma忽略编译器一些不必要的警告

>  使用方式:<br>
>  #pragma clang diagnostic push <br>
>  #pragma clang diagnostic ignored - "忽略警告内容" <br>
>  do something...<br>
>  #pragma clang diagnostic pop

```objc
SEL sel = self.data[indexPath.row].selector;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
[self performSelector:sel];
#pragma clang diagnostic pop
```
如上，假如我们没有使用pragma的话，则编译器会提示"PerformSelector may cause a leak because its selector is unknown"。

- 完整示例

```objc
#import "PragmaDemo.h"
#define CellIdentifier  @"CellIdentifier"

@interface SelectorModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) SEL selector;
@end

@implementation SelectorModel
+ (SelectorModel *)withTitle:(NSString *)title sel:(SEL)selector {
    SelectorModel *model = [SelectorModel new];
    model.title = title;
    model.selector = selector;
    return model;
}
@end

@interface PragmaDemo() <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<SelectorModel *> *data;
@end

@implementation PragmaDemo

#pragma mark - VC生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = @[[SelectorModel withTitle:@"selector1" sel:@selector(selector1)],
                  [SelectorModel withTitle:@"selector2" sel:@selector(selector2)]];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView;
    });
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - Button点击事件
- (void)buttonDidClick:(UIButton *)sender {
    NSLog(@"btn was clicked");
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = self.data[indexPath.row].title;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell %ld did click.", indexPath.row);
    SEL sel = self.data[indexPath.row].selector;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:sel];
#pragma clang diagnostic pop
}

#pragma mark - Selector
- (void)selector1 {
    NSLog(@"%s", __FUNCTION__);
}

- (void)selector2 {
    NSLog(@"%s", __FUNCTION__);
}
@end

```
