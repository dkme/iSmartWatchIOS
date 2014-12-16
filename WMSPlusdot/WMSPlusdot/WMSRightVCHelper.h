//
//  WMSRightVCHelper.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-16.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMSBluetooth.h"

@interface WMSRightVCHelper : NSObject

#pragma mark - 电量提醒
+ (BOOL)isSendLowBatteryRemind:(float)batteryLevel;
+ (void)startLowBatteryRemind:(WMSSettingProfile *)setting
                   completion:(void(^)(void))aCallBack;

@end
