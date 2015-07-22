//
//  Condition.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/1.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "Condition.h"

@implementation Condition

- (NSString *)condition
{
    return [[self class] matchConditionDescription:self.conditionDescription];
}

+ (NSDictionary *)imageMap {
    static NSDictionary *_imageMap = nil;
    if (! _imageMap) {
        //根据weather中的main字段来获取对应的天气状态
        _imageMap = @{
                      @"clouds":@"weather-clouds",//多云 mist, 其他的不匹配的多为多云
                      @"clear":@"weather-clear",//晴
                      
                      @"light rain":@"weather-light rain",//小雨
                      @"moderate rain":@"weather-moderate rain",//中雨，其他含有rain的，都为中雨
                      @"heavy rain":@"weather-heavy rain",//大雨
                      
                      @"light snow":@"weather-light snow",//小雪
                      @"moderate snow":@"weather-moderate snow",//中雪 其他含有snow的，都为中雪
                      @"heavy snow":@"weather-heavy snow",//大雪
                      };
    }
    return _imageMap;
}
+ (NSDictionary *)weatherMap {
    static NSDictionary *_weatherMap = nil;
    if (!_weatherMap) {
        _weatherMap = @{
                        @"clouds":NSLocalizedString(@"多云", nil),
                        @"clear":NSLocalizedString(@"晴", nil),
                        
                        @"light rain":NSLocalizedString(@"小雨", nil),
                        @"moderate rain":NSLocalizedString(@"中雨", nil),
                        @"heavy rain":NSLocalizedString(@"大雨", nil),
                        
                        @"light snow":NSLocalizedString(@"小雪", nil),
                        @"moderate snow":NSLocalizedString(@"中雪", nil),
                        @"heavy snow":NSLocalizedString(@"大雪", nil),
                        };
    }
    return _weatherMap;
}

+ (NSString *)matchConditionDescription:(NSString *)desc
{
    static NSArray *matchKey, *matchValue;
    matchKey = matchValue = nil;
    if (!matchKey) {///使用正则表达式语法
        matchKey = @[
                     @"clear",
                     @"clouds",
                     @"light.*rain",
                     @"moderate.*rain",
                     @"heavy.*rain",
                     @"light.*snow",
                     @"moderate.*snow",
                     @"heavy.*snow",
                     
                     @"snow",
                     @"rain",
                     ];
    }
    if (!matchValue) {
        matchValue = @[
                     @"clear",
                     @"clouds",
                     @"light rain",
                     @"moderate rain",
                     @"heavy rain",
                     @"light snow",
                     @"moderate snow",
                     @"heavy snow",
                     
                     @"light snow",
                     @"light rain",
                     ];
    }

    NSRange matchResult;
    for (int i=0; i<matchKey.count; i++) {
        matchResult = [desc rangeOfString:matchKey[i] options:NSRegularExpressionSearch];///使用正则表达式匹配字符串
        if (matchResult.location != NSNotFound) {
            return matchValue[i];
        }
    }
    
    return @"clouds";
}

- (NSString *)imageName {
    NSString *key = [[self class] matchConditionDescription:self.conditionDescription];
    return [[self class] imageMap][key];
}
- (NSString *)weatherName {
    NSString *key = [[self class] matchConditionDescription:self.conditionDescription];
    return [[self class] weatherMap][key];
}


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",//返回的温度单位是开氏度(K)
             @"conditionDescription": @"weather",
             @"condition": @"weather",
             @"icon": @"weather",
             };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{date:%@, humidity:%f, temperature:%f, locationName:%@, conditionDescription:%@, condition:%@, icon:%@}",
            self.date.description, self.humidity.floatValue, self.temperature.floatValue, self.locationName, self.conditionDescription,
            self.condition, self.icon];
}

#pragma mark - JSONTTransformer

#define KELVIN_TO_DEGREES                   272.15

+ (NSValueTransformer *)conditionDescriptionJSONTransformer {
    return [self weatherJSONTransformerOfKey:@"description"];
}

+ (NSValueTransformer *)conditionJSONTransformer {
    return [self weatherJSONTransformerOfKey:@"main"];
}

+ (NSValueTransformer *)iconJSONTransformer {
    return [self weatherJSONTransformerOfKey:@"icon"];
}

+ (NSValueTransformer *)temperatureJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return @( ((NSNumber *)value).floatValue - KELVIN_TO_DEGREES );
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return @( ((NSNumber *)value).floatValue + KELVIN_TO_DEGREES );
    }];
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:((NSNumber *)value).floatValue];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [NSNumber numberWithDouble:[value timeIntervalSince1970]];
    }];
}


//这个是不会自动调用的
+ (NSValueTransformer *)weatherJSONTransformerOfKey:(NSString *)key
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        NSDictionary *dicObj = [value firstObject];
        return dicObj[key];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return @[@{key:value}];
    }];
}

@end
