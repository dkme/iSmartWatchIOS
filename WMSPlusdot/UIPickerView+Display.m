//
//  UIPickerView+Display.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-29.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "UIPickerView+Display.h"

@implementation UIPickerView (Display)

- (void)show:(BOOL)animated
{
    if ([self isVisible]) {
        return ;
    }
    __block CGPoint or = self.frame.origin;
    float offset = self.bounds.size.height;
    if (animated) {
        [UIView animateWithDuration:0.7 animations:^{
            if (or.y == ScreenHeight) {
                or.y -= offset;
                self.frame = (CGRect){or,self.bounds.size};
            }
        }];
    } else {
        if (or.y == ScreenHeight) {
            or.y -= offset;
            self.frame = (CGRect){or,self.bounds.size};
        }
    }
}

- (void)hidden:(BOOL)animated
{
    if (![self isVisible]) {
        return ;
    }
    __block CGPoint or = self.frame.origin;
    float offset = self.bounds.size.height;
    if (animated) {
        [UIView animateWithDuration:0.7 animations:^{
            if (or.y == ScreenHeight - offset) {
                or.y += offset;
                self.frame = (CGRect){or,self.bounds.size};
            }
        }];
    } else {
//        if (or.y == ScreenHeight - offset) {
//            or.y += offset;
//            self.frame = (CGRect){or,self.bounds.size};
//        }
        CGRect frame = self.frame;
        frame.origin.x = 0;
        frame.origin.y = ScreenHeight;
        self.frame = frame;
    }
    DEBUGLog(@"inputView frame(%f,%f)",self.frame.origin.x,self.frame.origin.y);
}

#pragma mark - Private
- (BOOL)isVisible
{
    if (self.frame.origin.y >= ScreenHeight) {
        return NO;
    } else {
        return YES;
    }
    return YES;
}

@end
