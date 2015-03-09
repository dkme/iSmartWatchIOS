//
//  WMSAlertView.m
//  WMSPlusdot
//
//  Created by Sir on 15-2-3.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSAlertView.h"

@implementation WMSAlertView

+ (id)alertViewWithText:(NSString *)text
             detailText:(NSString *)detailText
        leftButtonTitle:(NSString *)leftTitle
       rightButtonTitle:(NSString *)rightTitle
{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"WMSAlertView" owner:nil options:nil];
    WMSAlertView *view = (WMSAlertView *)[nibView objectAtIndex:0];
    view.backgroundColor = [UIColor whiteColor];
    view.textLabel.backgroundColor = [UIColor whiteColor];
    view.detailTextLabel.backgroundColor = [UIColor whiteColor];
    view.detailTextLabel.numberOfLines = -1;
    view.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    view.textLabel.text = text;
    view.detailTextLabel.text = detailText;
    [view.leftButton setTitle:leftTitle forState:UIControlStateNormal];
    [view.rightButton setTitle:rightTitle forState:UIControlStateNormal];
    [view.leftButton setBackgroundColor:[UIColor whiteColor]];
    [view.rightButton setBackgroundColor:[UIColor whiteColor]];
    [view.layer setCornerRadius:10.f];
    [view.layer setBorderWidth:1];
    [view.layer setBorderColor:[UIColor clearColor].CGColor];
    
    return view;
}

+ (id)defaultAlertView
{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"WMSAlertView" owner:nil options:nil];
    WMSAlertView *view = (WMSAlertView *)[nibView objectAtIndex:0];
    view.backgroundColor = [UIColor whiteColor];
    view.textLabel.backgroundColor = [UIColor whiteColor];
    view.detailTextLabel.backgroundColor = [UIColor whiteColor];
    view.textLabel.text = @"";
    view.detailTextLabel.text = @"";
    view.textLabel.textAlignment = NSTextAlignmentCenter;
    view.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    view.detailTextLabel.numberOfLines = -1;
    view.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    return view;
}
//调整label，button的位置
- (CGRect)updateSubviews
{
    CGRect detailTextLabelFrame = CGRectZero;
    CGRect leftButtonFrame = CGRectZero;
    CGRect rightButtonFrame = CGRectZero;
    
    CGRect frame = self.textLabel.frame;
    CGPoint or = frame.origin;
    or.y = frame.origin.y+frame.size.height+8.f;
    detailTextLabelFrame = (CGRect){or,self.detailTextLabel.frame.size};
    
    frame = detailTextLabelFrame;
    or = frame.origin;
    or.y = frame.origin.y+frame.size.height+8.f;
    leftButtonFrame = (CGRect){or,self.leftButton.frame.size};
    
    frame = leftButtonFrame;
    or = frame.origin;
    or.y = frame.origin.y+frame.size.height+2.f;
    rightButtonFrame = (CGRect){or,self.rightButton.frame.size};
    
    self.detailTextLabel.frame = detailTextLabelFrame;
    self.leftButton.frame = leftButtonFrame;
    self.rightButton.frame = rightButtonFrame;
    
    CGSize size = self.frame.size;
    size.height = rightButtonFrame.origin.y+rightButtonFrame.size.height+6.f;
    return (CGRect){self.frame.origin,size};
}

- (IBAction)leftButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:0];
    }
}

- (IBAction)rightButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:1];
    }
}





@end
