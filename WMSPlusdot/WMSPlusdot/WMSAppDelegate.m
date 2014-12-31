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
#import "WMSBleControl.h"

#import "WMSHelper.h"
#import "WMSPostNotificationHelper.h"
#import "WMSAppConfig.h"
#import "WMSConstants.h"

#import "GGAudioTool.h"

#import <AVFoundation/AVFoundation.h>

@interface WMSAppDelegate ()<RESideMenuDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation WMSAppDelegate
{
    NSTimer *_backgroundTimer;
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
        
        sideMenu.contentViewController = [[UINavigationController alloc] initWithRootViewController:contentVC];
        sideMenu.leftMenuViewController = leftVC;
        sideMenu.rightMenuViewController = rightVC;
        sideMenu.backgroundImage = [UIImage imageNamed:@"main_bg.png"];
        sideMenu.delegate = self;
        
        _reSideMenu = sideMenu;
    }
    return _reSideMenu;
}

#pragma mark - 启动

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    

    [WMSPostNotificationHelper cancelAllNotification];
    
    _wmsBleControl  = [[WMSBleControl alloc] init];
    
    [self setupApp];
    
    if ([WMSHelper isFirstLaunchApp]) {
        self.window.rootViewController = [WMSGuideVC guide];
        [self.window makeKeyAndVisible];
        return YES;
    }

    self.window.rootViewController = [self reSideMenu];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    DEBUGLog(@"%s",__FUNCTION__);
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DEBUGLog(@"%s",__FUNCTION__);
    [WMSPostNotificationHelper resetAllNotification];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
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

#pragma mark - Private
- (void)setupApp
{
    //设置导航栏的颜色，标题字体和颜色
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGBAlpha(0x00D5E1, 1)];
    //[[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //阴影
    //NSShadow *shadow = [[NSShadow alloc] init];
    //shadow.shadowColor = UIColorFromRGBAlpha(0x000000, 0.8);
    //shadow.shadowOffset = CGSizeMake(0, 0);
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName:[UIColor whiteColor],
                                 /*NSShadowAttributeName:shadow*/
                                  };
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)tik{
    DEBUGLog(@"tick .....");
    if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 61.0) {
        [[GGAudioTool sharedInstance] playSilentSound];
        
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    }
}

@end
