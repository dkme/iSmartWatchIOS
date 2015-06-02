//
//  Condition.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/1.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

@interface Condition : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;//湿度
@property (nonatomic, strong) NSNumber *temperature;//温度
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSString *conditionDescription;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSString *icon;

- (NSString *)imageName;

- (NSString *)weatherName;

@end
