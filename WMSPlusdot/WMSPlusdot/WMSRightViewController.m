//
//  WMSRightViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-21.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSRightViewController.h"
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "UIViewController+Tip.h"
#import "WMSAppDelegate.h"
#import "WMSAntiLostVC.h"
#import "WMSClockListVC.h"
#import "WMSUpdateVC.h"
#import "GGIViewController.h"

#import "WMSSwitchCell.h"
#import "MBProgressHUD.h"

#import "WMSPostNotificationHelper.h"
#import "WMSMyAccessory.h"
#import "WMSConstants.h"
#import "WMSSoundOperation.h"

#import "GGDeviceTool.h"
#import "WMSDeviceModel.h"
#import "WMSDeviceModel+Configure.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#define SECTION_NUMBER                          5-1
#define SECTION0_HEADER_HEIGHT                  50.f
#define SECTION_HEADER_HEIGHT                   40.f
#define SECTION_HEADER_DEFAULT_HEIGHT           0.1f
#define SECTION_FOOTER_DEFAULT_HEIGHT           0.1f
#define CELL_CONTENT_PREFIX                     @"                   "

#define ANTI_LOST_DISTANCE                      60

#define PLAY_ALERT_DURATION                     8.0
#define PLAY_VIBRATE_TIMEINTERVAL               1.0

@interface WMSRightViewController ()<WMSSwitchCellDelegage,RESideMenuDelegate,GGIViewControllerDelegate>

@property (strong, nonatomic) NSArray *section1TitleArray;
@property (strong, nonatomic) NSArray *section2TitleArray;
@property (strong, nonatomic) NSArray *section3TitleArray;
@property (strong, nonatomic) NSArray *section4TitleArray;
@property (strong, nonatomic) NSArray *section5TitleArray;
@property (strong, nonatomic) NSArray *headerTitleArray;

@property (strong, nonatomic) WMSBleControl *bleControl;
@property (strong, nonatomic) GGIViewController *pickerController;

@end

@implementation WMSRightViewController
{
    WMSSoundOperation *_soundOperation;
    
    CTCallCenter *_callCenter;
    
    int _configIndex;
    BOOL _isVisible;
    BOOL _isNeedConfig;
}

#pragma mark - Property Getter Method
- (NSArray *)section1TitleArray
{
    if (!_section1TitleArray) {
        _section1TitleArray = @[
                                NSLocalizedString(@"Phone",nil),
                                NSLocalizedString(@"SMS",nil),
                                //NSLocalizedString(@"Email",nil),
                                NSLocalizedString(@"Battery",nil),
                                ];
    }
    return _section1TitleArray;
}
- (NSArray *)section2TitleArray
{
    if (!_section2TitleArray) {
        _section2TitleArray = @[
                                NSLocalizedString(@"Wechat",nil),
                                NSLocalizedString(@"QQ",nil),
                                NSLocalizedString(@"Skype",nil),
                                NSLocalizedString(@"WhatsApp",nil),
                                NSLocalizedString(@"Facebook",nil),
                                NSLocalizedString(@"Twitter",nil),
                                ];
    }
    return _section2TitleArray;
}
- (NSArray *)section3TitleArray
{
    if (!_section3TitleArray) {
        _section3TitleArray = @[
                                NSLocalizedString(@"震动",nil),
                                ];
    }
    return _section3TitleArray;
}
- (NSArray *)section4TitleArray
{
    if (!_section4TitleArray) {
        _section4TitleArray = @[NSLocalizedString(@"防丢",nil),
                                ];
    }
    return _section4TitleArray;
}
- (NSArray *)section5TitleArray
{
    if (!_section5TitleArray) {
        _section5TitleArray = @[
                                NSLocalizedString(@"拍照",nil)
                                ];
    }
    return _section5TitleArray;
}
- (NSArray *)headerTitleArray
{
    if (!_headerTitleArray) {
        _headerTitleArray = @[NSLocalizedString(@"Remind Setting",nil),
                              //NSLocalizedString(@"社交",nil),
                              NSLocalizedString(@"提醒方式",nil),
                              NSLocalizedString(@"其他",nil),
                              @"",
                              ];
    }
    return _headerTitleArray;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sideMenuViewController.delegate = self;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    
    [self setupProperty];
    [self setupTableView];
    
    [self listeningCall];
    [self registerForNotifications];
}
- (void)didReceiveMemoryWarning
{
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
    self.bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    _soundOperation = [[WMSSoundOperation alloc] init];
    
}
- (void)setupTableView
{
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tintColor = UICOLOR_DEFAULT;
}

#pragma mark - Helper
//#pragma mark - 电量
- (void)batteryOperation:(float)battery
{
    if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging) {
        return ;
    }
    if ([WMSRightVCHelper isSendLowBatteryRemind:battery]) {
        if ([WMSRightVCHelper lowBatteryRemind]) {
            [WMSRightVCHelper startLowBatteryRemind:self.bleControl.settingProfile completion:^{
                [WMSPostNotificationHelper postLowBatteryLocalNotification];
            }];
        }
    }
}

#pragma mark - 监听来电/按键
- (void)listeningCall
{
//    __weak __typeof(&*self) weakSelf = self;
//    _callCenter = [[CTCallCenter alloc] init];
//    _callCenter.callEventHandler = ^(CTCall* call) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        WMSSwitchCell *cell = (WMSSwitchCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
//        BOOL on = cell.mySwitch.on;
//        if ([call.callState isEqualToString:CTCallStateDisconnected])
//        {
//            DEBUGLog(@"Call has been disconnected");
//            if (on) {
//                [weakSelf.bleControl.settingProfile finishRemind:OtherRemindTypeCall completion:^(BOOL success) {
//                    
//                }];
//            }
//        }
//        else if ([call.callState isEqualToString:CTCallStateConnected])
//        {
//            DEBUGLog(@"Call has just been connected");
//            if (on) {
//                [weakSelf.bleControl.settingProfile finishRemind:OtherRemindTypeCall completion:^(BOOL success) {
//                    
//                }];
//            }
//        }
//        else if([call.callState isEqualToString:CTCallStateIncoming])
//        {
//            DEBUGLog(@"Call is incoming");
//            if (on) {
//                [weakSelf.bleControl.settingProfile startRemind:OtherRemindTypeCall completion:^(BOOL success) {
//                    DEBUGLog(@"开启电话提醒成功");
//                }];
//            }
//        }
//        else if ([call.callState isEqualToString:CTCallStateDialing])
//        {
//            DEBUGLog(@"call is dialing");
//        }
//        else
//        {
//            DEBUGLog(@"Nothing is done");
//        }
//    };
}

#pragma mark - 遥控拍照
- (GGIViewController *)openCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return nil;
    }
    GGIViewController *picker = [[GGIViewController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        picker.textLabel.adjustsFontSizeToFitWidth = YES;
        picker.textLabel.text = NSLocalizedString(@"请按下手表上的确认键拍照...", nil);
    }];
    return picker;
}
- (void)openPhotoLibrary
{
    UIImagePickerControllerSourceType sourceType;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return ;
    }
    
    sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.allowsEditing=YES;
    picker.delegate = nil;
    picker.navigationBar.barStyle = UIBarStyleDefault;
    picker.navigationBar.translucent = NO;
    
    [self.pickerController presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Notification
- (void)registerForNotifications
{
    //监测电量
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteyChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidDisConnectPeripheral:) name:WMSBleControlPeripheralDidDisConnect object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralDidEndDFU:) name:WMSUpdateVCEndDFU object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOperationDeviceButton:) name:OperationDeviceButtonNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDevicePowerChanged:) name:DevicePowerChangedNotification object:nil];

}
- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)batteyChanged:(NSNotification *)notification
{
    UIDevice *device = notification.object;
    DEBUGLog(@">>>battery:%f",device.batteryLevel);
    [self batteryOperation:device.batteryLevel];
}
//Ble
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    if (_isVisible || _isNeedConfig) {
        [WMSRightVCHelper startFirstConnectedConfig:self.bleControl.settingProfile completion:^{
            [self.tableView reloadData];
        }];
    }
    float battery = [[UIDevice currentDevice] batteryLevel];
    [self batteryOperation:battery];
    
    self.pickerController.textLabel.text = NSLocalizedString(@"请按下手表上的确认键拍照...", nil);
}

- (void)handleDidDisConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"self.pickerController:%@",self.pickerController);
    [self hideHUDAtViewCenter];
    self.pickerController.textLabel.text = NSLocalizedString(@"正在尝试重新连接...", nil);
}

- (void)peripheralDidEndDFU:(NSNotification *)notification
{
    //进行初始化配置
    _isNeedConfig = YES;
    [WMSRightVCHelper resetFirstConnectedConfig];
}

- (void)handleOperationDeviceButton:(NSNotification *)notification
{
    NSString *operation = notification.userInfo[@"operation"];
    if ([OperationTakePhoto isEqualToString:operation]) {
        [self.pickerController takePhoto];
    }
}

- (void)handleDevicePowerChanged:(NSNotification *)notification
{
    NSUInteger powerPercent = [notification.object unsignedIntegerValue];
    //TODO 比较电量是否低于指定值
    if (powerPercent <= WATCH_LOW_BATTERY) {
        [self.bleControl.settingProfile setRemindWay:RemindWayNot completion:^(BOOL isSuccess) {
            DEBUGLog_DETAIL(@"设置提醒方式%d", isSuccess);
            if (isSuccess) {
                [WMSRightVCHelper savaRemindWay:RemindWayNot];
            }
        }];
    }
}

#pragma mark - RESideMenuDelegate
- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    if ( [self class] == [menuViewController class] ) {
        sideMenu.scaleContentView = NO;
        [self.tableView reloadData];
    } else {
        sideMenu.scaleContentView = YES;
    }
}
- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    if ([self class] == [menuViewController class]) {
        sideMenu.scaleContentView = YES;
    }
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    if ( [self class] == [menuViewController class] ) {
        _isVisible = YES;
        if ([self.bleControl isConnected]) {
            [WMSRightVCHelper startFirstConnectedConfig:self.bleControl.settingProfile completion:nil];
        }
//        AccessoryGeneration g = [WMSMyAccessory generationForBindAccessory];
//        if ([WMSMyAccessory isBindAccessory]) {
//            switch (g) {
//                case AccessoryGenerationONE:
//                    
//                    break;
//                    
//                default:
//                    break;
//            }
//        }
    }
}
- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    if ([self class] == [menuViewController class]) {
        _isVisible = NO;
    }
}

#pragma mark - GGIViewControllerDelegate
- (void)GGIViewController:(GGIViewController *)viewController didClickImage:(UIImage *)image
{
    [self openPhotoLibrary];
}
- (void)GGIViewControllerDidClose:(GGIViewController *)viewController
{
    self.pickerController.delegate = nil;
    self.pickerController = nil;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.section1TitleArray.count;
//        case 1:
//            return self.section2TitleArray.count;
        case 2-1:
            return self.section3TitleArray.count;
        case 3-1:
            return self.section4TitleArray.count;
        case 4-1:
            return self.section5TitleArray.count;
        default:
            break;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
//        case 1:
        case 2-1:
        //case 3-1:
        {
            NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",(int)indexPath.section,(int)indexPath.row];
            UINib *cellNib = [UINib nibWithNibName:@"WMSSwitchCell" bundle:nil];
            [self.tableView registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
            WMSSwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            NSString *text = nil;
            BOOL on = NO;
            
            if (indexPath.section == 0)
            {
                text = [self.section1TitleArray objectAtIndex:indexPath.row];
                if (indexPath.row == self.section1TitleArray.count-1) {//电池
                    on = [WMSRightVCHelper lowBatteryRemind];
                } else {
                    NSString *key = [self settingKeyFromIndexPath:indexPath];
                    if (key) {
                        on = [(NSNumber*)[WMSRightVCHelper loadSettingItemDataOfKey:key] boolValue];
                    }
                }
            }
//            else if (indexPath.section == 1)
//            {
//                text = [self.section2TitleArray objectAtIndex:indexPath.row];
//                NSString *key = [self settingKeyFromIndexPath:indexPath];
//                if (key) {
//                    on = [(NSNumber*)[WMSRightVCHelper loadSettingItemDataOfKey:key] boolValue];
//                }
//            }
            else if (indexPath.section == 2-1)
            {
                text = [self.section3TitleArray objectAtIndex:indexPath.row];
                on = [WMSRightVCHelper loadRemindWay];
            }
//            else if (indexPath.section == 3-1)
//            {
//                text = [self.section4TitleArray objectAtIndex:indexPath.row];
//                on = [WMSRightVCHelper loadLost];
//            }
            
            if (![self.bleControl isConnected]) {
                on = NO;
            }
            [cell configureCellWithText:text switchOn:on];
            cell.delegate = self;
            
            return cell;
        }
        case 2:
        case 4-1:
        {
            NSString *cellIdentifier = [NSString stringWithFormat:@"section%d%d",(int)indexPath.section,(int)indexPath.row];
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_b.png"]];

            NSString *txt = @"";
            if (indexPath.section == 2) {
                txt = self.section4TitleArray[indexPath.row];
            } else {
                txt = self.section5TitleArray[indexPath.row];
            }
            cell.textLabel.text = [CELL_CONTENT_PREFIX stringByAppendingString:txt];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = Font_DINCondensed(18);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return SECTION0_HEADER_HEIGHT;
//        case 1:
        case 2-1:
            return SECTION_HEADER_HEIGHT;
        case 3-1:
            return SECTION_HEADER_HEIGHT;
        case 4-1:
            return SECTION_HEADER_DEFAULT_HEIGHT;
        default:
            break;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return SECTION_FOOTER_DEFAULT_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [tableView rectForHeaderInSection:section].size.height;
    CGRect frame = CGRectMake(80, height-30, 200, 30);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.font = Font_DINCondensed(18);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [self.headerTitleArray objectAtIndex:section];
    UIView *myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor clearColor];
    [myView addSubview:titleLabel];
    
    return myView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
//    BOOL result = [self checkoutWithIsBind:[WMSMyAccessory isBindAccessory] isConnected:self.bleControl.isConnected];
//    if (result == NO) {
//        return;
//    }
    
    if (indexPath.section == 3-1) {
        if (indexPath.row == 0) {
            WMSAntiLostVC *vc = [[WMSAntiLostVC alloc] init];
            vc.title = self.section4TitleArray[indexPath.row];
            MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
        }
//        else if (indexPath.row == 1) {
//            WMSClockListVC *VC = [[WMSClockListVC alloc] init];
//            MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:VC];
//            [self presentViewController:nav animated:YES completion:nil];
//        } else{};
        return ;
    }
    
    if (indexPath.section == 4 && indexPath.row == 0) {
        self.pickerController = [self openCamera];
        return;
    }
}

#warning 在设置为“震动”方式时，提醒用户
- (void)showWarningWhenRemindWayIsVibration
{
    [self showTip:NSLocalizedString(@"设置为“震动”模式，会加快电池的损耗", nil)];
}

#pragma mark - WMSSwitchCellDelegage
- (void)switchCell:(WMSSwitchCell *)switchCell didClickSwitch:(UISwitch *)sw
{
    BOOL result = [self checkoutWithIsBind:[WMSMyAccessory isBindAccessory] isConnected:self.bleControl.isConnected];
    if (result == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sw.on = (sw.on?NO:YES);//保持sw的状态不变
        });
        return;
    }
    //当绑定手表，连接成功后，才能进行后面的操作
    NSIndexPath *indexPath = [self.tableView indexPathForCell:switchCell];
    if (indexPath.section == 0 && indexPath.row == self.section1TitleArray.count-1) {
        [WMSRightVCHelper savaLowBatteryRemind:sw.on];
    } else if (indexPath.section == 2-1) {
        BOOL isShowWarning = NO;
        if (sw.on) {//当设置成“震动”时，提醒用户
            //当电压小于指定值时，不允许切换至“震动”
            if ([WMSDeviceModel deviceModel].power <= WATCH_LOW_BATTERY) {
                sw.on = (sw.on?NO:YES);
                [WMSRightVCHelper showTipOfLowBatteryNotSetVibrationRemindWay];
                return ;
            } else {
                //什么提示...
                isShowWarning = YES;
            }
        }
        //发送设置提醒方式的命令
        RemindWay way = sw.on ? RemindWayShake : RemindWayNot;
        [self.bleControl.settingProfile setRemindWay:way completion:^(BOOL isSuccess) {
            DEBUGLog_DETAIL(@"设置提醒方式%d", isSuccess);
            if (isSuccess) {
                [WMSRightVCHelper savaRemindWay:way];
            }
        }];
    }
//    else if (indexPath.section == 3-1)
//    {
//        [self.bleControl.settingProfile setLost:sw.on completion:^(BOOL isSuccess) {
//            DEBUGLog_DETAIL(@"设置防丢%d", isSuccess);
//        }];
//
//    }
    else
    {
        NSString *key = [self settingKeyFromIndexPath:indexPath];
        RemindEvents event = [self eventFromIndexPath:indexPath];
        [self.bleControl.settingProfile setRemindEvent:event completion:^(BOOL isSuccess) {
            DEBUGLog_DETAIL(@"设置提醒项%d", isSuccess);
            if (isSuccess) {
                [WMSRightVCHelper savaSettingItemForKey:key data:@(sw.on)];
            }
        }];
    }
}

- (NSString *)settingKeyFromIndexPath:(NSIndexPath *)indexPath
{
    static NSDictionary *map = nil;
    if (!map) {
        NSArray *settingKeys = @[@"Phone",@"SMS"/*,@"Email",@"Wechat",@"QQ",@"Skype",@"WhatsApp",@"Facebook",@"Twitter"*/];
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:settingKeys.count];
        NSIndexPath *index = nil;
        
        static int sections[1] = {0};
        sections[0] = (int)self.section1TitleArray.count-1;
        //sections[1] = (int)self.section2TitleArray.count;
        for (int i=0; i<( sizeof(sections)/sizeof(int) ); i++) {
            for (int j=0; j<sections[i]; j++) {
                index = [NSIndexPath indexPathForRow:j inSection:i];
                [indexPaths addObject:index];
            }
        }
        
        map = [NSDictionary dictionaryWithObjects:settingKeys forKeys:indexPaths];
    }
    return map[indexPath];
}

- (RemindEvents)eventFromIndexPath:(NSIndexPath *)indexPath
{
    static NSDictionary *map = nil;
    if (!map) {
        NSArray *settingKeys = @[@"Phone",@"SMS"/*,@"Email",@"QQ",@"Wechat",@"sina",@"Facebook",@"Twitter",@"WhatsApp",@"Skype"*/];
        NSMutableArray *events = [NSMutableArray arrayWithCapacity:settingKeys.count];
        for (int i=RemindEventCall; i<=RemindEventSMS; i++) {
            [events addObject:@(i)];
        }
        
        map = [NSDictionary dictionaryWithObjects:events forKeys:settingKeys];
    }
    NSString *key = [self settingKeyFromIndexPath:indexPath];
    return (RemindEvents)[map[key] unsignedIntegerValue];
}

@end
