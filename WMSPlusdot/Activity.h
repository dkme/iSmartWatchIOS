//
//  Activity.h
//  WMSPlusdot
//
//  Created by Sir on 15-2-11.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Activity : NSObject <NSCopying>

@property (nonatomic) int actID;
@property (nonatomic, strong) NSString *actName;
@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *actMemo;
@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic) int consumeBeans;

@end
