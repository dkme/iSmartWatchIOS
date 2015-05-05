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

+ (void)readDeviceMac:(WMSBleControl *)bleControl
           completion:(readDeviceMac)callback
{
    [bleControl.deviceProfile readDeviceMac:^(NSString *mac) {
        [WMSDeviceModel deviceModel].mac = mac;
        if (callback) {
            callback(mac);
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

+ (void)readDeviceBatteryInfo:(WMSBleControl *)bleControl
                   completion:(readDeviceBatteryInfo)callback
{
    [bleControl.deviceProfile readDeviceBatteryInfo:^(BatteryType type, BatteryStatus status, float voltage, float percentage) {
        [self deviceModel].voltage = voltage;
        if (callback) {
            callback(voltage);
        }
    }];
}

@end
