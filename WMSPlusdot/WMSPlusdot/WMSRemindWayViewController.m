//
//  WMSRemindWayViewController.m
//  WMSPlusdot
//
//  Created by Sir on 14-10-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSRemindWayViewController.h"

#define SECTION_NUMBER              1
#define SECTION_FOOTER_HEIGHT       1

@interface WMSRemindWayViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *textArray;

@end

@implementation WMSRemindWayViewController

#pragma mark - Getter
- (NSArray *)textArray
{
    if (!_textArray) {
        _textArray = [[NSArray alloc] initWithObjects:
                      NSLocalizedString(@"不提醒",nil),
                      NSLocalizedString(@"震动",nil),
                      NSLocalizedString(@"响铃",nil),
                      NSLocalizedString(@"震动+响铃",nil),
                      nil];
    }
    return _textArray;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;

    //UIImage *image = [UIImage imageNamed:@"back_btn_a.png"];
    //UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonItemAction:)];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil) style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonItemAction:)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"同步", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonItemAction:)];
    self.navigationItem.leftBarButtonItems = @[leftItem];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark - Action
- (void)leftButtonItemAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightButtonItemAction:(id)sender
{
    DEBUGLog(@"rightButtonItemAction");
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.textArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self.textArray objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_FOOTER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return SECTION_FOOTER_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    for (int i=0; i<[self.textArray count]; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:path];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    UITableViewCell *checkedCell=[self.tableView cellForRowAtIndexPath:indexPath];
    [checkedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

@end
