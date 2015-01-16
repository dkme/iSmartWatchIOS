//
//  WMSDeviceModel+Configure.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-16.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSDeviceModel+Configure.h"
#import "NSDate+Formatter.h"
#import "WMSBluetooth.h"

@implementation WMSDeviceModel (Configure)

+ (void)readDeviceInfo:(WMSBleControl *)bleControl
            completion:(readInfoCallBack)callBack;
{
    [bleControl.deviceProfile readDeviceInfoWithCompletion:^(NSUInteger batteryEnergy, NSUInteger version, NSUInteger todaySteps, NSUInteger todaySportDurations, NSUInteger endSleepMinute, NSUInteger endSleepHour, NSUInteger sleepDurations, DeviceWorkStatus workStatus, BOOL success)
     {
         [WMSDeviceModel deviceModel].batteryEnergy = batteryEnergy;
         [WMSDeviceModel deviceModel].version = version;
         if (callBack) {
             callBack(batteryEnergy,version);
         }
     }];
}
+ (void)setDeviceDate:(WMSBleControl *)bleControl
               completion:(setDateCallBack)callback
{
    [bleControl.settingProfile setCurrentDate:[NSDate systemDate] completion:^(BOOL success)
     {
         if (callback) {
             callback();
         }
     }];
}

@end
