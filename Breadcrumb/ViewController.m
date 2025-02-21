//
//  ViewController.m
//  Breadcrumb
//
//  Created by autophix on 2025/1/20.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIScrollView *breadcrumbView;                // 面包屑导航栏
@property (nonatomic, strong) UITableView *tableView;                      // 列表
@property (nonatomic, strong) NSMutableArray<NSString *> *navigationStack; // 路径栈
@property (nonatomic, strong) NSArray<NSString *> *currentItems;           // 当前层级数据
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 初始化导航路径（从根路径开始）
    self.navigationStack = [NSMutableArray arrayWithObject:@"Root"];
    
    // 动态生成当前层级数据
    self.currentItems = [self fetchDataForPath:self.navigationStack];
    
    // 创建列表
    [self setupTableView];
    [self updateBreadcrumbView];
}

#pragma mark - Setup Methods

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    // 在 tableView 上设置 tableHeaderView
    self.tableView.tableHeaderView = self.breadcrumbView;
}

#pragma mark - Breadcrumb Management

- (void)updateBreadcrumbView {
    // 如果没有 breadcrumbView, 初始化它
    if (!self.breadcrumbView) {
        self.breadcrumbView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        self.breadcrumbView.backgroundColor = UIColor.redColor;
        self.breadcrumbView.showsHorizontalScrollIndicator = NO;
    }
    
    // 清空当前视图
    [self.breadcrumbView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat xOffset = 10;
    for (NSInteger i = 0; i < self.navigationStack.count; i++) {
        NSString *title = self.navigationStack[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:title forState:UIControlStateNormal];
        button.tag = i;
        [button sizeToFit];
        button.frame = CGRectMake(xOffset, 5, button.frame.size.width, 30);
        [button addTarget:self action:@selector(breadcrumbTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.breadcrumbView addSubview:button];
        
        xOffset += button.frame.size.width + 10;
        
        // 添加箭头（图片）
        if (i < self.navigationStack.count - 1) {
            UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ICON_arrow"]];
            arrowImageView.frame = CGRectMake(xOffset, 10, 12, 20); // 适当调整位置
            [self.breadcrumbView addSubview:arrowImageView];
            xOffset += 20; // 为箭头留出间距
        }
    }
    
    // 设置内容大小
    self.breadcrumbView.contentSize = CGSizeMake(xOffset, 40);
        
    // 第一层时也显示面包屑，确保面包屑视图始终有高度
    if (self.navigationStack.count > 1) {
        self.tableView.tableHeaderView = self.breadcrumbView;
        // 自动滚动到最后
        if (xOffset > self.breadcrumbView.frame.size.width) {
            CGFloat scrollOffset = xOffset - self.breadcrumbView.frame.size.width;
            [self.breadcrumbView setContentOffset:CGPointMake(scrollOffset, 0) animated:YES];
        } else {
            [self.breadcrumbView setContentOffset:CGPointZero animated:YES];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        // 保证 breadcrumbView 在第一层时仍然显示
        [self.breadcrumbView setContentOffset:CGPointZero animated:YES];
    }
}


- (NSArray<NSString *> *)fetchDataForPath:(NSArray<NSString *> *)path  {
    NSInteger currentLevel = path.count; // 当前层级，从 1 开始
    NSMutableArray<NSString *> *subItems = [NSMutableArray array];
    // 动态生成子级数据
    for (int i = 1; i <= 3; i++) {
        [subItems addObject:[NSString stringWithFormat:@"第%ld层-Item%d", (long)currentLevel, i]];
    }
    
    return subItems;
}

- (void)breadcrumbTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    
    // 截断路径栈到点击的层级
    [self.navigationStack removeObjectsInRange:NSMakeRange(index + 1, self.navigationStack.count - index - 1)];
    
    // 动态加载对应层级数据
    self.currentItems = [self fetchDataForPath:self.navigationStack];
    
    // 刷新界面
    [self updateBreadcrumbView];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.currentItems[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedItem = self.currentItems[indexPath.row];
    
    // 更新路径栈
    [self.navigationStack addObject:selectedItem];
    
    // 动态加载下一级数据
    self.currentItems = [self fetchDataForPath:self.navigationStack];
    
    // 刷新界面
    [self updateBreadcrumbView];
    [self.tableView reloadData];
}

@end
