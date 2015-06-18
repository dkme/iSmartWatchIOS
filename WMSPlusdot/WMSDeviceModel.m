//
//  WMSDeviceModel.m
//  WMSPlusdot
//
//  Created by Sir on 14-10-9.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSDeviceModel.h"

@implementation WMSDeviceModel

+ (WMSDeviceModel *)deviceModel
{
    static dispatch_once_t onceToken = 0;
    __strong static WMSDeviceModel *defaultObject = nil;
    dispatch_once(&onceToken, ^{
        defaultObject = [[WMSDeviceModel alloc] init];
    });
    return defaultObject;
}

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}
- (void)dealloc
{
    DEBUGLog_METHOD;
}

- (void)resetDevice
{
    self.mac = nil;
    self.firmName = nil;
    self.firmwareVersion = 0;
    self.hardwareVersion = 0;
    self.softwareVersion = 0;
    self.power = 0;
    self.batteryTypel = 0;
    self.status = 0;
    self.productModel = 0;
}

@end
