//
//  WMSStackManager.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/10.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSStackManager.h"
#import "NSMutableArray+Stack.h"
#import "WMSMyTimers.h"
#import "BLEUtils.h"


@interface WMSStackManager ()

@property (nonatomic, strong) NSMutableDictionary *stackMap;


@end

@implementation WMSStackManager

- (id)init
{
    if (self = [super init]) {
        _myTimers = [[WMSMyTimers alloc] init];
        
        _stackMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}




- (BOOL)pushObj:(id)obj toStackOfTimeID:(int)timeID
{
    if (!obj) {
        return NO;
    }
    
    NSMutableArray *stack = self.stackMap[@(timeID)];
    if (stack == nil) {
        stack = [NSMutableArray new];
        [stack push:obj];
        [self.stackMap setObject:stack forKey:@(timeID)];
        return YES;
    }
    [stack push:obj];
    return YES;
}


- (id)popObjFromStackOfTimeID:(int)timeID
{
    NSMutableArray *stack = self.stackMap[@(timeID)];
    if (stack == nil) {
        return nil;
    }
    
    if ([self.myTimers isValidForTimeID:timeID]) {
        [self.myTimers resetTriggerCountOfTimerID:timeID];
        id aCallback = [stack pop];
        if (![stack isHasData]) {
            [self.myTimers deleteTimerForTimeID:timeID];
        }
        return aCallback;
    }
    return nil;
}



@end
