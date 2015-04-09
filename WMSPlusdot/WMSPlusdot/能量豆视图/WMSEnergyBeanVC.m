//
//  WMSEnergyBeanVC.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-28.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSEnergyBeanVC.h"
#import "WMSAppDelegate.h"
#import "WMSHowGetBeanVC.h"
#import "WMSDetailsVC.h"
#import "WMSMyAccessoryViewController.h"
#import "UIViewController+Tip.h"
#import "WMSBeanCell.h"
#import "MBProgressHUD.h"
#import "ExchangeBeanRule.h"
#import "WMSSportModel.h"
#import "WMSSportDatabase.h"
#import "WMSRequestTool.h"
#import "CacheClass.h"
#import "WMSMyAccessory.h"
#import "ArrayDataSource.h"
#import "WMSConstants.h"

#define BOTTOM_BUTTON_TITLE1                    @"领取"
#define BOTTOM_BUTTON_TITLE2                    @"如何获取能量豆?"
//const static NSTimeInterval reloadTimeInterval             = 60.f;
//const static NSUInteger TargetSteps                        = 10;//10步兑换1个能量豆

enum {
    SportSteps = 0,
    SleepDuration = 1,
};//tableView的第一行显示步数，第二行显示睡眠时长

@interface WMSEnergyBeanVC ()<MBProgressHUDDelegate>
{
    NSDate *_lastReloadDate;
    NSUInteger _currentBeans;//当前的能量豆
    NSUInteger _exchangedSteps;//已兑换过的步数
    NSUInteger _targetSteps;//几步兑换1个能量豆
    BOOL _postState;//用于领取能量豆时要发送的状态
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
    [self loadDataFromServer];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barStyle = UIBarStyleDefault;
    navBar.translucent = NO;
    
    [self reloadData];
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
//    [CacheClass cleanCacheData];
    NSDictionary *data = [CacheClass cachedExchangedStepsAndDateForMac:[WMSMyAccessory macForBindAccessory]];
    NSDate *savaDate = data[@"date"];
    if ([NSDate daysOfDuringDate:[NSDate systemDate] andDate:savaDate] == 0)
    {
        _exchangedSteps = [data[@"steps"] unsignedIntegerValue];
    } else {
        _exchangedSteps = 0;
    }
    _postState = NO;
}
- (void)setupUI
{
    self.title = NSLocalizedString(@"能量豆", nil);
    self.myBeanLabel.text = @"    我的能量豆: ";
    [self updateBottomButtonTitle];
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
- (void)loadDataFromServer
{
    if (![WMSMyAccessory isBindAccessory]) {
        return ;
    }

    [self showHUDAtViewCenter:nil];
    [WMSRequestTool requestExchangeRuleList:^(BOOL result, NSArray *list) {
        if (result) {
            for (ExchangeBeanRule *rule in list) {
                if (rule.ruleType == ExchangeBeanRuleTypeRuning) {
                    _targetSteps = rule.eventNumber;//
                }else{}
            }
            [WMSRequestTool requestUserBeansWithUserKey:[WMSMyAccessory macForBindAccessory] completion:^(BOOL result, int beans,NSError *error)
             {
                 if (result) {
                     _currentBeans = beans;
                     [self setMyBean:beans];
                     [CacheClass cacheMyBeans:beans mac:[WMSMyAccessory macForBindAccessory]];
                     [self hideHUDAtViewCenter];
                     [self reloadData];
                 }else{
                     [self hideHUDAtViewCenter];
                     [self showLoadFailedTip];
                 }
             }];
        } else {
            [self hideHUDAtViewCenter];
            [self showLoadFailedTip];
        }
    }];
}

- (void)reloadData
{
    DEBUGLog(@"perpheral mac : %@",[WMSMyAccessory macForBindAccessory]);
    if (![WMSMyAccessory isBindAccessory]) {
        [self.tableView reloadData];
        return ;
    }
    //若本地缓存的能量豆为0（没有缓存），则从网络请求数据
    int beans = [CacheClass cachedBeansForMac:[WMSMyAccessory macForBindAccessory]];
    if (beans <= 0) {
        [WMSRequestTool requestUserBeansWithUserKey:[WMSMyAccessory macForBindAccessory] completion:^(BOOL result, int beans,NSError *error)
         {
             if (result) {
                 _currentBeans = beans;
                 [self setMyBean:beans];
                 [CacheClass cacheMyBeans:beans mac:[WMSMyAccessory macForBindAccessory]];
             }else{}
         }];
        NSDictionary *data = [CacheClass cachedExchangedStepsAndDateForMac:[WMSMyAccessory macForBindAccessory]];
        NSDate *savaDate = data[@"date"];
        if ([NSDate daysOfDuringDate:[NSDate systemDate] andDate:savaDate] == 0)
        {
            _exchangedSteps = [data[@"steps"] unsignedIntegerValue];
        } else {
            _exchangedSteps = 0;
        }
    } else {
        _currentBeans = beans;
        [self setMyBean:beans];
    }
    
    [self.tableView reloadData];
}
- (void)updateBottomButtonTitle
{
    if (self.listData.count > 0) {
        [self.bottomButton setTitle:BOTTOM_BUTTON_TITLE1 forState:UIControlStateNormal];
    } else {
        [self.bottomButton setTitle:BOTTOM_BUTTON_TITLE2 forState:UIControlStateNormal];
    }
}
- (void)showLoadFailedTip
{
    UILabel *centerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 120.f)];
    centerLbl.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
    centerLbl.text = @"加载失败\n请检查您的网络，轻击屏幕重新加载";
    centerLbl.textAlignment = NSTextAlignmentCenter;
    centerLbl.numberOfLines = -1;
    centerLbl.userInteractionEnabled = YES;
    centerLbl.tag = 1001;
    [self.view addSubview:centerLbl];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedScreen:)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Actions
- (void)clickedScreen:(id)sender
{
    [self.view removeGestureRecognizer:sender];
    [[self.view viewWithTag:1001] removeFromSuperview];
    [self loadDataFromServer];
}

- (void)backAction:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)bottomButtonAction:(id)sender {
    if (self.listData.count == 0)
    {
        //跳转到如何获取能量豆界面
        WMSHowGetBeanVC *vc = [[WMSHowGetBeanVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return ;
    }
    
    NSInteger i = 0;
    NSUInteger willExchangeSteps = 0;
    NSUInteger willPostBeanNumber = _currentBeans;
    for (NSNumber *obj in self.listData) {
        if (i == SportSteps) {
            willExchangeSteps = [obj unsignedIntegerValue];
            NSUInteger beans = willExchangeSteps/_targetSteps;
            willPostBeanNumber += beans;
        }
        i++;
    }
    [self getsBeans:(int)willPostBeanNumber willExchangeSteps:willExchangeSteps];
}
- (void)getsBeans:(int)beans willExchangeSteps:(NSUInteger)steps
{
    [self showHUDAtViewCenter:nil];
    
    NSArray *results = [[WMSSportDatabase sportDatabase] querySportData:[NSDate systemDate]];
    NSUInteger sportSteps = 0;
    if (results.count > 0) {
        WMSSportModel *model = results[0];
        sportSteps = model.sportSteps;
    }else{}
    [WMSRequestTool requestGetBeanWithUserKey:[WMSMyAccessory macForBindAccessory] beanNumber:beans secretKey:SECRET_KEY stepNumber:(int)sportSteps state:_postState type:1 completion:^(BOOL result, int beans) {
        if (result) {
            [self setMyBean:beans];
            [CacheClass cacheMyBeans:beans mac:[WMSMyAccessory macForBindAccessory]];
            while (self.listData.count) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.listData removeObjectAtIndex:0];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            [self updateBottomButtonTitle];
            _postState = NO;
        } else {
            [self showTip:@"领取失败"];
        }
        [self hideHUDAtViewCenter];
    }];
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
    NSUInteger beans = steps/_targetSteps;
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
    
    //    if (indexPath.row == SportSteps) {
    //        NSUInteger steps = [self.listData[indexPath.row] unsignedIntegerValue];
    //        NSUInteger beans = steps/_targetSteps;
    //        _exchangedSteps += steps;
    //        numBeans += beans;
    //        [self getsBeans:(int)numBeans];
    //    }else{}
    //    [self.listData removeObjectAtIndex:indexPath.row];
    //    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self bottomButtonAction:nil];
}

#pragma mark -  Notifications
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beansDidOutOfDate:) name:WMSAppDelegateNewDay object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handelBindSuccess:) name:WMSBindAccessorySuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handelUnBindSuccess:) name:WMSUnBindAccessorySuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetNewGiftBag:) name:WMSGetNewGiftBag object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFirstSyncData:) name:NOTIFICATION_FIRST_SYNC_DATA object:nil];
    
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
- (void)appWillTerminate:(NSNotification *)notification
{
    [CacheClass cacheMyExchangedSteps:_exchangedSteps date:[NSDate systemDate] mac:[WMSMyAccessory macForBindAccessory]];
}
- (void)appDidEnterBackground:(NSNotification *)notification
{
    [CacheClass cacheMyExchangedSteps:_exchangedSteps date:[NSDate systemDate] mac:[WMSMyAccessory macForBindAccessory]];
}
- (void)handelBindSuccess:(NSNotification *)notification
{
    [self reloadData];
}
- (void)handelUnBindSuccess:(NSNotification *)notification
{
    [CacheClass cleanCacheData];
    [self setMyBean:0];
}
- (void)handleGetNewGiftBag:(NSNotification *)notification
{
    int beans = [CacheClass cachedBeansForMac:[WMSMyAccessory macForBindAccessory]];
    [self setMyBean:beans];
}
- (void)handleFirstSyncData:(NSNotification *)notification
{
    BOOL isHaveData = [notification.userInfo[@"isHaveData"] boolValue];
    _postState = !isHaveData;
}

@end
