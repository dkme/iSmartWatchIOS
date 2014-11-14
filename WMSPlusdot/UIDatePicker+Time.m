//
//  UIDatePicker+Time.m
//  WMSPlusdot
//
//  Created by Sir on 14-11-12.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "UIDatePicker+Time.h"

const NSTimeInterval hour8TimeInterval = 8*60*60;

@implementation UIDatePicker (Time)

- (void)setPickerDate:(NSDate *)date
{
    //设置的date为08:00，但显示的时间会多8个小时，所以先减去8个小时
    self.date = [NSDate dateWithTimeInterval:-1*hour8TimeInterval sinceDate:date];
}

@end
