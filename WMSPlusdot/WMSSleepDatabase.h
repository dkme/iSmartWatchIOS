//
//  WMSSleepDatabase.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-18.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WMSSleepModel;

@interface WMSSleepDatabase : NSObject

+ (WMSSleepDatabase *)sleepDatabase;

- (BOOL)insertSleepData:(WMSSleepModel *)model;

- (BOOL)updateSleepData:(WMSSleepModel *)model;

- (BOOL)deleteAllSleepData;

- (BOOL)deleteSleepData:(WMSSleepModel *)model;

- (NSArray *)queryAllSleepData;

- (NSArray *)querySleepData:(NSDate *)sleepDate;

- (NSArray *)querySleepDataWithYear:(NSUInteger)year month:(NSUInteger)month;

- (NSDate *)queryEarliestDate;

- (double)avgSleepTimeFromYear:(NSUInteger)year month:(NSUInteger)month;



@end
