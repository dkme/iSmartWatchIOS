//
//  WMSBoundCell.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-4.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSBoundCell.h"

@implementation WMSBoundCell

- (void)awakeFromNib {
    // Initialization code
    self.bottomLabel.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
