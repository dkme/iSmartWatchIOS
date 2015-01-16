//
//  WMSDeviceModel+Configure.h
//  WMSPlusdot
//
//  Created by Sir on 15-1-16.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSDeviceModel.h"
@class WMSBleControl;

typedef void(^readInfoCallBack)(NSUInteger batteryEnergy,NSUInteger version);
typedef void(^setDateCallBack)(void);

@interface WMSDeviceModel (Configure)

+ (void)readDeviceInfo:(WMSBleControl *)bleControl
            completion:(readInfoCallBack)callBack;
+ (void)setDeviceDate:(WMSBleControl *)bleControl
               completion:(setDateCallBack)callback;

@end
