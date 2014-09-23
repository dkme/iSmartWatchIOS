//
//  WMSSleepModel.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-17.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSSleepModel : NSObject

@property (nonatomic, strong) NSDate *sleepDate;

@property (nonatomic, assign) NSUInteger sleepEndHour;

@property (nonatomic, assign) NSUInteger sleepEndMinute;

@property (nonatomic, assign) NSUInteger sleepMinute;

@property (nonatomic, assign) NSUInteger asleepMinute;

@property (nonatomic, assign) NSUInteger awakeCount;

@property (nonatomic, assign) NSUInteger deepSleepMinute;

@property (nonatomic, assign) NSUInteger lightSleepMinute;

/*距离开始的时间*/
@property (nonatomic, assign) UInt16 *startedMinutes;

/*睡眠状态*/
@property (nonatomic, assign) UInt8 *startedStatus;

/*这个状态持续的时间*/
@property (nonatomic, assign) UInt8 *statusDurations;

/*startedMinutes,startedStatus,statusDurations 
 三个数组中的每个元素是一一对应的，所以数据的长度是相同的*/
@property (nonatomic, assign) NSUInteger dataLength;


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
             dataLength:(NSUInteger)dataLength;

/**
 *给数组赋值
 */
- (void)setStartedMinutes:(UInt16 *)startedMinutes withLength:(NSUInteger)dataLength;

- (void)setStartedStatus:(UInt8 *)startedStatus withLength:(NSUInteger)dataLength;

- (void)setStatusDurations:(UInt8 *)statusDurations withLength:(NSUInteger)dataLength;

@end
