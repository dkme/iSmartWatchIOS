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
#import "DataPackage.h"

@interface WMSSettingProfile ()
{
    
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
- (WMSMyTimers *)myTimers
{
    return self.bleControl.myTimers;
}

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

#pragma mark - Public Methods
- (void)setCurrentDate:(NSDate *)date
            completion:(setCurrentDateCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetCurrentDate];
    }
    
    //send
    UInt16 year = [NSDate yearOfDate:date];
    Byte month = [NSDate monthOfDate:date];
    Byte day = [NSDate dayOfDate:date];
    Byte hour = [NSDate hourOfDate:date];
    Byte minute = [NSDate minuteOfDate:date];
    Byte second = [NSDate secondOfDate:date];
    Byte week_day = [NSDate weekdayOfDate:date];
    if (week_day == 1) {//系统时间中，1-7表示周日-周六
        week_day = 6;//协议中0-6表示周一到周日
    } else {
        week_day = week_day - 2;
    }
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = year & 0xFF;
    data[1] = (year & 0xFF00) >> 8;
    data[2] = month;
    data[3] = day;
    data[4] = hour;
    data[5] = minute;
    data[6] = second;
    data[7] = week_day;
    DataPackage *package = [DataPackage packageWithCMD:CMDSetCurrentDate data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDSetCurrentDate];
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
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetPersonInfo];
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
    
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = weight & 0xFF;
    data[1] = (weight & 0xFF00) >> 8;
    data[2] = height;
    data[3] = gender;
    data[4] = year & 0xFF;
    data[5] = (year & 0xFF00) >> 8;
    data[6] = month;
    data[7] = day;
    data[8] = stride;
    data[9] = metric;
    DataPackage *package = [DataPackage packageWithCMD:CMDSetPersonInfo data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDSetPersonInfo];
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
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetAlarmClock];
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
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = no;
    data[1] = hour;
    data[2] = minute;
    data[3] = byte;
    data[4] = snoozeMinute;
    DataPackage *package = [DataPackage packageWithCMD:CMDSetAlarmClock data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDSetAlarmClock];
    
}

- (void)setTargetWithStep:(UInt32)step
          withSleepMinute:(UInt16)minute
           withCompletion:(setTargetCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetTarget];
    }
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = step & 0xFF;
    data[1] = (step & 0xFF00) >> 8;
    data[2] = (step & 0xFF0000) >> 16;
    data[3] = (step & 0xFF000000) >> 24;
    data[4] = 0xFF;
    data[5] = 0xFF;
    data[6] = 0xFF;
    data[7] = 0xFF;
    DataPackage *package = [DataPackage packageWithCMD:CMDSetTarger data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDSetTarget];
}

- (void)setRemindWithMode:(RemindMode)remindMode
           withCompletion:(setRemindModeCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetRemindMode];
    }
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = remindMode;
    DataPackage *package = [DataPackage packageWithCMD:CMDSetRemind data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDSetRemindMode];
}

- (void)setRemindEventsType:(RemindEventsType)remindEventsType
                 completion:(setRemindEventsCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetRemindEvents];
    }
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = 0x03;
    data[1] = remindEventsType;
    DataPackage *package = [DataPackage packageWithCMD:CMDSetRemind data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDSetRemindEvents];
}

- (void)setRemindEventsType:(RemindEventsType)remindEventsType
                       mode:(RemindMode)remindMode
                 completion:(setRemindEventsAndModeCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetRemindEventsAndMode];
    }
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = remindMode;
    data[1] = remindEventsType;
    DataPackage *package = [DataPackage packageWithCMD:CMDSetRemind data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDSetRemindEventsAndMode];
}

- (void)startRemind:(OtherRemindType)remindType
         completion:(startRemind)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackStartRemind];
    }
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = remindType;
    DataPackage *package = [DataPackage packageWithCMD:CMDStartSendOtherRemind data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDStartSendOtherRemind];
}

- (void)finishRemind:(OtherRemindType)remindType
          completion:(finishRemind)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackFinishRemind];
    }
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = remindType;
    DataPackage *package = [DataPackage packageWithCMD:CMDEndSendOtherRemind data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDEndSendOtherRemind];
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
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetSportRemind];
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
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = intervalMinute & 0xFF;
    data[1] = (intervalMinute & 0xFF00) >> 8;
    data[2] = repetitions;
    data[3] = startHour;
    data[4] = startMinute;
    data[5] = endHour;
    data[6] = endMinute;
    DataPackage *package = [DataPackage packageWithCMD:CMDSetSportRemind data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDSetSportRemind];
}

- (void)setAntiLostStatus:(BOOL)openOrClose
                 distance:(NSUInteger)distance
             timeInterval:(NSUInteger)interval
               completion:(setAntiLostCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSetAntiLost];
    }
    Byte data[DATA_LENGTH] = {0};
    data[0] = openOrClose;
    data[1] = distance;
    data[2] = interval;
    DataPackage *package = [DataPackage packageWithCMD:CMDSetAntiLost data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDSetAntiLost];
}

#pragma mark - Handle
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
