//
//  UITableViewCell+Activity.m
//  WMSPlusdot
//
//  Created by Sir on 15-2-12.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "UITableViewCell+Activity.h"
#import "NSDate+Formatter.h"
#import "Activity.h"
#import "GiftBag.h"

@implementation UITableViewCell (Activity)

- (void)configureCellWithActivity:(Activity *)activity
{
    self.textLabel.text = activity.memo;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *strURL = [NSString stringWithFormat:@"%@%@",@"",activity.logo];
    NSURL *url = [NSURL URLWithString:strURL];
    UIImage *placeholderImage = [UIImage imageNamed:@"plusdot_gift_bean_b贴在礼包图标上.png"];
    [self.imageView setImageWithURL:url placeholderImage:placeholderImage];
}

- (void)configureCellWithGiftBag:(GiftBag *)bag
{
    self.textLabel.text = bag.exchangeCode;
    self.detailTextLabel.text = [NSDate stringFromDate:bag.getDate format:@"yyyy.MM.dd"];
    NSString *strURL = [NSString stringWithFormat:@"%@%@",@"",bag.logo];
    NSURL *url = [NSURL URLWithString:strURL];
    UIImage *placeholderImage = [UIImage imageNamed:@"plusdot_gift_bean_b贴在礼包图标上.png"];
    [self.imageView setImageWithURL:url placeholderImage:placeholderImage];
}

@end
