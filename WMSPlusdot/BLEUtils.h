//
//  BLEUtils.h
//  WMSPlusdot
//
//  Created by Sir on 15-4-14.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

//通讯命令字
typedef NS_ENUM(Byte, CMDType) {
    CMDSetCurrentDate = 0x01,
    CMDSetPersonInfo = 0x02,
    CMDSetAlarmClock = 0x03,
    CMDSetTarger = 0x04,
    CMDSetRemind = 0x05,
    CMDSetBinding = 0x07,
    CMDSetSportRemind = 0x08,
    CMDSetAntiLost = 0x09,
    
    CMDGetDeviceInfo = 0x0A,
    CMDGetDeviceTime = 0x0B,
    CMDGETDeviceMac = 0xA1,
    
    CMDSwitchControlMode = 0xF2,
    CMDSwitchUpdateMode = 0x30,
    CMDResetDevice = 0xF4,
    
    //DeviceProfile
    CMDPrepareSyncSportData = 0x13,
    CMDStartSyncSportData = 0x14,
    CMDEndSyncSportData = 0x15,
    
    CMDPrepareSyncSleepData = 0x16,
    CMDAgainPrepareSyncSleepData = 0x19,
    CMDStartSyncSleepData = 0x17,
    CMDEndSyncSleepData = 0x18,
    
    CMDReadDeviceRemoteData = 0xF0,
    
    //SettingProfile
    CMDStartSendOtherRemind = 0x20,
    CMDEndSendOtherRemind = 0x21,
    
    //RemindProfile
    CMDStartRemind = 0x20,
    CMDEndRemind = 0x21,
};

//timeID
typedef NS_ENUM(int, TimeID) {
    TimeIDSubscribeNotifyCharact = 100,
    TimeIDBindSetting,
    TimeIDSwitchControlMode,
    TimeIDSwitchUpdateMode,
    
    //DeviceProfile
    TimeIDReadDeviceInfo = 200,
    TimeIDReadDeviceTime,
    TimeIDReadDeviceMac,
    TimeIDPrepareSyncSportData,
    TimeIDStartSyncSportData,
    TimeIDEndSyncSportData,
    
    TimeIDPrepareSyncSleepData,
    TimeIDAgainPrepareSyncSleepData,
    TimeIDStartSyncSleepData,
    TimeIDEndSyncSleepData,
    
    //SettingProfile
    TimeIDSetCurrentDate = 300,
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
    
    //RemindProfile
    TimeIDStartRemind = 400,
    TimeIDEndRemind,
};

//超时设置
static const NSUInteger MAX_TIMEOUT_COUNT                           = 5;
static const NSUInteger SUBSCRIBE_CHARACTERISTICS_INTERVAL          = 2;
static const NSUInteger WRITEVALUE_CHARACTERISTICS_INTERVAL         = 2;
#define KEY_TIMEOUT_USERINFO_CHARACT    @"KEY_TIMEOUT_USERINFO_CHARACT"
#define KEY_TIMEOUT_USERINFO_VALUE      @"KEY_TIMEOUT_USERINFO_VALUE"




