//
//  WMSDeviceModel+Configure.h
//  WMSPlusdot
//
//  Created by Sir on 15-1-16.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSDeviceModel.h"
#import "WMSBluetooth.h"

typedef void(^readInfoCallBack)(NSUInteger batteryEnergy,NSUInteger version);
typedef void(^readInfoCallBack2)(NSUInteger energy,NSUInteger version,DeviceWorkStatus workStatus, NSUInteger deviceID, BOOL isPaired);
typedef void(^readDeviceMac)(NSString *mac);
typedef void(^setDateCallBack)(void);
typedef void(^readDeviceBatteryInfo)(float voltage);

@interface WMSDeviceModel (Configure)

+ (void)readDeviceInfo:(WMSBleControl *)bleControl
            completion:(readInfoCallBack)callBack;

+ (void)readDevicedetailInfo:(WMSBleControl *)bleControl
                  completion:(readInfoCallBack2)callBack;

+ (void)readDeviceMac:(WMSBleControl *)bleControl
           completion:(readDeviceMac)callback;

+ (void)setDeviceDate:(WMSBleControl *)bleControl
           completion:(setDateCallBack)callback;

+ (void)readDeviceBatteryInfo:(WMSBleControl *)bleControl
                   completion:(readDeviceBatteryInfo)callback;

@end
