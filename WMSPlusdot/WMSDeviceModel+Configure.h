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
typedef void(^setDateCallBack)(void);

@interface WMSDeviceModel (Configure)

+ (void)readDeviceInfo:(WMSBleControl *)bleControl
            completion:(readInfoCallBack)callBack;

+ (void)readDevicedetailInfo:(WMSBleControl *)bleControl
                  completion:(readInfoCallBack2)callBack;

+ (void)setDeviceDate:(WMSBleControl *)bleControl
               completion:(setDateCallBack)callback;

@end
