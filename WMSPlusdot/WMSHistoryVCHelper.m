//
//  WMSHistoryVCHelper.m
//  WMSPlusdot
//
//  Created by Sir on 14-11-7.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSHistoryVCHelper.h"

#define ONE_YEAR_FIRST_MONTH         1
#define ONE_YEAR_LAST_MONTH          12

@implementation WMSHistoryVCHelper

+ (NSArray *)xAxisShowMonthsFromEarliestDate:(NSDate *)date currentDate:(NSDate *)date2
{
    NSUInteger earliestYear = [NSDate yearOfDate:date];
    NSUInteger currentYear = [NSDate yearOfDate:date2];
    NSUInteger startMonth = (currentYear>earliestYear ? ONE_YEAR_FIRST_MONTH : [NSDate monthOfDate:date]);
    NSUInteger endMonth = [NSDate monthOfDate:date2];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:12];
    for (NSUInteger i=startMonth ; i<=endMonth; i++) {
        [values addObject:@(i)];
    }
    return values;
}

+ (NSArray *)xAxisValuesFromEarliestDate:(NSDate *)date currentDate:(NSDate *)date2
{
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:12];
    NSArray *months=[self xAxisShowMonthsFromEarliestDate:date currentDate:date2];
    for (NSNumber *number in months) {
        NSUInteger mm = [number unsignedIntegerValue];
        NSString *format = NSLocalizedString(@"%u月", nil);
        NSString *obj = [NSString stringWithFormat:format,(unsigned int)mm];
        [values addObject:obj];
    }
    return values;
}

+ (NSDate *)chartStartDateFromEarliestDate:(NSDate *)date currentDate:(NSDate *)date2
{
    NSUInteger earliestYear = [NSDate yearOfDate:date];
    NSUInteger currentYear = [NSDate yearOfDate:date2];
    NSUInteger month = (currentYear>earliestYear ? ONE_YEAR_FIRST_MONTH : [NSDate monthOfDate:date]);
    NSUInteger startYear = currentYear;
    NSUInteger startMonth = month;
    NSString *strDate = [NSString stringWithFormat:@"%04u-%02u",(unsigned int)startYear,(unsigned int)startMonth];
    return [NSDate dateFromString:strDate format:@"yyyy-MM"];
}

@end
