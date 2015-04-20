//
//  WMSBleControl.h
//  WMSPlusdot
//
//  Created by John on 14-9-2.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LGBluetooth.h"
#import "WMSMyTimers.h"
#import "BLEUtils.h"

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
typedef NS_ENUM(NSInteger, BindingResult) {
    BindingResultSuccess    = 0x00,
    BindingResultTimeout    = 0x01,
    BindingResultPaired     = 0x02,
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


//Block
typedef void (^WMSBleControlScanedPeripheralCallback)(NSArray *peripherals);

typedef void (^WMSBleSwitchToControlModeCallback)(BOOL success,NSString *failReason);
typedef void (^WMSBleSwitchToUpdateModeCallback)(SwitchToUpdateResult result,NSString *failReason);

typedef void (^WMSBleSendDataCallback)(BOOL success);

typedef void (^WMSBleBindSettingCallBack)(BindingResult result);


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

@property (nonatomic, readonly) WMSMyTimers *myTimers;

- (id)init;

- (void)scanForPeripheralsByInterval:(NSUInteger)aScanInterval
                          completion:(WMSBleControlScanedPeripheralCallback)aCallback;

- (void)stopScanForPeripherals;

- (void)connect:(LGPeripheral *)peripheral;

- (void)disconnect;
- (void)disconnect:(void(^)(BOOL success))aCallback;

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

#pragma mark - Private
- (void)disconnectWithReason:(NSString *)reason;
/*
 * 添加定时器，在发送数据超时后，重新发送
 * @param charact 重发所用的特性
 * @param data 重发的数据
 */
- (void)addTimerWithTimeInterval:(NSTimeInterval)interval handleCharacteristic:(LGCharacteristic *)charact handleData:(NSData *)data timeID:(TimeID)ID;

@end
