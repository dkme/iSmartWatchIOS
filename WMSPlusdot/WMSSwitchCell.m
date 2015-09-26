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
    //DEBUGLog(@"awakeFromNib");
    [self.mySwitch setOn:YES animated:NO];
    [self.mySwitch addTarget:self action:@selector(switchBtnValueChangedHandle:) forControlEvents:UIControlEventValueChanged];
    [self.mySwitch setOnTintColor:UICOLOR_DEFAULT];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configureCellWithText:(NSString *)text switchOn:(BOOL)on
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
    
    self.myLabelText.text = text;
    self.myLabelText.textColor = [UIColor whiteColor];
    self.myLabelText.font = Font_DINCondensed(18);
    
    self.mySwitch.on = on;
}

#pragma mark - Events
- (void)switchBtnValueChangedHandle:(UISwitch *)sw
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchCell:didClickSwitch:)]) {
        [self.delegate switchCell:self didClickSwitch:sw];
    }
}

@end
