//
//  NSDate+Formatter.m
//  WMSPlusdot
//
//  Created by John on 14-8-30.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "NSDate+Formatter.h"

const NSInteger oneDayTimeInterval = 24*60*60;

@implementation NSDate (Formatter)

+ (NSString *)stringDateForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy";
    return [dateFormatter stringFromDate:date];
}
+ (NSString *)dateOfYear:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy";
    NSString *strYear = [dateFormatter stringFromDate:date];
    
    return strYear;
}
+ (NSString *)dateOfMonth:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM";
    NSString *strMonth = [dateFormatter stringFromDate:date];
    
    return strMonth;
}
+ (NSString *)dateOfDay:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd";
    NSString *strDay = [dateFormatter stringFromDate:date];

    return strDay;
}

+ (NSDateMode)compareDate:(NSDate *)date
{
    NSDate *today = [NSDate date];
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:oneDayTimeInterval*-1.f];
    NSDate *tomorrow = [NSDate dateWithTimeIntervalSinceNow:oneDayTimeInterval];
    NSDate *refDate = date;
    
    //10 first characters of description is the calendar date:
    NSString *todayString = [[today description] substringToIndex:10];
    NSString *yesterdayString = [[yesterday description] substringToIndex:10];
    NSString *tomorrowString = [[tomorrow description] substringToIndex:10];
    NSString *refDateString = [[refDate description] substringToIndex:10];
    
    if ([refDateString isEqualToString:todayString])
    {
        return NSDateModeToday;
    } else if ([refDateString isEqualToString:yesterdayString])
    {
        return NSDateModeYesterday;
    } else if ([refDateString isEqualToString:tomorrowString])
    {
        return NSDateModeTomorrow;
    }
    else
    {
        return NSDateModeUnknown;
    }
}
+ (NSString *)formatDate:(NSDate *)date withFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = dateFormat;
    return [formatter stringFromDate:date];
}

@end
