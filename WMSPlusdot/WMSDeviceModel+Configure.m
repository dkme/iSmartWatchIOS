//
//  WMSDeviceModel+Configure.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-16.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSDeviceModel+Configure.h"
#import "NSDate+Formatter.h"

@implementation WMSDeviceModel (Configure)

+ (void)readDeviceInfo:(WMSBleControl *)bleControl
            completion:(readInfoCallBack)callBack;
{
    [bleControl.deviceProfile readDeviceInfoWithCompletion:^(NSUInteger energy, NSUInteger version, NSUInteger todaySteps, NSUInteger todaySportDurations, DeviceWorkStatus workStatus, NSUInteger deviceID, BOOL isPaired) {
        [WMSDeviceModel deviceModel].batteryEnergy = (int)energy;
        [WMSDeviceModel deviceModel].version = version;
        if (callBack) {
            callBack(energy,version);
        }
    }];
}

+ (void)readDevicedetailInfo:(WMSBleControl *)bleControl
                  completion:(readInfoCallBack2)callBack
{
    [bleControl.deviceProfile readDeviceInfoWithCompletion:^(NSUInteger energy, NSUInteger version, NSUInteger todaySteps, NSUInteger todaySportDurations, DeviceWorkStatus workStatus, NSUInteger deviceID, BOOL isPaired) {
        [WMSDeviceModel deviceModel].batteryEnergy = (int)energy;
        [WMSDeviceModel deviceModel].version = version;
        if (callBack) {
            callBack(energy,version,workStatus,deviceID,isPaired);
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
