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
- (id)initWithClock:(WMSAlarmClockModel *)clock
{
    if (self = [super init]) {
        _status = clock.status;
        _startHour = clock.startHour;
        _startMinute = clock.startMinute;
        _snoozeMinute = clock.snoozeMinute;
        _repeats = clock.repeats;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    WMSAlarmClockModel *model = (WMSAlarmClockModel *)object;
    if (self.status             ==model.status                  &&
        self.startHour          ==model.startHour               &&
        self.startMinute        ==model.startMinute             &&
        self.snoozeMinute       ==model.snoozeMinute            &&
        [self.repeats isEqualToArray:model.repeats]             )
    {
        return YES;
    }
    return NO;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_status) forKey:@"WMSAlarmClockModel.status"];
    [aCoder encodeObject:@(_startHour) forKey:@"WMSAlarmClockModel.startHour"];
    [aCoder encodeObject:@(_startMinute) forKey:@"WMSAlarmClockModel.startMinute"];
    [aCoder encodeObject:@(_snoozeMinute) forKey:@"WMSAlarmClockModel.snoozeMinute"];
    [aCoder encodeObject:_repeats forKey:@"WMSAlarmClockModel.repeats"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _status = [[aDecoder decodeObjectForKey:@"WMSAlarmClockModel.status"] boolValue];
    _startHour = (NSUInteger)[[aDecoder decodeObjectForKey:@"WMSAlarmClockModel.startHour"] integerValue];;
    _startMinute = (NSUInteger)[[aDecoder decodeObjectForKey:@"WMSAlarmClockModel.startMinute"] integerValue];
    _snoozeMinute = (NSUInteger)[[aDecoder decodeObjectForKey:@"WMSAlarmClockModel.snoozeMinute"] integerValue];
    _repeats = [aDecoder decodeObjectForKey:@"WMSAlarmClockModel.repeats"];
    
    return self;
}

@end
