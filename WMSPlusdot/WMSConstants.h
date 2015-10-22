//
//  WMSStringConstants.h
//  WMSPlusdot
//
//  Created by Sir on 14-10-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#pragma mark - 提示语句
#define TIP_NO_BINDING              @"请先在“绑定配件”中绑定您的手表"
#define TIP_NO_CONNECTION           @"您还没有连接手表或连接已断开"
//更新
#define ALERTVIEW_TITLE             NSLocalizedString(@"更新提醒",nil)
#define ALERTVIEW_MESSAGE           NSLocalizedString(@"发现新的版本，快去更新吧！",nil)
#define ALERTVIEW_CANCEL_TITLE      NSLocalizedString(@"暂不更新",nil)
#define ALERTVIEW_OK_TITLE          NSLocalizedString(@"去App Store更新",nil)

#pragma mark - 尺寸、坐标
#define HUD_LOCATED_BOTTOM_SIZE     CGSizeMake(250.0, 60.0)
#define HUD_LOCATED_CENTER_SIZE     CGSizeMake(250.0, 120.0)
#define HUD_LOCATED_BOTTOM_Y_OFFSET ( ScreenHeight/2.0-60 )
#define HUD_LOCATED_CENTER_Y_OFFSET ( 0 )
#define HUD_SHOW_RIGHT_VC_X_OFFSET  ( 20.0 )
#define SYNC_BUTTON_SIZE            CGSizeMake(43.f, 30.f)


#pragma mark - 用户信息
#define USERINFO_GENDER             1//男
#define USERINFO_HEIGHT             170//cm
#define USERINFO_CURRENT_WEIGHT     60//kg
#define USERINFO_TARGET_WEIGHT      60//kg
#define USERINFO_BIRTHDAY           @"1970-01-01"
#define USERINFO_STRIDE      StrideWithGender(USERINFO_GENDER,USERINFO_HEIGHT)


//#pragma mark - 日期
//#define ONE_YEAR_FIRST_MONTH         1
//#define ONE_YEAR_LAST_MONTH          12

#pragma mark - 图表
#define LEFT_INTERVAL               0
#define BOTTOM_INTERVAL             30.f
#define POINTER_INTERVAL            45.f
#define LEVEL_LINE_NUMBER           6
#define CHART_INTERVAL_TO_YAXIS     20
#define PNBAR_WIDTH                 30
#define BAR_DEFAULT_HEIGHT          5

#pragma mark - 手表低电量
#define WATCH_LOW_BATTERY           20
#define WATCH_LOW_VOLTAGE           2.85//手表电压低于该值提示用户

#pragma mark - 设置目标
#define MIN_SPORT_STEPS             6000
#define MAX_SPORT_STEPS             60000
#define DEFAULT_TARGET_STEPS        60000

#pragma mark - 软件版本号
#define FIRMWARE_TARGET_VERSION     12.0
#define FIRMWARE_CAN_READ_MAC       13.0
#define FIRMWARE_ADD_BATTERY_INFO   20.0//添加读取设备电池信息的接口

#pragma mark - 固件版本号
#define FIRMWARE_NEW_VERSION        8.01 //使用新的固件

















