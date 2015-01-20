//
//  WMSBleControl.h
//  WMSPlusdot
//
//  Created by John on 14-9-2.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGBluetooth.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "WMSMyTimers.h"

@class WMSSettingProfile;
@class WMSDeviceProfile;
@class WMSRemindProfile;

//Notification identifiers
/*
 *扫描结束时的通知
 */
extern NSString * const WMSBleControlScanFinish;

/*
 *外设连接成功时的通知
 */
extern NSString * const WMSBleControlPeripheralDidConnect;

/*
 *外设连接失败时的通知
 */
extern NSString * const WMSBleControlPeripheralConnectFailed;

/*
 *外设连接断开时的通知
 */
extern NSString * const WMSBleControlPeripheralDidDisConnect;

/*
 *蓝牙状态更新时的通知
 */
extern NSString * const WMSBleControlBluetoothStateUpdated;


//
typedef NS_ENUM(NSUInteger, ControlMode) {
    ControlModeRemote = 0x01,
    ControlModePlayMusic = 0x02,
    ControlModeNormal = 0xFF,
};

typedef NS_ENUM(NSUInteger, BindSettingCMD) {
    bindSettingCMDBind = 0x01,
    bindSettingCMDUnbind = 0x02,
    
    BindSettingCMDMandatoryBind = 0x03,
    BindSettingCMDMandatoryUnBind = 0x04,
};

//通讯命令字
typedef NS_ENUM(Byte, CMDType) {
    CMDSetCurrentDate = 0x01,
    CMDSetPersonInfo = 0x02,
    CMDSetAlarmClock = 0x03,
    CMDSetTarger = 0x04,
    CMDSetRemind = 0x05,
    CMDSetBinding = 0x07,
    CMDSetSportRemind = 0x08,
    CMDSetAntiLost = 0x09,
    
    CMDGetDeviceInfo = 0x0A,
    CMDGetDeviceTime = 0x0B,
    
    CMDSwitchControlMode = 0xF2,
    CMDSwitchUpdateMode = 0x30,
    CMDResetDevice = 0xF4,
};
//蓝牙状态
typedef NS_ENUM(NSInteger, WMSBleState) {
    WMSBleStateUnknown = 0,
    WMSBleStateResetting,
    WMSBleStateUnsupported,
    WMSBleStateUnauthorized,
    WMSBleStatePoweredOff,
    WMSBleStatePoweredOn,
};
//切换升级模式的返回结果
typedef NS_ENUM(NSInteger, SwitchToUpdateResult) {
    SwitchToUpdateResultSuccess = 0x00,
    SwitchToUpdateResultLowBattery = 0x01,
    SwitchToUpdateResultUnsupported = 0x02,
};

#define KEY_TIMEOUT_USERINFO_CHARACT    @"KEY_TIMEOUT_USERINFO_CHARACT"
#define KEY_TIMEOUT_USERINFO_VALUE      @"KEY_TIMEOUT_USERINFO_VALUE"

static const NSUInteger MAX_TIMEOUT_COUNT = 5;
static const NSUInteger SUBSCRIBE_CHARACTERISTICS_INTERVAL = 2;
static const NSUInteger WRITEVALUE_CHARACTERISTICS_INTERVAL = 2;

static const int PACKET_LENGTH = 16;
static const int DATA_LENGTH = 13;
#define COMPANG_LOGO    0xA6
#define DEVICE_TYPE     0x27


//Block
typedef void (^WMSBleControlScanedPeripheralCallback)(NSArray *peripherals);

typedef void (^WMSBleSwitchToControlModeCallback)(BOOL success,NSString *failReason);
typedef void (^WMSBleSwitchToUpdateModeCallback)(SwitchToUpdateResult result,NSString *failReason);

typedef void (^WMSBleSendDataCallback)(BOOL success);

typedef void (^WMSBleBindSettingCallBack)(BOOL success);


@interface WMSBleControl : NSObject

@property (nonatomic, readonly) LGPeripheral *connectedPeripheral;
@property (nonatomic, readonly) LGCharacteristic *readWriteCharacteristic;
@property (nonatomic, readonly) LGCharacteristic *notifyCharacteristic;
@property (nonatomic, readonly) BOOL isScanning;
@property (nonatomic, readonly) BOOL isConnecting;
@property (nonatomic, readonly) BOOL isConnected;
@property (nonatomic, readonly) WMSBleState bleState;

@property (nonatomic, readonly) WMSSettingProfile *settingProfile;
@property (nonatomic, readonly) WMSDeviceProfile *deviceProfile;
@property (nonatomic, readonly) WMSRemindProfile *remindProfile;

- (id)init;

- (void)scanForPeripheralsByInterval:(NSUInteger)aScanInterval
                          completion:(WMSBleControlScanedPeripheralCallback)aCallback;

- (void)stopScanForPeripherals;

- (void)connect:(LGPeripheral *)peripheral;

- (void)disconnect;


/**
 发送数据
 */
//- (void)sendDataToPeripheral:(NSData *)data
//                  completion:(WMSBleSendDataCallback)aCallBack;//废弃的

/*
 绑定配件
 */
- (void)bindSettingCMD:(BindSettingCMD)cmd
            completion:(WMSBleBindSettingCallBack)aCallBack;

/**
 模式控制
 */
- (void)switchToControlMode:(ControlMode)controlMode
                openOrClose:(BOOL)status
                 completion:(WMSBleSwitchToControlModeCallback)aCallBack;

/**
 切换到升级模式
 */
- (void)switchToUpdateModeCompletion:(WMSBleSwitchToUpdateModeCallback)aCallBack;

/**
 .........
 */
- (void)resetDevice;//discarded

@end
