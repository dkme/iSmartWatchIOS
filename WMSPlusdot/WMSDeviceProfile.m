//
//  WMSDeviceProfile.m
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSDeviceProfile.h"
#import "WMSBleControl.h"
#import "NSMutableArray+Stack.h"
#import "DataPackage.h"

static const int HOUR_NUMBER            = 24;
static const int STARTED_NUMBER         = 50;

@interface WMSDeviceProfile ()
{
    //同步数据
    int _totals_SportData;
    UInt16 _year_SportData;
    Byte _month_SportData;
    Byte _day_SportData;
    NSString *_dateString_SportData;
    NSUInteger _todaySteps_SportData;
    NSUInteger _todaySportDurations_SportData;
    NSUInteger _surplusDays_SportData;
    UInt16 _perHourData_SportData[HOUR_NUMBER];
    int _index_SportData;
    
    
    int _totals_SleepData;
    UInt16 _year_SleepData;
    Byte _month_SleepData;
    Byte _day_SleepData;
    NSString *_dateString_SleepData;
    NSUInteger _sleepEndHour_SleepData;
    NSUInteger _sleepEndMinute_SleepData;
    NSUInteger _todaySleepDurations_SleepData;
    NSUInteger _todayAsleepDurations_SleepData;
    NSUInteger _awakeCount_SleepData;
    NSUInteger _lightSleepMinute_SleepData;
    NSUInteger _deepSleepMinute_SleepData;
    UInt16 _minutes_SleepData[STARTED_NUMBER];//存放距离睡眠开始的分钟数
    UInt8 _status_SleepData[STARTED_NUMBER];//存放睡眠的状态与上面一一对应
    UInt8 _durations_SleepData[STARTED_NUMBER];//存放某个睡眠状态的持续时间,与上面一一对应
    int _index_SleepData;//数组下表
    int _arrActualLength_SleepData;//数组的实际长度
    
}

@property (nonatomic, strong) WMSBleControl *bleControl;
@property (nonatomic, strong) LGCharacteristic *rwCharact;
@property (nonatomic, strong) LGCharacteristic *notifyCharact;

@property (nonatomic, strong) WMSMyTimers *myTimers;

//Block
@property (nonatomic, copy) readDeviceRemoteDataCallBack readDeviceRemoteDataBlock;

//Stack
@property (nonatomic, strong) NSMutableArray *stackReadDeviceInfo;
@property (nonatomic, strong) NSMutableArray *stackReadDeviceTime;
@property (nonatomic, strong) NSMutableArray *stackSyncSportData;
@property (nonatomic, strong) NSMutableArray *stackSyncSleepData;
@property (nonatomic, strong) NSMutableArray *stackReadDeviceRemoteData;
@property (nonatomic, strong) NSMutableArray *stackReadDeviceMac;
@property (nonatomic, strong) NSMutableArray *stackReadBatteryInfo;
@end

@implementation WMSDeviceProfile

#pragma mark - Getter
- (WMSMyTimers *)myTimers
{
    return self.bleControl.myTimers;
}

- (NSMutableArray *)stackReadDeviceInfo
{
    if (!_stackReadDeviceInfo) {
        _stackReadDeviceInfo = [NSMutableArray new];
    }
    return _stackReadDeviceInfo;
}
- (NSMutableArray *)stackReadDeviceTime
{
    if (!_stackReadDeviceTime) {
        _stackReadDeviceTime = [NSMutableArray new];
    }
    return _stackReadDeviceTime;
}
- (NSMutableArray *)stackSyncSportData
{
    if (!_stackSyncSportData) {
        _stackSyncSportData = [NSMutableArray new];
    }
    return _stackSyncSportData;
}
- (NSMutableArray *)stackSyncSleepData
{
    if (!_stackSyncSleepData) {
        _stackSyncSleepData = [NSMutableArray new];
    }
    return _stackSyncSleepData;
}
- (NSMutableArray *)stackReadDeviceRemoteData
{
    if (!_stackReadDeviceRemoteData) {
        _stackReadDeviceRemoteData = [NSMutableArray new];
    }
    return _stackReadDeviceRemoteData;
}
- (NSMutableArray *)stackReadDeviceMac
{
    if (!_stackReadDeviceMac) {
        _stackReadDeviceMac = [NSMutableArray new];
    }
    return _stackReadDeviceMac;
}
- (NSMutableArray *)stackReadBatteryInfo
{
    if (!_stackReadBatteryInfo) {
        _stackReadBatteryInfo = [NSMutableArray new];
    }
    return _stackReadBatteryInfo;
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
- (void)readDeviceInfoWithCompletion:(readDeviceInfoCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackReadDeviceInfo];
    }
    
    Byte data[DATA_LENGTH] = {0};
    DataPackage *package = [DataPackage packageWithCMD:CMDGetDeviceInfo data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDReadDeviceInfo];
}

- (void)readDeviceTimeWithCompletion:(readDeviceTimeCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackReadDeviceTime];
    }
    
    Byte data[DATA_LENGTH] = {0};
    DataPackage *package = [DataPackage packageWithCMD:CMDGetDeviceTime data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDReadDeviceTime];
}

- (void)syncDeviceSportDataWithCompletion:(syncDeviceSportDataCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    memset(_perHourData_SportData, 0, HOUR_NUMBER);
    _index_SportData = 0;
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSyncSportData];
    }
    
    [self prepareSyncSportData];
}

- (void)syncDeviceSleepDataWithCompletion:(syncDeviceSleepDataCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    memset(_minutes_SleepData, 0, STARTED_NUMBER);
    memset(_status_SleepData, 0, STARTED_NUMBER);
    memset(_durations_SleepData, 0, STARTED_NUMBER);
    _index_SleepData = 0;
    _arrActualLength_SleepData = 0;
    
    if (aCallBack) {
        [NSMutableArray push:aCallBack toArray:self.stackSyncSleepData];
    }
    
    [self prepareSyncSleepData];
}

- (void)readDeviceRemoteDataWithCompletion:(readDeviceRemoteDataCallBack)aCallBack
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    if (aCallBack) {
        self.readDeviceRemoteDataBlock = aCallBack;
    }
}

- (void)readDeviceMac:(readDeviceMacCallBack)aCallback
{
    if (!self.bleControl.isConnected) {
        return ;
    }
    if (aCallback) {
        [NSMutableArray push:aCallback toArray:self.stackReadDeviceMac];
    }
    
    Byte data[DATA_LENGTH] = {0};
    DataPackage *package = [DataPackage packageWithCMD:CMDGETDeviceMac data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDReadDeviceMac];
}

- (void)readDeviceBatteryInfo:(readDeviceBatteryInfoCallBack)aCallback
{
    if (!self.bleControl.isConnected) {
        return ;
    }
    if (aCallback) {
        [NSMutableArray push:aCallback toArray:self.stackReadBatteryInfo];
    }
    Byte data[DATA_LENGTH] = {0};
    DataPackage *package = [DataPackage packageWithCMD:CMDReadDeviceBatteryInfo data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDReadDeviceBatteryInfo];
}

#pragma mark - Handle
//Notification
- (void)handleDidGetNotifyValue:(NSNotification *)notification
{
    NSError *error = notification.object;
    NSData *value = [notification.userInfo objectForKey:@"value"];
    LGCharacteristic *charact = [notification.userInfo objectForKey:@"charact"];
    //DEBUGLog(@"notify value:%@,error:%@",value,error);
    if (charact == self.notifyCharact) {
        if (error) {
            DEBUGLog(@"通知错误，主动断开");
            [self.bleControl disconnect];
            return;
        }
        Byte package[PACKET_LENGTH] = {0};
        [value getBytes:package length:PACKET_LENGTH];
        Byte cmd = package[2];
        
        if (cmd == CMDGetDeviceInfo) {
            if ([self.myTimers isValidForTimeID:TimeIDReadDeviceInfo]) {
                [self.myTimers deleteTimerForTimeID:TimeIDReadDeviceInfo];
                
                readDeviceInfoCallBack callBack = [NSMutableArray popFromArray:self.stackReadDeviceInfo];
                if (callBack) {
                    Byte energy = package[3];
                    Byte version = package[4];
                    UInt32 steps = ((UInt32)package[8] << 24) + ((UInt32)package[7] << 16) + ((UInt32)package[6] << 8 ) + package[5];
                    UInt16 durations = ((UInt16)package[10] << 8) + package[9];
                    Byte workStatus = package[11];
                    UInt16 deviceID = ((UInt16)package[13] << 8) + package[12];
                    UInt8 pairFlag = package[14];
                    callBack(energy,version,steps,durations,workStatus,deviceID,pairFlag);
                }
            }
            return;
        }
        
        if (cmd == CMDGetDeviceTime) {
            if ([self.myTimers isValidForTimeID:TimeIDReadDeviceTime]) {
                [self.myTimers deleteTimerForTimeID:TimeIDReadDeviceTime];
                
                readDeviceTimeCallBack callBack = [NSMutableArray popFromArray:self.stackReadDeviceTime];
                if (callBack) {
                    DEBUGLog(@"read year:low8:0x%X,hight8:0x%X",package[3],package[4]);
                    UInt16 year = ((UInt16)package[4] << 8) + package[3];
                    Byte month = package[5];
                    Byte day = package[6];
                    Byte hour = package[7];
                    Byte minute = package[8];
                    Byte second = package[9];
                    Byte weekDay = package[10];
                    
                    NSString *dateString = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d %d",year,month,day,hour,minute,second,weekDay];
                    
                    callBack(dateString,YES);
                }
            }
            return;
        }
        
        if (cmd == CMDPrepareSyncSportData ||
            cmd == CMDStartSyncSportData   ||
            cmd == CMDEndSyncSportData)
        {
            [self handleSyncSportData:package];
            return;
        }
        
        if (cmd == CMDPrepareSyncSleepData ||
            cmd == CMDStartSyncSleepData   ||
            cmd == CMDEndSyncSleepData     ||
            cmd == CMDAgainPrepareSyncSleepData
           )
        {
            [self handleSyncSleepData:package];
            return;
        }
        
        if (cmd == CMDReadDeviceRemoteData) {
            //DEBUGLog(@"监听到按键状态");
            //readDeviceRemoteDataCallBack callBack = [NSMutableArray popFromArray:self.stackReadDeviceRemoteData];
            readDeviceRemoteDataCallBack callBack = self.readDeviceRemoteDataBlock;
            if (callBack) {
                Byte type = package[3];
                callBack(type);
            }
            //回复，不用超时重传
            Byte pg[DATA_LENGTH] = {0};
            DataPackage *package = [DataPackage packageWithCMD:CMDReadDeviceRemoteData data:pg];
            NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
            [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
            return;
        }
        
        if (cmd == CMDGETDeviceMac) {
            if ([self.myTimers isValidForTimeID:TimeIDReadDeviceMac]) {
                [self.myTimers deleteTimerForTimeID:TimeIDReadDeviceMac];
                
                readDeviceMacCallBack callBack = [NSMutableArray popFromArray:self.stackReadDeviceMac];
                if (callBack) {
                    UInt8 mac0 = package[3];
                    UInt8 mac1 = package[4];
                    UInt8 mac2 = package[5];
                    UInt8 mac3 = package[6];
                    UInt8 mac4 = package[7];
                    UInt8 mac5 = package[8];
                    NSString *mac = [NSString stringWithFormat:@"%X:%X:%X:%X:%X:%X",mac5,mac4,mac3,mac2,mac1,mac0];
                    callBack(mac);
                }
                callBack = nil;
            }
            return;
        }
        
        if (cmd == CMDReadDeviceBatteryInfo) {
            if ([self.myTimers isValidForTimeID:TimeIDReadDeviceBatteryInfo]) {
                [self.myTimers deleteTimerForTimeID:TimeIDReadDeviceBatteryInfo];
                
                readDeviceBatteryInfoCallBack callBack = [NSMutableArray popFromArray:self.stackReadBatteryInfo];
                if (callBack) {
                    UInt8 batt_type = package[3];
                    UInt16 batt_vol = package[4] + ((UInt16)package[5] << 8);//mv
                    UInt8 batt_stat = package[6];
                    UInt8 batt_level = package[7];
                    callBack(batt_type,batt_stat,batt_vol/1000.0,batt_level/100.0);
                    callBack = nil;
                }
            }
            return;
        }
    }
}

- (void)handleSyncSportData:(Byte[PACKET_LENGTH])package
{
    Byte cmd = package[2];
    
    if (cmd == CMDPrepareSyncSportData) {
        if (![self.myTimers isValidForTimeID:TimeIDPrepareSyncSportData]) {
            return;
        }
        [self.myTimers deleteTimerForTimeID:TimeIDPrepareSyncSportData];
        
        UInt16 year = package[3] + ((UInt16)package[4] << 8);
        Byte month = package[5];
        Byte day = package[6];
        NSString *strDate = [NSString stringWithFormat:@"%04d-%02d-%02d",year,month,day];
        UInt32 todaySteps = package[7] + ((UInt32)package[8] << 8) + ((UInt32)package[9] << 16) + ((UInt32)package[10] << 24);
        UInt16 todaySportDurations = package[11] + ((UInt16)package[12] << 8);
        UInt16 totals = package[13] + ((UInt16)package[14] << 8);
        Byte surplusDays = package[15];
        
        _totals_SportData = totals;
        
        _year_SportData = year;
        _month_SportData = month;
        _day_SportData = day;
        
        _dateString_SportData = strDate;
        _todaySteps_SportData = todaySteps;
        _todaySportDurations_SportData = todaySportDurations;
        _surplusDays_SportData = surplusDays;
        
        //把这些数据传出去
        //不要在这里回调，在这个同步命令结束时回调
//        syncDeviceSportDataCallBack callBack = [NSMutableArray popFromArray:self.stackSyncSportData];
//        if (callBack) {
//            callBack(strDate,todaySteps,todaySportDurations,surplusDays);
//        }
DEBUGLog(@"---->PrepareSync date:%d-%d-%d,total:%d",_year_SportData,_month_SportData,_day_SportData,_totals_SportData);
        
        [self startSyncSportData:1];
        
        return;
    }
    
    if (cmd == CMDStartSyncSportData) {
        if (![self.myTimers isValidForTimeID:TimeIDStartSyncSportData]) {
            return;
        }
        [self.myTimers deleteTimerForTimeID:TimeIDStartSyncSportData];
        
        Byte len = package[3];
        UInt16 currentSerial = package[4] + ((UInt16)package[5] << 8);
        UInt16 data0 = package[6] + ((UInt16)package[7] << 8);
        UInt16 data1 = package[8] + ((UInt16)package[9] << 8);
        UInt16 data2 = package[10] + ((UInt16)package[11] << 8);
        UInt16 data3 = package[12] + ((UInt16)package[13] << 8);
        UInt16 data4 = package[14] + ((UInt16)package[15] << 8);
        _perHourData_SportData[_index_SportData] = data0;
        _index_SportData++;
        _perHourData_SportData[_index_SportData] = data1;
        _index_SportData++;
        _perHourData_SportData[_index_SportData] = data2;
        _index_SportData++;
        _perHourData_SportData[_index_SportData] = data3;
        _index_SportData++;
        _perHourData_SportData[_index_SportData] = data4;
        _index_SportData++;
        DEBUGLog(@"---->len=%d---serial=%d----data:%d,%d,%d,%d,%d\n",len,currentSerial,data0,data1,data2,data3,data4);
        
        if (_totals_SportData <= currentSerial) {//数据同步完了
            _totals_SportData = 0;
            [self endSyncSportData];
            return;
        }
        
        currentSerial++;//自加1
        [self startSyncSportData:currentSerial];
        
        return;
    }
    
    if (cmd == CMDEndSyncSportData) {
        if (![self.myTimers isValidForTimeID:TimeIDEndSyncSportData]) {
            return;
        }
        [self.myTimers deleteTimerForTimeID:TimeIDEndSyncSportData];
        
        UInt16 year = package[3] + ((UInt16)package[4] << 8);
        Byte month = package[5];
        Byte day = package[6];
        DEBUGLog(@"---->EndSync date:%d-%d-%d",year,month,day);
        
        syncDeviceSportDataCallBack callBack = [NSMutableArray popFromArray:self.stackSyncSportData];
        if (callBack) {
            callBack(_dateString_SportData,_todaySteps_SportData,_todaySportDurations_SportData,_surplusDays_SportData,_perHourData_SportData,HOUR_NUMBER);
        }
        _dateString_SportData = @"";
        _todaySteps_SportData = 0;
        _todaySportDurations_SportData = 0;
        _surplusDays_SportData = 0;
        memset(_perHourData_SportData, 0, HOUR_NUMBER);
        _index_SportData = 0;
        
        return;
    }
}

- (void)handleSyncSleepData:(Byte[PACKET_LENGTH])package
{
    Byte cmd = package[2];
    
    if (cmd == CMDPrepareSyncSleepData) {
        if (![self.myTimers isValidForTimeID:TimeIDPrepareSyncSleepData]) {
            return;
        }
        [self.myTimers deleteTimerForTimeID:TimeIDPrepareSyncSleepData];
        
        UInt16 year = package[3] + ((UInt16)package[4] << 8);
        Byte month = package[5];
        Byte day = package[6];
        NSString *strDate = [NSString stringWithFormat:@"%04d-%02d-%02d",year,month,day];
        Byte endHour = package[7];
        Byte endMinute = package[8];
        UInt16 sleepDurations = package[9] + ((UInt16)package[10] << 8);
        UInt16 asleepMinute = package[11] + ((UInt16)package[12] << 8);
        Byte awakeCount = package[13];
        UInt16 totals = package[14] + ((UInt16)package[15] << 8);
        
        _totals_SleepData = totals;
        
        _year_SleepData = year;
        _month_SleepData = month;
        _day_SleepData = day;
        
        _dateString_SleepData = strDate;
        _sleepEndHour_SleepData = endHour;
        _sleepEndMinute_SleepData = endMinute;
        _todaySleepDurations_SleepData = sleepDurations;
        _todayAsleepDurations_SleepData = asleepMinute;
        _awakeCount_SleepData = awakeCount;
        
DEBUGLog(@"---->>>PrepareSync date:%d-%d-%d,total:%d",_year_SleepData,_month_SleepData,_day_SleepData,_totals_SleepData);
        
        [self againPrepareSyncSleepData];
        return;
    }
    
    if (cmd == CMDAgainPrepareSyncSleepData) {
        if (![self.myTimers isValidForTimeID:TimeIDAgainPrepareSyncSleepData]) {
            return;
        }
        [self.myTimers deleteTimerForTimeID:TimeIDAgainPrepareSyncSleepData];
        
        UInt16 lightSleepMinute = package[3] + ((UInt16)package[4] << 8);
        UInt16 deepSleepMinute = package[5] + ((UInt16)package[6] << 8);
        _lightSleepMinute_SleepData = lightSleepMinute;
        _deepSleepMinute_SleepData = deepSleepMinute;
        
        DEBUGLog(@"---->>>lightSleepMinute:%d,deepSleepMinute:%d",lightSleepMinute,deepSleepMinute);
        
        [self startSyncSleepData:1];
        return;
    }
    
    if (cmd == CMDStartSyncSleepData) {
        if (![self.myTimers isValidForTimeID:TimeIDStartSyncSleepData]) {
            return;
        }
        [self.myTimers deleteTimerForTimeID:TimeIDStartSyncSleepData];
        
        Byte len = package[3];
        UInt16 currentSerial = package[4] + ((UInt16)package[5] << 8);
        
        UInt16 started0 = package[6] + ((UInt16)package[7] << 8);
        UInt16 started0_minutes = started0 >> 4;
        UInt8 started0_status = started0 & 0x0F;
        UInt8 durations0 = package[8];
        
        UInt16 started1 = package[9] + ((UInt16)package[10] << 8);
        UInt16 started1_minutes = started1 >> 4;
        UInt8 started1_status = started1 & 0x0F;
        UInt8 durations1 = package[11];
        
        UInt16 started2 = package[12] + ((UInt16)package[13] << 8);
        UInt16 started2_minutes = started2 >> 4;
        UInt8 started2_status = started2 & 0x0F;
        UInt8 durations2 = package[14];
        
        _minutes_SleepData[_index_SleepData] = started0_minutes;
        _status_SleepData[_index_SleepData] = started0_status;
        _durations_SleepData[_index_SleepData] = durations0;
        _index_SleepData++;
        
        _minutes_SleepData[_index_SleepData] = started1_minutes;
        _status_SleepData[_index_SleepData] = started1_status;
        _durations_SleepData[_index_SleepData] = durations1;
        _index_SleepData++;
        
        _minutes_SleepData[_index_SleepData] = started2_minutes;
        _status_SleepData[_index_SleepData] = started2_status;
        _durations_SleepData[_index_SleepData] = durations2;
        _index_SleepData++;
        
        _arrActualLength_SleepData += len/3;
        
//        DEBUGLog(@"---->>>len=%d---serial=%d----started_minutes,started_status,durations:(%d,%d,%d),(%d,%d,%d),(%d,%d,%d)\n",
//                 len,currentSerial,
//                 started0_minutes,started0_status,durations0,
//                 started1_minutes,started1_status,durations1,
//                 started2_minutes,started2_status,durations2);
        
        if (_totals_SleepData <= currentSerial) {//数据同步完了
            _totals_SleepData = 0;
            [self endSyncSleepData];
            return;
        }
        
        currentSerial++;
        [self startSyncSleepData:currentSerial];
        
        return;
    }
    
    if (cmd == CMDEndSyncSleepData) {
        if (![self.myTimers isValidForTimeID:TimeIDEndSyncSleepData]) {
            return;
        }
        [self.myTimers deleteTimerForTimeID:TimeIDEndSyncSleepData];
        //DEBUGLog(@"end sleep");
        //
        syncDeviceSleepDataCallBack callBack = [NSMutableArray popFromArray:self.stackSyncSleepData];
        //DEBUGLog(@"stack:%@,callBack:%@",self.stackSyncSleepData,callBack);
        if (callBack) {
            callBack(_dateString_SleepData,
                     _sleepEndHour_SleepData,
                     _sleepEndMinute_SleepData,
                     _todaySleepDurations_SleepData,
                     _todayAsleepDurations_SleepData,
                     _awakeCount_SleepData,
                     _deepSleepMinute_SleepData,
                     _lightSleepMinute_SleepData,
                     _minutes_SleepData,
                     _status_SleepData,
                     _durations_SleepData,
                     _arrActualLength_SleepData);
        }
        
        return;
    }
}

#pragma mark - 同步运动数据整个流程
- (void)prepareSyncSportData
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    Byte data[DATA_LENGTH] = {0};
    DataPackage *package = [DataPackage packageWithCMD:CMDPrepareSyncSportData data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDPrepareSyncSportData];
}
- (void)startSyncSportData:(UInt16)serial//Serial从1开始
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    Byte data[DATA_LENGTH] = {0};
    data[0] = serial & 0xFF;
    data[1] = (serial & 0xFF00) >> 8;
    DataPackage *package = [DataPackage packageWithCMD:CMDStartSyncSportData data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDStartSyncSportData];
    
}
- (void)endSyncSportData
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = _year_SportData & 0xFF;
    data[1] = (_year_SportData & 0xFF00) >> 8;
    data[2] = _month_SportData;
    data[3] = _day_SportData;
    DataPackage *package = [DataPackage packageWithCMD:CMDEndSyncSportData data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDEndSyncSportData];
}

#pragma mark - 同步睡眠数据整个流程
- (void)prepareSyncSleepData
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte data[DATA_LENGTH] = {0};
    DataPackage *package = [DataPackage packageWithCMD:CMDPrepareSyncSleepData data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDPrepareSyncSleepData];
}
- (void)againPrepareSyncSleepData
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte data[DATA_LENGTH] = {0};
    DataPackage *package = [DataPackage packageWithCMD:CMDAgainPrepareSyncSleepData data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {DEBUGLog(@"响应");}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDAgainPrepareSyncSleepData];
}
- (void)startSyncSleepData:(UInt16)serial
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = serial & 0xFF;
    data[1] = (serial & 0xFF00) >> 8;
    DataPackage *package = [DataPackage packageWithCMD:CMDStartSyncSleepData data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDStartSyncSleepData];
}
- (void)endSyncSleepData
{
    if (![self.bleControl isConnected]) {
        return ;
    }
    
    Byte data[DATA_LENGTH] = {0};
    data[0] = _year_SleepData & 0xFF;
    data[1] = (_year_SleepData & 0xFF00) >> 8;
    data[2] = _month_SleepData;
    data[3] = _day_SleepData;
    DataPackage *package = [DataPackage packageWithCMD:CMDEndSyncSleepData data:data];
    NSData *sendData = [NSData dataWithBytes:[package packet] length:PACKET_LENGTH];
    
    [self.rwCharact writeValue:sendData completion:^(NSError *error) {}];
    
    [self.bleControl addTimerWithTimeInterval:WRITEVALUE_CHARACTERISTICS_INTERVAL handleCharacteristic:self.rwCharact handleData:sendData timeID:TimeIDEndSyncSleepData];
}

@end
