//
//  WMSPersonModel.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-11.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSPersonModel.h"

@implementation WMSPersonModel

- (id)initWithName:(NSString *)name
             image:(UIImage *)image
          birthday:(NSDate *)birthday
            gender:(NSUInteger)gender
            height:(NSUInteger)height
     currentWeight:(NSUInteger)currentWeight
      targetWeight:(NSUInteger)targetWeight
            stride:(NSUInteger)stride
{
    if (self = [super init]) {
        _name = name;
        _image = image;
        _birthday = birthday;
        _gender = gender;
        _height = height;
        _currentWeight = currentWeight;
        _targetWeight = targetWeight;
        _stride = stride;
    }
    return self;
}

@end
