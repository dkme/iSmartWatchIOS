//
//  WMSDeviceProfile.m
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSDeviceProfile.h"
#import "WMSBleControl.h"
//#import "BLEUtils.h"
#include "parse.h"

NSString * const DevicePowerChangedNotification = @"WMSDeviceProfile.DevicePowerChangedNotification";

@interface WMSDeviceProfile ()

@property (nonatomic, strong) WMSBleControl *bleControl;
@property (nonatomic, strong) LGCharacteristic *serialPortWriteCharacteristic;

@end

@implementation WMSDeviceProfile

#pragma mark - Init
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
    //LGCharacteristic *batteryCharacteristic = [self.bleControl findCharactWithUUID:CHARACTERISTIC_BATTERY_UUID];
    
    //[self.bleControl characteristic:batteryCharacteristic enableNotify:YES withTimeID:TimeIDEnableNotifyForBatteryCharacteristic];
}
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidGetNotifyValue:) name:LGCharacteristicDidNotifyValueNotification object:nil];
}
- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)dealloc
{
    _bleControl = nil;
    _serialPortWriteCharacteristic = nil;

    [self unregisterFromNotifications];
}

#pragma mark - Public Methods

- (void)readDeviceFirm:(deviceFirmCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = readDeviceFirm(&p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_READ_DEVICE_FIRM_NAME];
}

- (void)readDeviceProductModel:(deviceProductModelCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = readDeviceProductModel(&p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_READ_DEVICE_PRODUCT_MODEL];
}

- (void)readDeviceHardwareVersion:(deviceVersionCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = readDeviceHardwareVersion(&p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_READ_DEVICE_HARDWARE_VERSION];
}

- (void)readDeviceFirmwareVersion:(deviceVersionCallback)aCallback
{
//    if (aCallback) {
//        [self.bleControl.stackManager pushObj:aCallback toStackOfTimeID:TIME_ID_READ_DEVICE_FIRMWARE_VERSION];
//    }
//    [self.readFirmwareVersionCharacteristic readValueWithBlock:^(NSData *data, NSError *error) {
//        if (error) {
//            DEBUGLog_DETAIL(@"读取数据错误，主动断开");
//            [self.bleControl disconnectWithReason:@"读取数据错误，app主动断开"];
//            return ;
//        }
//        BLE_UInt8 package[PACKAGE_SIZE] = {0};
//        [data getBytes:package length:PACKAGE_SIZE];
//        float version = 0;
//        int res = getDeviceFirmwareVersion(package, PACKAGE_SIZE, &version);
//        if (res == HANDLE_OK) {
//            deviceVersionCallback popCallback = [self.bleControl.stackManager popObjFromStackOfTimeID:TIME_ID_READ_DEVICE_FIRMWARE_VERSION];
//            if (popCallback) {
//                popCallback(version);
//            }
//        }
//    }];
    
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = readDeviceFirmwareVersion(&p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_READ_DEVICE_FIRMWARE_VERSION];
}

- (void)readDeviceSoftwareVersion:(deviceVersionCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = readDeviceSoftwareVersion(&p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_READ_DEVICE_SOFTWARE_VERSION];
}

- (void)readDeviceMACAddress:(deviceMACAddressCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = readDeviceMacAddress(&p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_READ_DEVICE_MAC_ADDRESS];
}

- (void)readDeviceBatteryInfo:(deviceBatteryInfoCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = readDeviceBatteryInfo(&p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_READ_DEVICE_BATTERY_INFO];
}


#pragma mark - Handle
- (void)handleDidGetNotifyValue:(NSNotification *)notification
{
    NSError *error = notification.object;
    NSData *value = [notification.userInfo objectForKey:KLGNotifyValue];
    LGCharacteristic *charact = [notification.userInfo objectForKey:KLGNotifyCharacteristic];
    
    NSString *uuid = charact.UUIDString;
    if (error) {
        DEBUGLog_DETAIL(@"通知错误，主动断开, uuid:%@", uuid);
        [self.bleControl disconnectWithReason:@"通知错误，app主动断开"];
        return;
    }
    
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    [value getBytes:package length:PACKAGE_SIZE];
    struct_parse_package s_pg = parse(package, PACKAGE_SIZE);
    BLE_UInt8 cmd = s_pg.cmd;
    BLE_UInt8 key = s_pg.key;
    
    int handleRes = 0;//处理结果
    
    if ([CHARACTERISTIC_SERIAL_PORT_READ_UUID isEqualToString:uuid]) {
        switch (CMD_KEY(cmd, key)) {
                
            case CMD_KEY(CMD_readDeviceInfo, ReadDeviceFirmName):
            {
                DeviceFirms firm = getDeviceFirm(package, PACKAGE_SIZE);
                if (firm != FIRM_Unknown) {
                    deviceFirmCallback aCallback = [self.bleControl.stackManager popObjFromStackOfTimeID:TIME_ID_READ_DEVICE_FIRM_NAME];
                    if (aCallback) {
                        static NSDictionary *firmsMap = nil;
                        if (!firmsMap) {
                            firmsMap = @{
                                         @(0x01)        : @"nordic",
                                         };
                        }
                        aCallback(firmsMap[@(firm)]);
                    }
                }
                break;
            }
                
            case CMD_KEY(CMD_readDeviceInfo, ReadDeviceProductModel):
            {
                ProductModels model = getDeviceProductModel(package, PACKAGE_SIZE);
                if (model != MODEL_Unknown) {
                    deviceProductModelCallback aCallback = [self.bleControl.stackManager popObjFromStackOfTimeID:TIME_ID_READ_DEVICE_PRODUCT_MODEL];
                    if (aCallback) {
                        aCallback(model);
                    }
                }
            }
             
            case CMD_KEY(CMD_readDeviceInfo, ReadDeviceHardwareVersion):
            {
                float version = getDeviceHardwareVersion(package, PACKAGE_SIZE);
                if (handleRes != 0) {
                    deviceVersionCallback aCallback = [self.bleControl.stackManager popObjFromStackOfTimeID:TIME_ID_READ_DEVICE_HARDWARE_VERSION];
                    if (aCallback) {
                        aCallback(version);
                    }
                }
                break;
            }
                
            case CMD_KEY(CMD_readDeviceInfo, ReadDeviceFirmwareVersion):
            {
                float version = getDeviceFirmwareVersion(package, PACKAGE_SIZE);
                if (handleRes != 0) {
                    deviceVersionCallback aCallback = [self.bleControl.stackManager popObjFromStackOfTimeID:TIME_ID_READ_DEVICE_FIRMWARE_VERSION];
                    if (aCallback) {
                        aCallback(version);
                    }
                }
                break;
            }
                
            case CMD_KEY(CMD_readDeviceInfo, ReadDeviceSoftwareVersion):
            {
                float version = getDeviceSoftwareVersion(package, PACKAGE_SIZE);
                if (handleRes != 0) {
                    deviceVersionCallback aCallback = [self.bleControl.stackManager popObjFromStackOfTimeID:TIME_ID_READ_DEVICE_SOFTWARE_VERSION];
                    if (aCallback) {
                        aCallback(version);
                    }
                }
                break;
            }
                
            case CMD_KEY(CMD_readDeviceInfo, ReadDeviceMacAddress):
            {
                Struct_MacAddress res = getDeviceMacAddress(package, PACKAGE_SIZE);
                if (res.error == HANDLE_OK) {
                    deviceMACAddressCallback aCallback = [self.bleControl.stackManager popObjFromStackOfTimeID:TIME_ID_READ_DEVICE_MAC_ADDRESS];
                    if (aCallback) {
                        NSString *macAddress = @"";
                        for (int i=0; i<MAC_ADDRESS_LENGTH; i++) {
                            macAddress = [macAddress stringByAppendingFormat:@"%02X", res.mac[i]];
                            if (i < MAC_ADDRESS_LENGTH-1) {
                                macAddress = [macAddress stringByAppendingString:@":"];
                            }
                        }
                        aCallback(macAddress);
                    }
                }
                break;
            }
                
            case CMD_KEY(CMD_readDeviceInfo, ReadDeviceBatteryInfo):
            {
                Struct_BatteryInfo res = getDeviceBatteryInfo(package, PACKAGE_SIZE);
                if (res.error == HANDLE_OK) {
                    deviceBatteryInfoCallback aCallback = [self.bleControl.stackManager popObjFromStackOfTimeID:TIME_ID_READ_DEVICE_BATTERY_INFO];
                    if (aCallback) {
                        aCallback(res.type, res.status);
                    }
                }
            }
            default:
                break;
        }///switch
    }///if
//    else if ([CHARACTERISTIC_BATTERY_UUID isEqualToString:uuid])
//    {
//        BLE_UInt8 power = getDevicePower(package, PACKAGE_SIZE);
//        if (power != 0) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:DevicePowerChangedNotification object:@(power) userInfo:nil];
//        }
//    }
}

@end
