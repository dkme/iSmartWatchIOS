//
//  EHTMyTimers.m
//  RobinsApp
//
//  Created by user on 14-6-9.
//  Copyright (c) 2014年 shenzhen eHealthy. All rights reserved.
//

#import "WMSMyTimers.h"

#define UNKNOWN_TIMER_ID    1234567890

@interface WMSMyTimers()
@property (nonatomic, strong) NSMutableDictionary *allTimers;

//存放每个timer的触发次数
@property (nonatomic, strong) NSMutableDictionary *timerTriggerCountDic;
@end

@implementation WMSMyTimers

- (id)init
{
    if (self = [super init]) {
        _allTimers = [[NSMutableDictionary alloc] init];
        
        _timerTriggerCountDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo timeID:(int)ID
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    
    [self deleteTimerForTimeID:ID];
    [self deleteTimerTriggerCountForTimeID:ID];
    
    [self.allTimers setObject:timer forKey:@(ID)];
    [self.timerTriggerCountDic setObject:@(0) forKey:@(ID)];
}
- (void)deleteTimerForTimeID:(int)ID
{
    NSTimer *timer = [self.allTimers objectForKey:@(ID)];
    if (timer) {
        [timer invalidate];
        [self.allTimers removeObjectForKey:@(ID)];
    }
}
- (void)deleteTimerForTimer:(NSTimer *)timer
{
    [self deleteTimerForTimeID:[self getTimerID:timer]];
}
- (void)deleteAllTimers
{
    for (NSNumber *key in [self.allTimers allKeys]) {
        [self deleteTimerForTimeID:[key intValue]];
    }
}
- (int)getTimerID:(NSTimer *)timer
{
    for (NSNumber *key in [self.allTimers allKeys]) {
        if (timer == [self.allTimers objectForKey:key]) {
            return [key intValue];
        }
    }
    return UNKNOWN_TIMER_ID;
}
- (BOOL)isValidForTimeID:(int)ID
{
    NSTimer *tm = [self getTimerForTimeID:ID];
    if (tm && tm.isValid) {
        return YES;
    }
    return NO;
}

- (NSTimer *)getTimerForTimeID:(int)ID
{
    return [self.allTimers objectForKey:@(ID)];
}
- (NSString *)description
{
    return [self.allTimers description];
}


- (void)addTriggerCountToTimer:(NSTimer *)timer
{
    int ID = [self getTimerID:timer];
    int count = [self triggerCountForTimer:timer];
    count++;
    
    [self.timerTriggerCountDic setObject:@(count) forKey:@(ID)];
}

- (int)triggerCountForTimer:(NSTimer *)timer
{
    int ID = [self getTimerID:timer];
    int count = [[self.timerTriggerCountDic objectForKey:@(ID)] intValue];
    
    return count;
}
- (void)resetTriggerCountOfTimerID:(int)ID
{
    [self.timerTriggerCountDic setObject:@(0) forKey:@(ID)];
}

- (void)deleteTimerTriggerCountForTimeID:(int)ID
{
    [self.timerTriggerCountDic removeObjectForKey:@(ID)];
}

@end
