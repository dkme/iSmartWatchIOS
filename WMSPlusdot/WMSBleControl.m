//
//  WMSBleControl.m
//  WMSPlusdot
//
//  Created by John on 14-9-2.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSBleControl.h"
#import "WMSSettingProfile.h"
#import "WMSDeviceProfile.h"
#import "WMSRemindProfile.h"
#import "NSMutableArray+Stack.h"

static const NSUInteger CONNECT_PERIPHERAL_INTERVAL = 60;
static const NSUInteger DISCOVER_SERVICES_INTERVAL = 30;
static const NSUInteger DISCOVER_CHARACTERISTICS_INTERVAL = 10;


//timeID
enum {
    TimeIDSubscribeNotifyCharact = 100,
    TimeIDBindSetting,
    TimeIDSwitchControlMode,
    TimeIDSwitchUpdateMode,
};

NSString * const WMSBleControlPeripheralDidConnect = @"com.guogee.ios.PeripheralDidConnect";
NSString * const WMSBleControlPeripheralConnectFailed = @"com.guogee.ios.PeripheralConnectFailed";

NSString * const WMSBleControlPeripheralDidDisConnect =
    @"LGPeripheralDidDisconnect";
NSString * const WMSBleControlBluetoothStateUpdated =
    @"LGCentralManagerStateUpdatedNotification";
NSString * const WMSBleControlScanFinish =
    @"LGCentralManagerScanPeripheralFinishNotification";

#define CUSTOM_SERVICE_UUID             @"0A60"
#define CUSTOM_CHARACTERISTIC1_UUID     @"0A66"
#define CUSTOM_CHARACTERISTIC2_UUID     @"0A67"

@interface WMSBleControl ()

@property (nonatomic, strong) LGCentralManager *centralManager;
@property (nonatomic, strong) NSArray *specificServiceArray;

@property (nonatomic, strong) NSMutableArray *characteristicArray;
@property (nonatomic, strong) WMSMyTimers *myTimers;

//Block
@property (nonatomic, copy) WMSBleControlScanedPeripheralCallback scanedBlock;
@property (nonatomic, copy) WMSBleSendDataCallback sendDataBlock;


//Stack
@property (nonatomic, strong) NSMutableArray *sendDataOperationStack;
@property (nonatomic, strong) NSMutableArray *stackBindSetting;
@property (nonatomic, strong) NSMutableArray *stackSwitchControlMode;
@property (nonatomic, strong) NSMutableArray *stackSwitchUpdateMode;
@end

@implementation WMSBleControl
{
    NSUInteger findCharacteristicCount;
    
    Byte packet[PACKET_LENGTH];
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

- (NSMutableArray *)characteristicArray
{
    if (!_characteristicArray) {
        _characteristicArray = [[NSMutableArray alloc] init];
    }
    return _characteristicArray;
}
- (NSArray *)specificServiceArray
{
    if (!_specificServiceArray) {
        _specificServiceArray = @[CUSTOM_SERVICE_UUID];
    }
    return _specificServiceArray;
}

//Stack
- (NSMutableArray *)sendDataOperationStack
{
    if (!_sendDataOperationStack) {
        _sendDataOperationStack = [NSMutableArray new];
    }
    return _sendDataOperationStack;
}

- (NSMutableArray *)stackSwitchControlMode
{
    if (!_stackSwitchControlMode) {
        _stackSwitchControlMode = [NSMutableArray new];
    }
    return _stackSwitchControlMode;
}
- (NSMutableArray *)stackSwitchUpdateMode
{
    if (!_stackSwitchUpdateMode) {
        _stackSwitchUpdateMode = [NSMutableArray new];
    }
    return _stackSwitchUpdateMode;
}
- (NSMutableArray *)stackBindSetting
{
    if (!_stackBindSetting) {
        _stackBindSetting = [NSMutableArray new];
    }
    return _stackBindSetting;
}


#pragma mark - Init
- (id)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}
- (void)setup
{
    _centralManager = [LGCentralManager sharedInstance];
    //_centralManager.centralState;
    
    _myTimers = [[WMSMyTimers alloc] init];
    
    _isConnecting = NO;
    findCharacteristicCount = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePeripheralDidDisconnect:) name:kLGPeripheralDidDisconnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidGetNotifyValue:) name:LGCharacteristicDidNotifyValueNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleManagerUpdatedState:) name:LGCentralManagerStateUpdatedNotification object:nil];
}

- (void)dealloc
{
    [self.myTimers deleteAllTimers];
    self.myTimers = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)scanForPeripheralsByInterval:(NSUInteger)aScanInterval
                          completion:(WMSBleControlScanedPeripheralCallback)aCallback
{
    if ([self.centralManager isScanning]) {
        return;
    }
    
    NSMutableArray *scannedPeripheral = [NSMutableArray new];
    
    [self.centralManager scanForPeripheralsByInterval:aScanInterval completion:^(NSArray *peripherals)
    {
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
        //[scannedPeripheral addObjectsFromArray:peripherals];
        if (aCallback) {
            aCallback(scannedPeripheral);
        }
    }];
    
    NSArray *serviceUUIDs = @[[CBUUID UUIDWithString:@"0A60"]];
    [self.centralManager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
//    NSArray *array = [self.centralManager retrieveConnectedPeripheralsWithServices:serviceUUIDs];//获取系统已连接的外设
//    for (LGPeripheral *p in array) {
//        [scannedPeripheral addObject:p];
//        DEBUGLog(@"system connected");
//        if (aCallback) {
//            aCallback(scannedPeripheral);
//        }
//    }
    
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
        //[self.centralManager.manager stopScan];
        //DEBUGLog(@"stopScan");
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(connectPeripheralTimeout:)
                                               object:peripheral];
    [self performSelector:@selector(connectPeripheralTimeout:) withObject:peripheral afterDelay:CONNECT_PERIPHERAL_INTERVAL];

    [peripheral connectWithCompletion:^(NSError *error) {
        //DEBUGLog(@"connect Completions");
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(connectPeripheralTimeout:)
                                                   object:peripheral];
        DEBUGLog(@"关闭连接定时器");
        
        if (error) {
            [self postNotificationConnectFailedForPeripheral:peripheral];
        } else {
            [self performSelector:@selector(discoverServicesTimeout:) withObject:peripheral afterDelay:DISCOVER_SERVICES_INTERVAL];
            
            [peripheral discoverServicesWithCompletion:^(NSArray *services, NSError *error)
             {
                 DEBUGLog(@"发现服务");
                 [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                          selector:@selector(discoverServicesTimeout:)
                                                            object:peripheral];
                 
                 if (error) {
                     [self postNotificationConnectFailedForPeripheral:peripheral];
                     return ;
                 }
                 
                 if ([self checkDiscoverServices:services] == NO) {
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
    if (self.isConnected == NO) {
        return;
    }
    [self.connectedPeripheral disconnectWithCompletion:^(NSError *error) {
        [self disConnectedClearup];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WMSBleControlPeripheralDidDisConnect object:self userInfo:nil];
    }];
}

#pragma mark - 对包的处理
- (Byte *)packet
{
    return packet;
}
- (void)resetPacket
{
    memset(packet, 0, PACKET_LENGTH);
    packet[0] = COMPANG_LOGO;
    packet[1] = DEVICE_TYPE;
}
- (void)setPacketCMD:(CMDType)cmd
{
    packet[2] = cmd;
}
- (void)setPacketData:(Byte[DATA_LENGTH])data length:(int)dataLength
{
    const int i = 3;
    int size = DATA_LENGTH;
    if (dataLength < DATA_LENGTH) {
        size = dataLength;
    }
    for (int j = 0; j < size; j++) {
        packet[i+j] = data[j];
    }
}
- (void)setPacketCMD:(CMDType)cmd andData:(Byte *)data dataLength:(int)length
{
    [self resetPacket];
    [self setPacketCMD:cmd];
    [self setPacketData:data length:length];
}

#pragma mark - Private Methods
- (void)discoverCharacteristics:(NSArray *)services forPeripheral:(LGPeripheral *)peripheral
{
    [self performSelector:@selector(discoverCharacteristicsTimeout:) withObject:peripheral afterDelay:DISCOVER_CHARACTERISTICS_INTERVAL];
    
    for (LGService *sv in services) {
        [sv discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
            if (error) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(discoverCharacteristicsTimeout:) object:peripheral];//取消定时器
                [self postNotificationConnectFailedForPeripheral:peripheral];
                return ;
            }
            
            [self.characteristicArray addObjectsFromArray:characteristics];
            
            
            findCharacteristicCount ++;
            if (findCharacteristicCount == [services count]) {//所有服务中的特性都已发现
                findCharacteristicCount = 0;
                DEBUGLog(@"发现特性");
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(discoverCharacteristicsTimeout:) object:peripheral];//取消定时器
                
                if ([self checkDiscoverCharacteristics:characteristics] == NO) {
                    [self postNotificationConnectFailedForPeripheral:peripheral];
                    return ;
                }
                
                //初始化Profile
                [self connectedConfig:peripheral];
                
                //发送连接成功通知
                [[NSNotificationCenter defaultCenter] postNotificationName:WMSBleControlPeripheralDidConnect object:self userInfo:nil];
            }
        }];
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

- (void)connectedConfig:(LGPeripheral *)peripheral
{
    _connectedPeripheral = peripheral;
    _readWriteCharacteristic = [self findCharactWithUUID:CUSTOM_CHARACTERISTIC1_UUID];
    _notifyCharacteristic = [self findCharactWithUUID:CUSTOM_CHARACTERISTIC2_UUID];
    
    _settingProfile = [[WMSSettingProfile alloc] initWithBleControl:self];
    _deviceProfile = [[WMSDeviceProfile alloc] initWithBleControl:self];
    _remindProfile = [[WMSRemindProfile alloc] initWithBleControl:self];
    
    _isConnecting = NO;
    
    if (!_readWriteCharacteristic || !_notifyCharacteristic) {
        return ;
    }
    
    [self subscribeNotifyCharacteristic];
    
    
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidGetNotifyValue:) name:LGCharacteristicDidNotifyValueNotification object:nil];
}

- (void)disConnectedClearup
{
    _connectedPeripheral = nil;
    _readWriteCharacteristic = nil;
    _notifyCharacteristic = nil;
    
    _settingProfile = nil;
    _deviceProfile = nil;
    _remindProfile = nil;
    
    _isConnecting = NO;
    findCharacteristicCount = 0;
    
    self.scanedBlock = nil;
    [self.stackBindSetting removeAllObjects];
    [self.stackSwitchControlMode removeAllObjects];
    [self.stackSwitchUpdateMode removeAllObjects];
    
    [self.characteristicArray removeAllObjects];
    [self.myTimers deleteAllTimers];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

//订阅slef.notifyCharacteristic
- (void)subscribeNotifyCharacteristic
{
    BOOL isNotify = _notifyCharacteristic.cbCharacteristic.isNotifying;
    if (isNotify == NO) {
        __weak typeof(self) weakSelf = self;
        [_notifyCharacteristic setNotifyValue:YES completion:^(NSError *error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return ;
            }
            [strongSelf handleDidSubscribeForCharact:strongSelf.notifyCharacteristic error:error];
        }];
        
        [self.myTimers addTimerWithTimeInterval:SUBSCRIBE_CHARACTERISTICS_INTERVAL
                                         target:self
                                       selector:@selector(subscribeNotifyCharactTimeout:)
                                       userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:_notifyCharacteristic,KEY_TIMEOUT_USERINFO_VALUE:@(YES)}
                                        repeats:YES
                                         timeID:TimeIDSubscribeNotifyCharact];
    }
}

//校验发现的服务是不是含有所需的服务
- (BOOL)checkDiscoverServices:(NSArray *)services
{
    if ([services count] < [self.specificServiceArray count]) {
        return NO;
    }
    
    int count = 0;
    for (LGService *sv in services) {
        for (NSString *uuid in self.specificServiceArray) {
            if (NSOrderedSame==[uuid caseInsensitiveCompare:sv.UUIDString]) {//不区分大小写比较
                count++;
                if (count == [self.specificServiceArray count]) {
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
    NSArray *specificCharactsUUID = @[CUSTOM_CHARACTERISTIC1_UUID,CUSTOM_CHARACTERISTIC2_UUID];
    
    if ([characts count] < [specificCharactsUUID count]) {
        return NO;
    }
    
    int count = 0;
    for (LGCharacteristic *c in characts) {
        for (NSString *uuid in specificCharactsUUID) {
            if (NSOrderedSame == [uuid caseInsensitiveCompare:c.UUIDString]) {
                count++;
                if (count == [specificCharactsUUID count]) {
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
    //[peripheral disconnectWithCompletion:nil];
    [self disConnectedClearup];
    [[NSNotificationCenter defaultCenter] postNotificationName:WMSBleControlPeripheralConnectFailed object:self userInfo:nil];
}

#pragma mark - Peripheral operation
//- (void)sendDataToPeripheral:(NSData *)data
//                  completion:(WMSBleSendDataCallback)aCallBack
//{
//    //self.sendDataBlock = aCallBack;
//    if (aCallBack) {
//        [self push:aCallBack toArray:self.sendDataOperationStack];
//    }
//
//    //不确定是写响应还是写无响应
//    [self.readWriteCharacteristic writeValue:data completion:^(NSError *error) {
//        ;
//    }];
//
//    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
//                                     target:self
//                                   selector:@selector(writeValueToCharactTimeout:)
//                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:_readWriteCharacteristic,KEY_TIMEOUT_USERINFO_VALUE:data}
//                                    repeats:YES
//                                     timeID:TimeIDSubscribeNotifyCharact];
//}


- (void)bindSettingCMD:(BindSettingCMD)cmd
            completion:(WMSBleBindSettingCallBack)aCallBack
{
    if (self.isConnected == NO) {
        return;
    }
    Byte package[DATA_LENGTH] = {0};
    package[0] = cmd;
    [self setPacketCMD:CMDSetBinding andData:package dataLength:DATA_LENGTH];
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackBindSetting];
    }
    //send
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    
    [self.readWriteCharacteristic writeValue:sendData completion:^(NSError *error) {}];
    
//    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
//                                     target:self
//                                   selector:@selector(writeValueToCharactTimeout:)
//                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.readWriteCharacteristic,KEY_TIMEOUT_USERINFO_VALUE:sendData}
//                                    repeats:YES
//                                     timeID:TimeIDBindSetting];
}

- (void)switchToControlMode:(ControlMode)controlMode
                openOrClose:(BOOL)status
                 completion:(WMSBleSwitchToControlModeCallback)aCallBack
{
    if (self.isConnected == NO) {
        return;
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = (Byte)controlMode;
    package[1] = status;
    
    [self setPacketCMD:CMDSwitchControlMode andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSwitchControlMode];
    }
    
    //send
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    
    [self.readWriteCharacteristic writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.readWriteCharacteristic,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDSwitchControlMode];
}

- (void)switchToUpdateModeCompletion:(WMSBleSwitchToUpdateModeCallback)aCallBack
{
    if (self.isConnected == NO) {
        return;
    }
    
    Byte package[DATA_LENGTH] = {0};
    
    [self setPacketCMD:CMDSwitchUpdateMode andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSwitchUpdateMode];
    }
    
    //send
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    
    [self.readWriteCharacteristic writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.readWriteCharacteristic,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDSwitchUpdateMode];
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
    [self.myTimers addTriggerCountToTimer:timer];
    
    int triggerCount = [self.myTimers triggerCountForTimer:timer];
    if (triggerCount >= MAX_TIMEOUT_COUNT) {//超时次数过多，断开连接
        [self.myTimers deleteAllTimers];
        
        DEBUGLog(@"订阅超时，主动断开");
        [self disconnect];
        return;
    }
    
    //重发时，蓝牙若为连接状态，则重新发送；否则清除所有Timer
    if (self.isConnected) {
        LGCharacteristic *charact = [timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_CHARACT];
        BOOL value = [[timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_VALUE] intValue];
        
        __weak LGCharacteristic *weakCharact = charact;
        [charact setNotifyValue:value completion:^(NSError *error) {
            __strong LGCharacteristic *strongCharact = weakCharact;
            if (strongCharact) {
                [self handleDidSubscribeForCharact:weakCharact error:error];
            }
        }];
    } else {
        [self.myTimers deleteAllTimers];
    }
}

- (void)writeValueToCharactTimeout:(NSTimer *)timer
{
    [self.myTimers addTriggerCountToTimer:timer];
    
    int triggerCount = [self.myTimers triggerCountForTimer:timer];
    if (triggerCount >= MAX_TIMEOUT_COUNT) {//超时次数过多，断开连接
        DEBUGLog(@"写入超时[TimerID:%d]，主动断开 %@",[self.myTimers getTimerID:timer],NSStringFromClass([self class]));
        [self.myTimers deleteAllTimers];
        [self disconnect];
        return;
    }
    
    //重发时，蓝牙若为连接状态，则重新发送；否则清除所有Timer
    if (self.isConnected) {
        LGCharacteristic *charact = [timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_CHARACT];
        NSData *value = [timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_VALUE];
        
        [charact writeValue:value completion:nil];
    } else {
        [self.myTimers deleteAllTimers];
    }
}


#pragma mark - Handle
- (void)handleDidSubscribeForCharact:(LGCharacteristic *)charact error:(NSError *)error
{
    if (charact == _notifyCharacteristic) {
        if (error) {
            return ;//等待超时
        }
        //清楚Timer
        [self.myTimers deleteTimerForTimeID:TimeIDSubscribeNotifyCharact];
    }
}

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
    //CBCentralManagerState state = self.centralManager.manager.state;
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
    NSData *value = [notification.userInfo objectForKey:@"value"];
    LGCharacteristic *charact = [notification.userInfo objectForKey:@"charact"];
    DEBUGLog(@">>>>>notify value");
    if (charact == self.notifyCharacteristic) {
        if (error) {
            DEBUGLog(@"通知错误，主动断开 %@",NSStringFromClass([WMSBleControl class]));
            [self disconnect];
            return;
        }
        Byte package[PACKET_LENGTH] = {0};
        [value getBytes:package length:PACKET_LENGTH];
        Byte cmd = package[2];
        
        if (cmd == CMDSetBinding) {
            //if ([self.myTimers isValidForTimeID:TimeIDBindSetting]) {//成功
              //  [self.myTimers deleteTimerForTimeID:TimeIDBindSetting];
                
                WMSBleBindSettingCallBack callBack = [NSMutableArray popFromArray:self.stackBindSetting];
                if (callBack) {
                    callBack(YES);
                }
            //}
            return;
        }
        if (cmd == CMDSwitchControlMode) {
            if ([self.myTimers isValidForTimeID:TimeIDSwitchControlMode]) {//成功
                [self.myTimers deleteTimerForTimeID:TimeIDSwitchControlMode];
            
                WMSBleSwitchToControlModeCallback callBack = [NSMutableArray popFromArray:self.stackSwitchControlMode];
                if (callBack) {
                    callBack(YES,nil);
                }
            }
            return;
        }
        if (cmd == CMDSwitchUpdateMode) {
            if ([self.myTimers isValidForTimeID:TimeIDSwitchUpdateMode]) {//成功
                [self.myTimers deleteTimerForTimeID:TimeIDSwitchUpdateMode];
                
                WMSBleSwitchToUpdateModeCallback callBack = [NSMutableArray popFromArray:self.stackSwitchUpdateMode];
                if (callBack) {
                    callBack(YES,nil);
                }
            }
            return;
        }
        
    }
}

@end
