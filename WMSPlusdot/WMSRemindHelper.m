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
    NSString *str = @"";
    BOOL flag = YES;//标识是否每天都重复
    for (int i=0; i<[repeats count]; i++) {
        BOOL var = [repeats[i] boolValue];
        if (YES == var) {
            str = [str stringByAppendingString:@" "];
            str = [str stringByAppendingString:arr[i]];
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

@end
