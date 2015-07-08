//
//  WMSSyncProfile.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/9.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSSyncProfile.h"
#import "WMSBleControl.h"
#include "sync.h"
#include "parse.h"

@interface WMSSyncProfile ()

@property (nonatomic, strong) WMSBleControl *bleControl;
@property (nonatomic, strong) LGCharacteristic *serialPortWriteCharacteristic;

@end

@implementation WMSSyncProfile

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
    
}
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidGetNotifyValue:) name:KLGCharacteristicDidNotifyValueNotification object:nil];
}
- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    _bleControl = nil;
    _serialPortWriteCharacteristic = nil;
    
    [self unregisterFromNotifications];
}

#pragma mark - Public Methods
- (void)syncSportData:(syncSportDataCallback)aCallback
{
    BLE_UInt8 package[PACKAGE_SIZE] = {0};
    BLE_UInt8 *p = package;
    int res = syncSportData(&p);
    if (res != HANDLE_OK) {
        return ;
    }
    [self.bleControl writeBytes:package length:PACKAGE_SIZE toCharacteristic:self.serialPortWriteCharacteristic response:NO callbackHandle:aCallback withTimeID:TIME_ID_SYNC_SPORT_DATA];
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
    
    Byte package[PACKAGE_SIZE] = {0};
    [value getBytes:package length:PACKAGE_SIZE];
    struct_parse_package s_pg = parse(package, PACKAGE_SIZE);
    Byte cmd = s_pg.cmd;
    Byte key = s_pg.key;
    
    if (NSOrderedSame == [CHARACTERISTIC_SERIAL_PORT_READ_UUID caseInsensitiveCompare:uuid]) {
        switch (CMD_KEY(cmd, key)) {
            case CMD_KEY(CMD_syncData, KEY_syncSportData):
            {
                Struct_SportData res = getSportData(package, PACKAGE_SIZE);
                if (res.error == HANDLE_OK) {
                    NSString *strDate = [NSString stringWithFormat:@"%04d-%02d-%02d", res.year, res.month, res.day];
                    NSDate *date = [NSDate dateFromString:strDate format:@"yyyy-MM-dd"];
                    syncSportDataCallback aCallback = [self.bleControl.stackManager popObjFromStackOfTimeID:TIME_ID_SYNC_SPORT_DATA];
                    if (aCallback) {
                        aCallback(date, res.steps, res.distances, res.fireHeats, res.durations, res.notSyncDays);
                    }
                }
                break;
            }
                
            default:
                break;
        }
    }///if
}


@end
