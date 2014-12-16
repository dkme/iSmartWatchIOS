//
//  WMSRightVCHelper.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-16.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSRightVCHelper.h"

#define LOW_BATTERY_LEVEL1       0.20f
#define LOW_BATTERY_LEVEL2       0.15f
#define LOW_BATTERY_LEVEL3       0.10f
#define LOW_BATTERY_LEVEL4       0.05f
#define LOW_BATTERY_REMIND_TIMEINTERVAL 20

@implementation WMSRightVCHelper

+ (BOOL)isSendLowBatteryRemind:(float)batteryLevel
{
    if (batteryLevel == LOW_BATTERY_LEVEL1 ||
        batteryLevel == LOW_BATTERY_LEVEL2 ||
        batteryLevel == LOW_BATTERY_LEVEL3 ||
        batteryLevel == LOW_BATTERY_LEVEL4)
    {
        return YES;
    }
    return NO;
}
+ (void)startLowBatteryRemind:(WMSSettingProfile *)setting
                   completion:(void(^)(void))aCallBack
{
    __weak __typeof(&*setting) weakSetting = setting;
    [weakSetting startRemind:OtherRemindTypeLowBattery completion:^(BOOL success) {
        DEBUGLog(@"开启低电量提醒成功");
        __strong __typeof(&*setting) strongSetting = weakSetting;
        if (strongSetting) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishLowBatteryRemind:) object:strongSetting];
            [self performSelector:@selector(finishLowBatteryRemind:) withObject:strongSetting afterDelay:LOW_BATTERY_REMIND_TIMEINTERVAL];
            if (aCallBack) {
                aCallBack();
            }
        }
    }];
}
+ (void)finishLowBatteryRemind:(WMSSettingProfile *)setting
{
    [setting finishRemind:OtherRemindTypeLowBattery completion:^(BOOL success) {
        DEBUGLog(@"停止低电量提醒成功");
    }];
}

- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}

@end
