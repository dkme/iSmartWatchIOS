//
//  FormatClass.m
//  WMSPlusdot
//
//  Created by Sir on 15-3-2.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "FormatClass.h"

@implementation FormatClass

+ (NSString *)formatDuration:(NSUInteger)duration
{
    NSString *hour = [NSString stringWithFormat:@"%u",duration/60];
    NSString *mu = [NSString stringWithFormat:@"%u",duration%60];
    NSString *hourLbl = NSLocalizedString(@"Hour",nil);
    NSString *muLbl = NSLocalizedString(@"Minutes",nil);
    if (duration/60 <= 0) {
        hour = @"";
        hourLbl = @"";
    }
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@",hour,hourLbl,mu,muLbl];
    return str;
}

@end
