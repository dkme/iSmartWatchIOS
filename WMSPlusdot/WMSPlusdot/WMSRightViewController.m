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

#define SECTION_NUMBER                          4//5
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

@property (strong, nonatomic) NSArray *settingItemArray;
@property (strong, nonatomic) NSArray *cellIndexPathArray;//与上面的值一一对应
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
        _section1TitleArray = @[NSLocalizedString(@"Phone",nil),
                                NSLocalizedString(@"Battery",nil)
                                ];
    }
    return _section1TitleArray;
}
- (NSArray *)section2TitleArray
{
    if (!_section2TitleArray) {
        _section2TitleArray = @[NSLocalizedString(@"Wechat",nil),
                                NSLocalizedString(@"QQ",nil),
                                NSLocalizedString(@"Facebook",nil),
                                NSLocalizedString(@"Twitter",nil)
                                ];
    }
    return _section2TitleArray;
}
- (NSArray *)section3TitleArray
{
    if (!_section3TitleArray) {
        _section3TitleArray = @[NSLocalizedString(@"震动",nil),
                                NSLocalizedString(@"蜂鸣",nil),
                                NSLocalizedString(@"震动+蜂鸣",nil),
                                ];
    }
    return _section3TitleArray;
}
- (NSArray *)section4TitleArray
{
    if (!_section4TitleArray) {
        _section4TitleArray = @[NSLocalizedString(@"防丢",nil),
                                //                                NSLocalizedString(@"Smart alarm clock", nil)
                                ];
    }
    return _section4TitleArray;
}
- (NSArray *)section5TitleArray
{
    if (!_section5TitleArray) {
        _section5TitleArray = @[NSLocalizedString(@"拍照",nil)
                                ];
    }
    return _section5TitleArray;
}
- (NSArray *)headerTitleArray
{
    if (!_headerTitleArray) {
        _headerTitleArray = @[NSLocalizedString(@"Remind Setting",nil),
                              NSLocalizedString(@"提醒方式",nil),
                              NSLocalizedString(@"其他",nil),
                              @"",
                              ];
    }
    return _headerTitleArray;
}

- (NSArray *)settingItemArray//存放保存设置项字典的key
{
    if (!_settingItemArray) {
        _settingItemArray = @[@"Call",@"SMS",@"Email",@"WeiXin",@"QQ",@"Facebook",@"Twitter"];
    }
    return _settingItemArray;
}
- (NSArray *)cellIndexPathArray
{
    if (!_cellIndexPathArray) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:7];
        NSIndexPath *index = nil;
        
        index = [NSIndexPath indexPathForRow:0 inSection:0];
        [indexPaths addObject:index];
        
        index = [NSIndexPath indexPathForRow:1 inSection:0];
        [indexPaths addObject:index];
        
        index = [NSIndexPath indexPathForRow:2 inSection:0];
        [indexPaths addObject:index];
        
        index = [NSIndexPath indexPathForRow:0 inSection:1];
        [indexPaths addObject:index];
        
        index = [NSIndexPath indexPathForRow:1 inSection:1];
        [indexPaths addObject:index];
        
        index = [NSIndexPath indexPathForRow:2 inSection:1];
        [indexPaths addObject:index];
        
        index = [NSIndexPath indexPathForRow:3 inSection:1];
        [indexPaths addObject:index];
        
        _cellIndexPathArray = indexPaths;
    }
    return _cellIndexPathArray;
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
//根据cell的indexPath，得出该cell表示的设置项在字典中的key
- (NSString *)keyForIndexpath:(NSIndexPath *)indexPath
{
    int index = -1;
    for (int i=0; i<[self.cellIndexPathArray count]; i++) {
        NSIndexPath *obj = self.cellIndexPathArray[i];
        if (indexPath.section == obj.section &&
            indexPath.row == obj.row)
        {
            index = i;
            break;
        }
    }
    if (index < 0) {
        return nil;
    }
    return self.settingItemArray[index];
}
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
//#pragma mark - 监测手表电量
- (void)deviceIsLowBattery:(void(^)(BOOL isLow))aCallback
{
    double version = [WMSDeviceModel deviceModel].version;
    double voltage = [WMSDeviceModel deviceModel].voltage;
    if (version < FIRMWARE_ADD_BATTERY_INFO) {
        if (aCallback) {
            aCallback(NO);
        }
        return ;
    }
    if (voltage <= 0.0) {//表示还没读取设备电压
        [WMSDeviceModel readDeviceBatteryInfo:self.bleControl completion:^(float voltage) {
            if (aCallback) {
                aCallback( (voltage<=WATCH_LOW_VOLTAGE) );
            }
        }];
    } else {
        if (aCallback) {
            aCallback( (voltage<=WATCH_LOW_VOLTAGE) );
        }
    }
}

#pragma mark - 监听来电/按键
- (void)listeningCall
{
    __weak __typeof(&*self) weakSelf = self;
    _callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler = ^(CTCall* call) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        WMSSwitchCell *cell = (WMSSwitchCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
        BOOL on = cell.mySwitch.on;
        if ([call.callState isEqualToString:CTCallStateDisconnected])
        {
            DEBUGLog(@"Call has been disconnected");
            if (on) {
                [weakSelf.bleControl.settingProfile finishRemind:OtherRemindTypeCall completion:^(BOOL success) {
                    
                }];
            }
        }
        else if ([call.callState isEqualToString:CTCallStateConnected])
        {
            DEBUGLog(@"Call has just been connected");
            if (on) {
                [weakSelf.bleControl.settingProfile finishRemind:OtherRemindTypeCall completion:^(BOOL success) {
                    
                }];
            }
        }
        else if([call.callState isEqualToString:CTCallStateIncoming])
        {
            DEBUGLog(@"Call is incoming");
            if (on) {
                [weakSelf.bleControl.settingProfile startRemind:OtherRemindTypeCall completion:^(BOOL success) {
                    DEBUGLog(@"开启电话提醒成功");
                }];
            }
        }
        else if ([call.callState isEqualToString:CTCallStateDialing])
        {
            DEBUGLog(@"call is dialing");
        }
        else
        {
            DEBUGLog(@"Nothing is done");
        }
    };
}

//#pragma mark - 监听按键
- (void)listeningKeys
{
    [self.bleControl.deviceProfile readDeviceRemoteDataWithCompletion:^(RemoteDataType dataType)
     {
         DEBUGLog(@"监听到的按键dataType:0x%X",(int)dataType);
         if (RemoteDataTypeTakephoto == dataType) {
             [self.pickerController takePhoto];
         }
         else if (RemoteDataTypeFindPhone == dataType) {
             [_soundOperation playAlarmWithDuration:PLAY_ALERT_DURATION andVibrateWithTimeInterval:PLAY_VIBRATE_TIMEINTERVAL completion:nil];
             
             [WMSPostNotificationHelper postSeachPhoneLocalNotification];
             //开启闪烁
             //[[GGDeviceTool sharedInstance] startWebcamFlicker];
         }
     }];
}
#pragma mark - 遥控拍照
- (void)switchToRemoteMode
{
    [self.bleControl switchToControlMode:ControlModeRemote openOrClose:YES completion:^(BOOL success, NSString *failReason)
     {
         [self hideHUDAtViewCenter];
         if (success) {//切换模式成功，进入相机界面
             dispatch_async(dispatch_get_main_queue(), ^{
                 GGIViewController *picker = [self openCamera];
                 self.pickerController = picker;
             });
         } else {}
     }];
}
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
        [WMSRightVCHelper startFirstConnectedConfig:self.bleControl.settingProfile completion:nil];
    }
    float battery = [[UIDevice currentDevice] batteryLevel];
    [self batteryOperation:battery];
    
    [self listeningKeys];
    
    self.pickerController.textLabel.text = NSLocalizedString(@"请按下手表上的确认键拍照...", nil);
    
    __weak __typeof(self) weakSelf = self;
    [self deviceIsLowBattery:^(BOOL isLow) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (isLow) {
            //设置为响铃提醒
            [WMSRightVCHelper setRemindWay:2 handle:strongSelf.bleControl.settingProfile completion:^(BOOL success) {
                [strongSelf.tableView reloadData];
            }];
        } else {
            [strongSelf.tableView reloadData];
        }
    }];
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
        AccessoryGeneration g = [WMSMyAccessory generationForBindAccessory];
        if ([WMSMyAccessory isBindAccessory]) {
            switch (g) {
                case AccessoryGenerationONE:
                    
                    break;
                    
                default:
                    break;
            }
        }
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
        {
            NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
            UINib *cellNib = [UINib nibWithNibName:@"WMSSwitchCell" bundle:nil];
            [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
            
            WMSSwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
            
            cell.myLabelText.text = [self.section1TitleArray objectAtIndex:indexPath.row];
            cell.myLabelText.textColor = [UIColor whiteColor];
            cell.myLabelText.font = Font_DINCondensed(18);
            
            if ([self.bleControl isConnected]) {
                NSDictionary *readData = [WMSRightVCHelper loadSettingItemData];
                NSString *key = [self keyForIndexpath:indexPath];
                if (key) {
                    cell.mySwitch.on = [[readData objectForKey:key] boolValue];
                }
            } else {
                cell.mySwitch.on = NO;
            }
            
            if (indexPath.row == 3-2) {//电池
                cell.mySwitch.on = [self.bleControl isConnected] ? [WMSRightVCHelper lowBatteryRemind] : NO;
            }
            
            cell.delegate = self;
            
            return cell;
        }
            //        case 1:
            //        {
            //            NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
            //            UINib *cellNib = [UINib nibWithNibName:@"WMSSwitchCell" bundle:nil];
            //            [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
            //
            //            WMSSwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            cell.backgroundColor = [UIColor clearColor];
            //            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
            //
            //            cell.myLabelText.text = [self.section2TitleArray objectAtIndex:indexPath.row];
            //            cell.myLabelText.textColor = [UIColor whiteColor];
            //            cell.myLabelText.font = Font_DINCondensed(18);
            //
            //            if ([self.bleControl isConnected]) {
            //                NSDictionary *readData = [self readSettingItemData];
            //                NSString *key = [self keyForIndexpath:indexPath];
            //                if (key) {
            //                    cell.mySwitch.on = [[readData objectForKey:key] boolValue];
            //                }
            //            } else {
            //                cell.mySwitch.on = NO;
            //            }
            //            cell.delegate = self;
            //
            //            return cell;
            //        }
        case 2-1:
        {
            NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",(int)indexPath.section,(int)indexPath.row];
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_b.png"]];
            
            NSString *txt = [self.section3TitleArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [CELL_CONTENT_PREFIX stringByAppendingString:txt];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = Font_DINCondensed(18);
            if ([self.bleControl isConnected]) {
                if ([WMSRightVCHelper loadRemindWay] == indexPath.row + 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            return cell;
        }
        case 3-1:
        {
            NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_b.png"]];
            
            NSString *txt = self.section4TitleArray[indexPath.row];
            cell.textLabel.text = [CELL_CONTENT_PREFIX stringByAppendingString:txt];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = Font_DINCondensed(18);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        case 4-1:
        {
            NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_b.png"]];
            
            NSString *txt = [self.section5TitleArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [CELL_CONTENT_PREFIX stringByAppendingString:txt];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = Font_DINCondensed(18);
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.font = Font_System(12);
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
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
    AccessoryGeneration g = [WMSMyAccessory generationForBindAccessory];
    if ([WMSMyAccessory isBindAccessory]) {
        switch (g) {
            case AccessoryGenerationONE:
                return 44.f;
            case AccessoryGenerationTWO:
                return (indexPath.section==1?0.1f:44.f);
            default:
                break;
        }
    }
    return 44.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return SECTION0_HEADER_HEIGHT;
            //case 1:
        case 2-1:
        {
            AccessoryGeneration g = [WMSMyAccessory generationForBindAccessory];
            if ([WMSMyAccessory isBindAccessory]) {
                switch (g) {
                    case AccessoryGenerationONE:
                        return SECTION_HEADER_HEIGHT;
                    case AccessoryGenerationTWO:
                        return 0.1;
                    default:
                        break;
                }
            }
            return SECTION_HEADER_HEIGHT;
        }
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
    
    if (section == 1) {
        AccessoryGeneration g = [WMSMyAccessory generationForBindAccessory];
        if ([WMSMyAccessory isBindAccessory]) {
            switch (g) {
                case AccessoryGenerationONE:
                    break;
                case AccessoryGenerationTWO:
                    titleLabel.text = @"";
                    break;
                default:
                    break;
            }
        }
    }
    
    return myView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
    BOOL result = [self checkoutWithIsBind:[WMSMyAccessory isBindAccessory] isConnected:self.bleControl.isConnected];
    if (result == NO) {
        return;
    }
    
    if (indexPath.section == 2-1) {
        if ([WMSRightVCHelper loadRemindWay] != indexPath.row+1) {//当提醒方式改变时再去设置
            if (indexPath.row+1 == 1 || indexPath.row+1 == 3) {//当设置成“震动”时，提醒用户
                //当电压小于指定值时，不允许切换至“震动”
                if ([WMSDeviceModel deviceModel].voltage <= WATCH_LOW_VOLTAGE) {
                    [WMSRightVCHelper showTipOfLowBatteryNotSetVibrationRemindWay];
                    return ;
                } else {
                    //什么提示...
                    [self showTip:NSLocalizedString(@"设置为“震动”模式，会缩减电池的寿命", nil)];
                }
            }
            
            for (int i=0; i<[self.section3TitleArray count]; i++) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:path];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            UITableViewCell *checkedCell=[self.tableView cellForRowAtIndexPath:indexPath];
            [checkedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
            
            int way = (int)indexPath.row+1;
            [WMSRightVCHelper setRemindWay:way handle:self.bleControl.settingProfile completion:^(BOOL success) {
                DEBUGLog(@"提醒方式设置%@",success?@"成功":@"失败");
                if (success) {
                    [WMSRightVCHelper savaRemindWay:way];
                    [self showOperationSuccessTip:NSLocalizedString(@"提醒方式设置成功", nil)];
                }
            }];
        }
        return;
    }
    
    if (indexPath.section == 3-1) {
        if (indexPath.row == 0) {
            WMSAntiLostVC *vc = [[WMSAntiLostVC alloc] init];
            vc.title = self.section4TitleArray[indexPath.row];
            MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
        }
        else if (indexPath.row == 1) {
            WMSClockListVC *VC = [[WMSClockListVC alloc] init];
            MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:VC];
            [self presentViewController:nav animated:YES completion:nil];
        } else{};
        return ;
    }
    
    if (indexPath.section == 4-1 && indexPath.row == 0) {
        [self switchToRemoteMode];
        return;
    }
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
    if ([switchCell.myLabelText.text
         isEqualToString:NSLocalizedString(@"Battery", nil)])
    {
        [WMSRightVCHelper setLowBatteryRemind:sw.on];
        return;
    }
    
    NSIndexPath *atIndex = [self.tableView indexPathForCell:switchCell];
    NSString *key = [self keyForIndexpath:atIndex];
    [WMSRightVCHelper savaSettingItemForKey:key data:@(sw.on)];
}

@end
