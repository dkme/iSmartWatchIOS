//
//  UITableViewCell+Configure.m
//  WMSPlusdot
//
//  Created by Sir on 15-3-2.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "UITableViewCell+Configure.h"
#import "Activity.h"
#import "GiftBag.h"
#import "ExchangeBeanRule.h"
#import "FormatClass.h"
#import "NSDate+Formatter.h"
#import "WMSURLMacro.h"

@implementation UITableViewCell (Configure)

- (void)configureCellWithActivity:(Activity *)activity
{
    self.textLabel.text = activity.actName;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSURL *url = [NSURL URLWithString:activity.logo];
    UIImage *placeholderImage = [UIImage imageNamed:@"plusdot_gift_bean_b贴在礼包图标上.png"];
    [self.imageView setImageWithURL:url placeholderImage:placeholderImage];
}

- (void)configureCellWithGiftBag:(GiftBag *)bag
{
    self.textLabel.text = bag.gameName;
    self.detailTextLabel.text = [bag.getDate substringToIndex:10];
    NSURL *url = [NSURL URLWithString:bag.logo];
    UIImage *placeholderImage = [UIImage imageNamed:@"plusdot_gift_bean_b贴在礼包图标上.png"];
    [self.imageView setImageWithURL:url placeholderImage:placeholderImage];
}

- (void)configureCellWithExchangeBeanRule:(ExchangeBeanRule *)rule
                                indexPath:(NSIndexPath *)indexPath
{
    self.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor whiteColor];
    self.detailTextLabel.textColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    int row = (int)indexPath.row;
    NSString *text = @"";
    switch (rule.ruleType) {
        case ExchangeBeanRuleTypeRuning:
            text = [NSString stringWithFormat:@"%d.每天跑%d步",row+1,rule.eventNumber];
            break;
        case ExchangeBeanRuleTypeSleep:
        {
            NSString *durationStr = [FormatClass formatDuration:rule.eventNumber];
            text = [NSString stringWithFormat:@"%d.每天睡眠%@",row+1,durationStr];
            break;
        }
        default:
            break;
    }
    self.textLabel.text = text;
    
    NSString *beanStr = [NSString stringWithFormat:@"+%d",rule.beanNumber];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:beanStr attributes:nil];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    UIImage *image = [UIImage imageNamed:@"plusdot_gift_bean_small.png"];
    textAttachment.image = image;
    textAttachment.bounds = CGRectMake(0, -2.0, 15.0, 15.0);
    NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [str appendAttributedString:textAttachmentString];
    self.detailTextLabel.attributedText = str;
}

@end
