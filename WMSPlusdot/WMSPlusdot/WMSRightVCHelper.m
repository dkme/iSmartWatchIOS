//
//  WMSRightVCHelper.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-16.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSRightVCHelper.h"
#import "WMSFileMacro.h"

#define LOW_BATTERY_LEVEL1       0.20f
#define LOW_BATTERY_LEVEL2       0.15f
#define LOW_BATTERY_LEVEL3       0.10f
#define LOW_BATTERY_LEVEL4       0.05f
#define LOW_BATTERY_REMIND_TIMEINTERVAL 20

@implementation WMSRightVCHelper

+ (BOOL)isSendLowBatteryRemind:(float)batteryLevel
{
    if (batteryLevel == LOW_BATTERY_LEVEL1 ||
        batteryLevel == LOW_BATTERY_LEVEL2 ||
        batteryLevel == LOW_BATTERY_LEVEL3 ||
        batteryLevel == LOW_BATTERY_LEVEL4)
    {
        return YES;
    }
    return NO;
}
+ (void)startLowBatteryRemind:(WMSSettingProfile *)setting
                   completion:(void(^)(void))aCallBack
{
    WeakObj(setting, weakSetting);
    [setting setRemind:YES event:RemindEventLowBattery completion:^(BOOL isSuccess) {
        DEBUGLog(@"开启低电量提醒%d", isSuccess);
        if (isSuccess) {
            StrongObj(weakSetting, strongSetting);
            if (strongSetting) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishLowBatteryRemind:) object:strongSetting];
                [self performSelector:@selector(finishLowBatteryRemind:) withObject:strongSetting afterDelay:LOW_BATTERY_REMIND_TIMEINTERVAL];
                if (aCallBack) {
                    aCallBack();
                }
            }
        }
    }];
}
+ (void)finishLowBatteryRemind:(WMSSettingProfile *)setting
{
    [setting setRemind:NO event:RemindEventLowBattery completion:^(BOOL isSuccess) {
        DEBUGLog(@"停止低电量提醒%d", isSuccess);
    }];
}

#pragma mark - 数据加载与保存
+ (NSArray *)__settingItemArray//存放保存设置项字典的key
{
    static NSArray *settingItemArray = nil;
    if (!settingItemArray) {
        settingItemArray = @[@"Phone",@"SMS",@"Email",@"Wechat",@"QQ",@"Skype",@"WhatsApp",@"Facebook",@"Twitter"];
    }
    return settingItemArray;
}

//+ (RemindEventsType)__remindEventsType
//{
//    NSDictionary *readData = [self loadSettingItemData];
//    NSArray *values = [readData objectsForKeys:self.__settingItemArray notFoundMarker:@""];
//    
//    NSUInteger events[7] = {RemindEventsTypeCall,RemindEventsTypeSMS,RemindEventsTypeEmail,RemindEventsTypeWeixin,RemindEventsTypeQQ,RemindEventsTypeFacebook,RemindEventsTypeTwitter};
//    RemindEventsType eventsType = 0x00;
//    for (int i=0; i<[values count]; i++) {
//        BOOL openOrClose = [[values objectAtIndex:i] boolValue];
//        if (openOrClose) {
//            eventsType = (eventsType | events[i]);
//        }
//    }
//    return eventsType;
//}

+ (NSDictionary *)loadSettingItemData
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_SETTINGS)];
    NSMutableDictionary *mutiDic = [NSMutableDictionary dictionaryWithDictionary:readData];
    if (readData == nil) {
        for (int i=0; i<[self.__settingItemArray count]; i++) {
            [mutiDic setObject:@(1) forKey:self.__settingItemArray[i]];//默认设置项都为打开状态
        }
    }
    return mutiDic;
}
+ (NSObject *)loadSettingItemDataOfKey:(NSString *)key
{
    NSDictionary *dic = [self loadSettingItemData];
    return dic[key];
}

+ (void)savaSettingItemForKey:(NSString *)key data:(NSObject *)object
{
    NSDictionary *readData = [self loadSettingItemData];
    NSMutableDictionary *writeData = [NSMutableDictionary dictionaryWithDictionary:readData];
    [writeData setObject:object forKey:key];
    [writeData writeToFile:FilePath(FILE_SETTINGS) atomically:YES];
}

+ (BOOL)lowBatteryRemind
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_REMIND)];
    id obj = [readData objectForKey:@"battery"];
    if (obj == nil) {
        return 1;//默认为打开状态
    }
    return [obj boolValue];
}
+ (void)savaLowBatteryRemind:(BOOL)openOrClose
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_REMIND)];
    NSMutableDictionary *writeData = [NSMutableDictionary dictionaryWithDictionary:readData];
    [writeData setObject:@(openOrClose) forKey:@"battery"];
    [writeData writeToFile:FilePath(FILE_REMIND) atomically:YES];
}

+ (int)loadRemindWay
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_REMIND_WAY)];
    int way = [[readData objectForKey:@"remindWay"] intValue];
    if (readData == nil || way == 0) {
        return RemindWayShake;//默认“响铃”
    }
    return way;
}
+ (void)savaRemindWay:(int)way
{
    NSDictionary *writeData = @{@"remindWay":@(way)};
    [writeData writeToFile:FilePath(FILE_REMIND_WAY) atomically:YES];
}

//+ (void)setRemindWay:(int)way handle:(WMSSettingProfile *)handle completion:(void(^)(BOOL success))aCallBack
//{
//    RemindMode mode = way;//way与RemindMode一一对应
//    RemindEventsType type = [self __remindEventsType];
//    [handle setRemindEventsType:type mode:mode completion:^(BOOL success)
//     {
//         if (aCallBack) {
//             aCallBack(success);
//         }
//     }];
//}

//防丢设置项的加载与保存
+ (BOOL)loadLost
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FileDocumentPath(FILE_ANTILOST)];
    BOOL on = [[readData objectForKey:@"on"] boolValue];
    if (!readData) {
        return YES;//默认为“打开”
    }
    return on;
}
+ (void)savaLost:(BOOL)openOrClose
{
    NSDictionary *writeData = @{@"on":@(openOrClose)};
    [writeData writeToFile:FileDocumentPath(FILE_ANTILOST) atomically:YES];
}

#pragma mark - 第一次连接成功后，对设置项的配置
+ (void)resetFirstConnectedConfig
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:@"firstConnected"];
}
+ (void)startFirstConnectedConfig:(WMSSettingProfile *)handle
                       completion:(void(^)(void))aCallBack
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isFirst = [userDefaults boolForKey:@"firstConnected"];
    if (isFirst == NO) {
        //配置设置项
        [self __configWithIndex:0 handle:handle completion:^{
            DEBUGLog(@"配置完成");
            [userDefaults setBool:YES forKey:@"firstConnected"];
            if (aCallBack) {
                aCallBack();
            }
        }];
    }
}

+ (void)__configWithIndex:(int)index
                   handle:(WMSSettingProfile *)handle
               completion:(void(^)(void))aCallback
{
    WeakObj(handle, weakHandle);
    switch (index) {
        case 0:
        {
            RemindEvents event = 0;
            for (int i=RemindEventCall; i<=RemindEventSMS; i++) {
                event |= i;
            }
            [handle setRemindEvent:event completion:^(BOOL isSuccess) {
                if (isSuccess) {
                    StrongObj(weakHandle, strongHandle);
                    [self __configWithIndex:index+1 handle:strongHandle completion:aCallback];
                }
            }];
            break;
        }
        case 1:
        {
            RemindWay way = [self loadRemindWay];
            [handle setRemindWay:way completion:^(BOOL isSuccess) {
                if (isSuccess) {
                    StrongObj(weakHandle, strongHandle);
                    [self __configWithIndex:index+1 handle:strongHandle completion:aCallback];
                }
            }];
            break;
        }
//        case 2:
//        {
//            BOOL openOrClose = [self loadLost];
//            [handle setLost:openOrClose completion:^(BOOL isSuccess) {
//                if (isSuccess) {
//                    StrongObj(weakHandle, strongHandle);
//                    [self __configWithIndex:index+1 handle:strongHandle completion:aCallback];
//                }
//            }];
//            
//            break;
//        }
            
        default:
        {
            if (aCallback) {
                aCallback();
            }
            break;
        }
    }
}

//+ (void)__startConfigWithHandle:(WMSSettingProfile *)handle
//                     completion:(void(^)(void))aCallBack
//{
//    RemindEvents event = 0;
//    for (int i=RemindEventCall; i<RemindEventSkype; i++) {
//        event |= i;
//    }
//    WeakObj(handle, weakHandle);
//    [handle setRemindEvent:event completion:^(BOOL isSuccess) {
//        if (isSuccess) {
//            StrongObj(weakHandle, strongHandle);
//            RemindWay way = [self loadRemindWay];
//            [strongHandle setRemindWay:way completion:^(BOOL isSuccess) {
//                if (aCallBack) {
//                    aCallBack();
//                }
//            }];
//        }
//    }];
//}

//+ (void)__continueConfigWithHandle:(WMSSettingProfile *)handle
//                       configIndex:(int)index
//                        completion:(void(^)(void))aCallBack
//{
//    switch (index) {
//        case 1:
//        {
//            __weak __typeof(handle) weakHandle = handle;
//            [handle setRemindEventsType:eventsType mode:mode completion:^(BOOL success)
//             {
//                 if (success) {
//                     __strong __typeof(weakHandle) strongHandle = weakHandle;
//                     if (strongHandle) {
//                         [self __continueConfigWithHandle:strongHandle configIndex:index+1 completion:aCallBack];
//                     }
//                 }
//             }];
//            break;
//        }
//        default:
//        {
//            if (aCallBack) {
//                aCallBack();
//            }
//            break;
//        }
//    }
//}

#pragma mark - AlertView
+ (void)showTipOfLowBatteryNotSetVibrationRemindWay
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"手表电量过低，不能设置为“震动”模式",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",nil) otherButtonTitles:nil];
    [alertView show];
}

@end
