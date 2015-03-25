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

#import "GGAudioTool.h"

#import <AVFoundation/AVFoundation.h>

NSString *const WMSAppDelegateReSyncData = @"com.ios.plusdot.WMSAppDelegateReSyncData";
NSString *const WMSAppDelegateNewDay = @"com.ios.plusdot.WMSAppDelegateReSyncData";

@interface WMSAppDelegate ()<RESideMenuDelegate>
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
    
    _wmsBleControl = [[WMSBleControl alloc] init];
    [WMSPostNotificationHelper cancelAllNotification];
    [self setupReSyncDataTimer];
    [self setupAppAppearance];
    [self registerForNotifications];
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
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    
    if (_backgroundTimer && [_backgroundTimer isValid]) {
        [_backgroundTimer invalidate];
        _backgroundTimer = nil;
    }
    _backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(tik) userInfo:nil repeats:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DEBUGLog(@"%s",__FUNCTION__);
    [_backgroundTimer invalidate];
    _backgroundTimer = nil;
    
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
//        navBar.barStyle = UIBarStyleBlackTranslucent;
//        navBar.translucent = YES;
    }
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName:[UIColor whiteColor],
                                 NSFontAttributeName:Font_DINCondensed(20.f),
                                  };
    [navBar setTitleTextAttributes:attributes];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
//#pragma mark - 后台计时，在00:00发送同步命令
- (void)setupReSyncDataTimer
{
    NSDate *today = [NSDate systemDate];
    NSDate *tomorrow = [NSDate dateWithTimeInterval:24*60*60 sinceDate:today];
    NSString *strDate = [NSString stringWithFormat:@"%04d-%02d-%02d 00:00:00",[NSDate yearOfDate:tomorrow],[NSDate monthOfDate:tomorrow],[NSDate dayOfDate:tomorrow]];
    NSDate *targetDate = [NSDate dateFromString:strDate format:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeInterval interval = [targetDate timeIntervalSinceDate:today];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncData) object:nil];
    [self performSelector:@selector(syncData) withObject:nil afterDelay:interval];
}
- (void)syncData
{
    DEBUGLog(@"%s",__FUNCTION__);
    [[NSNotificationCenter defaultCenter] postNotificationName:WMSAppDelegateReSyncData object:nil];
}

#pragma mark - other methods
- (void)tik
{
    DEBUGLog(@"tick .....");
    //发送一个命令，保持蓝牙连接
    [self keepBLEConnection];
    
    if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 61.0) {
        [[GGAudioTool sharedInstance] playSilentSound];
        
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    }
}
- (void)keepBLEConnection
{
    [_wmsBleControl.deviceProfile readDeviceTimeWithCompletion:^(NSString *dateString, BOOL success) {
        DEBUGLog(@"read device time %@",dateString);
    }];
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
}
- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Handle
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    [self connectedConfigure];
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

- (void)connectedConfigure
{
    if (![WMSMyAccessory isBindAccessory]) {
        return ;
    }
    [WMSDeviceModel setDeviceDate:self.wmsBleControl completion:^{
        [WMSDeviceModel readDevicedetailInfo:self.wmsBleControl completion:^(NSUInteger energy, NSUInteger version, DeviceWorkStatus workStatus, NSUInteger deviceID, BOOL isPaired) {
            if (!isPaired) {
                [self.wmsBleControl bindSettingCMD:BindSettingCMDMandatoryBind completion:nil];
            }
        }];
    }];
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
    if (peripheral) {
        [self.wmsBleControl connect:peripheral];
    } else {
        [self.wmsBleControl scanForPeripheralsByInterval:SCAN_PERIPHERAL_INTERVAL completion:^(NSArray *peripherals)
         {
             LGPeripheral *p = [peripherals lastObject];
             if ([WMSMyAccessory isBindAccessory]) {
                 NSString *uuid = [WMSMyAccessory identifierForbindAccessory];
                 if ([p.UUIDString isEqualToString:uuid])
                 {
                     [self.wmsBleControl connect:p];
                 }
             }
         }];
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

@end
