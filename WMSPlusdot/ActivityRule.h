//
//  ActivityRule.h
//  WMSPlusdot
//
//  Created by Sir on 15-2-11.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ActivityRuleType) {
    ActivityRuleTypeRuning = 1,
    ActivityRuleTypeSleep = 2,
    ActivityRuleTypeBean = 3,
};
typedef NS_ENUM(NSUInteger, ActivityRuleCycleType) {
    ActivityRuleCycleTypeHour = 0,
    ActivityRuleCycleTypeDay = 1,
    ActivityRuleCycleTypeWeek = 2,
};

@interface ActivityRule : NSObject

@property (nonatomic) int ruleID;
@property (nonatomic) ActivityRuleType ruleType;
@property (nonatomic) int count;
@property (nonatomic) ActivityRuleCycleType cycleType;
@property (nonatomic) int cycleCount;
@property (nonatomic, strong) NSString *ruleMemo;
@property (nonatomic) int activityID;

@end
