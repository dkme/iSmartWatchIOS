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

static const NSUInteger CONNECT_PERIPHERAL_INTERVAL = 10;
static const NSUInteger DISCOVER_SERVICES_INTERVAL = 30;
static const NSUInteger DISCOVER_CHARACTERISTICS_INTERVAL = 10;


//timeID
enum {
    TimeIDSubscribeNotifyCharact = 100,
    
    TimeIDSwitchControlMode,
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
@property (nonatomic, strong) NSMutableArray *stackSwitchControlMode;
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
    switch (state) {
        case CBCentralManagerStateUnsupported:
            return BleStateUnsupported;
        case CBCentralManagerStatePoweredOff:
            return BleStatePoweredOff;
        case CBCentralManagerStatePoweredOn:
            return BleStatePoweredOn;
        default:
            break;
    }
    return BleStateUnsupported;
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
        [scannedPeripheral addObjectsFromArray:peripherals];
        
//        for (LGPeripheral *p in peripherals) {
//            DEBUGLog(@">>>>>>ps:%@",p.cbPeripheral);
//        }
        
        if (aCallback) {
            aCallback(scannedPeripheral);
        }
    }];
    
    NSArray *serviceUUIDs = @[[CBUUID UUIDWithString:@"0A60"]];
    NSArray *array = [self.centralManager retrieveConnectedPeripheralsWithServices:serviceUUIDs];//获取系统已连接的外设
    for (LGPeripheral *p in array) {
        [scannedPeripheral addObject:p];
        
        if (aCallback) {
            aCallback(scannedPeripheral);
        }
    }
    
}

- (void)stopScanForPeripherals
{
    [self.centralManager stopScanForPeripherals];
}

- (void)connect:(LGPeripheral *)peripheral
{    
    DEBUGLog(@"BleControl Connect");
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

//- (void)disconnect:(LGPeripheral *)peripheral
//{
//    [peripheral disconnectWithCompletion:^(NSError *error) {
//        [self disConnectedClearup];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:WMSBleControlPeripheralDidDisConnect object:self userInfo:nil];
//    }];
//}
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

#pragma mark - Peripheral operation
- (void)sendDataToPeripheral:(NSData *)data
                  completion:(WMSBleSendDataCallback)aCallBack
{
    //self.sendDataBlock = aCallBack;
    if (aCallBack) {
        [self push:aCallBack toArray:self.sendDataOperationStack];
    }
    
    //不确定是写响应还是写无响应
    [self.readWriteCharacteristic writeValue:data completion:^(NSError *error) {
        ;
    }];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:_readWriteCharacteristic,KEY_TIMEOUT_USERINFO_VALUE:data}
                                    repeats:YES
                                     timeID:TimeIDSubscribeNotifyCharact];
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
    
    [self.characteristicArray removeAllObjects];
    [self.myTimers deleteAllTimers];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

//订阅slef.notifyCharacteristic
- (void)subscribeNotifyCharacteristic
{
    BOOL isNotify = _notifyCharacteristic.cbCharacteristic.isNotifying;
    if (isNotify == NO) {
        __weak WMSBleControl *weakSelf = self;
        __strong WMSBleControl *strongSelf = weakSelf;
        [_notifyCharacteristic setNotifyValue:YES completion:^(NSError *error) {
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
    [self disConnectedClearup];
    [[NSNotificationCenter defaultCenter] postNotificationName:WMSBleControlPeripheralConnectFailed object:self userInfo:nil];
}

- (void)push:(id)anObject toArray:(NSMutableArray *)aArray
{
    [aArray addObject:anObject];
}

- (id)popFromArray:(NSMutableArray *)aArray
{
    id aObject = nil;
    if ([aArray count] > 0) {
        aObject = [aArray objectAtIndex:0];
        [aArray removeObjectAtIndex:0];
    }
    return aObject;
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
        
        __block LGCharacteristic *blockCharact = charact;
        [charact setNotifyValue:value completion:^(NSError *error) {
            [self handleDidSubscribeForCharact:blockCharact error:error];
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
        [self.myTimers deleteAllTimers];
        
        DEBUGLog(@"写入超时，主动断开 %@",NSStringFromClass([self class]));
        [self disconnect];
        return;
    }
    
    //重发时，蓝牙若为连接状态，则重新发送；否则清除所有Timer
    if (self.isConnected) {
        LGCharacteristic *charact = [timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_CHARACT];
        NSData *value = [timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_VALUE];
        
        //__block LGCharacteristic *blockCharact = charact;
        
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
        
    }
}

@end
