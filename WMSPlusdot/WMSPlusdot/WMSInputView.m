//
//  WMSInputView.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-29.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSInputView.h"

@interface WMSInputView ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightItem;

@end

@implementation WMSInputView

- (id)initWithLeftItemTitle:(NSString *)leftTitle
             RightItemTitle:(NSString *)rightTitle
{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"WMSInputView" owner:nil options:nil];
    WMSInputView *inputView = (WMSInputView *)[nibView objectAtIndex:0];
    _toolBar.barTintColor = [UIColor whiteColor];
    _toolBar.backgroundColor = [UIColor whiteColor];
    [inputView.leftItem setTitle:leftTitle];
    [inputView.rightItem setTitle:rightTitle];
    
    return inputView;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    [self.leftItem setTitle:@"leftItem"];
    [self.rightItem setTitle:@"rightItem"];
}

- (void)show:(BOOL)animated;
{
    if ([self isVisible]) {
        return ;
    }
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = self.frame;
            frame.origin.x = 0;
            frame.origin.y = ScreenHeight-frame.size.height;
            self.frame = frame;
        }];
    } else {
        CGRect frame = self.frame;
        frame.origin.x = 0;
        frame.origin.y = ScreenHeight-frame.size.height;
        self.frame = frame;
    }
}

- (void)hidden:(BOOL)animated;
{
    if (![self isVisible]) {
        return ;
    }
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = self.frame;
            frame.origin.x = 0;
            frame.origin.y = ScreenHeight;
            self.frame = frame;
        }];
    } else {
        CGRect frame = self.frame;
        frame.origin.x = 0;
        frame.origin.y = ScreenHeight;
        self.frame = frame;
    }
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

#pragma mark - Action
- (IBAction)leftItemAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputView:didClickLeftItem:)])
    {
        [self.delegate inputView:self didClickLeftItem:sender];
    }
}
- (IBAction)RightItemAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputView:didClickRightItem:)])
    {
        [self.delegate inputView:self didClickRightItem:sender];
    }
}

@end
