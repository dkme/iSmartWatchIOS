//
//  WMSClockCell.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-12.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSClockCell.h"

@implementation WMSClockCell

- (void)awakeFromNib {
    // Initialization code
    [self.mySwitch setOn:YES animated:NO];
    [self.mySwitch addTarget:self action:@selector(switchBtnValueChangedHandle:) forControlEvents:UIControlEventValueChanged];
    [self.mySwitch setOnTintColor:UICOLOR_DEFAULT];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Events
- (void)switchBtnValueChangedHandle:(UISwitch *)sw
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clockCell:didClickSwitch:)]) {
        [self.delegate clockCell:self didClickSwitch:sw];
    }
}

@end
