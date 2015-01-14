//
//  WMSRemindHelper.m
//  WMSPlusdot
//
//  Created by Sir on 14-10-27.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSRemindHelper.h"

@implementation WMSRemindHelper

+ (NSString *)descriptionOfRepeats:(NSArray *)repeats
{
    NSArray *arr = @[NSLocalizedString(@"一",nil),
                     NSLocalizedString(@"二",nil),
                     NSLocalizedString(@"三",nil),
                     NSLocalizedString(@"四",nil),
                     NSLocalizedString(@"五",nil),
                     NSLocalizedString(@"六",nil),
                     NSLocalizedString(@"七",nil)];
    return [self descriptionOfRepeats:repeats withStrings:arr];
}
+ (NSString *)description2OfRepeats:(NSArray *)repeats
{
    NSArray *arr = @[NSLocalizedString(@"周一",nil),
                     NSLocalizedString(@"周二",nil),
                     NSLocalizedString(@"周三",nil),
                     NSLocalizedString(@"周四",nil),
                     NSLocalizedString(@"周五",nil),
                     NSLocalizedString(@"周六",nil),
                     NSLocalizedString(@"周日",nil)];
    return [self descriptionOfRepeats:repeats withStrings:arr];
}
+ (NSString *)descriptionOfRepeats:(NSArray *)repeats withStrings:(NSArray *)strings
{
    NSString *str = @"";
    BOOL flag = YES;//标识是否每天都重复
    for (int i=0; i<[repeats count]; i++) {
        BOOL var = [repeats[i] boolValue];
        if (YES == var) {
            str = [str stringByAppendingString:@" "];
            str = [str stringByAppendingString:strings[i]];
        } else {
            flag = NO;
        }
    }
    if ([repeats count] > 0 && flag) {
        return NSLocalizedString(@"每天",nil);
    }
    else {
        return ([str isEqualToString:@""]?NSLocalizedString(@"永不", nil):str);
    }
}

+ (NSArray *)repeatsWithArray:(NSArray *)array
{
    NSArray *repeats = array;
    NSUInteger index = [repeats indexOfObject:@(1)];
    if (index >= repeats.count) {//表明没有重复的天，此时设为当天重复
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        NSInteger unitFlags = NSWeekdayCalendarUnit;
        NSDate *now=[NSDate date];
        comps = [calendar components:unitFlags fromDate:now];
        NSInteger weekDay = [comps weekday];
        NSMutableArray *mutiArray = [NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0,@0,@0]];
        int i = 0;
        if (weekDay == 1) {//周日
            i = (int)[mutiArray count]-1;
        } else {
            i = weekDay - 2;
        }
        mutiArray[i] = @(1);
        repeats = mutiArray;
    }
    return repeats;
}

@end
