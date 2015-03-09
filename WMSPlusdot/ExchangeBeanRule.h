//
//  ExchangeBeanRule.h
//  WMSPlusdot
//
//  Created by Sir on 15-3-2.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ExchangeBeanRuleType) {
    ExchangeBeanRuleTypeRuning = 1,
    ExchangeBeanRuleTypeSleep = 2,
    ExchangeBeanRuleTypeOther = 10,
};

@interface ExchangeBeanRule : NSObject

@property (nonatomic) int ruleID;
@property (nonatomic) ExchangeBeanRuleType ruleType;
@property (nonatomic) int eventNumber;
@property (nonatomic) int beanNumber;

@end
