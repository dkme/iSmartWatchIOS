//
//  WMSAlarmClock.m
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSAlarmClock.h"

@implementation WMSAlarmClock

- (id)initWithHour:(Byte)hour
        withMinute:(Byte)minute
   withRepetitions:(Byte)repeat
{
    if (self = [super init]) {
        _hour = hour;
        _minute = minute;
        _repetitions = repeat;
    }
    return self;
}

@end
