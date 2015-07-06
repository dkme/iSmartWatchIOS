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
#import "WMSStackManager.h"
#import "update.h"

@class WMSSettingProfile;
@class WMSDeviceProfile;
@class WMSSyncProfile;

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


/**
 * 点击手表按键时的通知
 * userInfo中的key：
 *                “operation” see OperationType
 */
extern NSString * const OperationDeviceButtonNotification;

/**************OperationType****************/
extern NSString * const OperationLookingIPhone;
extern NSString * const OperationTakePhoto;


///指定的服务与特性
#define SERVICE_BATTERY_UUID                                    @"180F"
#define CHARACTERISTIC_BATTERY_UUID                             @"2A19"

#define SERVICE_LOSE_UUID                                       @"1803"
#define CHARACTERISTIC_LOSE_UUID                                @"2A06"

//#define SERVICE_LOOK_UUID                                       @"1802"
//#define CHARACTERISTIC_LOOK_UUID                                @"2A06"

#define SERVICE_SERIAL_PORT_UUID                                @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_SERIAL_PORT_READ_UUID                    @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_SERIAL_PORT_WRITE_UUID                   @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"



//蓝牙状态
typedef NS_ENUM(NSInteger, WMSBleState) {
    WMSBleStateUnknown = 0,
    WMSBleStateResetting,
    WMSBleStateUnsupported,
    WMSBleStateUnauthorized,
    WMSBleStatePoweredOff,
    WMSBleStatePoweredOn,
};


//Block
typedef void (^WMSBleControlScanedPeripheralCallback)(NSArray *peripherals);

typedef void(^bindDeviceCallback)(BOOL isSuccess);
typedef void(^switchModeCallback)(BOOL isSuccess, RequestUpdateFirmwareErrorCode errCode);


@interface WMSBleControl : NSObject

@property (nonatomic, readonly) LGPeripheral *connectedPeripheral;
@property (nonatomic, readonly) BOOL isScanning;
@property (nonatomic, readonly) BOOL isConnecting;
@property (nonatomic, readonly) BOOL isConnected;
@property (nonatomic, readonly) WMSBleState bleState;

@property (nonatomic, readonly) WMSSettingProfile   *settingProfile;
@property (nonatomic, readonly) WMSDeviceProfile    *deviceProfile;
@property (nonatomic, readonly) WMSSyncProfile      *syncProfile;

@property (nonatomic, readonly) WMSStackManager *stackManager;


- (void)scanForPeripheralsByInterval:(NSUInteger)aScanInterval
                          completion:(WMSBleControlScanedPeripheralCallback)aCallback;

- (void)stopScanForPeripherals;

- (void)connect:(LGPeripheral *)peripheral;

- (void)disconnect;
- (void)disconnect:(void(^)(BOOL success))aCallback;

#pragma mark - Public handle
///在连接成功后，监听按键，然后以通知的形式发送出去（可以一对多）

///绑定设备
- (void)bindDevice:(bindDeviceCallback)aCallback;

///解绑设备
- (void)unbindDevice:(bindDeviceCallback)aCallback;

///切换到升级模式
- (void)switchToUpdateMode:(switchModeCallback)aCallback;




#pragma mark - Private
- (void)disconnectWithReason:(NSString *)reason;

- (LGCharacteristic *)findCharactWithUUID:(NSString *)UUIDStr;

/*
 * 添加定时器，在发送数据超时后，重新发送
 * @param charact 重发所用的特性
 * @param data 重发的数据
 */
- (void)addTimerWithTimeInterval:(NSTimeInterval)interval handleCharacteristic:(LGCharacteristic *)charact handleData:(NSData *)data timeID:(TimeID)ID;

/**
 * 向指定的characteristic中，写入数据
 * @param bytes 写入的数据
 * @param length 写入数据的长度
 * @param characteristic 指定的特性
 * @param response 写的方式，是否写响应
 * @param aCallback 回调
 * @param timeID 每个写操作都有唯一的timeID
 * #warning 当aCallback为nil时，不会启动time，所以timeID无效
 */
- (void)writeBytes:(const void *)bytes length:(NSUInteger)length toCharacteristic:(LGCharacteristic *)characteristic response:(BOOL)response callbackHandle:(id)aCallback withTimeID:(int)timeID;

/**
 * 订阅指定的characteristic
 * @param enable 是否使能通知
 */
- (void)characteristic:(LGCharacteristic *)characteristic enableNotify:(BOOL)enable withTimeID:(int)timeID;

@end
