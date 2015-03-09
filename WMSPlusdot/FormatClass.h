//
//  FormatClass.h
//  WMSPlusdot
//
//  Created by Sir on 15-3-2.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormatClass : NSObject

/*
 *  格式化时长，若小于1个小时，则只显示分钟，否则小时和分钟都要显示
 */
+ (NSString *)formatDuration:(NSUInteger)duration;

@end
