//
//  WMSDeviceModel.h
//  WMSPlusdot
//
//  Created by Sir on 14-10-9.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "reading.h"

@interface WMSDeviceModel : NSObject

@property (nonatomic, assign) double firmwareVersion;
@property (nonatomic, assign) double hardwareVersion;
@property (nonatomic, assign) double softwareVersion;
@property (nonatomic, strong) NSString *firmName;//厂商名
@property (nonatomic, assign) NSUInteger productModel;//产品型号
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, assign) double power;//电量，通过通知去获取
@property (nonatomic, assign) BatteryType batteryTypel;
@property (nonatomic, assign) BatteryStatus status;

+ (WMSDeviceModel *)deviceModel;

- (void)resetDevice;

@end
