//
//  WMSBindingView.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-18.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSBindingView.h"

@implementation WMSBindingView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:(aDecoder)]) {
        
    }
    return self;
}

//- (id)init
//{
//    if (self = [super init]) {
//        NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"WMSBindingView" owner:nil options:nil];
//        return [nibView objectAtIndex:0];
//    }
//    return self;
//}

+ (id)instanceBindingView
{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"WMSBindingView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

@end
