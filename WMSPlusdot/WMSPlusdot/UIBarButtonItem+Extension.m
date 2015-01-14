//
//  UIBarButtonItem+Extension.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-13.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "UIBarButtonItem+Extension.h"

@implementation UIBarButtonItem (Extension)

+ (UIBarButtonItem *)itemWithImageName:(NSString *)imageName highImageName:(NSString *)highImageName target:(id)target action:(SEL)action
{
    //自定义UIView
    UIButton *btn=[[UIButton alloc]init];
    
    //设置按钮的背景图片（默认/高亮）
    [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:highImageName] forState:UIControlStateHighlighted];

    //设置按钮的尺寸和图片一样大，使用了UIImage的分类
    CGRect frame = btn.frame;
    CGSize size = btn.currentBackgroundImage.size;
    frame.size = CGSizeMake(size.width/2, size.height/2);
    btn.frame = frame;
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

+ (UIBarButtonItem *)itemWithTitle:(NSString *)title textColor:(UIColor *)textColor font:(UIFont *)font size:(CGSize)size target:(id)target action:(SEL)action
{
    UIButton *btn=[[UIButton alloc] init];
    CGRect frame = btn.frame;
    frame.size = size;
    btn.frame = frame;
    btn.titleLabel.font = font;
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
+ (UIBarButtonItem *)itemWithTitle:(NSString *)title size:(CGSize)size target:(id)target action:(SEL)action
{
    UIFont *font = [UIFont systemFontOfSize:15.f];
    return [self itemWithTitle:title font:font size:size target:target action:action];
}
+ (UIBarButtonItem *)itemWithTitle:(NSString *)title font:(UIFont *)font size:(CGSize)size target:(id)target action:(SEL)action
{
    UIColor *textColor = [UIColor whiteColor];
    return [UIBarButtonItem itemWithTitle:title textColor:textColor font:font size:size target:target action:action];
}

@end
