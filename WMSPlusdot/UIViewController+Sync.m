//
//  UIViewController+Sync.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/7/20.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "UIViewController+Sync.h"
#import <objc/runtime.h>

@implementation UIViewController (Sync)

- (BOOL)isNeedBackWhenAfterSync
{
    return [objc_getAssociatedObject(self, @selector(isNeedBackWhenAfterSync)) boolValue];
}
- (void)setNeedBackWhenAfterSync:(BOOL)isNeed
{
    objc_setAssociatedObject(self, @selector(isNeedBackWhenAfterSync), @(isNeed), OBJC_ASSOCIATION_ASSIGN);
}

@end
