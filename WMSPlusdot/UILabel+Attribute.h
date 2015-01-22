//
//  UILabel+Attribute.h
//  WMSPlusdot
//
//  Created by Sir on 15-1-22.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Attribute)

/*
 text           设置的文本
 mark           片段分隔符，默认为'/'
 attrsArray     存放描述attributes的字典对象
 */
- (void)setSegmentsText:(NSString *)text separateMark:(NSString *)mark attributes:(NSArray *)attrsArray;

/*
 text           设置的文本
 numbers        分为几段(从左向右)
 attrsArray     存放描述attributes的字典对象
 */
//- (void)setSegmentsText:(NSString *)text numbers:(NSUInteger)numbers attributes:(NSArray *)attrsArray;

@end
