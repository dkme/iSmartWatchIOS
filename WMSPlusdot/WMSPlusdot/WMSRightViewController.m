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

#import "WMSSwitchCell.h"
#import "MBProgressHUD.h"
#import "CRToast.h"

#import "WMSRightVCHelper.h"
#import "WMSPostNotificationHelper.h"
#import "WMSMyAccessory.h"
#import "WMSConstants.h"
#import "WMSSoundOperation.h"

#import "GGDeviceTool.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#define SECTION_NUMBER  4//5
#define SECTION0_HEADER_HEIGHT  50.f
#define SECTION_HEADER_HEIGHT   40.f
#define SECTION_HEADER_DEFAULT_HEIGHT   0.1f
#define SECTION_FOOTER_DEFAULT_HEIGHT   0.1f
#define CELL_CONTENT_PREFIX     @"                   "

#define LOW_BATTERY_LEVEL1       0.20f
#define LOW_BATTERY_LEVEL2       0.15f
#define LOW_BATTERY_LEVEL3       0.10f
#define LOW_BATTERY_LEVEL4       0.05f
#define LOW_BATTERY_REMIND_TIMEINTERVAL 20
#define ANTI_LOST_DISTANCE       60

#define PLAY_ALERT_DURATION         8.0
#define PLAY_VIBRATE_TIMEINTERVAL   1.0

@interface WMSRightViewController ()<WMSSwitchCellDelegage,RESideMenuDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) NSArray *section1TitleArray;
@property (strong, nonatomic) NSArray *section2TitleArray;
@property (strong, nonatomic) NSArray *section3TitleArray;
@property (strong, nonatomic) NSArray *section4TitleArray;
@property (strong, nonatomic) NSArray *section5TitleArray;
@property (strong, nonatomic) NSArray *headerTitleArray;

@property (strong, nonatomic) WMSBleControl *bleControl;
@property (strong, nonatomic) UIImagePickerController *pickerController;

@property (strong, nonatomic) NSArray *settingItemArray;
@property (strong, nonatomic) NSArray *cellIndexPathArray;//与上面的值一一对应
@end

@implementation WMSRightViewController
{
    WMSSoundOperation *_soundOperation;
    
    CTCallCenter *_callCenter;
    
    int _configIndex;
    BOOL _isVisible;
}

#pragma mark - Property Getter Method
- (NSArray *)section1TitleArray
{
    if (!_section1TitleArray) {
        _section1TitleArray = @[NSLocalizedString(@"Phone",nil),
                                //NSLocalizedString(@"Message",nil),
                                //NSLocalizedString(@"Email",nil),
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
        _section4TitleArray = @[NSLocalizedString(@"防丢",nil)
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
                              //NSLocalizedString(@"Social contact",nil),
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

    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    self.tableView.scrollEnabled = NO;
    //self.tableView.tintColor = UICOLOR_DEFAULT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.sideMenuViewController.delegate = self;
    self.bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    
    //监测电量
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteyChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidDisConnectPeripheral:) name:WMSBleControlPeripheralDidDisConnect object:nil];
    
    _soundOperation = [[WMSSoundOperation alloc] init];
    [self listeningCall];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DEBUGLog(@"+++++RightViewController viewWillAppear");
    //    self.sideMenuViewController.scaleContentView = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"RightViewController dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

///
- (NSDictionary *)readSettingItemData
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_SETTINGS)];
    NSMutableDictionary *mutiDic = [NSMutableDictionary dictionaryWithDictionary:readData];
    if (readData == nil) {
        for (int i=0; i<[self.settingItemArray count]; i++) {
            [mutiDic setObject:@(1) forKey:self.settingItemArray[i]];//默认设置项都为打开状态
        }
    }
    return mutiDic;
}
- (void)savaSettingItemForKey:(NSString *)key object:(NSObject *)object
{
    NSDictionary *readData = [self readSettingItemData];
    NSMutableDictionary *writeData = [NSMutableDictionary dictionaryWithDictionary:readData];
    [writeData setObject:object forKey:key];
    BOOL b = [writeData writeToFile:FilePath(FILE_SETTINGS) atomically:YES];
    DEBUGLog(@"保存数据%@",b?@"成功":@"失败");
}

- (BOOL)antiLostStatus
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_REMIND)];
    id obj = [readData objectForKey:@"antiLost"];
    if (obj == nil) {
        return 1;
    }
    return [obj boolValue];
}
- (BOOL)lowBatteryStatus
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_REMIND)];
    id obj = [readData objectForKey:@"battery"];
    if (obj == nil) {
        return 1;//默认为打开状态
    }
    return [obj boolValue];
}
- (void)setAntiLost:(BOOL)openOrClose
{
    //设置防丢成功，保存设置
    [self.bleControl.settingProfile setAntiLostStatus:openOrClose distance:ANTI_LOST_DISTANCE completion:^(BOOL success)
     {
         DEBUGLog(@"设置防丢%@",success?@"成功":@"失败");
         [self showOperationSuccessTip:NSLocalizedString(@"防丢设置成功", nil)];
         NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_REMIND)];
         NSMutableDictionary *writeData = [NSMutableDictionary dictionaryWithDictionary:readData];
         [writeData setObject:@(openOrClose) forKey:@"antiLost"];
         [writeData writeToFile:FilePath(FILE_REMIND) atomically:YES];
     }];
}
- (void)setLowBattery:(BOOL)openOrClose
{
    [self showOperationSuccessTip:NSLocalizedString(@"提醒设置成功", nil)];
    //直接保存
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_REMIND)];
    NSMutableDictionary *writeData = [NSMutableDictionary dictionaryWithDictionary:readData];
    [writeData setObject:@(openOrClose) forKey:@"battery"];
    [writeData writeToFile:FilePath(FILE_REMIND) atomically:YES];
}

//0：不提醒，1：震动，2：响铃，3：震动+响铃
- (int)readRemindWay
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_REMIND_WAY)];
    int way = [[readData objectForKey:@"remindWay"] intValue];
    if (readData == nil || way == 0) {
        return 3;//默认“震动+响铃”
    }
    return way;
}
- (void)savaRemindWay:(int)way
{
    NSDictionary *writeData = @{@"remindWay":@(way)};
    [writeData writeToFile:FilePath(FILE_REMIND_WAY) atomically:YES];
}

- (void)setRemindWay:(int)way
{
    RemindMode mode = way;//way与RemindMode一一对应
    RemindEventsType type = [self remindEventsType];
    [self.bleControl.settingProfile setRemindEventsType:type mode:mode completion:^(BOOL success)
     {
         DEBUGLog(@"提醒方式设置%@",success?@"成功":@"失败");
         [self savaRemindWay:way];
         [self showOperationSuccessTip:NSLocalizedString(@"提醒方式设置成功", nil)];
     }];
}

- (RemindEventsType)remindEventsType
{
    NSDictionary *readData = [self readSettingItemData];
    DEBUGLog(@"readData:%@",readData);
    NSArray *values = [readData objectsForKeys:self.settingItemArray notFoundMarker:@"aa"];
    
    NSUInteger events[7] = {RemindEventsTypeCall,RemindEventsTypeSMS,RemindEventsTypeEmail,RemindEventsTypeWeixin,RemindEventsTypeQQ,RemindEventsTypeFacebook,RemindEventsTypeTwitter};
    RemindEventsType eventsType = 0x00;
    for (int i=0; i<[values count]; i++) {
        BOOL openOrClose = [[values objectAtIndex:i] boolValue];
        if (openOrClose) {
            eventsType = (eventsType | events[i]);
        }
    }
    return eventsType;
}

#pragma mark - 第一次连接成功后，对设置项的配置
- (void)resetFirstConnectedConfig
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:@"firstConnected"];
}

- (void)firstConnectedConfig
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isFirst = [userDefaults boolForKey:@"firstConnected"];
    if (isFirst == NO) {
        //配置设置项
        [self showHUDAtViewCenter:NSLocalizedString(@"正在配置设置项，请稍等...", nil)];
        [self startFirstConnectedConfig:^{
            //配置成功
            [self hideHUDAtViewCenter];
            [self showTip:NSLocalizedString(@"设置项配置成功", nil)];
            [userDefaults setBool:YES forKey:@"firstConnected"];
        }];
    }
}

- (void)startFirstConnectedConfig:(void(^)(void))aCallBack
{
    RemindEventsType eventsType = [self remindEventsType];
    _configIndex = 0;
    [self.bleControl.settingProfile setRemindEventsType:eventsType completion:^(BOOL success)
     {
         if (success) {
             [self continueFirstConnectedConfig:^{
                 if (aCallBack) {
                     aCallBack();
                 }
             }];
         }
     }];
}
- (void)continueFirstConnectedConfig:(void(^)(void))aCallBack
{
    RemindEventsType eventsType = [self remindEventsType];
    RemindMode mode = [self readRemindWay];
    BOOL antiLostStatus = [self antiLostStatus];
    _configIndex ++;
    switch (_configIndex) {
        case 1:
        {
            [self.bleControl.settingProfile setRemindEventsType:eventsType mode:mode completion:^(BOOL success)
             {
                 if (success) {
                     [self continueFirstConnectedConfig:aCallBack];
                 }
             }];
            break;
        }
        case 2:
        {
            [self.bleControl.settingProfile setAntiLostStatus:antiLostStatus distance:ANTI_LOST_DISTANCE completion:^(BOOL success)
            {
                if (success) {
                    if (aCallBack) {
                        aCallBack();
                    }
                }
            }];
            break;
        }
        default:
            break;
    }
}

#pragma mark - 监听按键
- (void)listeningKeys
{
    [self.pickerController showTip:NSLocalizedString(@"重新建立了连接", nil)];
    
    [self.bleControl.deviceProfile readDeviceRemoteDataWithCompletion:^(RemoteDataType dataType)
     {
         DEBUGLog(@"监听到的按键dataType:0x%X",(int)dataType);
         if (RemoteDataTypeTakephoto == dataType) {
             [self.pickerController takePicture];
         }
         else if (RemoteDataTypeFindPhone == dataType) {
             [_soundOperation playAlarmWithDuration:PLAY_ALERT_DURATION andVibrateWithTimeInterval:PLAY_VIBRATE_TIMEINTERVAL completion:nil];
             
             [WMSPostNotificationHelper postSeachPhoneLocalNotification];
             //开启闪烁
             //[[GGDeviceTool sharedInstance] startWebcamFlicker];
         }
     }];
}

#pragma mark - 监听来电
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

#pragma mark - 遥控拍照
- (void)switchToRemoteMode
{
    //NSLocalizedString(@"正在切换至遥控模式...",nil);
    //[self showHUDAtViewCenter:NSLocalizedString(@"按下手表右上角按键进行拍照", nil)];
    [self.bleControl switchToControlMode:ControlModeRemote openOrClose:YES completion:^(BOOL success, NSString *failReason)
     {
         [self hideHUDAtViewCenter];
         if (success) {//切换模式成功，进入相机界面
             //[self showTip:NSLocalizedString(@"切换至拍照模式成功", nil)];
             
             UIImagePickerController *picker = [self openCamera];
             self.pickerController = picker;
         } else {
             //[self showTip:NSLocalizedString(@"切换至拍照模式失败", nil)];
         }
     }];
}

- (UIImagePickerController *)openCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return nil;
    }
    UIImagePickerControllerSourceType sourceType;
    sourceType=UIImagePickerControllerSourceTypeCamera;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    //设置图像选取控制器的类型为静态图像
    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
    picker.allowsEditing=NO;
    picker.showsCameraControls = YES;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
    return picker;
}

#pragma mark - 电量
- (void)batteryOperation:(float)battery
{
    if ([WMSRightVCHelper isSendLowBatteryRemind:battery]) {
        if ([self lowBatteryStatus]) {
            [WMSRightVCHelper startLowBatteryRemind:self.bleControl.settingProfile completion:^{
                [WMSPostNotificationHelper postLowBatteryLocalNotification];
            }];
        }
    }
}

#pragma mark - Notification
- (void)batteyChanged:(NSNotification *)notification
{
    UIDevice *device = notification.object;
    DEBUGLog(@">>>battery:%f",device.batteryLevel);
    [self batteryOperation:device.batteryLevel];
}
//Ble
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    if (_isVisible) {
        [self firstConnectedConfig];
    }
    [self.tableView reloadData];

    float battery = [[UIDevice currentDevice] batteryLevel];
    [self batteryOperation:battery];
    
    [self listeningKeys];
}

- (void)handleDidDisConnectPeripheral:(NSNotification *)notification
{
    //[self.tableView reloadData];
    DEBUGLog(@"self.pickerController:%@",self.pickerController);
    [self hideHUDAtViewCenter];
    [self.pickerController showTip:NSLocalizedString(@"您的连接已断开", nil)];
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
            [self firstConnectedConfig];
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


#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //判断是静态图像还是视频
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //UIImage* editedImage = [info objectForKey:UIImagePickerControllerEditedImage];//获取用户编辑之后的图像
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //将该图像保存到媒体库中
        UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.pickerController = nil;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
                NSDictionary *readData = [self readSettingItemData];
                NSString *key = [self keyForIndexpath:indexPath];
                if (key) {
                    cell.mySwitch.on = [[readData objectForKey:key] boolValue];
                    //DEBUGLog(@"status:%d",cell.mySwitch.on);
                }
            } else {
                cell.mySwitch.on = NO;
            }
            
            if (indexPath.row == 3-2) {//电池
                cell.mySwitch.on = [self.bleControl isConnected] ? [self lowBatteryStatus] : NO;
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
                if ([self readRemindWay] == indexPath.row + 1) {
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
            //cell.mySwitch.on = [self.bleControl isConnected]?[self antiLostStatus]:NO;
            
            //cell.delegate = self;
            
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
            //cell.detailTextLabel.text = NSLocalizedString(@"拍摄的照片保存在照片库", nil);
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.font = Font_System(12);//Font_DINCondensed(12);
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
    
//    if (indexPath.section == 3-1 && indexPath.row == 0) {
//        WMSAntiLostVC *vc = [[WMSAntiLostVC alloc] init];
//        vc.title = self.section4TitleArray[indexPath.row];
//        MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:vc];
//        [self presentViewController:nav animated:YES completion:nil];
//        return;
//    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
    BOOL result = [self checkoutWithIsBind:[WMSMyAccessory isBindAccessory] isConnected:self.bleControl.isConnected];
    if (result == NO) {
        return;
    }
    
    if (indexPath.section == 2-1) {
        if ([self readRemindWay] != indexPath.row+1) {//当提醒方式改变时再去设置
            for (int i=0; i<[self.section3TitleArray count]; i++) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:path];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            UITableViewCell *checkedCell=[self.tableView cellForRowAtIndexPath:indexPath];
            [checkedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
            
            int way = (int)indexPath.row+1;
            [self setRemindWay:way];
        }
        return;
    }
    
    if (indexPath.section == 3-1 && indexPath.row == 0) {
        WMSAntiLostVC *vc = [[WMSAntiLostVC alloc] init];
        vc.title = self.section4TitleArray[indexPath.row];
        MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
        return;
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
        [self setLowBattery:sw.on];
        return;
    }
    if ([switchCell.myLabelText.text
         isEqualToString:NSLocalizedString(@"防丢", nil)])
    {
        [self setAntiLost:sw.on];
        return;
    }
    
    
    NSIndexPath *atIndex = [self.tableView indexPathForCell:switchCell];
    
//    NSDictionary *readData = [self readSettingItemData];
//    NSArray *values = [readData objectsForKeys:self.settingItemArray notFoundMarker:@"aa"];
//    NSUInteger events[7] = {RemindEventsTypeCall,RemindEventsTypeSMS,RemindEventsTypeEmail,RemindEventsTypeWeixin,RemindEventsTypeQQ,RemindEventsTypeFacebook,RemindEventsTypeTwitter};
//    NSUInteger eventsType = 0x00;
//    NSUInteger type = 0;
//    for (int i=0; i<[values count]; i++) {
//        NSIndexPath *indexPathObj = [self.cellIndexPathArray objectAtIndex:i];
//        if (atIndex.section == indexPathObj.section && atIndex.row == indexPathObj.row)
//        {
//            type = events[i];
//        } else {
//            BOOL openOrClose = [[values objectAtIndex:i] boolValue];
//            if (openOrClose) {
//                eventsType = (eventsType | events[i]);
//            }
//        }
//    }
//    if ([sw isOn]) {
//        eventsType = (eventsType | type);
//    }
//    DEBUGLog(@"eventsType:0x%X",(int)eventsType);
//    [self.bleControl.settingProfile setRemindEventsType:eventsType completion:^(BOOL success)
//     {
//         if (success) {
//             [self showOperationSuccessTip:NSLocalizedString(@"提醒设置成功", nil)];
//             NSString *key = [self keyForIndexpath:atIndex];
//             [self savaSettingItemForKey:key object:@([sw isOn])];
//         }
//     }];
    NSString *key = [self keyForIndexpath:atIndex];
    [self savaSettingItemForKey:key object:@([sw isOn])];
}

@end
