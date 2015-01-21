//
//  UIBarButtonItem+Extension.h
//  WMSPlusdot
//
//  Created by Sir on 15-1-13.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIBarButtonItem (Extension)

+ (UIBarButtonItem *)itemWithImageName:(NSString *)imageName highImageName:(NSString *)highImageName target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)itemWithTitle:(NSString *)title size:(CGSize)size target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)itemWithTitle:(NSString *)title font:(UIFont *)font size:(CGSize)size target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)itemWithTitle:(NSString *)title textColor:(UIColor *)textColor font:(UIFont *)font size:(CGSize)size target:(id)target action:(SEL)action;

+ (UIBarButtonItem *)defaultItemWithTarget:(id)target action:(SEL)action;

@end
