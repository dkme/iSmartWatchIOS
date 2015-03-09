//
//  ExchangeBeanRule.m
//  WMSPlusdot
//
//  Created by Sir on 15-3-2.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "ExchangeBeanRule.h"

@implementation ExchangeBeanRule

- (NSString *)description
{
    return [NSString stringWithFormat:@"[ruleID=%d,ruleType=%d,eventNumber=%d,beanNumber=%d]",_ruleID,_ruleType,_eventNumber,_beanNumber];
}

@end
