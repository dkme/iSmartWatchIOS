//
//  WMSRemindProfile.h
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WMSBleControl;

//
//typedef NS_ENUM(Byte, RemindEventsType) {
//    RemindEventsTypeMessage = 0x02,//QQ，微信消息
//    RemindEventsTypeSearchBracelets = 0x10,
//};

@interface WMSRemindProfile : NSObject

/**
 初始化方法
 */
- (id)initWithBleControl:(WMSBleControl *)bleControl;

/**
 提醒事件
 */
//- (void)remindEventsType:(RemindEventsType)remindEventsType;

@end
