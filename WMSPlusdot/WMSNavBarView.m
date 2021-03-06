//
//  WMSNavBarView.m
//  WMSPlusdot
//
//  Created by John on 14-8-29.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSNavBarView.h"

#define LEFT_BUTTON_RECT CGRectMake(8, 24, 35, 35)
#define RIGHT_BUTTON_RECT CGRectMake((ScreenWidth-8-45),24,45,35)
#define TITLE_LABEL_RECT CGRectMake(75, 26, 170, 35)

@interface WMSNavBarView ()

@end

@implementation WMSNavBarView

#pragma mark - Getter
- (UIButton *)buttonLeft
{
    if (!_buttonLeft) {
        _buttonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonLeft.frame = LEFT_BUTTON_RECT;
        //[_buttonLeft addTarget:self action:@selector(clickedButtonLeft:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonLeft;
}
- (UIButton *)buttonRight
{
    if (!_buttonRight) {
        _buttonRight = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonRight.frame = RIGHT_BUTTON_RECT;
    }
    return _buttonRight;
}
- (UILabel *)labelTitle
{
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] initWithFrame:TITLE_LABEL_RECT];
        _labelTitle.text = @"";
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        _labelTitle.textColor = [UIColor whiteColor];
        _labelTitle.font = [UIFont fontWithName:@"DIN Condensed" size:20.f];
    }
    return _labelTitle;
}

#pragma mark - Life Cycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    //self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.buttonLeft];
    [self addSubview:self.buttonRight];
    [self addSubview:self.labelTitle];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Action

@end
