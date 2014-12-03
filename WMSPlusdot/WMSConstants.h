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


#pragma mark - 尺寸、坐标
#define HUD_LOCATED_BOTTOM_SIZE     CGSizeMake(250.0, 60.0)
#define HUD_LOCATED_CENTER_SIZE     CGSizeMake(250.0, 120.0)
#define HUD_LOCATED_BOTTOM_Y_OFFSET ( ScreenHeight/2.0-60 )
#define HUD_LOCATED_CENTER_Y_OFFSET ( 0 )
#define HUD_SHOW_RIGHT_VC_X_OFFSET  ( 20.0 )


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

