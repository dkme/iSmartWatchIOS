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

+ (NSUInteger)yearOfDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy";
    NSString *strYear = [dateFormatter stringFromDate:date];
    
    return [strYear integerValue];
}

+ (NSUInteger)monthOfDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM";
    NSString *strMonth = [dateFormatter stringFromDate:date];
    
    return [strMonth integerValue];
}

+ (NSUInteger)dayOfDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd";
    NSString *strDay = [dateFormatter stringFromDate:date];

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

+ (NSString *)formatDate:(NSDate *)date withFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = dateFormat;
    return [formatter stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)formatter
{    
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return [NSDate dateWithTimeInterval:24*60*60 sinceDate:date];
}

+ (NSInteger)daysOfDuringDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    //只保留日期中的年月日
    NSString *date1String = [[date1 description] substringToIndex:10];
    NSString *date2String = [[date2 description] substringToIndex:10];
    //DEBUGLog(@"date1String:%@,date2String:%@",date1String,date2String);
    NSDate *dt1 = [NSDate dateFromString:date1String format:@"yyyy-MM-dd"];
    NSDate *dt2 = [NSDate dateFromString:date2String format:@"yyyy-MM-dd"];
    //DEBUGLog(@"dt1:%@,dt2:%@",[dt1 description],[dt2 description]);
    NSTimeInterval interval = [dt1 timeIntervalSinceDate:dt2];
    //DEBUGLog(@"interval:%f",interval);
    //DEBUGLog(@"days:%f",interval/60/60/24);
    return (interval/60/60/24);
}

@end
