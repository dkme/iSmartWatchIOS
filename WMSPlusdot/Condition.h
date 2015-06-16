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
@property (nonatomic, strong) NSString *locationName;//城市名字，以定位的为准，不用请求返回的结果（因为结果是英文的）
@property (nonatomic, strong) NSString *conditionDescription;//天气描述
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSString *icon;

- (NSString *)imageName;

- (NSString *)weatherName;

@end
