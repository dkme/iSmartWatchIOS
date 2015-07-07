//
//  WMSBleControl.m
//  WMSPlusdot
//
//  Created by John on 14-9-2.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSBleControl.h"
#import "NSMutableArray+Stack.h"
#import "WMSDeviceModel.h"
#import "WMSDeviceModel+Configure.h"
#include "binding.h"
#include "parse.h"
#include "control.h"

static const NSUInteger CONNECT_PERIPHERAL_INTERVAL             = 60;
static const NSUInteger DISCOVER_SERVICES_INTERVAL              = 30;
static const NSUInteger DISCOVER_CHARACTERISTICS_INTERVAL       = 10;

NSString * const WMSBleControlPeripheralDidConnect      = @"com.guogee.ios.PeripheralDidConnect";
NSString * const WMSBleControlPeripheralConnectFailed   = @"com.guogee.ios.PeripheralConnectFailed";

NSString * const WMSBleControlPeripheralDidDisConnect   =
    @"LGPeripheralDidDisconnect";
NSString * const WMSBleControlBluetoothStateUpdated     =
    @"LGCentralManagerStateUpdatedNotification";
NSString * const WMSBleControlScanFinish                =
    @"LGCentralManagerScanPeripheralFinishNotification";

NSString * const OperationDeviceButtonNotification = @"WMSBleControl.OperationDeviceButtonNotification";

/**************OperationType****************/
NSString * const OperationLookingIPhone = @"WMSBleControl.OperationType.OperationLookingIPhone";
NSString * const OperationTakePhoto = @"WMSBleControl.OperationType.OperationTakePhoto";


@interface WMSBleControl ()

@property (nonatomic, strong) LGCentralManager *centralManager;
@property (nonatomic, strong) LGPeripheral *connectingPeripheral;//用于在连接过程中去断开连接

@property (nonatomic, strong) NSArray *specificServiceUUIDs;
@property (nonatomic, strong) NSArray *specificCharacteristicUUIDs;

@property (nonatomic, strong) NSMutableArray *characteristicArray;

//characteristic
@property (nonatomic, strong) LGCharacteristic *serialPortReadCharacteristic;
@property (nonatomic, strong) LGCharacteristic *serialPortWriteCharacteristic;


//Block
@property (nonatomic, copy) WMSBleControlScanedPeripheralCallback scanedBlock;

@end

@implementation WMSBleControl
{
    NSUInteger findCharacteristicCount;
}

#pragma mark - Getter
- (BOOL)isScanning
{
    return [self.centralManager isScanning];
}
- (BOOL)isConnected
{
    if (_connectedPeripheral == nil) {
        return NO;
    }
    
    CBPeripheralState state = _connectedPeripheral.cbPeripheral.state;
    if (CBPeripheralStateConnected == state) {
        return YES;
    }
    return NO;
}
- (WMSBleState)bleState
{
    CBCentralManagerState state = self.centralManager.manager.state;
    return (WMSBleState)state;
}

- (NSArray *)specificServiceUUIDs
{
    if (!_specificServiceUUIDs) {
        _specificServiceUUIDs = @[
                                  //SERVICE_BATTERY_UUID,
                                  SERVICE_LOSE_UUID,
                                  //SERVICE_LOOK_UUID,
                                  SERVICE_SERIAL_PORT_UUID,
                                  ];
    }
    return _specificServiceUUIDs;
}
- (NSArray *)specificCharacteristicUUIDs
{
    if (!_specificCharacteristicUUIDs) {
        _specificCharacteristicUUIDs = @[
                                         //CHARACTERISTIC_BATTERY_UUID,
                                         CHARACTERISTIC_LOSE_UUID,
                                         //CHARACTERISTIC_LOOK_UUID,
                                         CHARACTERISTIC_SERIAL_PORT_READ_UUID,
                                         CHARACTERISTIC_SERIAL_PORT_WRITE_UUID,
                                         ];
    }
    return _specificCharacteristicUUIDs;
}

- (NSMutableArray *)characteristicArray
{
    if (!_characteristicArray) {
        _characteristicArray = [[NSMutableArray alloc] init];
    }
    return _characteristicArray;
}

#pragma mark - Init
- (id)init
{
    if (self = [super init]) {
        [self setup];
        [self registerForNotifications];
    }
    return self;
}
- (void)setup
{
    _centralManager = [LGCentralManager sharedInstance];
    
    _stackManager = [[WMSStackManager alloc] init];
    
    _isConnecting = NO;
    findCharacteristicCount = 0;
}

- (void)dealloc
{
    _stackManager = nil;
    
    [self unregisterFromNotifications];
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePeripheralDidDisconnect:) name:kLGPeripheralDidDisconnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidGetNotifyValue:) name:LGCharacteristicDidNotifyValueNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleManagerUpdatedState:) name:LGCentralManagerStateUpdatedNotification object:nil];
}
- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods
- (void)scanForPeripheralsByInterval:(NSUInteger)aScanInterval
                          completion:(WMSBleControlScanedPeripheralCallback)aCallback
{
    if ([self.centralManager isScanning]) {
        return;
    }
    NSMutableArray *scannedPeripheral = [NSMutableArray new];
    
    NSArray *svUUIDs = @[[CBUUID UUIDWithString:SERVICE_SERIAL_PORT_UUID], [CBUUID UUIDWithString:SERVICE_LOSE_UUID]];
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [self.centralManager scanForPeripheralsByInterval:aScanInterval services:svUUIDs options:options completion:^(NSArray *peripherals) {
        //排除重复的设备
        LGPeripheral *oldObj = nil;
        LGPeripheral *newObj = [peripherals lastObject];
        NSString *identifier = newObj.UUIDString;
        for (LGPeripheral *p in scannedPeripheral) {
            if ([p.UUIDString isEqualToString:identifier]) {
                oldObj = p;
                break ;
            }
        }
        if (oldObj) {
            [scannedPeripheral removeObject:oldObj];
        }
        [scannedPeripheral addObject:newObj];
        if (aCallback) {
            aCallback(scannedPeripheral);
        }
    }];
    [self.centralManager retrieveConnectedPeripheralsWithServices:svUUIDs];
}

- (void)stopScanForPeripherals
{
    [self.centralManager stopScanForPeripherals];
}

- (void)connect:(LGPeripheral *)peripheral
{    
    _isConnecting = YES;
    
    if (self.isScanning) {
        [self stopScanForPeripherals];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(connectPeripheralTimeout:)
                                               object:peripheral];
    [self performSelector:@selector(connectPeripheralTimeout:) withObject:peripheral afterDelay:CONNECT_PERIPHERAL_INTERVAL];

    [self setConnectingPeripheral:peripheral];
    DEBUGLog(@"connecting peripheral %@",peripheral);
    [peripheral connectWithCompletion:^(NSError *error) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(connectPeripheralTimeout:)
                                                   object:peripheral];
        DEBUGLog(@"关闭连接定时器");
        
        if (error) {
            DEBUGLog(@"[line:%d] connect peripheral error",__LINE__);
            [self postNotificationConnectFailedForPeripheral:peripheral];
        } else {
            [self performSelector:@selector(discoverServicesTimeout:) withObject:peripheral afterDelay:DISCOVER_SERVICES_INTERVAL];
            
            [peripheral discoverServices:nil completion:^(NSArray *services, NSError *error)
            {
                DEBUGLog(@"发现服务");
                [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                         selector:@selector(discoverServicesTimeout:)
                                                           object:peripheral];
                
                if (error) {
                    DEBUGLog(@"[line:%d] DiscoverServices error",__LINE__);
                    [self postNotificationConnectFailedForPeripheral:peripheral];
                    return ;
                }
                
                if ([self checkDiscoverServices:services] == NO) {
                    DEBUGLog(@"[line:%d] checkDiscoverServices failed",__LINE__);
                    [self postNotificationConnectFailedForPeripheral:peripheral];
                    return ;
                }
                
                [self discoverCharacteristics:services forPeripheral:peripheral];
            }];
        }
    }];
}

- (void)disconnect
{
    [self disconnectWithReason:@"用户自己去断开的"];
}
- (void)disconnect:(void(^)(BOOL success))aCallback
{
    NSString *reason = @"用户自己去断开的";
    //disconnect
    if (self.isConnected) {//若为YES,self.connectedPeripheral必不为nil
        [self.connectedPeripheral disconnectWithCompletion:^(NSError *error) {
            [self disConnectedClearup];
            if (aCallback) {
                aCallback( (!error ? YES : NO) );
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:WMSBleControlPeripheralDidDisConnect object:nil userInfo:@{@"reason":reason}];
        }];
        return ;
    }
    if (self.isConnecting) {//self.connectedPeripheral为nil,则不能使用上面的方式“断开”连接
        CBPeripheral *p = self.connectingPeripheral.cbPeripheral;
        if (p) {
            [self.centralManager.manager cancelPeripheralConnection:p];
            [self disConnectedClearup];
        }
        if (aCallback) {
            aCallback(YES);
        }
    }
}

#pragma mark - Peripheral operation
- (void)bindDevice:(bindDeviceCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = bindWatch(&p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_BIND_DEVICE];
}

- (void)unbindDevice:(bindDeviceCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = unbindWatch(&p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_UNBIND_DEVICE];
}

- (void)switchToUpdateMode:(switchModeCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = updateFirmware(&p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_SWITCH_MODE];
}


#pragma mark -
#pragma mark - Private Methods
- (void)discoverCharacteristics:(NSArray *)services forPeripheral:(LGPeripheral *)peripheral
{
    [self performSelector:@selector(discoverCharacteristicsTimeout:) withObject:peripheral afterDelay:DISCOVER_CHARACTERISTICS_INTERVAL];
    
    for (LGService *sv in services) {
        [sv discoverCharacteristicsWithUUIDs:nil completion:^(NSArray *characteristics, NSError *error) {
            if (error) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(discoverCharacteristicsTimeout:) object:peripheral];//取消定时器
                DEBUGLog(@"[line:%d] DiscoverCharacteristics error",__LINE__);
                [self postNotificationConnectFailedForPeripheral:peripheral];
                return ;
            }
            
            [self.characteristicArray addObjectsFromArray:characteristics];
            
            
            findCharacteristicCount ++;
            if (findCharacteristicCount == [services count]) {//所有服务中的特性都已发现
                findCharacteristicCount = 0;
                DEBUGLog(@"发现特性");
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(discoverCharacteristicsTimeout:) object:peripheral];//取消定时器
                
                if ([self checkDiscoverCharacteristics:self.characteristicArray] == NO) {
                    DEBUGLog(@"[line:%d] checkDiscoverCharacteristics failed",__LINE__);
                    [self postNotificationConnectFailedForPeripheral:peripheral];
                    return ;
                }
                
                //初始化Profile
                [self connectedConfig:peripheral];
                [self readPeripheralInfo:^{
                    //发送连接成功通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:WMSBleControlPeripheralDidConnect object:self userInfo:nil];
                }];
            }
        }];
    }
}

- (void)connectedConfig:(LGPeripheral *)peripheral
{
    self.connectingPeripheral = nil;
    _isConnecting = NO;
    _connectedPeripheral = peripheral;
    
    self.serialPortReadCharacteristic = [self findCharactWithUUID:CHARACTERISTIC_SERIAL_PORT_READ_UUID];
    self.serialPortWriteCharacteristic = [self findCharactWithUUID:CHARACTERISTIC_SERIAL_PORT_WRITE_UUID];
    
    _settingProfile = [[WMSSettingProfile alloc] initWithBleControl:self];
    _deviceProfile  = [[WMSDeviceProfile alloc] initWithBleControl:self];
    _syncProfile    = [[WMSSyncProfile alloc] initWithBleControl:self];
    _testingProfile = [[WMSTestingProfile alloc] initWithBleControl:self];

    [self characteristic:self.serialPortReadCharacteristic enableNotify:YES withTimeID:TimeIDEnableNotifyForSerialPortReadCharacteristic];
}

- (void)disConnectedClearup
{
    _connectedPeripheral = nil;
    _serialPortReadCharacteristic = nil;
    _serialPortWriteCharacteristic = nil;
    
    _settingProfile = nil;
    _deviceProfile = nil;
    _syncProfile = nil;
    _testingProfile = nil;
    
    _isConnecting = NO;
    findCharacteristicCount = 0;
    
    [self setScanedBlock:nil];
    [self setConnectingPeripheral:nil];
    
    [self.characteristicArray removeAllObjects];
    [self.stackManager.myTimers deleteAllTimers];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

//校验发现的服务是不是含有所需的服务
- (BOOL)checkDiscoverServices:(NSArray *)services
{
    if ([services count] < [self.specificServiceUUIDs count]) {
        return NO;
    }
    
    int count = 0;
    for (LGService *sv in services) {
        for (NSString *uuid in self.specificServiceUUIDs) {
            if (NSOrderedSame==[uuid caseInsensitiveCompare:sv.UUIDString]) {//不区分大小写比较
                count++;
                if (count == [self.specificServiceUUIDs count]) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

//校验发现的特性是不是含有所需的特性
- (BOOL)checkDiscoverCharacteristics:(NSArray *)characts
{
    if ([characts count] < [self.specificCharacteristicUUIDs count]) {
        return NO;
    }
    
    int count = 0;
    for (LGCharacteristic *c in characts) {
        for (NSString *uuid in self.specificCharacteristicUUIDs) {
            if (NSOrderedSame == [uuid caseInsensitiveCompare:c.UUIDString]) {
                count++;
                if (count == [self.specificCharacteristicUUIDs count]) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

//发送通知
- (void)postNotificationConnectFailedForPeripheral:(LGPeripheral *)peripheral
{
    DEBUGLog(@"连接失败");
    //判断外设是否已连接，若已连接则断开连接，但不发送断开连接的通知，而应发送连接失败的通知
    CBPeripheralState state = peripheral.cbPeripheral.state;
    if (CBPeripheralStateConnected == state) {
        [peripheral disconnectWithCompletion:nil];
    }
    [self disConnectedClearup];
    [[NSNotificationCenter defaultCenter] postNotificationName:WMSBleControlPeripheralConnectFailed object:peripheral userInfo:nil];
}


#pragma mark - 在此处统一读取设备信息
- (void)readPeripheralInfo:(void(^)(void))aCallback
{
    WMSDeviceModel *model = [WMSDeviceModel deviceModel];
    __block UInt8 bitFlags= 0x00;
    [self.deviceProfile readDeviceMACAddress:^(NSString *MACAddress) {
        model.mac = MACAddress;
        bitFlags |= (0x01 << 0);
        if (bitFlags == 0xFF) {
            aCallback();
        }
    }];
    [self.deviceProfile readDeviceFirmwareVersion:^(float version) {
        model.firmwareVersion = version;
        bitFlags |= (0x01 << 1);
        if (bitFlags == 0xFF) {
            aCallback();
        }
    }];
    [self.deviceProfile readDeviceHardwareVersion:^(float version) {
        model.hardwareVersion = version;
        bitFlags |= (0x01 << 2);
        if (bitFlags == 0xFF) {
            aCallback();
        }
    }];
    [self.deviceProfile readDeviceSoftwareVersion:^(float version) {
        model.softwareVersion = version;
        bitFlags |= (0x01 << 3);
        if (bitFlags == 0xFF) {
            aCallback();
        }
    }];
    [self.deviceProfile readDeviceBatteryInfo:^(BatteryType type, BatteryStatus status) {
        model.batteryTypel = type;
        model.status = status;
        bitFlags |= (0x01 << 4);
        bitFlags |= (0x01 << 5);
        if (bitFlags == 0xFF) {
            aCallback();
        }
    }];
    [self.deviceProfile readDeviceFirm:^(NSString *firmName) {
        model.firmName = firmName;
        bitFlags |= (0x01 << 6);
        if (bitFlags == 0xFF) {
            aCallback();
        }
    }];
    [self.deviceProfile readDeviceProductModel:^(NSInteger m) {
        model.productModel = m;
        bitFlags |= (0x01 << 7);
        if (bitFlags == 0xFF) {
            aCallback();
        }
    }];
}


#pragma mark - Time out
//超时处理
- (void)connectPeripheralTimeout:(LGPeripheral *)peripheral
{
    DEBUGLog(@"连接外设超时，主动断开");
    [self postNotificationConnectFailedForPeripheral:peripheral];
}
- (void)discoverServicesTimeout:(LGPeripheral *)peripheral
{
    DEBUGLog(@"发现服务超时，主动断开");
    [self postNotificationConnectFailedForPeripheral:peripheral];
}
- (void)discoverCharacteristicsTimeout:(LGPeripheral *)peripheral
{
    DEBUGLog(@"发现特性超时，主动断开");
    [self postNotificationConnectFailedForPeripheral:peripheral];
}

- (void)subscribeNotifyCharactTimeout:(NSTimer *)timer
{
    [self.stackManager.myTimers addTriggerCountToTimer:timer];
    
    int triggerCount = [self.stackManager.myTimers triggerCountForTimer:timer];
    if (triggerCount >= MAX_TIMEOUT_COUNT) {//超时次数过多，断开连接
        [self.stackManager.myTimers deleteAllTimers];
        
        DEBUGLog(@"订阅超时，主动断开");
        [self disconnectWithReason:@"订阅超时，app主动断开"];
        return;
    }
    
    //重发时，蓝牙若为连接状态，则重新发送；否则清除所有Timer
    if (self.isConnected) {
        LGCharacteristic *charact = [timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_CHARACT];
        BOOL value = [[timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_VALUE] boolValue];
        
        int timeID = [self.stackManager.myTimers getTimerID:timer];
        [charact setNotifyValue:value completion:^(NSError *error) {
            if (error) {
                return ;//等待超时
            }
            //清楚Timer
            [self.stackManager.myTimers deleteTimerForTimeID:timeID];
        }];
    } else {
        [self.stackManager.myTimers deleteAllTimers];
    }
}

- (void)writeValueToCharactTimeout:(NSTimer *)timer
{
    [self.stackManager.myTimers addTriggerCountToTimer:timer];
    
    int triggerCount = [self.stackManager.myTimers triggerCountForTimer:timer];
    if (triggerCount > MAX_TIMEOUT_COUNT) {//超时次数过多，断开连接
        
        DEBUGLog(@"写入超时，主动断开 %@, timeID[%d]",NSStringFromClass([self class]),[self.stackManager.myTimers getTimerID:timer]);
        NSString *reason = [NSString stringWithFormat:@"写入超时[TimerID:%d]，app主动断开",[self.stackManager.myTimers getTimerID:timer]];
        [self.stackManager.myTimers deleteAllTimers];
        [self disconnectWithReason:reason];
        return;
    }
    
    //重发时，蓝牙若为连接状态，则重新发送；否则清除所有Timer
    if (self.isConnected) {
        LGCharacteristic *charact = [timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_CHARACT];
        NSData *value = [timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_VALUE];
        BOOL isResponse = [[timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_IS_WRITE_RESPONSE] boolValue];
        #warning 这里写的方式要与最初的保持一致
        if (isResponse) {
            [charact writeValue:value completion:^(NSError *error) {}];
        } else {
            [charact writeValue:value completion:nil];
        }
        DEBUGLog(@"timeID[%d]----第%d次重发",[self.stackManager.myTimers getTimerID:timer],triggerCount);
    } else {
        [self.stackManager.myTimers deleteAllTimers];
    }
}


#pragma mark - Handle

//Notification
//连接断开
- (void)handlePeripheralDidDisconnect:(NSNotification *)notification
{
    [self disConnectedClearup];
}

- (void)handleManagerUpdatedState:(NSNotification *)notification
{
    /*当蓝牙关闭时，连接会断开，
     但设备若为连接状态，则状态并不会变为非连接状态，
     此时该外设则为无效的，将外设置为空*/
    WMSBleState state = self.bleState;
    switch (state) {
        case WMSBleStateUnknown:
        case WMSBleStateResetting:
        case WMSBleStateUnsupported:
        case WMSBleStateUnauthorized:
        case WMSBleStatePoweredOff:
            [self disConnectedClearup];
            break;
        default:
            break;
    }
}

- (void)handleDidGetNotifyValue:(NSNotification *)notification
{
    NSError *error = notification.object;
    NSData *value = [notification.userInfo objectForKey:KLGNotifyValue];
    LGCharacteristic *charact = [notification.userInfo objectForKey:KLGNotifyCharacteristic];
    
    NSString *uuid = charact.UUIDString;
    if (error) {
        DEBUGLog(@"通知错误，主动断开 %@",NSStringFromClass([WMSBleControl class]));
        [self disconnectWithReason:@"通知错误，app主动断开"];
        return;
    }
    
    Byte package[PACKAGE_SIZE] = {0};
    [value getBytes:package length:PACKAGE_SIZE];
    struct_parse_package s_pg = parse(package, PACKAGE_SIZE);
    Byte cmd = s_pg.cmd;
    Byte key = s_pg.key;

    if ([CHARACTERISTIC_SERIAL_PORT_READ_UUID isEqualToString:uuid]) {
        if (cmd == CMD_control) {
            Struct_Control res = getControlCommand(package, PACKAGE_SIZE);
            if (res.error != HANDLE_OK) {
                return ;
            }
            ///发送一个通知
            NSString *operation = nil;
            if (ControlClick == res.control && ButtonTopRightCorner == res.button) {
                operation = OperationTakePhoto;
            }
            if (ControlLongPress == res.control && ButtonLowerRightCorner == res.button) {
                operation = OperationLookingIPhone;
            }
            if (operation) {
                [[NSNotificationCenter defaultCenter] postNotificationName:OperationDeviceButtonNotification object:self userInfo:@{@"operation":operation}];
            }
            return ;
        }
        
        
        switch (CMD_KEY(cmd, key)) {
            case CMD_KEY(CMD_binding, Binding):
            {
                BLE_UInt8 result = getBindingResult(package, PACKAGE_SIZE);
                bindDeviceCallback aCallback = [self.stackManager popObjFromStackOfTimeID:TIME_ID_BIND_DEVICE];
                if (aCallback) {
                    BOOL isSuccess = (result == OPERATION_OK ? YES : NO);
                    aCallback(isSuccess);
                }
                break;
            }
            case CMD_KEY(CMD_binding, unBinding):
            {
                BLE_UInt8 result = getUnbindingResult(package, PACKAGE_SIZE);
                bindDeviceCallback aCallback = [self.stackManager popObjFromStackOfTimeID:TIME_ID_UNBIND_DEVICE];
                if (aCallback) {
                    BOOL isSuccess = (result == OPERATION_OK ? YES : NO);
                    aCallback(isSuccess);
                }
                break;
            }
            case CMD_KEY(CMD_updateFirmware, UpdateFirmware):
            {
                Struct_UpdateResult res = getResult(package, PACKAGE_SIZE);
                if (res.error == HANDLE_OK) {
                    switchModeCallback aCallback = [self.stackManager popObjFromStackOfTimeID:TIME_ID_SWITCH_MODE];
                    if (aCallback) {
                        aCallback(res.isSuccess, res.errorCode);
                    }
                }
                break;
            }
            default:
                break;
        }///switch
    }
}


#pragma mark -
#pragma mark - Private Handle
- (void)disconnectWithReason:(NSString *)reason
{
    if (self.isConnected) {//若为YES,self.connectedPeripheral必不为nil
        [self.connectedPeripheral disconnectWithCompletion:^(NSError *error) {
            [self disConnectedClearup];
            [[NSNotificationCenter defaultCenter] postNotificationName:WMSBleControlPeripheralDidDisConnect object:nil userInfo:@{@"reason":reason}];
        }];
        DEBUGLog(@"is connected");
        return ;
    }
    if (self.isConnecting) {//self.connectedPeripheral为nil,则不能使用上面的方式“断开”连接
        CBPeripheral *p = self.connectingPeripheral.cbPeripheral;
        if (p) {
            [self.centralManager.manager cancelPeripheralConnection:p];
            [self disConnectedClearup];
        }
        DEBUGLog(@"is Connecting %@",p);
    }
}

//查找特性
- (LGCharacteristic *)findCharactWithUUID:(NSString *)UUIDStr
{
    for (LGCharacteristic *ct in self.characteristicArray) {
        if (NSOrderedSame == [UUIDStr caseInsensitiveCompare:ct.UUIDString]) {
            return ct;
        }
    }
    return nil;
}

//- (void)addTimerWithTimeInterval:(NSTimeInterval)interval handleCharacteristic:(LGCharacteristic *)charact handleData:(NSData *)data timeID:(TimeID)ID
//{
//    [self.stackManager.myTimers addTimerWithTimeInterval:interval
//                                                  target:self
//                                                selector:@selector(writeValueToCharactTimeout:)
//                                                userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:charact,
//                                                           KEY_TIMEOUT_USERINFO_VALUE:data}
//                                                 repeats:YES
//                                                  timeID:ID];
//}

- (void)writeBytes:(const void *)bytes length:(NSUInteger)length toCharacteristic:(LGCharacteristic *)characteristic response:(BOOL)response callbackHandle:(id)aCallback withTimeID:(int)timeID
{
    NSData *sendData = [NSData dataWithBytes:bytes length:length];
    if (response) {
        [characteristic writeValue:sendData completion:^(NSError *error){}];
    } else {
        [characteristic writeValue:sendData completion:nil];
    }
    if (aCallback) {
        [self.stackManager pushObj:aCallback toStackOfTimeID:timeID];
//        [self addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:characteristic handleData:sendData timeID:timeID];
        [self.stackManager.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                                      target:self
                                                    selector:@selector(writeValueToCharactTimeout:)
                                                    userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:characteristic,
                                                               KEY_TIMEOUT_USERINFO_VALUE:sendData,
                                                               KEY_TIMEOUT_USERINFO_IS_WRITE_RESPONSE:@(response),
                                                               }
                                                     repeats:YES
                                                      timeID:timeID];
    }
}

- (void)characteristic:(LGCharacteristic *)characteristic enableNotify:(BOOL)enable withTimeID:(int)timeID
{
    BOOL isNotify = characteristic.cbCharacteristic.isNotifying;
    if (isNotify != enable) {
        [characteristic setNotifyValue:enable completion:^(NSError *error) {
            if (error) {
                return ;//等待超时
            }
            //清楚Timer
            [self.stackManager.myTimers deleteTimerForTimeID:timeID];
        }];
        
        [self.stackManager.myTimers addTimerWithTimeInterval:SUBSCRIBE_CHARACTERISTICS_INTERVAL
                                                      target:self
                                                    selector:@selector(subscribeNotifyCharactTimeout:)
                                                    userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:characteristic,
                                                               KEY_TIMEOUT_USERINFO_VALUE:@(enable)}
                                                     repeats:YES
                                                      timeID:timeID];
        
    }
}

@end
