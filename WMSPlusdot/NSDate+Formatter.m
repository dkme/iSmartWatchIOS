//
//  NSDate+Formatter.m
//  WMSPlusdot
//
//  Created by John on 14-8-30.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "NSDate+Formatter.h"

const NSTimeInterval oneDayTimeInterval = 24*60*60;
const NSTimeInterval hour8TimeInterval = 8*60*60;

@implementation NSDate (Formatter)

+ (NSDate *)systemDate
{
    //获取的系统时间会少8h，所以将获取的系统时间加上8h，才是正确的系统时间
    return [NSDate dateWithTimeIntervalSinceNow:hour8TimeInterval];
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)dateFormat
{
    //NSDate---->NSString   会多8h，所以先减8h
    NSDate *newDate = [NSDate dateWithTimeInterval:(-1*hour8TimeInterval) sinceDate:date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = dateFormat;
    return [formatter stringFromDate:newDate];
}

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)formatter
{
    //NSString---->NSDate   会少8h，所以结果要加8h
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatter;
    NSDate *date = [dateFormatter dateFromString:dateString];
    return [NSDate dateWithTimeInterval:hour8TimeInterval sinceDate:date];
}


+ (NSUInteger)yearOfDate:(NSDate *)date
{
    NSString *strYear = [NSDate stringFromDate:date format:@"yyyy"];
    
    return [strYear integerValue];
}

+ (NSUInteger)monthOfDate:(NSDate *)date
{
    NSString *strMonth = [NSDate stringFromDate:date format:@"MM"];
    
    return [strMonth integerValue];
}

+ (NSUInteger)dayOfDate:(NSDate *)date
{
    NSString *strDay = [NSDate stringFromDate:date format:@"dd"];
    
    return [strDay integerValue];
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

+ (NSUInteger)daysOfDuringDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    //只保留日期中的年月日
    NSString *date1String = [[date1 description] substringToIndex:10];
    NSString *date2String = [[date2 description] substringToIndex:10];
    NSDate *dt1 = [NSDate dateFromString:date1String format:@"yyyy-MM-dd"];
    NSDate *dt2 = [NSDate dateFromString:date2String format:@"yyyy-MM-dd"];
    NSTimeInterval interval = [dt1 timeIntervalSinceDate:dt2];
    return (interval/oneDayTimeInterval);
}

@end
