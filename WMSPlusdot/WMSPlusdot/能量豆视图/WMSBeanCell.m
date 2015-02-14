//
//  WMSBeanCell.m
//  WMSPlusdot
//
//  Created by Sir on 15-2-6.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "WMSBeanCell.h"

@implementation WMSBeanCell

- (void)awakeFromNib {
    // Initialization code
    self.contentLabel.text = @"";
    self.detailContentLabel.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithContent:(NSString *)content beans:(NSUInteger)beans
{
    self.contentLabel.text = content;
    self.detailContentLabel.text = [NSString stringWithFormat:@"+%lu",(unsigned long)beans];
}


@end
