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

//+ (NSString *)stringDateForDate:(NSDate *)date;
+ (NSString *)dateOfYear:(NSDate *)date;
+ (NSString *)dateOfMonth:(NSDate *)date;
+ (NSString *)dateOfDay:(NSDate *)date;

+ (NSDateMode)compareDate:(NSDate *)date;
+ (NSString *)formatDate:(NSDate *)date withFormat:(NSString *)dateFormat;

@end
