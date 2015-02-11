//
//  UILabel+Attribute.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-22.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "UILabel+Attribute.h"

@implementation UILabel (Attribute)

- (void)setSegmentsText:(NSString *)text separateMark:(NSString *)mark attributes:(NSArray *)attrsArray
{
    if (!mark) {
        mark = @"/";
    }
    NSArray *components = [text componentsSeparatedByString:mark];
    NSString *labelText = @"";
    for (NSString *str in components) {
        labelText = [labelText stringByAppendingString:str];
    }
    NSMutableArray *mutiAttrs = [NSMutableArray arrayWithArray:attrsArray];
    if (mutiAttrs.count < components.count) {
        NSDictionary *defaultAttrs = @{NSFontAttributeName:self.font,
                                       NSForegroundColorAttributeName:self.textColor};
        for (int j=0; j<components.count-attrsArray.count; j++) {
            [mutiAttrs addObject:defaultAttrs];
        }
    }
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSUInteger loc, len;
    loc = len = 0;
    for (int i=0; i<components.count; i++) {
        NSString *s = components[i];
        len = s.length;
        NSRange range = NSMakeRange(loc, len);
        loc += len;
        NSDictionary *attrs = mutiAttrs[i];
        [attriString addAttributes:attrs range:range];
    }
    [self setAttributedText:attriString];
}

//- (void)setSegmentsText:(NSString *)text numbers:(NSUInteger)numbers attributes:(NSArray *)attrsArray
//{
//}

@end
