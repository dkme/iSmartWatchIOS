//
//  WMSHistoryVCHelper.h
//  WMSPlusdot
//
//  Created by Sir on 14-11-7.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSHistoryVCHelper : NSObject

+ (NSArray *)xAxisShowMonthsFromEarliestDate:(NSDate *)date currentDate:(NSDate *)date2;

+ (NSArray *)xAxisValuesFromEarliestDate:(NSDate *)date currentDate:(NSDate *)date2;

+ (NSDate *)chartStartDateFromEarliestDate:(NSDate *)date currentDate:(NSDate *)date2;

@end
