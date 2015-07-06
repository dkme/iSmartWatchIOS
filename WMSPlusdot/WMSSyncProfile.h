//
//  WMSSyncProfile.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/9.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WMSBleControl;

typedef void(^syncSportDataCallback)(NSDate *date, NSUInteger steps, NSUInteger distance, NSUInteger calories, NSUInteger durations, NSUInteger notSyncDays);

@interface WMSSyncProfile : NSObject


- (id)initWithBleControl:(WMSBleControl *)bleControl;

///同步运动数据
- (void)syncSportData:(syncSportDataCallback)aCallback;

@end
