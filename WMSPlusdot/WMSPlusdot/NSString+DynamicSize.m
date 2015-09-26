//
//  NSString+DynamicSize.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/7/30.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "NSString+DynamicSize.h"

@implementation NSString (DynamicSize)

- (CGSize)dynamicSizeWithFont:(UIFont *)font
{
    CGSize size = CGSizeZero;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        size = [self sizeWithAttributes:@{NSFontAttributeName:font}];
    } else {
        size = [self sizeWithFont:font];
    }
    CGSize strSize = CGSizeMake(ceilf(size.width), ceilf(size.height));///ceil 最接近的较大整数
    return strSize;
}

@end
