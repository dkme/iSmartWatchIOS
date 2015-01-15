//
//  WMSPostNotificationHelper.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-15.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSPostNotificationHelper.h"

@implementation WMSPostNotificationHelper

+ (void)cancelAllNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    [application cancelAllLocalNotifications];
}

+ (void)resetAllNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber=0;
    int count = (int)[[application scheduledLocalNotifications] count];
    if(count>0)
    {
        NSMutableArray *newarry= [NSMutableArray arrayWithCapacity:0];
        for (int i=0; i<count; i++)
        {
            UILocalNotification *notif=[[application scheduledLocalNotifications] objectAtIndex:i];
            notif.applicationIconBadgeNumber=i+1;
            [newarry addObject:notif];
        }
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        if (newarry.count>0)
        {
            for (int i=0; i<newarry.count; i++)
            {
                UILocalNotification *notif = [newarry objectAtIndex:i];
                [[UIApplication sharedApplication] scheduleLocalNotification:notif];
            }
        }
    }
}

+ (void)postSeachPhoneLocalNotification
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType type = UIUserNotificationTypeAlert |
                    UIUserNotificationTypeBadge |
                    UIUserNotificationTypeSound ;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification) {
        NSDate *now = [NSDate date];
        //从现在开始，0秒以后通知
        notification.fireDate=[now dateByAddingTimeInterval:0];
        //使用本地时区
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.alertBody=NSLocalizedString(@"你的手机在这里~", nil);
        //通知提示音 使用默认的
        notification.soundName= UILocalNotificationDefaultSoundName;
        notification.alertAction=NSLocalizedString(@"你的手机在这里~", nil);
        //这个通知到时间时，你的应用程序右上角显示的数字. 获取当前的数字+1
        //notification.applicationIconBadgeNumber=[[[UIApplication sharedApplication] scheduledLocalNotifications] count]+1;
        notification.applicationIconBadgeNumber=[UIApplication sharedApplication].applicationIconBadgeNumber+1;
        
        //add key  给这个通知增加key 便于半路取消。nfkey这个key是我自己随便起的。
        // 假如你的通知不会在还没到时间的时候手动取消 那下面的两行代码你可以不用写了。
        NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:@"SeachPhone",@"nfkey",nil];
        [notification setUserInfo:dict];
        //启动这个通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        //这句真的特别特别重要。如果不加这一句，通知到时间了，发现顶部通知栏提示的地方有了，然后你通过通知栏进去，然后你发现通知栏里边还有这个提示
        //除非你手动清除，这当然不是我们希望的。加上这一句就好了。网上很多代码都没有，就比较郁闷了。
        //[notification release];
    }
}

+ (void)postLowBatteryLocalNotification
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType type = UIUserNotificationTypeAlert |
                UIUserNotificationTypeBadge |
                UIUserNotificationTypeSound ;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification) {
        NSDate *now = [NSDate date];
        notification.fireDate=[now dateByAddingTimeInterval:0];
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.alertBody=NSLocalizedString(@"你的手机没电了，快去充电吧！", nil);
        notification.soundName= UILocalNotificationDefaultSoundName;
        notification.alertAction=NSLocalizedString(@"你的手机没电了，快去充电吧！", nil);
        notification.applicationIconBadgeNumber=[UIApplication sharedApplication].applicationIconBadgeNumber+1;
        NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:@"LowBattery",@"nfkey",nil];
        [notification setUserInfo:dict];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

+ (void)postNotifyWithAlartBody:(NSString *)body
{
    static BOOL flag = YES;
    if (flag) {
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
        {
            UIUserNotificationType type = UIUserNotificationTypeAlert |
            UIUserNotificationTypeBadge |
            UIUserNotificationTypeSound ;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        }
        flag = NO;
    }
    
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification) {
        NSDate *now = [NSDate date];
        notification.fireDate=[now dateByAddingTimeInterval:0];
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.alertBody=body;
        notification.soundName= UILocalNotificationDefaultSoundName;
        notification.alertAction=body;
        notification.applicationIconBadgeNumber=[UIApplication sharedApplication].applicationIconBadgeNumber+1;
//        NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:@"LowBattery",@"nfkey",nil];
//        [notification setUserInfo:dict];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

@end
