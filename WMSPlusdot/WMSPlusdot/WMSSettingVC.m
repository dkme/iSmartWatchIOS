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

#import "WMSNavBarView.h"
#import "JSCustomBadge.h"
#import "MBProgressHUD.h"
#import "WMSDetailCell.h"

#import "WMSAppConfig.h"
#import "WMSConstants.h"
#import "WMSDeviceModel.h"
#import "WMSHTTPRequest.h"
#import "WMSHelper.h"

#define SECTION_NUMBER                  2
#define SECTION0_HEADER_HEIGHT          30.f
#define SECTION_HEADER_HEIGHT           20.f

@interface WMSSettingVC ()<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,UIActionSheetDelegate>
{
    BOOL _isDetectedNewVersion;
    
    BOOL _isUpdateFirmware;
    NSString *_firmwareUpdateDesc;
    NSString *_firmwareUpdateURL;
}
@property (nonatomic, strong) NSArray *section0TitleArray;
@property (nonatomic, strong) NSArray *section1TitleArray;
@property (nonatomic, strong) UIButton *buttonExitLogin;
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
        _section1TitleArray = @[NSLocalizedString(@"故障排除", nil),
                                NSLocalizedString(@"常见问题", nil),
                                NSLocalizedString(@"适配机型", nil),
                                NSLocalizedString(@"版本更新", nil),
                                NSLocalizedString(@"固件更新", nil),
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
    [self setupNavBarView];
    [self setupTableView];
    [self setupUI];
    
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
}

#pragma mark - setup UI
- (void)setupNavBarView
{
    self.navBarView.backgroundColor = UICOLOR_DEFAULT;
    self.navBarView.labelTitle.text = NSLocalizedString(@"设置",nil);
    self.navBarView.labelTitle.font = Font_DINCondensed(20.0);
    [self.navBarView.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_a.png"] forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_b.png"] forState:UIControlStateHighlighted];
    [self.navBarView.buttonLeft addTarget:self action:@selector(buttonLeftClicked:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)setupTableView
{
    CGRect frame = self.tableView.frame;
    frame.size.width = 305;
    frame.origin.x = (ScreenWidth-frame.size.width)/2.0;
    self.tableView.frame = frame;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
- (void)setupUI
{
    self.view.backgroundColor = UIColorFromRGBAlpha(0xEEEEEE, 1.0);
    
    _buttonExitLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect buttonFrame = CGRectZero;
    buttonFrame.size = CGSizeMake(315, 45);
    buttonFrame.origin.x = (self.tableView.frame.size.width-buttonFrame.size.width)/2.0;
    buttonFrame.origin.y = self.tableView.frame.size.height-buttonFrame.size.height-30;
    if (!iPhone5) {
        buttonFrame.origin.y -= (568-480);
    }
    _buttonExitLogin.frame = buttonFrame;
    [_buttonExitLogin setTitle:NSLocalizedString(@"退出登录", nil) forState:UIControlStateNormal];
    [_buttonExitLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buttonExitLogin setBackgroundImage:[UIImage imageNamed:@"zq_public_red_btn_a.png"] forState:UIControlStateNormal];
    [_buttonExitLogin setBackgroundImage:[UIImage imageNamed:@"zq_public_red_btn_b.png"] forState:UIControlStateSelected];
    [_buttonExitLogin addTarget:self action:@selector(exitLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:self.buttonExitLogin];
}

#pragma mark - Private
- (void)checkAppUpdate
{
    //NSInteger a=[self isDetectedNewVersion];
    //DEBUGLog(@"^^^^^%@----->%d[%p]",[self class],[self isDetectedNewVersion],&(a));
    UIWindow *window = [WMSAppDelegate appDelegate].window;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:window];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.minSize = CGSizeMake(250, 120);
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"正在检测新版本...", nil);
    [window addSubview:hud];
    [hud show:YES];
    [self checkUpdateWithAPPID:@"930839162" completion:^(DetectResultValue isCanUpdate)
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
        //return ;
    }
    [WMSHTTPRequest detectionFirmwareUpdate:^(double newVersion, NSString *describe, NSString *strURL)
     {
         DEBUGLog(@"firmware curVersion:%f, newVersion:%f",[WMSDeviceModel deviceModel].version,newVersion);
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
        for (UIView *view in [cell subviews]) {
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
- (void)buttonLeftClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)exitLoginAction:(id)sender
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
            
        default:
            break;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",(int)section,(int)row];
    UINib *cellNib = [UINib nibWithNibName:@"WMSDetailCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    WMSDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *dic = [self imageNameWithTableView:tableView cellIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dic[@"image"]]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dic[@"selectedImage"]]];
    
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
            if (row == 3) {
                if ([self isDetectedNewVersion]==DetectResultCanUpdate/* ||
                    YES*/) {
                    if ([self isExistBadgeOfView:cell] == NO) {
                        JSCustomBadge *badge = [JSCustomBadge customBadgeWithString:@"New"];
                        [self view:cell addBadge:badge];
                    }
                } else {
                    [self removeBadgeFromView:cell];
                    cell.rightLabel.text = NSLocalizedString(@"已是最新版本", nil);
                }
            } else if (row == 4) {
                if (_isUpdateFirmware/* || YES*/) {
                    if ([self isExistBadgeOfView:cell] == NO) {
                        JSCustomBadge *badge = [JSCustomBadge customBadgeWithString:@"New"];
                        [self view:cell addBadge:badge];
                    }
                } else {
                    [self removeBadgeFromView:cell];
                    cell.rightLabel.text = NSLocalizedString(@"已是最新版本", nil);
                }
            }
            return cell;
        }
        default:
            return nil;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return SECTION0_HEADER_HEIGHT;
        case 1:
            return SECTION_HEADER_HEIGHT;
        default:
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
                    WMSWebVC *vc = [[WMSWebVC alloc] init];
                    vc.navBarTitle = self.section1TitleArray[row];
                    vc.strRequestURL = @"http://www.lepao.com/faq-mobile.html";
                    //[self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 3:
                {
                    if ([self isDetectedNewVersion]==DetectResultUnknown) {
                        [self checkAppUpdate];
                    }
                    break;
                }
                case 4:
                {
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    if ([self isExistBadgeOfView:cell] /*||YES*/) {
                        //........
                        WMSUpdateVC *vc = [[WMSUpdateVC alloc] init];
                        vc.navBarTitle = self.section1TitleArray[row];
                        vc.updateDescribe = _firmwareUpdateDesc;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
}

@end
