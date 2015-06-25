//
//  WMSSettingVC.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-8.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSettingVC.h"
#import "WMSAppDelegate.h"
#import "WMSLoginViewController.h"
#import "WMSWebVC.h"
#import "WMSUpdateVC.h"
#import "UIViewController+Tip.h"
#import "UIViewController+Update.h"
#import "WMSAboutVC.h"

#import "WMSNavBarView.h"
#import "JSCustomBadge.h"
#import "MBProgressHUD.h"
#import "WMSDetailCell.h"

#import "WMSAppConfig.h"
#import "WMSConstants.h"
#import "WMSDeviceModel.h"
#import "WMSHTTPRequest.h"
#import "WMSHelper.h"

#define SECTION_NUMBER                  3
#define CELL_HEIGHT                     41.f
#define SECTION0_HEADER_HEIGHT          30.f
#define SECTION_HEADER_HEIGHT           20.f

@interface WMSSettingVC ()<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
{
    BOOL _isDetectedNewVersion;
    
    BOOL _isUpdateFirmware;
    NSString *_firmwareUpdateDesc;
    NSString *_firmwareUpdateURL;
    
    WMSUpdateVC *_updateVC;
    
    CGFloat tableViewTotalHeight;
}
@property (nonatomic, strong) NSArray *section0TitleArray;
@property (nonatomic, strong) NSArray *section1TitleArray;
@end

@implementation WMSSettingVC

#pragma mark - Getter/Setter
- (NSArray *)section0TitleArray
{
    if (!_section0TitleArray) {
        _section0TitleArray = @[NSLocalizedString(@"我的账户", nil)];
    }
    return _section0TitleArray;
}
- (NSArray *)section1TitleArray
{
    if (!_section1TitleArray) {
        _section1TitleArray = @[
                                //NSLocalizedString(@"故障排除", nil),
                                //NSLocalizedString(@"常见问题", nil),
                                //NSLocalizedString(@"适配机型", nil),
                                //NSLocalizedString(@"APP版本", nil),
                                NSLocalizedString(@"固件版本", nil),
                                //@"关于",
                                ];
    }
    return _section1TitleArray;
}

- (BOOL)isNeedUpdateView
{
    return _needUpdateView;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupProperty];
    [self setupNavigationBar];
    [self setupTableView];
    [self setupUI];
    [self registerForNotifications];
    
    //[self checkAppUpdate];
    [self checkFirmwareUpdate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.isNeedUpdateView) {
        [self.tableView reloadData];
        self.needUpdateView = NO;
    }
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

#pragma mark - setup UI
- (void)setupProperty
{
    
}
- (void)setupNavigationBar
{
    self.title = NSLocalizedString(@"设置",nil);
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem defaultItemWithTarget:self action:@selector(backAction:)];
//    UINavigationBar *navBar = self.navigationController.navigationBar;
//    navBar.barStyle = UIBarStyleDefault;
//    navBar.translucent = NO;
}
- (void)setupTableView
{
    self.tableView.rowHeight = CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    CGFloat totalHeight = 0;
    NSInteger sections = self.tableView.numberOfSections;
    for (int i=0; i<sections-1; i++) {
        totalHeight += [self.tableView rectForSection:i].size.height;
    }
    totalHeight += [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sections-1]].size.height;
    tableViewTotalHeight = totalHeight;
}
- (void)setupUI
{
    self.view.backgroundColor = UIColorFromRGBAlpha(0xEEEEEE, 1.0);
}

#pragma mark - Private
- (void)checkAppUpdate
{
    UIWindow *window = [WMSAppDelegate appDelegate].window;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:window];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.minSize = CGSizeMake(250, 120);
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"正在检测新版本...", nil);
    [window addSubview:hud];
    [hud show:YES];
    [self checkUpdateWithAPPID:APP_ID completion:^(DetectResultValue isCanUpdate)
    {
        if (isCanUpdate == DetectResultUnknown) {
            hud.labelText = NSLocalizedString(@"网络不给力，稍后再试试吧", nil);
            [hud hide:YES afterDelay:1.0];
        } else if (isCanUpdate == DetectResultCanNotUpdate) {
            hud.labelText = NSLocalizedString(@"已是最新版本", nil);
            [hud hide:YES afterDelay:1.0];
        } else if (isCanUpdate == DetectResultCanNotUpdate) {
            [hud hide:YES afterDelay:0];
            [self showUpdateAlertViewWithTitle:ALERTVIEW_TITLE message:ALERTVIEW_MESSAGE cancelButtonTitle:ALERTVIEW_CANCEL_TITLE okButtonTitle:ALERTVIEW_OK_TITLE];
        }
    }];
}
- (void)checkFirmwareUpdate
{
    BOOL res = [[WMSAppDelegate appDelegate].wmsBleControl isConnected];
    if (res == NO) {
        return ;
    }
    [WMSHTTPRequest detectionFirmwareUpdate:^(double newVersion, NSString *describe, NSString *strURL)
     {
         DEBUGLog(@"firmware curVersion:%f, newVersion:%f",[WMSDeviceModel deviceModel].version,newVersion);
         //DEBUGLog(@"describe:%@, url:%@",describe,strURL);
         //newVersion = 100.0;
         if ([WMSDeviceModel deviceModel].version < newVersion) {
             [WMSHTTPRequest downloadFirmwareUpdateFileStrURL:strURL completion:^(BOOL success)
              {
                  //do something
                  DEBUGLog(@"下载%@",success?@"成功":@"失败");
                  if (success) {
                      _isUpdateFirmware = YES;
                      _firmwareUpdateDesc = describe;
                      _firmwareUpdateURL = strURL;
                      [self.tableView reloadData];
                  } else {
                      _isUpdateFirmware = NO;
                      _firmwareUpdateDesc = @"";
                      _firmwareUpdateURL = @"";
                  }
              }];
         } else {
             _isUpdateFirmware = NO;
             _firmwareUpdateDesc = @"";
             _firmwareUpdateURL = @"";
         }
     }];
}

- (BOOL)isExistBadgeOfView:(UITableViewCell *)cell
{
    //DEBUGLog(@"cell subviews:%@",cell.contentView.subviews);
    if ([cell class] == [WMSDetailCell class]) {
        for (UIView *view in [cell.contentView subviews]) {
            if ([view class] == [JSCustomBadge class]) {
                return YES;
            }
        }
    }
    return NO;
}
- (void)view:(UITableViewCell *)cell addBadge:(JSCustomBadge *)badge
{
    if ([cell class] == [WMSDetailCell class]) {
        WMSDetailCell *detaileCell = (WMSDetailCell *)cell;
        CGRect frame = badge.frame;
        frame.origin.x = detaileCell.frame.size.width-30-frame.size.width;
        frame.origin.y = (detaileCell.frame.size.height-frame.size.height)/2.0;
        badge.frame = frame;
        
        [detaileCell.contentView addSubview:badge];//注意将子视图加在cell的contentView中，而不是cell中
    }
}
- (void)removeBadgeFromView:(UITableViewCell *)cell
{
    if ([cell class] == [WMSDetailCell class]) {
        for (UIView *view in [cell.contentView subviews]) {
            if ([view class] == [JSCustomBadge class]) {
                [view removeFromSuperview];
            }
        }
    }
}

- (NSDictionary *)imageNameWithTableView:(UITableView *)tableView cellIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger rowCount = [tableView numberOfRowsInSection:indexPath.section];
    NSString *imageName = @"";
    NSString *selectedImageName = @"";
    if (rowCount == 1) {
        imageName = @"setting_vc_bg_a.png";
        selectedImageName = @"setting_vc_bg_b.png";
    } else if (rowCount == 2) {
        if (row == 0) {
            imageName = @"zq_light_list_top_a.png";
            selectedImageName = @"zq_light_list_top_b.png";
        } else {
            imageName = @"zq_light_list_bottom_a.png";
            selectedImageName = @"zq_light_list_bottom_b.png";
        }
    } else if (rowCount > 2) {
        if (row == 0) {
            imageName = @"zq_light_list_top_a.png";
            selectedImageName = @"zq_light_list_top_b.png";
        } else if (row == rowCount-1) {
            imageName = @"zq_light_list_bottom_a.png";
            selectedImageName = @"zq_light_list_bottom_b.png";
        } else {
            imageName = @"zq_light_list_middle_a.png";
            selectedImageName = @"zq_light_list_middle_b.png";
        }
    }
    return @{@"image":imageName,@"selectedImage":selectedImageName};
}

- (void)showActionSheet
{
    //警告
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:NSLocalizedString(@"退出登录", nil) otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Action
- (void)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)exitLogin
{
    [self showActionSheet];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    hud = nil;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//destructive
        if ([WMSAppConfig clearLoginInfo]) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [self.section0TitleArray count];
        case 1:
            return [self.section1TitleArray count];
        case 2:
            return 1;
        default:
            break;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    WMSDetailCell *cell = nil;
    if (section==0 || section==1) {
        NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",(int)section,(int)row];
        UINib *cellNib = [UINib nibWithNibName:@"WMSDetailCell" bundle:nil];
        [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
        NSDictionary *dic = [self imageNameWithTableView:tableView cellIndexPath:indexPath];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dic[@"image"]]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dic[@"selectedImage"]]];
    }
    switch (section) {
        case 0:
        {
            cell.leftLabel.text = [self.section0TitleArray objectAtIndex:row];
            cell.leftLabel.font = Font_System(15.0);
            cell.rightLabel.text = @"";
            cell.rightLabel.font = Font_System(12.0);
            if (row == 0) {
                if ([WMSAppConfig isHaveLogin]) {
                    cell.rightLabel.text = [WMSAppConfig loginUserName];
                } else {
                    cell.rightLabel.text = NSLocalizedString(@"点击此处登录", nil);
                }
            }
            return cell;
        }
        case 1:
        {
            cell.leftLabel.text = [self.section1TitleArray objectAtIndex:row];
            cell.leftLabel.font = Font_System(15.0);
            cell.rightLabel.text = @"";
            cell.rightLabel.font = Font_System(12.0);
//            if (row == 3-3) {
//                if ([self isDetectedNewVersion]==DetectResultCanUpdate/* ||
//                    YES*/) {
//                    if ([self isExistBadgeOfView:cell] == NO) {
//                        JSCustomBadge *badge = [JSCustomBadge customBadgeWithString:@"New"];
//                        [self view:cell addBadge:badge];
//                    }
//                } else {
//                    [self removeBadgeFromView:cell];
//                    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
//                    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
//                    cell.rightLabel.text = currentVersion;//NSLocalizedString(@"已是最新版本", nil);
//                }
//            }
            /*else*/ if (row == 4-3-1) {
                if (_isUpdateFirmware/* || YES*/) {
                    if ([self isExistBadgeOfView:cell] == NO) {
                        JSCustomBadge *badge = [JSCustomBadge customBadgeWithString:@"New"];
                        [self view:cell addBadge:badge];
                    }
                } else {
                    [self removeBadgeFromView:cell];
                    NSString *strVer = @"";
                    if ([WMSAppDelegate appDelegate].wmsBleControl.isConnected) {
                        double version = [WMSDeviceModel deviceModel].version;
                        strVer = [NSString stringWithFormat:@"%.01f",version];
                    } else {
                        strVer = @"unknown";
                    }
                    cell.rightLabel.text = strVer;
                }
            }
            return cell;
        }
        case 2:
        {
            NSString *Identifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            }
            cell.textLabel.text = NSLocalizedString(@"退出登录", nil);
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_btn_a.png"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_btn_b.png"]];
            BOOL res = [WMSAppConfig isHaveLogin];
            if (res) {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.backgroundView.alpha = 1.0;
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundView.alpha = 0.7;
            }
            return cell;
        }
        default:
            return nil;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CELL_HEIGHT;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return SECTION0_HEADER_HEIGHT;
        case 1:
            return SECTION_HEADER_HEIGHT;
        case 2:
            return tableView.bounds.size.height-tableViewTotalHeight-10-(NavBar_IS_Translucent?NAV_BAR_HEIGHT:0);
        default:
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView cellForRowAtIndexPath:indexPath].selectionStyle == UITableViewCellSelectionStyleNone) {
        return ;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
        case 0:
        {
            if (row == 0) {
                if ([WMSAppConfig isHaveLogin]==NO/* || YES*/) {
                    WMSLoginViewController *vc = [[WMSLoginViewController alloc] init];
                    vc.skipMode = SkipModeDissmiss;
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    nav.navigationBarHidden = YES;
                    [self presentViewController:nav animated:YES completion:^{
                        self.needUpdateView = YES;
                    }];
                }
            }
            break;
        }
        case 1:
        {
            switch (row) {
                case 0:
                {
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    if ([self isExistBadgeOfView:cell]/* ||YES*/) {
                        //........
                        _updateVC = [[WMSUpdateVC alloc] init];
                        _updateVC.title = self.section1TitleArray[row];
                        _updateVC.updateDescribe = _firmwareUpdateDesc;
                        self.navigationController.delegate = self;
                        [self.navigationController pushViewController:_updateVC animated:YES];
                    }
                    break;
                }
                case 1:
                {
                    WMSAboutVC *aboutVC = [[WMSAboutVC alloc] init];
                    aboutVC.title = self.section1TitleArray[row];
                    [self.navigationController pushViewController:aboutVC animated:YES];
                }
                    
                default:
                    break;
            }
            break;
        }
        case 2:
        {
            [self exitLogin];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self && _updateVC) {
        if (_updateVC.isUpdateSuccess) {
            _isUpdateFirmware = NO;
            [self.tableView reloadData];
        }
        _updateVC = nil;
        self.navigationController.delegate = nil;
    }
}

#pragma mark - Notification
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
}
- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    [self.tableView reloadData];
}

@end
