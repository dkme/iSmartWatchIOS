//
//  WMSActivityModel.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSActivityModel.h"

@implementation WMSActivityModel

- (id)initWithStatus:(BOOL)status
           startHour:(NSUInteger)startHour
         startMinute:(NSUInteger)startMinute
             endHour:(NSUInteger)endHour
           endMinute:(NSUInteger)endMinute
      intervalMinute:(NSUInteger)intervalMinute
             repeats:(NSArray *)repeats
{
    if (self = [super init]) {
        _status = status;
        _startHour = startHour;
        _startMinute = startMinute;
        _endHour = endHour;
        _endMinute = endMinute;
        _intervalMinute = intervalMinute;
        _repeats = repeats;
    }
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_status) forKey:@"WMSActivityModel.status"];
    [aCoder encodeObject:@(_startHour) forKey:@"WMSActivityModel.startHour"];
    [aCoder encodeObject:@(_startMinute) forKey:@"WMSActivityModel.startMinute"];
    [aCoder encodeObject:@(_endHour) forKey:@"WMSActivityModel.endHour"];
    [aCoder encodeObject:@(_endMinute) forKey:@"WMSActivityModel.endMinute"];
    [aCoder encodeObject:@(_intervalMinute) forKey:@"WMSActivityModel.intervalMinute"];
    [aCoder encodeObject:_repeats forKey:@"WMSActivityModel.repeats"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _status = [[aDecoder decodeObjectForKey:@"WMSActivityModel.status"] boolValue];
    _startHour = (NSUInteger)[[aDecoder decodeObjectForKey:@"WMSActivityModel.startHour"] integerValue];
    _startMinute = (NSUInteger)[[aDecoder decodeObjectForKey:@"WMSActivityModel.startMinute"] integerValue];
    _endHour = (NSUInteger)[[aDecoder decodeObjectForKey:@"WMSActivityModel.endHour"] integerValue];
    _endMinute = (NSUInteger)[[aDecoder decodeObjectForKey:@"WMSActivityModel.endMinute"] integerValue];
    _intervalMinute = (NSUInteger)[[aDecoder decodeObjectForKey:@"WMSActivityModel.intervalMinute"] integerValue];
    _repeats = [aDecoder decodeObjectForKey:@"WMSActivityModel.repeats"];
    
    return self;
}

@end
