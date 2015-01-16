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
        _batteryEnergy = 0;
        _version = 0.0;
    }
    return self;
}
- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}

- (void)resetDevice
{
    [WMSDeviceModel deviceModel].version = 0;
    [WMSDeviceModel deviceModel].batteryEnergy = 0;
}

@end
