//
//  NSDate+Formatter.h
//  WMSPlusdot
//
//  Created by John on 14-8-30.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NSDateMode) {
    NSDateModeYesterday = -1,
    NSDateModeToday = 0,
    NSDateModeTomorrow = 1,
    NSDateModeUnknown = 2,
};

@interface NSDate (Formatter)

+ (NSDate *)systemDate;

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)dateFormat;

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)formatter;

+ (NSUInteger)yearOfDate:(NSDate *)date;

+ (NSUInteger)monthOfDate:(NSDate *)date;

+ (NSUInteger)dayOfDate:(NSDate *)date;

+ (NSDateMode)compareDate:(NSDate *)date;

+ (NSUInteger)daysOfDuringDate:(NSDate *)date1 andDate:(NSDate *)date2;

@end
