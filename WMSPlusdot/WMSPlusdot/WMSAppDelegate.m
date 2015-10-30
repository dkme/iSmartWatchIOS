//
//  WMSAppDelegate.m
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSAppDelegate.h"
#import "RESideMenu.h"
#import "WMSLoginViewController.h"
#import "WMSLeftViewController.h"
#import "WMSRightViewController.h"
#import "WMSContentViewController.h"
#import "WMSBindingAccessoryViewController.h"
#import "WMSMyAccessoryViewController.h"
#import "WMSGuideVC.h"
#import "WMSUpdateVC.h"
#import "WMSBleControl.h"

#import "WMSHelper.h"
#import "WMSPostNotificationHelper.h"
#import "WMSAppConfig.h"
#import "WMSConstants.h"
#import "UIImage+Color.h"
#import "WMSMyAccessory.h"
#import "WMSDeviceModel.h"
#import "WMSDeviceModel+Configure.h"
#import "NSTimeZone+TimeDifference.h"

#import "GGAudioTool.h"
#import "WMSSoundOperation.h"

#import <AVFoundation/AVFoundation.h>

NSString *const WMSAppDelegateReSyncData = @"com.ios.plusdot.WMSAppDelegateReSyncData";
NSString *const WMSAppDelegateNewDay = @"com.ios.plusdot.WMSAppDelegateReSyncData";

@interface WMSAppDelegate ()<RESideMenuDelegate>

@property (nonatomic, strong) WMSSoundOperation *soundOperation;

@property (nonatomic, assign, getter=isAdjustTimeWhenConnected) BOOL adjustTimeWhenConnected;///Time zone

@property (nonatomic, copy) NSString *appUpdateUrlFromFir;

@end

@implementation WMSAppDelegate
{
    NSTimer *_backgroundTimer;
    BOOL _isStartDFU;//是否准备升级了
}

#pragma mark - 获取appDelegate
+ (WMSAppDelegate *)appDelegate
{
    return (WMSAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (UINavigationController *)loginNavigationCtrl
{
    if (!_loginNavigationCtrl) {
        WMSLoginViewController *loginVC = [[WMSLoginViewController alloc] initWithNibName:@"WMSLoginViewController" bundle:nil];
        _loginNavigationCtrl = [[UINavigationController alloc] initWithRootViewController:loginVC];
        _loginNavigationCtrl.navigationBarHidden = YES;
    }
    return _loginNavigationCtrl;
}
- (RESideMenu *)reSideMenu
{
    if (!_reSideMenu) {
        RESideMenu *sideMenu = [[RESideMenu alloc] init];
        sideMenu.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
        sideMenu.contentViewShadowColor = [UIColor blackColor];
        sideMenu.contentViewShadowOffset = CGSizeMake(0, 0);
        sideMenu.contentViewShadowOpacity = 0.6;
        sideMenu.contentViewShadowRadius = 3;
        sideMenu.contentViewShadowEnabled = NO;
        sideMenu.panGestureEnabled = YES;
        sideMenu.parallaxEnabled = NO;
        
        WMSContentViewController *contentVC = [[WMSContentViewController alloc] init];
        WMSLeftViewController *leftVC = [[WMSLeftViewController alloc] init];
        WMSRightViewController *rightVC = [[WMSRightViewController alloc] init];
        sideMenu.contentViewController = [[MyNavigationController alloc] initWithRootViewController:contentVC];
        sideMenu.leftMenuViewController = leftVC;
        sideMenu.rightMenuViewController = rightVC;
        sideMenu.backgroundImage = [UIImage imageNamed:@"main_bg.png"];
        sideMenu.delegate = self;
        
        _reSideMenu = sideMenu;
    }
    return _reSideMenu;
}
- (WMSBleControl *)wmsBleControl
{
    if (!_wmsBleControl) {
        _wmsBleControl  = [[WMSBleControl alloc] init];
    }
    return _wmsBleControl;
}

#pragma mark - 启动

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType type = UIUserNotificationTypeAlert |
        UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound ;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    ////////////////////////////////////////////////////
    
    _wmsBleControl = [[WMSBleControl alloc] init];
    [WMSPostNotificationHelper cancelAllNotification];
    [self setupReSyncDataTimer];
    [self setupAppAppearance];
    [self registerForNotifications];
    [self checkCurrentTimeZone];
    [self checkAppUpdatesFromFirPlatform];
    if ([WMSHelper isFirstLaunchApp]) {
        self.window.rootViewController = [WMSGuideVC guide];
        [self.window makeKeyAndVisible];
        return YES;
    }
    
    self.window.rootViewController = [self reSideMenu];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DEBUGLog(@"%s",__FUNCTION__);
    [self startCommunication];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DEBUGLog(@"%s",__FUNCTION__);
    [self stopCommunication];
    
    [self setupReSyncDataTimer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DEBUGLog(@"%s",__FUNCTION__);
    [WMSPostNotificationHelper resetAllNotification];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (notification) {
        [WMSPostNotificationHelper resetAllNotification];
    }
}

- (void)dealloc
{
    [self unregisterFromNotifications];
}

#pragma mark - setup
- (void)setupAppAppearance
{
    //设置导航栏的颜色，标题字体和颜色
    UINavigationBar *navBar = [UINavigationBar appearance];
    //[navBar setBarTintColor:UIColorFromRGBAlpha(0x00D5E1, 1)];
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setBackgroundImage:[UIImage imageFromColor:UICOLOR_DEFAULT] forBarMetrics:UIBarMetricsDefault];
    [navBar setShadowImage:[[UIImage alloc] init]];
    if (IS_IOS8) {
        navBar.barStyle = UIBarStyleBlack;
        navBar.translucent = YES;
    } else {
    }
    
    UIFont *font = Font_DINCondensed(18.f);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        if ([[WMSAppConfig systemLanguage] isEqualToString:kLanguageChinese]) {///DIN Condensed字体，在英文状态下，并不会出现显示不全的问题
            font = [UIFont boldSystemFontOfSize:19.f];
        }
    }
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName:[UIColor whiteColor],
                                 NSFontAttributeName:font,
                                  };
    [navBar setTitleTextAttributes:attributes];
}
//#pragma mark - 后台计时，在00:00发送同步命令
- (void)setupReSyncDataTimer
{
    NSDate *today = [NSDate systemDate];
    NSDate *tomorrow = [NSDate dateWithTimeInterval:24*60*60 sinceDate:today];
    NSString *strDate = [NSString stringWithFormat:@"%04d-%02d-%02d 00:00:00",(unsigned int)[NSDate yearOfDate:tomorrow],(unsigned int)[NSDate monthOfDate:tomorrow],(unsigned int)[NSDate dayOfDate:tomorrow]];
    NSDate *targetDate = [NSDate dateFromString:strDate format:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeInterval interval = [targetDate timeIntervalSinceDate:today];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncData) object:nil];
    [self performSelector:@selector(syncData) withObject:nil afterDelay:interval];
}
- (void)syncData
{
//    DEBUGLog(@"%s",__FUNCTION__);
//    if (self.wmsBleControl.isConnected) {
//        [self.wmsBleControl.settingProfile adjustDate:[NSDate systemDate] completion:^(BOOL isSuccess) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:WMSAppDelegateReSyncData object:nil];
//        }];
//    }
//    else {
//        [[NSNotificationCenter defaultCenter] postNotificationName:WMSAppDelegateReSyncData object:nil];
//    }
    [[NSNotificationCenter defaultCenter] postNotificationName:WMSAppDelegateReSyncData object:nil];
}

#pragma mark - 后台保持与BLE设备通讯，以防断开
- (void)startCommunication
{
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    
    if (_backgroundTimer && [_backgroundTimer isValid]) {
        [_backgroundTimer invalidate];
        _backgroundTimer = nil;
    }
    _backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(communication) userInfo:nil repeats:YES];
}
- (void)stopCommunication
{
    if (_backgroundTimer) {
        if ([_backgroundTimer isValid]) {
            [_backgroundTimer invalidate];
            _backgroundTimer = nil;
        }
    }
}
- (void)communication
{
    DEBUGLog(@"communication .....");
    //发送一个命令，保持蓝牙连接
    [self.wmsBleControl.deviceProfile readDeviceSoftwareVersion:NULL];
    
    if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 61.0) {
        [[GGAudioTool sharedInstance] playSilentSound];
        
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    }
}

#pragma mark -  Notifications
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidDisConnectPeripheral:) name:WMSBleControlPeripheralDidDisConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedConnectPeripheral:) name:WMSBleControlPeripheralConnectFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScanPeripheralFinish:) name:WMSBleControlScanFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUpdatedBLEState:) name:WMSBleControlBluetoothStateUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralDidStartDFU:) name:WMSUpdateVCStartDFU object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralDidEndDFU:) name:WMSUpdateVCEndDFU object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSystemTimeZoneDidChange:) name:NSSystemTimeZoneDidChangeNotification object:nil];///系统时区改变时的通知
}
- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Handle
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    if ([WMSMyAccessory isBindAccessory]) {
        [self connectedConfigure];
    }
}
- (void)handleDidDisConnectPeripheral:(NSNotification *)notification
{
    [[WMSDeviceModel deviceModel] resetDevice];
    //只有绑定了配件，在断开后才去重连
    if ([WMSMyAccessory isBindAccessory])
    {
        LGPeripheral *p = (LGPeripheral *)notification.object;
        [self scanAndConnectPeripheral:p];
    }
}
- (void)handleFailedConnectPeripheral:(NSNotification *)notification
{
    //只有绑定了配件，在断开后才去重连
    if ([WMSMyAccessory isBindAccessory])
    {
        [self scanAndConnectPeripheral:nil];
    }
}
- (void)handleScanPeripheralFinish:(NSNotification *)notification
{
    if ([WMSMyAccessory isBindAccessory]) {
        [self scanAndConnectPeripheral:nil];
    }
}
- (void)handleUpdatedBLEState:(NSNotification *)notification
{
    DEBUGLog(@"ble state: %d", (int)self.wmsBleControl.bleState);
    switch ([self.wmsBleControl bleState]) {
        case WMSBleStateResetting:
        case WMSBleStatePoweredOff:
            break;
        case WMSBleStatePoweredOn:
        {
            if ([WMSMyAccessory isBindAccessory]) {
                [self scanAndConnectPeripheral:nil];
            }
            break;
        }
        default:
            break;
    }
}

- (void)scanAndConnectPeripheral:(LGPeripheral *)peripheral
{
    switch ([self.wmsBleControl bleState]) {
        case WMSBleStateResetting:
        case WMSBleStatePoweredOff:
            return;
        default:
            break;
    }
    if ([self.wmsBleControl isConnecting]||[self.wmsBleControl isConnected])
    {
        return ;
    }
    if (_isStartDFU==YES) {
        return ;
    }
    if (peripheral/* && [self.wmsBleControl isHasBeenSystemConnectedPeripheral:peripheral]*/) {
        [self.wmsBleControl connect:peripheral];
    } else {
        WeakObj(self, weakSelf);
        [self.wmsBleControl scanForPeripheralsByInterval:SCAN_PERIPHERAL_INTERVAL scanning:^(LGPeripheral *peripheral) {
            StrongObj(weakSelf, strongSelf);
            BOOL hasBeenConnected = [strongSelf.wmsBleControl isHasBeenSystemConnectedPeripheral:peripheral];
            if ([WMSMyAccessory isBindAccessory]/* && hasBeenConnected*/) {
                NSString *uuid = [WMSMyAccessory identifierForbindAccessory];
                if ([peripheral.UUIDString isEqualToString:uuid])
                {
                    [strongSelf.wmsBleControl connect:peripheral];
                }
            }
        } completion:NULL];
    }
}

- (void)connectedConfigure
{
    if (self.isAdjustTimeWhenConnected) {
        [self adjustWatchTimeWhenSystemTimeZoneDidChange];
    }
}

#pragma mark - DFU
- (void)peripheralDidStartDFU:(NSNotification *)notification
{
    _isStartDFU = YES;
}
- (void)peripheralDidEndDFU:(NSNotification *)notification
{
    _isStartDFU = NO;
    //唤醒扫描
    [self scanAndConnectPeripheral:nil];
}

#pragma mark - Other
///报警
- (void)alarmWhenDisconnect
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FileDocumentPath(FILE_ANTILOST)];
    BOOL status = [readData[@"on"] boolValue];
    if (status || YES) {
        NSTimeInterval interval = [readData[@"interval"] integerValue];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playAlarmSound) object:nil];
        [self performSelector:@selector(playAlarmSound) withObject:nil afterDelay:interval];
    }
}
- (void)playAlarmSound
{
    if (!self.soundOperation) {
        _soundOperation = [[WMSSoundOperation alloc] init];
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sound_alarm" ofType:@"m4r"];
    [self.soundOperation playSoundWithFile:filePath duration:-1];
}

#pragma mark - Time zone
#define KPreviousTimeZoneName       @"com.WMSAppDelegate.previousTimeZoneName"
#define SECOND_OF_ONE_HOUR          (1*60*60)
#define CLOCK_CYCLE                 12
#define CLOCK_HALF_CYCLE            6
- (void)handleSystemTimeZoneDidChange:(NSNotification *)notification
{
    [self adjustWatchTimeWhenSystemTimeZoneDidChange];
}

- (void)adjustWatchTimeWhenSystemTimeZoneDidChange
{
    if (!self.wmsBleControl.isConnected) {
        self.adjustTimeWhenConnected = YES;
        return ;
    }
    self.adjustTimeWhenConnected = NO;
    [NSTimeZone resetSystemTimeZone];
    NSString *previousTimeZoneName = [[NSUserDefaults standardUserDefaults] objectForKey:KPreviousTimeZoneName];
    if (!previousTimeZoneName) {
        previousTimeZoneName = @"Asia/Shanghai";///默认为中国时区
    }
    NSTimeZone *curTimeZone = [NSTimeZone systemTimeZone];
    NSTimeZone *previousTimeZone = [NSTimeZone timeZoneWithName:previousTimeZoneName];
    NSInteger timeDifference = [curTimeZone timeDifferenceSinceTimeZone:previousTimeZone];///返回值单位为秒
    timeDifference = timeDifference/SECOND_OF_ONE_HOUR;///转换为小时
    if ((abs(timeDifference)%CLOCK_CYCLE) == 0) {
        return ;
    }
    NSInteger interval = 0;
    ROTATE_DIRECTION direction = 0;
    NSInteger abs_timeDifference = abs(timeDifference)%CLOCK_CYCLE;
    if (abs_timeDifference > CLOCK_HALF_CYCLE) {
        interval = CLOCK_CYCLE - abs_timeDifference;
        direction = (timeDifference>0 ? DIRECTION_anticlockwise : DIRECTION_clockwise);
    } else {
        interval = abs_timeDifference;
        direction = (timeDifference<0 ? DIRECTION_anticlockwise : DIRECTION_clockwise);
    }
    
    ///先将时间同步过去，再调整时间
    WeakObj(self, weakSelf);
    [self.wmsBleControl.settingProfile adjustDate:[NSDate systemDate] completion:^(BOOL isSuccess) {
        StrongObj(weakSelf, strongSelf);
        [strongSelf.wmsBleControl.settingProfile roughAdjustmentTimeWithDirection:direction timeInterval:interval completion:NULL];
        [[NSUserDefaults standardUserDefaults] setObject:curTimeZone.name forKey:KPreviousTimeZoneName];
    }];
    DEBUGLog(@"%@调整%d个小时", (direction==DIRECTION_clockwise?@"顺时针":@"逆时针"), (int)interval);
}

- (void)checkCurrentTimeZone
{
    NSString *currentTimeZoneName = [[NSTimeZone systemTimeZone] name];
    NSString *previousTimeZoneName = [[NSUserDefaults standardUserDefaults] objectForKey:KPreviousTimeZoneName];
    if (!previousTimeZoneName) {
        previousTimeZoneName = @"Asia/Shanghai";///默认为中国时区
    }
    if ([currentTimeZoneName isEqualToString:previousTimeZoneName]) {
        return ;
    }
    [self adjustWatchTimeWhenSystemTimeZoneDidChange];
}

#pragma mark - 通过fir.im平台，检查是否有更新
- (void)checkAppUpdatesFromFirPlatform
{
    ///使用 BundleID 进行检查更新
    ///see http://bughd.com/doc/ios-version-update
    NSString *bundleId = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    NSString *apiToken = @"337055ba6359308f20197dc8697562e4";
    NSString *bundleIdUrlString = [NSString stringWithFormat:@"http://api.fir.im/apps/latest/%@?api_token=%@", bundleId, apiToken];
    NSURL *requestURL = [NSURL URLWithString:bundleIdUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            //do something
            DEBUGLog(@"connectionError: %@", connectionError.localizedDescription);
        }else {
            NSError *jsonError = nil;
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError && [object isKindOfClass:[NSDictionary class]]) {
                //do something
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self analyzingInfoFromFirPlatform:object];
                });
            } else {
                DEBUGLog(@"jsonError: %@, object: %@", jsonError.localizedDescription, object);
            }
        }
    }];
}

- (void)analyzingInfoFromFirPlatform:(NSDictionary *)info
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString *newVersion = info[@"versionShort"];
    self.appUpdateUrlFromFir = info[@"update_url"];
    NSComparisonResult res = [currentVersion compare:newVersion options:NSCaseInsensitiveSearch];
    if (res == NSOrderedAscending) {///有更新
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ALERTVIEW_TITLE message:ALERTVIEW_MESSAGE delegate:self cancelButtonTitle:ALERTVIEW_CANCEL_TITLE otherButtonTitles:NSLocalizedString(@"现在更新", nil), nil];
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        ;
    } else {
        UIApplication *application = [UIApplication sharedApplication];
        if (self.appUpdateUrlFromFir) {
//            if ([application canOpenURL:[NSURL URLWithString:self.appUpdateUrlFromFir]]) {///适配iOS9，使用canOpenURL:方法需要将url加入白名单中
                [application openURL:[NSURL URLWithString:self.appUpdateUrlFromFir]];
//            }
        }
    }
}

@end
