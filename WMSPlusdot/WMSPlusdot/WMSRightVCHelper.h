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

#pragma mark - 数据加载与保存
//社交提醒设置项的加载与保存
+ (NSDictionary *)loadSettingItemData;
+ (void)savaSettingItemForKey:(NSString *)key data:(NSObject *)object;

//低电量提醒设置项的加载与保存
+ (BOOL)lowBatteryRemind;
+ (void)setLowBatteryRemind:(BOOL)openOrClose;

//提醒方式设置项的加载与保存
+ (int)loadRemindWay;//0：不提醒，1：震动，2：响铃，3：震动+响铃
+ (void)savaRemindWay:(int)way;
+ (void)setRemindWay:(int)way
              handle:(WMSSettingProfile *)handle
          completion:(void(^)(BOOL))aCallBack;

#pragma mark - 第一次连接成功后，对设置项的配置
+ (void)resetFirstConnectedConfig;
+ (void)startFirstConnectedConfig:(WMSSettingProfile *)handle
                       completion:(void(^)(void))aCallBack;


@end
