//
//  WMSAlarmClockModel.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSAlarmClockModel.h"

@implementation WMSAlarmClockModel

- (id)initWithStatus:(BOOL)openOrClose
           startHour:(NSUInteger)startHour
         startMinute:(NSUInteger)startMinute
        snoozeMinute:(NSUInteger)snoozeMinute
             repeats:(NSArray *)repeats
{
    if (self = [super init]) {
        _status = openOrClose;
        _startHour = startHour;
        _startMinute = startMinute;
        _snoozeMinute = snoozeMinute;
        _repeats = repeats;
    }
    return self;
}

@end
