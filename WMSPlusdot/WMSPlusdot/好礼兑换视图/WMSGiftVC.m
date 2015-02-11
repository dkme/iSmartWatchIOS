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
#import "ArrayDataSource.h"
#import "KOPopupView.h"
#import "WMSAlertView.h"
#import "UILabel+Attribute.h"

typedef enum {
    TopMenuItemActivity = 0,
    TopMenuItemGiftBag  = 1,
}TopMenuItem;

@interface WMSGiftVC ()<WMSAlertViewDelegate>
@property (nonatomic, strong) ArrayDataSource *arrayDataSource;
@property (nonatomic, strong) ArrayDataSource *arrayDataSource2;
@property (nonatomic, strong) KOPopupView *koPopupView;
@end

@implementation WMSGiftVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupView];
    [self setupNavigationBar];
    [self setupTopMenu];
    [self setupTableView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barStyle = UIBarStyleDefault;
    navBar.translucent = NO;
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
- (void)setupView
{
    self.title = NSLocalizedString(@"好礼兑换", nil);
    self.view.backgroundColor = UIColorFromRGBAlpha(0xEEEEEE, 1.0);
}
- (void)setupNavigationBar
{
    //self.navigationItem.leftBarButtonItem = [UIBarButtonItem defaultItemWithTarget:self action:@selector(backAction:)];
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
    self.tableView.backgroundColor = UIColorFromRGBAlpha(0xEEEEEE, 1.0);
    [self configureCell:TopMenuItemActivity];
}
- (void)configureCell:(TopMenuItem)item
{
    switch (item) {
        case TopMenuItemActivity:
        {
            if (!self.arrayDataSource) {
                TableViewCellConfigureBlock configureCell = ^(UITableViewCell *cell, NSString *item) {
                    cell.textLabel.text = item;
                };
                _arrayDataSource = [[ArrayDataSource alloc] initWithItems:@[@"11",@"22"] cellIdentifier:@"cellIdentifier" configureCellBlock:configureCell];
            }
            self.tableView.dataSource = self.arrayDataSource;
            [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
            break;
        }
        case TopMenuItemGiftBag:
        {
            if (!self.arrayDataSource2) {
                TableViewCellConfigureBlock configureCell = ^(UITableViewCell *cell, NSString *item) {
                    cell.textLabel.text = item;
                };
                _arrayDataSource2 = [[ArrayDataSource alloc] initWithItems:@[@"aa",@"bb"] cellIdentifier:@"cellIdentifier" configureCellBlock:configureCell];
            }
            self.tableView.dataSource = self.arrayDataSource2;
            [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
            break;
        }
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - Action
- (void)backAction:(id)sender
{
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    [self.koPopupView hideAnimated:YES];
    self.koPopupView = nil;
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
            if (!self.koPopupView) {
                KOPopupView *popupView = [KOPopupView popupView];
                WMSAlertView *alertView = [WMSAlertView alertViewWithText:@"龙武游戏礼包" detailText:@"" leftButtonTitle:NSLocalizedString(@"复制兑换码", nil) rightButtonTitle:NSLocalizedString(@"取消", nil)];
                NSArray *attrisArr = @[@{NSForegroundColorAttributeName:[UIColor blackColor]},
                                       @{NSForegroundColorAttributeName:UICOLOR_DEFAULT},
                                       ];
                [alertView.detailTextLabel setSegmentsText:@"兑换码为: /xxx-xxxx-xxx/ \n此礼包可在《龙武》长安大街激活\n 激活后将获得游戏道具" separateMark:@"/" attributes:attrisArr];
                alertView.frame = [alertView updateSubviews];
                alertView.delegate = self;
                alertView.center = self.tableView.center;
                [popupView.handleView addSubview:alertView];
                self.koPopupView = popupView;
            }
            [self.koPopupView show];
            
            break;
        }
        default:
            break;
    }
}

@end
