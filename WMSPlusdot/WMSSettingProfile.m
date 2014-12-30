//
//  WMSSettingProfile.m
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSettingProfile.h"
#import "WMSBleControl.h"
#import "NSMutableArray+Stack.h"

//static const int PACKET_LENGTH = 16;
//static const int DATA_LENGTH = 13;

//#define COMPANG_LOGO    0xA6
//#define DEVICE_TYPE     0x27

//通讯命令字
enum {
    CMDStartSendOtherRemind = 0x20,
    CMDEndSendOtherRemind = 0x21,
};

//TimeID
enum {
    TimeIDSetCurrentDate = 200,
    TimeIDSetPersonInfo,
    TimeIDSetAlarmClock,
    TimeIDSetTarget,
    TimeIDSetRemindMode,
    TimeIDSetRemindEvents,
    TimeIDSetRemindEventsAndMode,
    TimeIDSetSportRemind,
    TimeIDSetAntiLost,
    TimeIDStartSendOtherRemind,
    TimeIDEndSendOtherRemind,
};

@interface WMSSettingProfile ()
{
    Byte packet[PACKET_LENGTH];
}

@property (nonatomic, strong) WMSBleControl *bleControl;
@property (nonatomic, strong) LGCharacteristic *rwCharact;
@property (nonatomic, strong) LGCharacteristic *notifyCharact;

@property (nonatomic, strong) WMSMyTimers *myTimers;

//Block
 
//Stack
@property (nonatomic, strong) NSMutableArray *stackSetCurrentDate;
@property (nonatomic, strong) NSMutableArray *stackSetPersonInfo;
@property (nonatomic, strong) NSMutableArray *stackSetAlarmClock;
@property (nonatomic, strong) NSMutableArray *stackSetTarget;
@property (nonatomic, strong) NSMutableArray *stackSetRemindMode;
@property (nonatomic, strong) NSMutableArray *stackSetRemindEvents;
@property (nonatomic, strong) NSMutableArray *stackSetRemindEventsAndMode;
@property (nonatomic, strong) NSMutableArray *stackSetOtherRemind;
@property (nonatomic, strong) NSMutableArray *stackSetStartLowBatteryRemind;
@property (nonatomic, strong) NSMutableArray *stackSetStopLowBatteryRemind;
@property (nonatomic, strong) NSMutableArray *stackStartRemind;
@property (nonatomic, strong) NSMutableArray *stackFinishRemind;

@property (nonatomic, strong) NSMutableArray *stackSetSportRemind;
@property (nonatomic, strong) NSMutableArray *stackSetAntiLost;
@end

@implementation WMSSettingProfile

#pragma mark - Getter
- (NSMutableArray *)stackSetCurrentDate
{
    if (!_stackSetCurrentDate) {
        _stackSetCurrentDate = [NSMutableArray new];
    }
    return _stackSetCurrentDate;
}
- (NSMutableArray *)stackSetPersonInfo
{
    if (!_stackSetPersonInfo) {
        _stackSetPersonInfo = [NSMutableArray new];
    }
    return _stackSetPersonInfo;
}
- (NSMutableArray *)stackSetAlarmClock
{
    if (!_stackSetAlarmClock) {
        _stackSetAlarmClock = [NSMutableArray new];
    }
    return _stackSetAlarmClock;
}
- (NSMutableArray *)stackSetTarget
{
    if (!_stackSetTarget) {
        _stackSetTarget = [NSMutableArray new];
    }
    return _stackSetTarget;
}
- (NSMutableArray *)stackSetRemindMode
{
    if (!_stackSetRemindMode) {
        _stackSetRemindMode = [NSMutableArray new];
    }
    return _stackSetRemindMode;
}
- (NSMutableArray *)stackSetRemindEvents
{
    if (!_stackSetRemindEvents) {
        _stackSetRemindEvents = [NSMutableArray new];
    }
    return _stackSetRemindEvents;
}
- (NSMutableArray *)stackSetRemindEventsAndMode
{
    if (!_stackSetRemindEventsAndMode) {
        _stackSetRemindEventsAndMode = [NSMutableArray new];
    }
    return _stackSetRemindEventsAndMode;
}
- (NSMutableArray *)stackSetOtherRemind
{
    if (!_stackSetOtherRemind) {
        _stackSetOtherRemind = [NSMutableArray new];
    }
    return _stackSetOtherRemind;
}
- (NSMutableArray *)stackSetStartLowBatteryRemind
{
    if (!_stackSetStartLowBatteryRemind) {
        _stackSetStartLowBatteryRemind = [NSMutableArray new];
    }
    return _stackSetStartLowBatteryRemind;
}
- (NSMutableArray *)stackSetStopLowBatteryRemind
{
    if (!_stackSetStopLowBatteryRemind) {
        _stackSetStopLowBatteryRemind = [NSMutableArray new];
    }
    return _stackSetStopLowBatteryRemind;
}
- (NSMutableArray *)stackStartRemind
{
    if (!_stackStartRemind) {
        _stackStartRemind = [NSMutableArray new];
    }
    return _stackStartRemind;
}
- (NSMutableArray *)stackFinishRemind
{
    if (!_stackFinishRemind) {
        _stackFinishRemind = [NSMutableArray new];
    }
    return _stackFinishRemind;
}

- (NSMutableArray *)stackSetSportRemind
{
    if (!_stackSetSportRemind) {
        _stackSetSportRemind = [NSMutableArray new];
    }
    return _stackSetSportRemind;
}
- (NSMutableArray *)stackSetAntiLost
{
    if (!_stackSetAntiLost) {
        _stackSetAntiLost = [NSMutableArray new];
    }
    return _stackSetAntiLost;
}


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
- (void)setCurrentDate:(NSDate *)date
            completion:(setCurrentDateCallBack)aCallBack
{
    DEBUGLog(@"set current date");
    if (![self.bleControl isConnected]) {
        return ;
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy";
    UInt16 year = [[dateFormatter stringFromDate:date] intValue];
    dateFormatter.dateFormat = @"MM";
    Byte month = [[dateFormatter stringFromDate:date] intValue];
    dateFormatter.dateFormat = @"dd";
    Byte day = [[dateFormatter stringFromDate:date] intValue];
    dateFormatter.dateFormat = @"HH";
    Byte hour = [[dateFormatter stringFromDate:date] intValue];
    dateFormatter.dateFormat = @"mm";
    Byte minute = [[dateFormatter stringFromDate:date] intValue];
    dateFormatter.dateFormat = @"ss";
    Byte second = [[dateFormatter stringFromDate:date] intValue];
    dateFormatter.dateFormat = @"e";
    Byte week_day = [[dateFormatter stringFromDate:date] intValue];
DEBUGLog(@"【【%d-%d-%d %d:%d:%d %d】】",year,month,day,hour,minute,second,week_day);
    
    if (week_day == 1) {//系统时间中，1-7表示周日-周六
        week_day = 6;//协议中0-6表示周一到周日
    } else {
        week_day = week_day - 2;
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = year & 0xFF;
    package[1] = (year & 0xFF00) >> 8;
    package[2] = month;
    package[3] = day;
    package[4] = hour;
    package[5] = minute;
    package[6] = second;
    package[7] = week_day;

    [self setPacketCMD:CMDSetCurrentDate andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetCurrentDate];
    }
    
    //send
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDSetCurrentDate];
}

- (void)setPersonInfoWithWeight:(UInt16)weight
                     withHeight:(Byte)height
                     withGender:(GenderType)gender
                   withBirthday:(NSString *)birthday
                 withDateFormat:(NSString *)format
                     withStride:(Byte)stride
                     withMetric:(LengthUnitType)metric
                 withCompletion:(setPersonInfoCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    //解析日期字符串
    NSRange range = [format rangeOfString:@"yyyy"];
    if (range.length <= 0) {
        return;
    }
    unsigned short year = [[birthday substringWithRange:range] intValue];
    
    range = [format rangeOfString:@"MM"];
    if (range.length <= 0) {
        return;
    }
    Byte month = [[birthday substringWithRange:range] intValue];
    
    range = [format rangeOfString:@"dd"];
    if (range.length <= 0) {
        return;
    }
    Byte day = [[birthday substringWithRange:range] intValue];
    
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = weight & 0xFF;
    package[1] = (weight & 0xFF00) >> 8;
    package[2] = height;
    package[3] = gender;
    package[4] = year & 0xFF;
    package[5] = (year & 0xFF00) >> 8;
    package[6] = month;
    package[7] = day;
    package[8] = stride;
    package[9] = metric;
    
    [self setPacketCMD:CMDSetPersonInfo andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetPersonInfo];
    }
    
    //send
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {
        DEBUGLog(@"写响应");
    }];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDSetPersonInfo];
}

- (void)setAlarmClockWithId:(Byte)no
                   withHour:(Byte)hour
                 withMinute:(Byte)minute
                 withStatus:(BOOL)openOrClose
                 withRepeat:(Byte *)repeat
                 withLength:(NSUInteger)length
           withSnoozeMinute:(Byte)snoozeMinute
             withCompletion:(setAlarmClockCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return;
    }
    
    Byte byte = 0x00;
    if (openOrClose) {
        byte = byte | (0x01 << 0);
    }
    Byte week[7] = {0};
    for (int i=0; i<length; i++) {
        week[i] = repeat[i];
    }
    for (int j=0; j<7; j++) {
        if (week[j] != 0) {//重复
            byte = byte | (0x01 << (j+1));
        }
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = no;
    package[1] = hour;
    package[2] = minute;
    package[3] = byte;
    package[4] = snoozeMinute;
    
    [self setPacketCMD:CMDSetAlarmClock andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetAlarmClock];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDSetAlarmClock];
    
}

- (void)setTargetWithStep:(UInt32)step
          withSleepMinute:(UInt16)minute
           withCompletion:(setTargetCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = step & 0xFF;
    package[1] = (step & 0xFF00) >> 8;
    package[2] = (step & 0xFF0000) >> 16;
    package[3] = (step & 0xFF000000) >> 24;
    package[4] = minute & 0xFF;
    package[5] = (minute & 0xFF00) >> 8;
    
    [self setPacketCMD:CMDSetTarger andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetTarget];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDSetTarget];
}

- (void)setRemindWithMode:(RemindMode)remindMode
           withCompletion:(setRemindModeCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = remindMode;
    
    [self setPacketCMD:CMDSetRemind andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetRemindMode];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDSetRemindMode];
}

- (void)setRemindEventsType:(RemindEventsType)remindEventsType
                 completion:(setRemindEventsCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = 0x03;
    package[1] = remindEventsType;
    DEBUGLog(@"package[1]:0x%X",package[1]);
    [self setPacketCMD:CMDSetRemind andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetRemindEvents];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDSetRemindEvents];
}

- (void)setRemindEventsType:(RemindEventsType)remindEventsType
                       mode:(RemindMode)remindMode
                 completion:(setRemindEventsAndModeCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = remindMode;
    package[1] = remindEventsType;
    [self setPacketCMD:CMDSetRemind andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetRemindEventsAndMode];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDSetRemindEventsAndMode];
}

- (void)setOtherRemind:(OtherRemindType)remindType
            completion:(setOtherRemindCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = remindType;
    [self setPacketCMD:CMDStartSendOtherRemind andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetOtherRemind];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDStartSendOtherRemind];
}

- (void)setStartLowBatteryRemindCompletion:(setStartLowBatteryRemind)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = 0x11;
    [self setPacketCMD:CMDStartSendOtherRemind andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetStartLowBatteryRemind];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDStartSendOtherRemind];
}
- (void)setStopLowBatteryRemindCompletion:(setStartLowBatteryRemind)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = 0x11;
    [self setPacketCMD:CMDEndSendOtherRemind andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetStopLowBatteryRemind];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDEndSendOtherRemind];
}

- (void)startRemind:(OtherRemindType)remindType
         completion:(startRemind)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = remindType;
    [self setPacketCMD:CMDStartSendOtherRemind andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackStartRemind];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDStartSendOtherRemind];
}

- (void)finishRemind:(OtherRemindType)remindType
          completion:(finishRemind)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = remindType;
    [self setPacketCMD:CMDEndSendOtherRemind andData:package dataLength:DATA_LENGTH];
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackFinishRemind];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDEndSendOtherRemind];
}

- (void)setSportRemindWithStatus:(BOOL)openOrClose
                       startHour:(Byte)startHour
                     startMinute:(Byte)startMinute
                         endHour:(Byte)endHour
                       endMinute:(Byte)endMinute
                  intervalMinute:(UInt16)intervalMinute
                         repeats:(NSArray *)repeats
                      completion:(setSportRemindCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte repetitions = 0x00;
    if (openOrClose) {
        repetitions = repetitions | (0x01 << 0);
    }
    Byte week[7] = {0};
    for (int i=0; i<[repeats count]; i++) {
        week[i] = [repeats[i] integerValue];
    }
    for (int j=0; j<7; j++) {
        if (week[j] != 0) {//重复
            repetitions = repetitions | (0x01 << (j+1));
        }
    }
    
    Byte package[DATA_LENGTH] = {0};
    package[0] = intervalMinute & 0xFF;
    package[1] = (intervalMinute & 0xFF00) >> 8;
    package[2] = repetitions;
    package[3] = startHour;
    package[4] = startMinute;
    package[5] = endHour;
    package[6] = endMinute;
    
    [self setPacketCMD:CMDSetSportRemind andData:package dataLength:DATA_LENGTH];
    printf("package: 0x");
    for (int i=0; i<PACKET_LENGTH; i++) {
        printf("%02X",[self packet][i]);
    }
    printf("\n");
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetSportRemind];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDSetSportRemind];
}

- (void)setAntiLostStatus:(BOOL)openOrClose
                 distance:(NSUInteger)distance
               completion:(setAntiLostCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    Byte package[DATA_LENGTH] = {0};
    package[0] = openOrClose;
    package[1] = distance;
    package[2] = 0;
    [self setPacketCMD:CMDSetAntiLost andData:package dataLength:DATA_LENGTH];
//    printf("packet: 0x");
//    for (int i=0; i<16; i++) {
//        printf("%02X ",packet[i]);
//    }
//    printf("\n");
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetAntiLost];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDSetAntiLost];
}
- (void)setAntiLostStatus:(BOOL)openOrClose
                 distance:(NSUInteger)distance
             timeInterval:(NSUInteger)interval
               completion:(setAntiLostCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    Byte package[DATA_LENGTH] = {0};
    package[0] = openOrClose;
    package[1] = distance;
    package[2] = interval;
    [self setPacketCMD:CMDSetAntiLost andData:package dataLength:DATA_LENGTH];
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetAntiLost];
    }
    
    NSData *sendData = [NSData dataWithBytes:[self packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.myTimers addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL
                                     target:self
                                   selector:@selector(writeValueToCharactTimeout:)
                                   userInfo:@{KEY_TIMEOUT_USERINFO_CHARACT:self.rwCharact,KEY_TIMEOUT_USERINFO_VALUE:sendData}
                                    repeats:YES
                                     timeID:TimeIDSetAntiLost];
}


#pragma mark - Time out
- (void)writeValueToCharactTimeout:(NSTimer *)timer
{
    [self.myTimers addTriggerCountToTimer:timer];
    
    int triggerCount = [self.myTimers triggerCountForTimer:timer];
    if (triggerCount >= MAX_TIMEOUT_COUNT) {//超时次数过多，断开连接
        DEBUGLog(@"2写入超时[TimerID:%d]，主动断开 %@",[self.myTimers getTimerID:timer],NSStringFromClass([self class]));
        [self.myTimers deleteAllTimers];
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
//- (void)handleDidWriteValueForCharact:(LGCharacteristic *)charact error:(NSError *)error
//{
//    if (charact == self.rwCharact) {
//        if (error) {
//            return ;//等待超时
//        }
//        
//        //清除Timer
//        [self.myTimers deleteTimerForTimeID:TimeIDSetPersonInfo];
//    }
//}

//Notification
- (void)handleDidGetNotifyValue:(NSNotification *)notification
{
    NSError *error = notification.object;
    NSData *value = [notification.userInfo objectForKey:@"value"];
    LGCharacteristic *charact = [notification.userInfo objectForKey:@"charact"];
    DEBUGLog(@"notify value:%@,error:%@",value,error);
    if (charact == self.notifyCharact) {
        if (error) {
            DEBUGLog(@"通知错误，主动断开");
            [self.bleControl disconnect];
            return;
        }
        Byte package[PACKET_LENGTH] = {0};
        [value getBytes:package length:PACKET_LENGTH];
        Byte cmd = package[2];
        
        if (cmd == CMDSetCurrentDate) {
            if ([self.myTimers isValidForTimeID:TimeIDSetCurrentDate]) {
                [self.myTimers deleteTimerForTimeID:TimeIDSetCurrentDate];
                
                setCurrentDateCallBack callBack = [NSMutableArray popFromArray:self.stackSetCurrentDate];
                if (callBack) {
                    callBack(YES);
                }
            }
            return;
        }
        
        if (cmd == CMDSetPersonInfo) {
            if ([self.myTimers isValidForTimeID:TimeIDSetPersonInfo]) {//成功
                [self.myTimers deleteTimerForTimeID:TimeIDSetPersonInfo];
                
                setPersonInfoCallBack callBack = [NSMutableArray popFromArray:self.stackSetPersonInfo];
                if (callBack) {
                    callBack(YES);
                }
            }
            return;
        }
        
        if (cmd == CMDSetAlarmClock) {
            if ([self.myTimers isValidForTimeID:TimeIDSetAlarmClock]) {//成功
                [self.myTimers deleteTimerForTimeID:TimeIDSetAlarmClock];
                
                setAlarmClockCallBack callBack = [NSMutableArray popFromArray:self.stackSetAlarmClock];
                if (callBack) {
                    callBack(YES);
                }
            }
            return;
        }
        
        if (cmd == CMDSetTarger) {
            if ([self.myTimers isValidForTimeID:TimeIDSetTarget]) {
                [self.myTimers deleteTimerForTimeID:TimeIDSetTarget];
                
                setTargetCallBack callBack = [NSMutableArray popFromArray:self.stackSetTarget];
                if (callBack) {
                    callBack(YES);
                }
            }
            return;
        }
        
        if (cmd == CMDSetRemind) {
            if ([self.myTimers isValidForTimeID:TimeIDSetRemindMode]) {
                [self.myTimers deleteTimerForTimeID:TimeIDSetRemindMode];
                
                setRemindModeCallBack callBack = [NSMutableArray popFromArray:self.stackSetRemindMode];
                if (callBack) {
                    callBack(YES);
                }
                return;
            }
            if ([self.myTimers isValidForTimeID:TimeIDSetRemindEvents]) {
                [self.myTimers deleteTimerForTimeID:TimeIDSetRemindEvents];
                
                setRemindEventsCallBack callBack = [NSMutableArray popFromArray:self.stackSetRemindEvents];
                if (callBack) {
                    callBack(YES);
                }
                return;
            }
            if ([self.myTimers isValidForTimeID:TimeIDSetRemindEventsAndMode]) {
                [self.myTimers deleteTimerForTimeID:TimeIDSetRemindEventsAndMode];
                
                setRemindEventsAndModeCallBack callBack = [NSMutableArray popFromArray:self.stackSetRemindEventsAndMode];
                if (callBack) {
                    callBack(YES);
                }
                return;
            }
            
        }
        
        if (cmd == CMDSetSportRemind) {
            if ([self.myTimers isValidForTimeID:TimeIDSetSportRemind]) {
                [self.myTimers deleteTimerForTimeID:TimeIDSetSportRemind];
                
                setSportRemindCallBack callBack = [NSMutableArray popFromArray:self.stackSetSportRemind];
                if (callBack) {
                    callBack(YES);
                }
            }
            return;
        }
        
        if (cmd == CMDSetAntiLost) {
            if ([self.myTimers isValidForTimeID:TimeIDSetAntiLost]) {
                [self.myTimers deleteTimerForTimeID:TimeIDSetAntiLost];
                
                setAntiLostCallBack callBack = [NSMutableArray popFromArray:self.stackSetAntiLost];
                if (callBack) {
                    callBack(YES);
                }
            }
            return;
        }
        
        if (cmd == CMDStartSendOtherRemind ||
            cmd == CMDEndSendOtherRemind) {
            [self handleOtherRemind:package];
            return;
        }
    }
}

//发送其他提醒事件的过程
- (void)handleOtherRemind:(Byte[PACKET_LENGTH])package
{
    Byte cmd = package[2];
    //OtherRemindType type = (OtherRemindType)package[3];
    
    if (cmd == CMDStartSendOtherRemind) {
        if (![self.myTimers isValidForTimeID:TimeIDStartSendOtherRemind]) {
            return;
        }
        [self.myTimers deleteTimerForTimeID:TimeIDStartSendOtherRemind];
        
        startRemind callBack = [NSMutableArray popFromArray:self.stackStartRemind];
        if (callBack) {
            callBack(YES);
        }
        return;
    }
    if (cmd == CMDEndSendOtherRemind) {
        if (![self.myTimers isValidForTimeID:TimeIDEndSendOtherRemind]) {
            return;
        }
        [self.myTimers deleteTimerForTimeID:TimeIDEndSendOtherRemind];
        
        finishRemind callBack = [NSMutableArray popFromArray:self.stackFinishRemind];
        if (callBack) {
            callBack(YES);
        }
    }
}

@end
