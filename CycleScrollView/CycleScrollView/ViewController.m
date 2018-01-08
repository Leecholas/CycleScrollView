//
//  ViewController.m
//  CycleScrollView
//
//  Created by Leecholas on 2018/1/2.
//  Copyright © 2018年 Leecholas. All rights reserved.
//

#import "ViewController.h"
#import "CycleTableViewCell.h"
#import <SafariServices/SafariServices.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,CycleTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSourceArray;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_tableView) {
        [[_tableView visibleCells] enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CycleTableViewCell *cell = obj;
            [cell startTimer];
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"demo";
    [self setupData];
    [self setupUI];
}

- (void)setupUI {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kSystemTopHeight, kScreenWidth, kScreenHeight - kSystemTopHeight) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:_tableView];
}

- (void)setupData {
    _dataSourceArray = @[@{@"imageArray":@[@"0",@"1",@"2",@"3"],
                           @"linkUrl":@[@"http://gundam.wikia.com/wiki/Over_the_Rainbow",
                                        @"http://gundam.wikia.com/wiki/RX-0_Unicorn_Gundam",
                                        @"http://gundam.wikia.com/wiki/RX-0_Full_Armor_Unicorn_Gundam",
                                        @"http://gundam.wikia.com/wiki/NZ-666_Kshatriya"]}];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CycleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cycle"];
    if (!cell) {
        cell = [[CycleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cycle"];
        cell.delegate = self;
    }
    [cell showCycleImageWithImageArray:[_dataSourceArray firstObject][@"imageArray"] section:indexPath.section];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScreenWidth * 228 / 750;
}

#pragma mark - CycleTableViewCellDelegate
- (void)cycleTableViewCell:(CycleTableViewCell *)cycleCell TapActionWithIndex:(NSInteger)index {
    SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[_dataSourceArray firstObject][@"linkUrl"][index]]];
    [self.navigationController pushViewController:vc animated:YES];
    [cycleCell stopTimer];
}

@end
