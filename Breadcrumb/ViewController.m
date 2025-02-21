//
//  ViewController.m
//  Breadcrumb
//
//  Created by autophix on 2025/1/20.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIScrollView *breadcrumbView;
@property (nonatomic, strong) NSMutableArray<NSString *> *navigationStack;
@property (nonatomic, strong) NSArray<NSString *> *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationStack = [NSMutableArray arrayWithObject:@"Root"];
    self.dataArray = [self fetchDataForPath:self.navigationStack];
    [self setupTableView];
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0; // 移除 iOS 15+ 的 Header 顶部额外间距
    }
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)updateBreadcrumbView {
    if (!self.breadcrumbView) {
        self.breadcrumbView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        self.breadcrumbView.backgroundColor = UIColor.redColor;
        self.breadcrumbView.showsHorizontalScrollIndicator = NO;
    }

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

        if (i < self.navigationStack.count - 1) {
            UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ICON_arrow"]];
            arrowImageView.frame = CGRectMake(xOffset, 10, 12, 20);
            [self.breadcrumbView addSubview:arrowImageView];
            xOffset += 20;
        }
    }
}

- (NSArray<NSString *> *)fetchDataForPath:(NSArray<NSString *> *)path {
    NSInteger currentLevel = path.count;
    NSMutableArray<NSString *> *subItems = [NSMutableArray array];

    for (int i = 1; i <= 100; i++) {
        [subItems addObject:[NSString stringWithFormat:@"第%ld层-Item%d", (long)currentLevel, i]];
    }

    return subItems;
}

- (void)breadcrumbTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    [self.navigationStack removeObjectsInRange:NSMakeRange(index + 1, self.navigationStack.count - index - 1)];
    self.dataArray = [self fetchDataForPath:self.navigationStack];
    [self updateBreadcrumbView];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    cell.textLabel.text = self.dataArray[indexPath.section];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.breadcrumbView;
    } else {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.navigationStack.count > 1 ? 40 : CGFLOAT_MIN;
    } else {
        return CGFLOAT_MIN;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedItem = self.dataArray[indexPath.section];
    [self.navigationStack addObject:selectedItem];
    self.dataArray = [self fetchDataForPath:self.navigationStack];
    [self updateBreadcrumbView];
    [self.tableView reloadData];
}

@end
