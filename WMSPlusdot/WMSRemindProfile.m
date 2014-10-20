//
//  WMSRemindProfile.m
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSRemindProfile.h"
#import "WMSBleControl.h"

enum {
    CMDStartRemind = 0x20,
    CMDEndRemind = 0x21,
};
enum {
    TimeIDStartRemind = 400,
    TimeIDEndRemind,
};

@interface WMSRemindProfile ()
{
    Byte packet[PACKET_LENGTH];
}

@property (nonatomic, strong) WMSBleControl *bleControl;
@property (nonatomic, strong) LGCharacteristic *rwCharact;
@property (nonatomic, strong) LGCharacteristic *notifyCharact;

@property (nonatomic, strong) WMSMyTimers *myTimers;

//Stack

@end

@implementation WMSRemindProfile

#pragma mark - Init
- (id)initWithBleControl:(WMSBleControl *)bleControl
{
    if (self = [super init]) {
        self.bleControl = bleControl;
        self.rwCharact = self.bleControl.readWriteCharacteristic;
        self.notifyCharact = self.bleControl.notifyCharacteristic;
        
        [self setup];
    }
    return self;
}
- (void)setup
{
    _myTimers = [[WMSMyTimers alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidGetNotifyValue:) name:LGCharacteristicDidNotifyValueNotification object:nil];
}
- (void)dealloc
{
    self.bleControl = nil;
    self.rwCharact = nil;
    self.notifyCharact = nil;
    [self.myTimers deleteAllTimers];
    self.myTimers = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//对包的处理
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


#pragma mark - Public Methods
//- (void)remindEventsType:(RemindEventsType)remindEventsType
//{
//    [self startRemind:remindEventsType];
//}
//
//- (void)startRemind:(RemindEventsType)remindEventsType
//{
//    if (![self.bleControl isConnected]) {
//        return ;
//    }
//    
//    Byte package[DATA_LENGTH] = {0};
//    package[0] = remindEventsType;
//    package[1] = 0;
//    
//    [self setPacketCMD:CMDStartRemind andData:package dataLength:DATA_LENGTH];
//    
//    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
//    
//    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
//    
//    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
//                                     target:self
//                                   selector:@selector(writeValueToCharactTimeout:)
//                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
//                                    repeats:YES
//                                     timeID:TimeIDStartRemind];
//}
- (void)endRemind
{
    
}


#pragma mark - Time out
- (void)writeValueToCharactTimeout:(NSTimer *)timer
{
    [self.myTimers addTriggerCountToTimer:timer];
    
    int triggerCount = [self.myTimers triggerCountForTimer:timer];
    if (triggerCount >= MAX_TIMEOUT_COUNT) {//超时次数过多，断开连接
        [self.myTimers deleteAllTimers];
        
        DEBUGLog(@"写入超时，主动断开");
        [self.bleControl disconnect];
        return;
    }
    
    //重发时，蓝牙若为连接状态，则重新发送；否则清除所有Timer
    if (self.bleControl.isConnected) {
        LGCharacteristic *charact = [timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_CHARACT];
        NSData *value = [timer.userInfo objectForKey:KEY_TIMEOUT_USERINFO_VALUE];
        
        //__block LGCharacteristic *blockCharact = charact;
        
        [charact writeValue:value completion:nil];
    } else {
        [self.myTimers deleteAllTimers];
    }
}

#pragma mark - Handle
//Notification
- (void)handleDidGetNotifyValue:(NSNotification *)notification
{
    NSError *error = notification.object;
    NSData *value = [notification.userInfo objectForKey:@"value"];
    LGCharacteristic *charact = [notification.userInfo objectForKey:@"charact"];
    DEBUGLog(@"notify value:%@,error:%@",value,error);
    if (charact != self.notifyCharact) {
        return;
    }
    if (error) {
        DEBUGLog(@"通知错误，主动断开");
        [self.bleControl disconnect];
        return;
    }
    
    Byte package[PACKET_LENGTH] = {0};
    [value getBytes:package length:PACKET_LENGTH];
    Byte cmd = package[2];
    
    if (cmd == CMDStartRemind) {
        if (![self.myTimers isValidForTimeID:TimeIDStartRemind]) {
            return;
        }
        [self.myTimers deleteTimerForTimeID:TimeIDStartRemind];
        
        //不用返回
    }
}

@end
