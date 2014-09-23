//
//  WMSSportModel.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-11.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSportModel.h"

@implementation WMSSportModel

- (id)initWithSportDate:(NSDate *)sportDate
       sportTargetSteps:(NSUInteger)targerSteps
             sportSteps:(NSUInteger)sportSteps
            sportMinute:(NSUInteger)sportMinute
          sportDistance:(NSUInteger)sportDistance
           sportCalorie:(NSUInteger)sportCalorie
{
    if (self = [super init]) {
        _sportDate = sportDate;
        _targetSteps = targerSteps;
        _sportSteps = sportSteps;
        _sportMinute = sportMinute;
        _sportDistance = sportDistance;
        _sportCalorie = sportCalorie;
    }
    return self;
}

- (id)initWithSportDate:(NSDate *)sportDate
       sportTargetSteps:(NSUInteger)targerSteps
             sportSteps:(NSUInteger)sportSteps
            sportMinute:(NSUInteger)sportMinute
          sportDistance:(NSUInteger)sportDistance
           sportCalorie:(NSUInteger)sportCalorie
            perHourData:(UInt16 *)perHourData
             dataLength:(NSUInteger)dataLength
{
    self = [self initWithSportDate:sportDate sportTargetSteps:targerSteps sportSteps:sportSteps sportMinute:sportMinute sportDistance:sportDistance sportCalorie:sportCalorie];
    if (self) {
        //_perHourData = perHourData;
        //_dataLength = dataLength;
        [self setPerHourData:perHourData withLength:(int)dataLength];
    }
    return self;
}

//
- (void)setPerHourData:(UInt16 *)perHourData withLength:(int)length
{
    if(perHourData == NULL) {
        return ;
    }
    
    _dataLength = length;
    _perHourData = malloc(sizeof(perHourData[0])*length);
    for(int i=0; i<length; i++) {
        _perHourData[i] = perHourData[i];
    }
}

- (void)dealloc
{
    free(_perHourData);
}

@end
