//
//  WMSDeviceProfile.h
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "reading.h"
@class WMSBleControl;

extern NSString * const DevicePowerChangedNotification;


//Block
typedef void(^deviceVersionCallback)(float version);
typedef void(^deviceMACAddressCallback)(NSString *MACAddress);
typedef void(^deviceFirmCallback)(NSString *firmName);
typedef void(^deviceProductModelCallback)(NSInteger model);
typedef void(^deviceBatteryInfoCallback)(BatteryType type, BatteryStatus status);

@interface WMSDeviceProfile : NSObject

/**
 初始化方法
 */
- (id)initWithBleControl:(WMSBleControl *)bleControl;///在初始化该profile时，订阅电池服务，监听设备的电量


///读取设备厂商名
- (void)readDeviceFirm:(deviceFirmCallback)aCallback;

///读取设备产品型号
- (void)readDeviceProductModel:(deviceProductModelCallback)aCallback;

///读取设备硬件版本
- (void)readDeviceHardwareVersion:(deviceVersionCallback)aCallback;

///读取设备固件版本
- (void)readDeviceFirmwareVersion:(deviceVersionCallback)aCallback;

///读取设备软件版本
- (void)readDeviceSoftwareVersion:(deviceVersionCallback)aCallback;

///读取设备MAC地址
- (void)readDeviceMACAddress:(deviceMACAddressCallback)aCallback;

///读取设备电池信息
- (void)readDeviceBatteryInfo:(deviceBatteryInfoCallback)aCallback;

@end
