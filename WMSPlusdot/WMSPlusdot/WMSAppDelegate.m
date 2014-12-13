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
#import "WMSConstants.h"

#import <AVFoundation/AVFoundation.h>

@interface WMSAppDelegate ()<RESideMenuDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation WMSAppDelegate

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
        //WMSBindingAccessoryViewController *contentVC = [[WMSBindingAccessoryViewController alloc] init];
        //WMSMyAccessoryViewController *contentVC = [[WMSMyAccessoryViewController alloc] init];
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

- (void)localNotification
{
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        NSDate *now = [NSDate date];
        //从现在开始，10秒以后通知
        notification.fireDate=[now dateByAddingTimeInterval:10];
        //使用本地时区
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.alertBody=@"顶部提示内容，通知时间到啦";
        //通知提示音 使用默认的
        notification.soundName= UILocalNotificationDefaultSoundName;
        notification.alertAction=NSLocalizedString(@"你锁屏啦，通知时间到啦", nil);
        //这个通知到时间时，你的应用程序右上角显示的数字。
        notification.applicationIconBadgeNumber = 1;
        //add key  给这个通知增加key 便于半路取消。nfkey这个key是我自己随便起的。
        // 假如你的通知不会在还没到时间的时候手动取消 那下面的两行代码你可以不用写了。
        NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:10],@"nfkey",nil];
        [notification setUserInfo:dict];
        //启动这个通知
        DEBUGLog(@"启动这个通知");
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
        //这句真的特别特别重要。如果不加这一句，通知到时间了，发现顶部通知栏提示的地方有了，然后你通过通知栏进去，然后你发现通知栏里边还有这个提示
        //除非你手动清除，这当然不是我们希望的。加上这一句就好了。网上很多代码都没有，就比较郁闷了。
        //[notification release];
    }
}

#pragma mark - 启动

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    _wmsBleControl  = [[WMSBleControl alloc] init];
    
    [self setupApp];
    
    //[self localNotification];
    
//    if ([WMSHelper isFirstLaunchApp]) {
//        self.window.rootViewController = [WMSGuideVC guide];
//        [self.window makeKeyAndVisible];
//        return YES;
//    }
    

    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_LOGIN_INFO)];
    if (readData && ![[readData objectForKey:@"userName"] isEqualToString:@""]) {//已经登陆过
        self.window.rootViewController = [self reSideMenu];
    } else {
        self.window.rootViewController = [self loginNavigationCtrl];
    }

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    DEBUGLog(@"来电话了------------------");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DEBUGLog(@"进入后台了");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DEBUGLog(@"进入前台了");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    DEBUGLog(@"BecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Private
- (void)setupApp
{
    //设置导航栏的颜色，标题字体和颜色
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGBAlpha(0x00D5E1, 1)];
    //[[UINavigationBar appearance] setTranslucent:YES];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = UIColorFromRGBAlpha(0x000000, 0.8);
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor],NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName
                                                          , nil]];//[UIFont fontWithName:@"DIN Condensed" size:35.f],NSFontAttributeName
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - RESideMenuDelegate
- (void)sideMenu:(RESideMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer
{
    DEBUGLog(@"didRecognizePanGesture: %@", NSStringFromClass([sideMenu.contentViewController class]));
}
- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    DEBUGLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
    if ([@"WMSRightViewController" isEqualToString:
         NSStringFromClass([menuViewController class])]
        )
    {
        sideMenu.scaleContentView = NO;
    } else {
        sideMenu.scaleContentView = YES;
    }
    
    //当显示“设置目标”界面时，禁用左划手势
//    if ([UINavigationController class] != [sideMenu.contentViewController class]) {
//        return ;
//    }
//    UINavigationController *nav = (UINavigationController *)sideMenu.contentViewController;
//    NSString *vcClassName = NSStringFromClass([nav.topViewController class]);
//    if ([@"WMSContent2ViewController" isEqualToString:vcClassName]) {
//        if ([@"WMSRightViewController" isEqualToString:
//             NSStringFromClass([menuViewController class])])
//        {
//            sideMenu.panGestureEnabled = NO;
//        }
//    }
}
- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    DEBUGLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
    if ([@"WMSRightViewController" isEqualToString:
         NSStringFromClass([menuViewController class])]
        ) {
        sideMenu.scaleContentView = YES;
    }
}

@end
