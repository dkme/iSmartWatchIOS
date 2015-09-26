//
//  WMSTestingProfile.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/30.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "testing.h"

@class WMSBleControl;


typedef void(^monitorCallback)(ControlKey control, ButtonType button);
typedef void(^testSensorCallback)(NSInteger value);

@interface WMSTestingProfile : NSObject

- (id)initWithBleControl:(WMSBleControl *)bleControl;

///测试LED灯
- (void)testLEDWithType:(LEDType)type
                 status:(BOOL)openOrClose;

///测试马达
- (void)testMotor:(BOOL)openOrClose;

///测试显示屏
- (void)testDisplay:(BOOL)openOrClose;

///测试机芯齿轮
- (void)testMovementGear:(GEAR_TURN_DIRECTION)direction;

///监听按键
- (void)monitorDeviceButton:(monitorCallback)aCallback;

///测试传感器
- (void)testSensor:(testSensorCallback)aCallback;

@end
