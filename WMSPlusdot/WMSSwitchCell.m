//
//  WMSSwitchCell.m
//  WMSPlusdot
//
//  Created by John on 14-8-21.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSwitchCell.h"

@implementation WMSSwitchCell

- (void)awakeFromNib
{
    // Initialization code
    DEBUGLog(@"awakeFromNib");
    [self.mySwitch setOn:YES animated:NO];
    [self.mySwitch addTarget:self action:@selector(switchBtnValueChangedHandle:) forControlEvents:UIControlEventValueChanged];
    [self.mySwitch setOnTintColor:UIColorFromRGBAlpha(0x00D5E1, 1)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Events
- (void)switchBtnValueChangedHandle:(UISwitch *)sw
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchCell:didClickSwitch:)]) {
        [self.delegate switchCell:self didClickSwitch:sw];
    }
}

@end
