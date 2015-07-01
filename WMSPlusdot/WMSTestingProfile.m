//
//  WMSTestingProfile.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/30.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSTestingProfile.h"
#import "WMSBleControl.h"
#include "parse.h"

@interface WMSTestingProfile ()

@property (nonatomic, strong) WMSBleControl *bleControl;

@property (nonatomic, strong) LGCharacteristic *serialPortWriteCharacteristic;

@property (nonatomic, copy) monitorCallback monitorBlock;

@end

@implementation WMSTestingProfile

- (id)initWithBleControl:(WMSBleControl *)bleControl
{
    if (self = [super init]) {
        _bleControl = bleControl;
        
        [self setup];
        [self registerForNotifications];
    }
    return self;
}
- (void)setup
{
    _serialPortWriteCharacteristic = [self.bleControl findCharactWithUUID:CHARACTERISTIC_SERIAL_PORT_WRITE_UUID];
}
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidGetNotifyValue:) name:LGCharacteristicDidNotifyValueNotification object:nil];
}
- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)testLEDWithType:(LEDType)type
                 status:(BOOL)openOrClose
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = testLED(type, openOrClose, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:nil withTimeID:-1];
}

- (void)testMotor:(BOOL)openOrClose
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = testMotor(openOrClose, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:nil withTimeID:-1];
}

- (void)testDisplay:(BOOL)openOrClose
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = testDisplay(openOrClose, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:nil withTimeID:-1];
}

- (void)monitorDeviceButton:(monitorCallback)aCallback
{
    LGCharacteristic *serialPortReadCharacteristic = [self.bleControl findCharactWithUUID:CHARACTERISTIC_SERIAL_PORT_READ_UUID];
    [self.bleControl characteristic:serialPortReadCharacteristic enableNotify:YES withTimeID:TimeIDEnableNotifyForSerialPortReadCharacteristic];
    self.monitorBlock = aCallback;
}

#pragma mark - Handle
- (void)handleDidGetNotifyValue:(NSNotification *)notification
{
    NSError *error = notification.object;
    NSData *value = [notification.userInfo objectForKey:KLGNotifyValue];
    LGCharacteristic *charact = [notification.userInfo objectForKey:KLGNotifyCharacteristic];
    
    NSString *uuid = charact.UUIDString;
    if (error) {
        DEBUGLog(@"通知错误，主动断开 %@",NSStringFromClass([self class]));
        [self.bleControl disconnectWithReason:@"通知错误，app主动断开"];
        return;
    }
    
    Byte package[PACKAGE_SIZE] = {0};
    [value getBytes:package length:PACKAGE_SIZE];
    struct_parse_package s_pg = parse(package, PACKAGE_SIZE);
    Byte cmd = s_pg.cmd;
//    Byte key = s_pg.key;
    
    if ([CHARACTERISTIC_SERIAL_PORT_READ_UUID isEqualToString:uuid]) {
        if (cmd == CMD_control) {
            Struct_Control res = getControlCommand(package, PACKAGE_SIZE);
            if (res.error != HANDLE_OK) {
                return ;
            }
            ///回调
            if (self.monitorBlock) {
                self.monitorBlock(res.control, res.button);
            }
            return ;
        }
    }
}

@end
