//
//  WMSBindingView.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-18.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSBindingView.h"

@implementation WMSBindingView

+ (id)instanceBindingView
{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"WMSBindingView" owner:nil options:nil];
    WMSBindingView *view = (WMSBindingView *)[nibView objectAtIndex:0];
    return [self defaultInit:view];
}
+ (id)defaultInit:(WMSBindingView *)bindView
{
    bindView.textView.editable = NO;
    bindView.textView.userInteractionEnabled = NO;
    bindView.textView.backgroundColor = [UIColor clearColor];
    bindView.textView.textColor = [UIColor whiteColor];
    [bindView.bottomButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [bindView.bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bindView.bottomButton setBackgroundImage:[UIImage imageNamed:@"bind_btn_a.png"] forState:UIControlStateNormal];
    [bindView.bottomButton setBackgroundImage:[UIImage imageNamed:@"bind_btn_b.png"] forState:UIControlStateSelected];
    [bindView.bottomButton addTarget:bindView action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
    if (!iPhone5) {
        [bindView adaptiveIphone4];
    }
    return bindView;
}

- (void)adaptiveIphone4
{
    if (iPhone5) {
        return;
    }
    CGRect frame = self.imageView2.frame;
    frame.origin.y -= (568.0-480.0-40);
    self.imageView2.frame = frame;
    
    frame = self.textView.frame;
    frame.origin.y -= (568.0-480.0);
    self.textView.frame = frame;
    
    frame = self.bottomButton.frame;
    frame.origin.y -= (568.0-480.0);
    self.bottomButton.frame = frame;
}

- (void)show:(BOOL)animated forView:(UIView *)view
{
    if (self.isVisible) {
        return ;
    }
    self.alpha = 0.0;
    //self.textView.text = NSLocalizedString(@"请在手表灯亮起时,\n按下右上角按键,完成设备的匹配", nil);
    self.textView.textAlignment = NSTextAlignmentCenter;
    [view addSubview:self];
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1.0;
        } completion:nil];
    } else {
        self.alpha = 1.0;
    }
}
- (void)hidden:(BOOL)animated
{
    if (!self.isVisible) {
        return ;
    }
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
}

- (BOOL)isVisible
{
    if ([self superview]) {
        return YES;
    }
    return NO;
}

- (void)onButton:(id)sender
{
    [self hidden:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(bindingView:didClickBottomButton:)]) {
        [self.delegate bindingView:self didClickBottomButton:sender];
    }
}

@end
