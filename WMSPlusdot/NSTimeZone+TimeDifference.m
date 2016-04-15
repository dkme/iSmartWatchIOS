//
//  NSTimeZone+TimeDifference.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/8/11.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "NSTimeZone+TimeDifference.h"

@implementation NSTimeZone (TimeDifference)

- (NSInteger)timeDifferenceSinceTimeZone:(NSTimeZone *)timeZone
{
    NSInteger s1 = self.secondsFromGMT;
    NSInteger s2 = timeZone.secondsFromGMT;
    
    return s1-s2;
}

@end
