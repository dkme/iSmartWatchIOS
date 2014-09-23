//
//  WMSSleepModel.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-17.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSleepModel.h"

@implementation WMSSleepModel

- (id)initWithSleepDate:(NSDate *)sleepDate
           sleepEndHour:(NSUInteger)sleepEndHour
         sleepEndMinute:(NSUInteger)sleepEndMinute
            sleepMinute:(NSUInteger)sleepMinute
           asleepMinute:(NSUInteger)asleepMinute
             awakeCount:(NSUInteger)awakeCount
        deepSleepMinute:(NSUInteger)deepSleepMinute
       lightSleepMinute:(NSUInteger)lightSleepMinute
         startedMinutes:(UInt16 *)startedMinutes
          startedStatus:(UInt8 *)startedStatus
        statusDurations:(UInt8 *)statusDurations
             dataLength:(NSUInteger)dataLength
{
    if (self = [super init]) {
        _sleepDate = sleepDate;
        _sleepEndHour = sleepEndHour;
        _sleepEndMinute = sleepEndMinute;
        _sleepMinute = sleepMinute;
        _asleepMinute = asleepMinute;
        _awakeCount = awakeCount;
        _deepSleepMinute = deepSleepMinute;
        _lightSleepMinute = lightSleepMinute;
        [self setStartedMinutes:startedMinutes withLength:dataLength];
        [self setStartedStatus:startedStatus withLength:dataLength];
        [self setStatusDurations:statusDurations withLength:dataLength];
        _dataLength = dataLength;
    }
    return self;
}

- (void)setStartedMinutes:(UInt16 *)startedMinutes withLength:(NSUInteger)dataLength
{
    if(startedMinutes == NULL) {
        return ;
    }
    
    _dataLength = dataLength;
    _startedMinutes = malloc(sizeof(startedMinutes[0])*dataLength);
    for(int i=0; i<dataLength; i++) {
        _startedMinutes[i] = startedMinutes[i];
    }
}

- (void)setStartedStatus:(UInt8 *)startedStatus withLength:(NSUInteger)dataLength
{
    if(startedStatus == NULL) {
        return ;
    }
    
    _dataLength = dataLength;
    _startedStatus = malloc(sizeof(startedStatus[0])*dataLength);
    for(int i=0; i<dataLength; i++) {
        _startedStatus[i] = startedStatus[i];
    }
}

- (void)setStatusDurations:(UInt8 *)statusDurations withLength:(NSUInteger)dataLength
{
    if(statusDurations == NULL) {
        return ;
    }
    
    _dataLength = dataLength;
    _statusDurations = malloc(sizeof(statusDurations[0])*dataLength);
    for(int i=0; i<dataLength; i++) {
        _statusDurations[i] = statusDurations[i];
    }
}

- (void)dealloc
{
    free(_startedMinutes);
    free(_startedStatus);
    free(_statusDurations);
}

@end
