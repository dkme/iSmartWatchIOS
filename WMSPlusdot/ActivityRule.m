//
//  ActivityRule.m
//  WMSPlusdot
//
//  Created by Sir on 15-2-11.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "ActivityRule.h"

@implementation ActivityRule

- (NSString *)description
{
    return [NSString stringWithFormat:@"[ruleID=%d,ruleType=%d,count=%d,cycleType=%d,cycleCount=%d,ruleMemo=%@,activityID=%d]",_ruleID,_ruleType,_count,_cycleType,_cycleCount,_ruleMemo,_activityID];
}

@end
