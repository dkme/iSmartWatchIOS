//
//  WMSGiftVC.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-28.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSGiftVC.h"
#import "WMSDetailsVC.h"
#import "WMSAppDelegate.h"
#import "GGTopMenu.h"
#import "WMSLeftViewCell.h"
#import "KOPopupView.h"
#import "WMSAlertView.h"
#import "UILabel+Attribute.h"
#import "UITableViewCell+Activity.h"
#import "Activity.h"
#import "ActivityRule.h"
#import "GiftBag.h"
#import "WMSRequestTool.h"
#import "ArrayDataSource.h"

typedef enum {
    TopMenuItemActivity = 0,
    TopMenuItemGiftBag  = 1,
}TopMenuItem;

@interface WMSGiftVC ()<WMSAlertViewDelegate>
@property (nonatomic, strong) ArrayDataSource *arrayDataSource;
@property (nonatomic, strong) ArrayDataSource *arrayDataSource2;
@property (nonatomic, strong) KOPopupView *koPopupView;
@property (nonatomic, strong) NSMutableArray *activityList;
@property (nonatomic, strong) NSMutableArray *giftBagList;
@end

@implementation WMSGiftVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupProperty];
    [self setupView];
    [self setupNavigationBar];
    [self setupTopMenu];
    [self setupTableView];
    [self loadDataWithItem:TopMenuItemActivity];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barStyle = UIBarStyleDefault;
    navBar.translucent = NO;
    
    
    [WMSRequestTool requestActivityDetailsWithActivityID:5 completion:^(BOOL result, ActivityRule *rult) {
        DEBUGLog(@"result %d , rult %@",result,[rult description]);
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}

#pragma mark - setup
- (void)setupProperty
{
    _activityList = [NSMutableArray new];
    _giftBagList = [NSMutableArray new];
    
    //test
//    Activity *act = [[Activity alloc] initWithID:1 actName:@"test" beginDate:[NSDate systemDate] endDate:[NSDate systemDate] memo:@"test memo" gameName:@"game" logo:@"logo"];
//    [self.activityList addObject:act];
//    NSMutableArray *copyList = [self.activityList mutableCopy];
//    DEBUGLog(@"list:%@, copyList:%@",self.activityList,copyList);
//    //[self.activityList removeAllObjects];
//    act.actID = 100;
//    
//    DEBUGLog(@"modifed list:%@, copyList:%@",self.activityList,copyList);
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
    self.tableView.backgroundColor = UIColorFromRGBAlpha(0xEEEEEE, 1.0);
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
                    GiftBag *bag = [[GiftBag alloc] init];
                    bag.exchangeCode = items[indexPath.row];
                    bag.getDate = [NSDate systemDate];
                    bag.logo = @"";
                    [cell configureCellWithGiftBag:bag];
                    return cell;
                };
                _arrayDataSource2 = [[ArrayDataSource alloc] initWithItems:@[@"aa",@"bb"] configureTableViewBlock:configureTableCell];
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
            [WMSRequestTool requestActivityList:^(BOOL result, NSArray *list) {
                [self.activityList removeAllObjects];
                [self.activityList addObjectsFromArray:list];
                [self.arrayDataSource setItems:self.activityList];
                [self.tableView reloadData];
            }];
            break;
        }
        case TopMenuItemGiftBag:
        {
            [WMSRequestTool requestGiftBagListWithUserKey:@"test" completion:^(BOOL result, NSArray *list) {
                [self.giftBagList removeAllObjects];
                [self.giftBagList addObjectsFromArray:list];
                [self.tableView reloadData];
            }];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Action
- (void)backAction:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

#pragma mark - GGTopMenuDelegate
- (void)topMenu:(GGTopMenu *)topMenu didSelectItem:(NSInteger)item
{
    DEBUGLog(@"item:%d, selectedIndex:%d",item,topMenu.selectedItemIndex);
    [self configureCell:item];
}
#pragma mark - WMSAlertViewDelegate
- (void)alertView:(WMSAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            DEBUGLog(@"复制");
            [[UIPasteboard generalPasteboard] setPersistent:YES];
            [[UIPasteboard generalPasteboard] setValue:@"xxxxx" forPasteboardType:UIPasteboardTypeListString[0]];
            break;
        case 1:
            DEBUGLog(@"取消");
            break;
        default:
            break;
    }
    [self.koPopupView hideAnimated:YES],self.koPopupView = nil;
}

#pragma mark - UITableViewDelegate
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
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
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case TopMenuItemGiftBag:
        {
            NSString *code = [NSString stringWithFormat:@"code-%d",indexPath.row];
            [self showAlertViewWithCode:code];
            break;
        }
        default:
            break;
    }
}

- (void)showAlertViewWithCode:(NSString *)code
{
    if (!self.koPopupView) {
        WMSAlertView *alertView = [WMSAlertView alertViewWithText:@"龙武游戏礼包" detailText:@"" leftButtonTitle:NSLocalizedString(@"复制兑换码", nil) rightButtonTitle:NSLocalizedString(@"取消", nil)];
        NSArray *attrisArr = @[@{NSForegroundColorAttributeName:[UIColor blackColor]},
                               @{NSForegroundColorAttributeName:UICOLOR_DEFAULT},
                               ];
        NSString *text = [NSString stringWithFormat:@"兑换码为: /%@/ \n此礼包可在%@激活\n 激活后将获得游戏道具",code,@"adress"];
        [alertView.detailTextLabel setSegmentsText:text separateMark:@"/" attributes:attrisArr];
        alertView.frame = [alertView updateSubviews];
        alertView.delegate = self;
        alertView.center = self.tableView.center;
    
        KOPopupView *popupView = [KOPopupView popupView];
        [popupView.handleView addSubview:alertView];
        self.koPopupView = popupView;
    }
    [self.koPopupView show];
}

@end
