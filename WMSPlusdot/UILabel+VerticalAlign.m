//
//  UILabel+VerticalAlign.m
//  iOS application Demo
//
//  Created by guogee mac on 15/9/24.
//  Copyright © 2015年 guogee. All rights reserved.
//

#import "UILabel+VerticalAlign.h"

#define MAX_SIZE_HEIGHT     9999.f

@implementation UILabel (VerticalAlign)

- (void)alignTop
{
    NSInteger newLinesToPad = [self newLines];
    for(int i=0; i<newLinesToPad; i++) {
        self.text = [self.text stringByAppendingString:@"\n "];
    }
}

- (void)alignBottom
{
    NSInteger newLinesToPad = [self newLines];
    for(int i=0; i<newLinesToPad; i++) {
        self.text = [NSString stringWithFormat:@" \n%@",self.text];
    }
}

- (NSInteger)newLines
{
    CGFloat oneLineHeight = self.font.lineHeight;///一行的高度
    CGFloat finalHeight = MAX_SIZE_HEIGHT;
    CGFloat finalWidth = self.bounds.size.width;//expected width of label
    CGSize theStringSize = CGSizeZero;
    if ([self.text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        theStringSize = [self.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:nil].size;
    } else {
        theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    }
    NSInteger newLinesToPad = (self.bounds.size.height - theStringSize.height) / oneLineHeight;
    
    return newLinesToPad;
}

@end
