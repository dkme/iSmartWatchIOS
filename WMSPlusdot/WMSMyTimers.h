//
//  EHTMyTimers.h
//  RobinsApp
//
//  Created by user on 14-6-9.
//  Copyright (c) 2014年 shenzhen eHealthy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSMyTimers : NSObject

- (id)init;
- (void)addTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo timeID:(int)ID;
- (void)deleteTimerForTimeID:(int)ID;
- (void)deleteTimerForTimer:(NSTimer *)timer;
- (void)deleteAllTimers;
- (int)getTimerID:(NSTimer *)timer;
- (BOOL)isValidForTimeID:(int)ID;
- (NSTimer *)getTimerForTimeID:(int)ID;
- (NSString *)description;

- (void)addTriggerCountToTimer:(NSTimer *)timer;
- (int)triggerCountForTimer:(NSTimer *)timer;
- (void)resetTriggerCountOfTimerID:(int)ID;//重置定时器的触发次数

@end
