//
//  WMSSettingProfile.m
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSettingProfile.h"
#import "WMSBleControl.h"
#include "parse.h"

@interface WMSSettingProfile ()

@property (nonatomic, strong) WMSBleControl *bleControl;
@property (nonatomic, strong) LGCharacteristic *serialPortWriteCharacteristic;
@property (nonatomic, strong) LGCharacteristic *lookCharacteristic;

@end

@implementation WMSSettingProfile

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
    _lookCharacteristic = [self.bleControl findCharactWithUUID:CHARACTERISTIC_LOOK_UUID];
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
    _lookCharacteristic = nil;
    
    [self unregisterFromNotifications];
}

#pragma mark - Public Methods

- (void)adjustDate:(NSDate *)date
        completion:(settingCallback)aCallback
{
    UInt16 year = [NSDate yearOfDate:date];
    UInt8 month = [NSDate monthOfDate:date];
    UInt8 day = [NSDate dayOfDate:date];
    UInt8 hour = [NSDate hourOfDate:date];
    UInt8 minute = [NSDate minuteOfDate:date];
    UInt8 second = [NSDate secondOfDate:date];
    UInt8 week_day = [NSDate weekdayOfDate:date];
    if (week_day == 1) {//系统时间中，1-7表示周日-周六
        week_day = 7;//协议中1-7表示周一到周日
    } else {
        week_day = week_day - 1;
    }
    
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = setTime(year, month, day, hour, minute, second, week_day, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_SETTING_ADJUST_DATE];
}

- (void)setUserInfoWithGender:(GenderType)gender
                          age:(NSUInteger)age
                       height:(NSUInteger)height
                       weight:(NSUInteger)weight
                   completion:(settingCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = setUserInfo(gender, age, height, weight, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_SETTING_SET_USER_INFO];
}

- (void)setSportTarget:(NSUInteger)steps
            completion:(settingCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = setTarget(steps, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_SETTING_SET_SPORT_TARGET];
}

- (void)setLost:(BOOL)openOrClose
     completion:(settingCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = setLost(openOrClose, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_SETTING_SET_LOST];
}

- (void)setSitting:(BOOL)openOrClose
         startHour:(NSUInteger)startHour
           endHour:(NSUInteger)endHour
          duration:(NSUInteger)duration
           repeats:(NSArray *)repeats
        completion:(settingCallback)aCallback
{
    ///由低位到高位，依次代表从周一到周日的重复状态。Bit位为1表示重复，为0表示不重复。所有的bit为都为0时，表示只当天有效
    UInt8 dayFlags = 0x00;
    for (int i=0; i<repeats.count; i++) {///周一到周日
        UInt8 status_bit = [repeats[i] boolValue];
        if (status_bit != 0) {//不为0表示重复
            dayFlags |= (0x01 << i);
        }
    }
    
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = setSitting(openOrClose, duration, startHour, endHour, dayFlags, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_SETTING_SET_SITTING];
}

- (void)setRemindWay:(RemindWay)way
          completion:(settingCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = setRemindWay(way, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_SETTING_SET_REMIND_WAY];
}

- (void)setRemind:(BOOL)startOrEnd
            event:(RemindEvents)event
       completion:(settingCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = 0;
    int timeID = 0;
    if (startOrEnd) {
        res = setStartRemind(event, &p);
        timeID = TIME_ID_SETTING_SET_START_REMIND;
    } else {
        res = setStopRemind(event, &p);
        timeID = TIME_ID_SETTING_SET_STOP_REMIND;
    }
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:timeID];
}

- (void)setRemindEvent:(RemindEvents)event
            completion:(settingCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = setRemindEvent(event, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_SETTING_SET_REMIND_EVENT];
}

- (void)setWeatherType:(WeatherType)type
                  temp:(NSInteger)temp
              tempUnit:(TempUnit)unit
              humidity:(NSUInteger)humidity
            completion:(settingCallback)aCallback
{
    BLE_SInt8 package[PACKAGE_SIZE] = {0};
    BLE_SInt8 *p = package;
    int res = setWeather(type, temp, unit, humidity, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_SETTING_SET_WEATHER];
}

- (void)adjustTimeDirection:(ROTATE_DIRECTION)direction
                 completion:(settingCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = adjustTime(direction, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_SETTING_ADJUST_TIME];
}

- (void)setAlarmClock:(BOOL)openOrClose
                   ID:(NSUInteger)no
                 hour:(NSUInteger)hour
               minute:(NSUInteger)minute
             interval:(NSUInteger)interval
              repeats:(NSArray *)repeats
           completion:(settingCallback)aCallback
{
    ///由低位到高位，依次代表从周一到周日的重复状态。Bit位为1表示重复，为0表示不重复。所有的bit为都为0时，表示只当天有效
    UInt8 dayFlags = 0x00;
    for (int i=0; i<repeats.count; i++) {///周一到周日
        UInt8 status_bit = [repeats[i] boolValue];
        if (status_bit != 0) {//不为0表示重复
            dayFlags |= (0x01 << i);
        }
    }
    
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = setAlarmClock(no, hour, minute, dayFlags, openOrClose, interval, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_SETTING_ALARM_CLOCK];
}

- (void)setSearchDevice:(BOOL)openOrClose
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = setSearchDevice(openOrClose, &p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.lookCharacteristic response:NO callbackHandle:nil withTimeID:-1];
}


#pragma mark - Private
+ (NSUInteger)weatherTypeFromCondition:(NSString *)condition
{
    static NSDictionary *_weatherTypeMap = nil;
    if (!_weatherTypeMap) {
        _weatherTypeMap = @{
                        @"clouds":@(WeatherTypeClear),
                        @"clear":@(WeatherTypeClouds),
                        @"light rain":@(WeatherTypeLightRain),
                        @"moderate rain":@(WeatherTypeModerateRain),
                        @"heavy rain":@(WeatherTypeHeavyRain),
                        @"light snow":@(WeatherTypeLightSnow),
                        @"moderate snow":@(WeatherTypeModerateSnow),
                        @"heavy snow":@(WeatherTypeHeavySnow),
                        };
    }
    return ((NSNumber *)_weatherTypeMap[condition]).unsignedIntegerValue;
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
    
    if ([CHARACTERISTIC_SERIAL_PORT_READ_UUID isEqualToString:uuid]) {
        if (CMD_setting == cmd) {
            static NSDictionary *key_time_map = nil;
            if (!key_time_map) {                
                NSUInteger items = SetSearchDevice - SetTime;
                NSMutableDictionary *temp_dic = [NSMutableDictionary dictionaryWithCapacity:items];
                int temp_key, temp_value;
                temp_key = SetTime;
                temp_value = TIME_ID_SETTING_ADJUST_DATE;
                for (int i=0; i<items; i++) {
                    temp_key += i;
                    if (temp_key > SetAlarmClock) {
                        //temp_value保持不变
                    } else {
                        temp_value += i;
                    }
                    [temp_dic setObject:@(temp_value) forKey:@(temp_key)];
                }
                key_time_map = temp_dic;
            }
            int timeID = [key_time_map[@(key)] intValue];
            settingCallback aCallback = [self.bleControl.stackManager popObjFromStackOfTimeID:timeID];
            if (aCallback) {
                aCallback(YES);
            }
        }///if
    }
}

@end
