//
//  WMSHowGetBeanVC.m
//  WMSPlusdot
//
//  Created by Sir on 15-2-6.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSHowGetBeanVC.h"
#import "ExchangeBeanRule.h"
#import "UITableViewCell+Configure.h"
#import "WMSRequestTool.h"

@interface WMSHowGetBeanVC ()
@property (nonatomic, strong) NSArray *datas;
@end

@implementation WMSHowGetBeanVC

#pragma mark - Getter/Setter

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.title = NSLocalizedString(@"如何获取能量豆", nil);
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorColor = [UIColor whiteColor];
    
    [self loadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}

#pragma mark - Load data
- (void)loadData
{
    [WMSRequestTool requestExchangeRuleList:^(BOOL result, NSArray *list) {
        if (result) {
            self.datas = list;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuseIdentifier"];
    }
    [cell configureCellWithExchangeBeanRule:self.datas[indexPath.row] indexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
@end
