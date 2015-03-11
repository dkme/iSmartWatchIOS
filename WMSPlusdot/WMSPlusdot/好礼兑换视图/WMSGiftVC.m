//
//  WMSGiftVC.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-28.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSGiftVC.h"
#import "WMSDetailsVC.h"
#import "WMSMyAccessoryViewController.h"
#import "WMSAppDelegate.h"
#import "GGTopMenu.h"
#import "WMSLeftViewCell.h"
#import "KOPopupView.h"
#import "WMSAlertView.h"
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"
#import "UILabel+Attribute.h"
#import "UITableViewCell+Configure.h"
#import "Activity.h"
#import "ActivityRule.h"
#import "GiftBag.h"
#import "WMSRequestTool.h"
#import "CacheClass.h"
#import "ArrayDataSource.h"
#import "WMSMyAccessory.h"

typedef enum {
    TopMenuItemActivity = 0,
    TopMenuItemGiftBag  = 1,
}TopMenuItem;

@interface WMSGiftVC ()<WMSAlertViewDelegate,MBProgressHUDDelegate,EGORefreshTableHeaderDelegate>
{
    BOOL _reloading;
    BOOL _isForceLoadGiftBagDatas;
    BOOL _isNewGiftBag;
}
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, strong) ArrayDataSource *arrayDataSource;
@property (nonatomic, strong) ArrayDataSource *arrayDataSource2;
@property (nonatomic, strong) KOPopupView *koPopupView;
@property (nonatomic, strong) NSMutableArray *activityList;
@property (nonatomic, strong) NSMutableArray *giftBagList;
@end

@implementation WMSGiftVC

#pragma mark - Getter/Setter
- (EGORefreshTableHeaderView *)refreshHeaderView
{
    if (!_refreshHeaderView) {
        //DEBUGLog(@"ScreenWidth %f, bounds width %f",ScreenWidth,self.view.bounds.size.width);
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.tableView.frame.size.height, self.view.bounds.size.width, self.tableView.frame.size.height)];
        _refreshHeaderView.delegate = self;
    }
    return _refreshHeaderView;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupProperty];
    [self setupView];
    [self setupNavigationBar];
    [self setupTopMenu];
    [self setupTableView];
    [self loadDataFromServer];
    [self registerForNotifications];
    
    [self.refreshHeaderView refreshLastUpdatedDate];
    [self.refreshHeaderView forceToRefresh:self.tableView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barStyle = UIBarStyleDefault;
    navBar.translucent = NO;
    
    
    //    [WMSRequestTool requestActivityDetailsWithActivityID:5 completion:^(BOOL result, ActivityRule *rult) {
    //        DEBUGLog(@"result %d , rult %@",result,[rult description]);
    //    }];
    
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

#pragma mark - setup
- (void)setupProperty
{
    _activityList = [NSMutableArray new];
    _giftBagList = [NSMutableArray new];
    _reloading = NO;
    _isForceLoadGiftBagDatas = NO;
    _isNewGiftBag = NO;
}
- (void)setupView
{
    self.title = NSLocalizedString(@"好礼兑换", nil);
    self.view.backgroundColor = UIColorFromRGBAlpha(0xEEEEEE, 1.0);
}
- (void)setupNavigationBar
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"main_menu_icon_a.png" highImageName:@"main_menu_icon_b.png" target:self action:@selector(backAction:)];
}
- (void)setupTopMenu
{
    NSArray *items = @[NSLocalizedString(@"兑换活动", nil),
                       NSLocalizedString(@"我的礼包", nil),
                       ];
    self.topMenu.delegate = self;
    self.topMenu.backgroundColor = [UIColor whiteColor];
    self.topMenu.tintColor = UICOLOR_DEFAULT;
    self.topMenu.tintSize = CGSizeMake(100, 2);
    self.topMenu.separatorColor = [UIColor lightGrayColor];
    self.topMenu.titleColor = [UIColor blackColor];
    [self.topMenu setItems:items selectedItem:0];
}
- (void)setupTableView
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 60.f;
    self.tableView.backgroundColor = [UIColor whiteColor];//UIColorFromRGBAlpha(0xEEEEEE, 1.0);
    [self.tableView addSubview:self.refreshHeaderView];
    [self configureCell:TopMenuItemActivity];
}
- (void)configureCell:(TopMenuItem)item
{
    switch (item) {
        case TopMenuItemActivity:
        {
            static NSString *cellIdentifier = @"activityCell";
            if (!self.arrayDataSource) {
                TableViewCellConfigureBlock configureCell = ^(UITableViewCell *cell, Activity *item) {
                    [cell configureCellWithActivity:item];
                };
                _arrayDataSource = [[ArrayDataSource alloc] initWithItems:self.activityList cellIdentifier:cellIdentifier configureCellBlock:configureCell];
            }
            self.tableView.dataSource = self.arrayDataSource;
            [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
            break;
        }
        case TopMenuItemGiftBag:
        {
            if (!self.arrayDataSource2) {
                TableViewConfigureBlock configureTableCell = ^id(UITableView *tableView, NSIndexPath *indexPath, NSArray *items)
                {
                    static NSString *cellIdentifier = @"giftBagCell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
                    }
                    GiftBag *bag = (GiftBag *)items[indexPath.row];
                    [cell configureCellWithGiftBag:bag];
                    return cell;
                };
                _arrayDataSource2 = [[ArrayDataSource alloc] initWithItems:self.giftBagList configureTableViewBlock:configureTableCell];
            }
            self.tableView.dataSource = self.arrayDataSource2;
            break;
        }
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - Other
- (void)loadDataWithItem:(TopMenuItem)item
{
    switch (item) {
        case TopMenuItemActivity:
        {
            [WMSRequestTool requestActivityList:^(BOOL result, NSArray *list, NSError *error) {
                if (result) {
                    [self.activityList removeAllObjects];
                    [self.activityList addObjectsFromArray:list];
                    [self.arrayDataSource setItems:self.activityList];
                    [self.tableView reloadData];
                } else {
                    [self showLoadFailTip];
                }
                [self doneLoadingTableViewData];
            }];
            break;
        }
        case TopMenuItemGiftBag:
        {
            [WMSRequestTool requestGiftBagListWithUserKey:[WMSMyAccessory macForBindAccessory] completion:^(BOOL result, NSArray *list, NSError *error) {
                if (result) {
                    [self.giftBagList removeAllObjects];
                    [self.giftBagList addObjectsFromArray:list];
                    [self.arrayDataSource2 setItems:self.giftBagList];
                    [self.tableView reloadData];
                } else{
                    [self showLoadFailTip];
                }
                [self doneLoadingTableViewData];
            }];
            break;
        }
        default:
            break;
    }
}
- (void)loadDataFromServer
{
    [WMSRequestTool requestUserBeansWithUserKey:[WMSMyAccessory macForBindAccessory] completion:^(BOOL result, int beans,NSError *error)
     {
         if (result) {
             [CacheClass cacheMyBeans:beans mac:[WMSMyAccessory macForBindAccessory]];
         }else{}
     }];
}
- (void)showLoadFailTip
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"加载失败";
    [self.view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}

#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource
{
    _reloading = YES;
    [self loadDataWithItem:self.topMenu.selectedItemIndex];
    
}
- (void)doneLoadingTableViewData
{
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _reloading = NO;
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        [self.tableView reloadData];
    });
}

#pragma mark - Action
- (void)backAction:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
}

#pragma mark - GGTopMenuDelegate
- (void)topMenu:(GGTopMenu *)topMenu didSelectItem:(NSInteger)item
{
    [self doneLoadingTableViewData];
    [self configureCell:(TopMenuItem)item];
    if (!_isForceLoadGiftBagDatas) {
        double delayInSeconds = .5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.refreshHeaderView forceToRefresh:self.tableView];
        });
        _isForceLoadGiftBagDatas = YES;
    }else{}
    if (_isNewGiftBag && item == TopMenuItemGiftBag) {
        double delayInSeconds = .2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.refreshHeaderView forceToRefresh:self.tableView];
        });
        [topMenu hideBadgeFromItem:item];
        _isNewGiftBag = NO;
    }
}
#pragma mark - WMSAlertViewDelegate
- (void)alertView:(WMSAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            DEBUGLog(@"复制");
            NSString *value = alertView.code;
            [[UIPasteboard generalPasteboard] setPersistent:YES];
            [[UIPasteboard generalPasteboard] setValue:value forPasteboardType:UIPasteboardTypeListString[0]];
            break;
        }
        case 1:
            DEBUGLog(@"取消");
            break;
        default:
            break;
    }
    [self.koPopupView hideAnimated:YES],self.koPopupView = nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2.f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColorFromRGBAlpha(0xEEEEEE, 1.0);
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView cellForRowAtIndexPath:indexPath].selectionStyle ==
        UITableViewCellSelectionStyleNone) {
        return ;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (self.topMenu.selectedItemIndex) {
        case TopMenuItemActivity:
        {
            WMSDetailsVC *vc = [[WMSDetailsVC alloc] init];
            Activity *activity = self.activityList[indexPath.row];
            vc.activity = [activity copy];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            vc.icon = cell.imageView.image;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case TopMenuItemGiftBag:
        {
            GiftBag *bag = self.giftBagList[indexPath.row];
            //NSString *code = [NSString stringWithFormat:@"%@",bag.exchangeCode];
            [self showAlertViewWithTitle:bag.gameName code:bag.exchangeCode memo:bag.memo];
            break;
        }
        default:
            break;
    }
}

- (void)showAlertViewWithTitle:(NSString *)title code:(NSString *)code memo:(NSString *)memo
{
    if (!self.koPopupView) {
        WMSAlertView *alertView = [WMSAlertView alertViewWithText:title detailText:@"" leftButtonTitle:NSLocalizedString(@"复制兑换码", nil) rightButtonTitle:NSLocalizedString(@"取消", nil)];
        NSArray *attrisArr = @[@{NSForegroundColorAttributeName:[UIColor blackColor]},
                               @{NSForegroundColorAttributeName:UICOLOR_DEFAULT},
                               ];
        NSString *text = [NSString stringWithFormat:@"兑换码为: /%@/ \n%@",code,memo];
        [alertView.detailTextLabel setSegmentsText:text separateMark:@"/" attributes:attrisArr];
        alertView.delegate = self;
        alertView.frame = [alertView updateSubviews];
        alertView.center = self.tableView.center;
        alertView.code = code;
        
        KOPopupView *popupView = [KOPopupView popupView];
        [popupView.handleView addSubview:alertView];
        self.koPopupView = popupView;
    }
    [self.koPopupView show];
}

#pragma mark - EGORefreshTableHeaderDelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
}
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.refreshHeaderView egoRefreshScrollViewWillBeginScroll:scrollView];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -  Notifications
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewGiftBag:) name:WMSGetNewGiftBag object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUnBindSuccess:) name:WMSUnBindAccessorySuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBindSuccess:) name:WMSBindAccessorySuccess object:nil];
}
- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)getNewGiftBag:(NSNotification *)notification
{
    //[self.topMenu showBadge:@"New" forItem:TopMenuItemGiftBag];
    _isNewGiftBag = YES;
}
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    [self loadDataWithItem:TopMenuItemGiftBag];
    [self loadDataFromServer];
}
- (void)handleBindSuccess:(NSNotification *)notification
{
    [self loadDataWithItem:TopMenuItemGiftBag];
}
- (void)handleUnBindSuccess:(NSNotification *)notification
{
    [self loadDataWithItem:TopMenuItemGiftBag];
}

@end
