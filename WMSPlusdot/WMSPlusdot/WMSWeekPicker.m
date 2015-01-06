//
//  WMSWeekPicker.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSWeekPicker.h"

#define BUTTON_TAG_START            1000

@implementation WMSWeekPicker

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit
{
    NSUInteger defaultNumbers               = 7;
    CGSize defaultSize                      = CGSizeMake(40.f, 40.f);
    CGFloat defaultWidth                    = 4.f;
    
    self.componentNumbers                   = defaultNumbers;
    self.componentSize                      = defaultSize;
    self.componentIntervalWidth             = defaultWidth;
    self.textFont                           = Font_System(12.0);
    self.borderWidth                        = 0.5f;
    self.borderSelectedWidth                = 1.5f;
    self.borderColor                        = [UIColor grayColor];
    self.borderSelectedColor                = UICOLOR_DEFAULT;
    self.textColor                          = [UIColor grayColor];
    self.textSelectedColor                  = UICOLOR_DEFAULT;
    self.firstComponentLeftInterval         = (self.bounds.size.width - (defaultNumbers*(defaultSize.width+defaultWidth)-defaultWidth) )/2.0;
    self.componentStates                    = @[@(YES),@(YES),@(YES),@(YES),@(YES),
                                                @(YES),@(YES)];
    self.componentTitles = @[NSLocalizedString(@"周一",nil),
                             NSLocalizedString(@"周二",nil),
                             NSLocalizedString(@"周三",nil),
                             NSLocalizedString(@"周四",nil),
                             NSLocalizedString(@"周五",nil),
                             NSLocalizedString(@"周六",nil),
                             NSLocalizedString(@"周日",nil)];
}

- (void)reloadView
{
    [self setupButtons];
}

- (void)setupButtons
{
    CGFloat leftInterval = self.firstComponentLeftInterval;
    for (int i=0; i<_componentNumbers; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGSize size = _componentSize;
        CGFloat y = (self.bounds.size.height-size.height) / 2.0;
        CGPoint or = CGPointMake(leftInterval+size.width*i+_componentIntervalWidth*i, y);
        btn.frame = (CGRect){or,size};
        btn.tag = BUTTON_TAG_START + i;
        if (i < [self.componentStates count]) {
            BOOL selected = [self.componentStates[i] boolValue];
            if (selected) {
                btn.layer.borderWidth = self.borderSelectedWidth;
                btn.layer.borderColor = [self.borderSelectedColor CGColor];
                [btn setTitleColor:self.textSelectedColor forState:UIControlStateNormal];
            } else {
                btn.layer.borderWidth = self.borderWidth;
                btn.layer.borderColor = [self.borderColor CGColor];
                [btn setTitleColor:self.textColor forState:UIControlStateNormal];
            }
        }
        if (i < [self.componentTitles count]) {
            [btn.titleLabel setFont:_textFont];
            [btn setTitle:self.componentTitles[i] forState:UIControlStateNormal];
        }
        [btn addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}

#pragma mark - Action
- (void)clickedButton:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGColorRef colorRef = btn.layer.borderColor;
    UIColor *curColor = [UIColor colorWithCGColor:colorRef];
    if ([curColor isEqual:self.borderColor]) {
        btn.layer.borderWidth = self.borderSelectedWidth;
        btn.layer.borderColor = [self.borderSelectedColor CGColor];
    } else {
        btn.layer.borderWidth = self.borderWidth;
        btn.layer.borderColor = [self.borderColor CGColor];
    }
    UIColor *textColor = [btn titleColorForState:UIControlStateNormal];
    if ([textColor isEqual:self.textColor]) {
        [btn setTitleColor:self.textSelectedColor forState:UIControlStateNormal];
    } else {
        [btn setTitleColor:self.textColor forState:UIControlStateNormal];
    }
    
    NSMutableArray *mutiArray = [NSMutableArray arrayWithArray:self.componentStates];
    NSUInteger index = (NSUInteger)btn.tag - BUTTON_TAG_START;
    if (index < [mutiArray count]) {
        mutiArray[index] = @(!([mutiArray[index] boolValue]));
        self.componentStates = mutiArray;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(weekPicker:didClickComponent:)]) {
        [self.delegate weekPicker:self didClickComponent:index];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
