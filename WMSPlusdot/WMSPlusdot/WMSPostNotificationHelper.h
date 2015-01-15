//
//  WMSPostNotificationHelper.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-15.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WMSPostNotificationHelper : NSObject

+ (void)cancelAllNotification;

+ (void)resetAllNotification;

+ (void)postSeachPhoneLocalNotification;

+ (void)postLowBatteryLocalNotification;

+ (void)postNotifyWithAlartBody:(NSString *)body;

@end
