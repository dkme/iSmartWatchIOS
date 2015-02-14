//
//  WMSEnergyBeanVC.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-28.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSEnergyBeanVC.h"
#import "WMSAppDelegate.h"
#import "WMSBeanCell.h"
#import "WMSSportModel.h"
#import "WMSSportDatabase.h"
#import "WMSMyAccessory.h"
#import "ArrayDataSource.h"

//const static NSTimeInterval reloadTimeInterval             = 60.f;
const static NSUInteger TargetSteps                        = 10;

enum {
    SportSteps = 0,
    SleepDuration = 1,
};//tableView的第一行显示步数，第二行显示睡眠时长
static NSUInteger numBeans = 0;
@interface WMSEnergyBeanVC ()
{
    NSDate *_lastReloadDate;
    NSUInteger _exchangedSteps;//已兑换过的步数
}
@property (nonatomic, strong) NSMutableArray *listData;
@end

@implementation WMSEnergyBeanVC

#pragma mark - Getter/Setter
- (void)setMyBean:(NSUInteger)bean
{
    NSString *format = [NSString stringWithFormat:@"    %@",NSLocalizedString(@"我的能量豆: %d",nil)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:format,bean] attributes:nil];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    UIImage *image = [UIImage imageNamed:@"plusdot_gift_bean_small.png"];
    textAttachment.image = image;
    textAttachment.bounds = CGRectMake(2.0, -2.0, 15.0, 15.0);
    NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [str appendAttributedString:textAttachmentString];
    self.myBeanLabel.attributedText = str;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupProperty];
    [self setupUI];
    [self setupNavigationBar];
    [self setupTableView];
    [self registerForNotifications];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barStyle = UIBarStyleDefault;
    navBar.translucent = NO;
    
    [self reloadData];
}
- (void)viewDidDisappear:(BOOL)animated
{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
    [self unregisterFromNotifications];
}

#pragma mark - Setup
- (void)setupProperty
{
    _listData = [NSMutableArray new];
    [self setMyBean:0];
}
- (void)setupUI
{
    self.title = NSLocalizedString(@"能量豆", nil);
}
- (void)setupNavigationBar
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"main_menu_icon_a.png" highImageName:@"main_menu_icon_b.png" target:self action:@selector(backAction:)];
}
- (void)setupTableView
{
    self.tableView.backgroundColor = UIColorFromRGBAlpha(0xEEEEEE, 1.0);
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 44.f;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

#pragma mark - Other
- (void)reloadData
{
    DEBUGLog(@"perpheral mac : %@",[WMSMyAccessory macForBindAccessory]);
    if (![WMSMyAccessory isBindAccessory]) {
        [self.tableView reloadData];
        return ;
    }
    //从数据库中查询数据
    [self.listData removeAllObjects];
    NSArray *results = [[WMSSportDatabase sportDatabase] querySportData:[NSDate systemDate]];
    if (results.count > 0) {
        WMSSportModel *model = results[0];
        NSUInteger unExchangeSteps = model.sportSteps-_exchangedSteps;
        NSUInteger showSteps = (unExchangeSteps/TargetSteps)*TargetSteps;
        if (showSteps >= TargetSteps) {
            [self.listData addObject:@(showSteps)];
        }else{};
    }else{};
    [self.tableView reloadData];
}

#pragma mark - Actions
- (void)backAction:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)bottomButtonAction:(id)sender {
    if (self.listData.count == 0) {
        return ;
    }
    [self getsBeans];
    while (self.listData.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.listData removeObjectAtIndex:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
- (void)getsBeans
{
    NSInteger i = 0;
    for (NSNumber *obj in self.listData) {
        if (i == SportSteps) {
            _exchangedSteps += [obj unsignedIntegerValue];
            NSUInteger beans = _exchangedSteps/TargetSteps;
            numBeans += beans;
        }
    }
    [self setMyBean:numBeans];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"WMSBeanCell"];
    WMSBeanCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WMSBeanCell" owner:self options:nil] lastObject];
    }
    NSUInteger steps = [self.listData[indexPath.row] unsignedIntegerValue];
    NSString *content = [NSString stringWithFormat:@"完成%lu步",(unsigned long)steps];
    NSUInteger beans = steps/TargetSteps;
    [cell configureWithContent:content beans:beans];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [tableView rectForHeaderInSection:section].size.height;
    CGRect frame = CGRectMake(0, 0, ScreenWidth, height);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.text = @"请先绑定您的手表";
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.font = Font_System(12.0);
    titleLabel.numberOfLines = -1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    if (![WMSMyAccessory isBindAccessory]) {
        [view addSubview:titleLabel];
    }
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger steps = [self.listData[indexPath.row] unsignedIntegerValue];
    NSUInteger beans = steps/TargetSteps;
    _exchangedSteps += steps;
    numBeans += beans;
    [self setMyBean:numBeans];
    [self.listData removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -  Notifications
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beansDidOutOfDate:) name:WMSAppDelegateNewDay object:nil];
}
- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)beansDidOutOfDate:(NSNotification *)notification
{
    _exchangedSteps = 0;
    [self reloadData];
}

@end
