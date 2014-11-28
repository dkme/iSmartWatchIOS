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

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"WMSPersonModel.name"];
    [aCoder encodeObject:_image forKey:@"WMSPersonModel.image"];
    [aCoder encodeObject:_birthday forKey:@"WMSPersonModel.birthday"];
    [aCoder encodeObject:@(_gender) forKey:@"WMSPersonModel.gender"];
    [aCoder encodeObject:@(_height) forKey:@"WMSPersonModel.height"];
    [aCoder encodeObject:@(_currentWeight) forKey:@"WMSPersonModel.currentWeight"];
    [aCoder encodeObject:@(_targetWeight) forKey:@"WMSPersonModel.targetWeight"];
    [aCoder encodeObject:@(_stride) forKey:@"WMSPersonModel.stride"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _name = [aDecoder decodeObjectForKey:@"WMSPersonModel.name"];
    _image = [aDecoder decodeObjectForKey:@"WMSPersonModel.image"];
    _birthday = [aDecoder decodeObjectForKey:@"WMSPersonModel.birthday"];
    _gender = [[aDecoder decodeObjectForKey:@"WMSPersonModel.gender"] unsignedIntegerValue];
    _height = [[aDecoder decodeObjectForKey:@"WMSPersonModel.height"] unsignedIntegerValue];
    _currentWeight = [[aDecoder decodeObjectForKey:@"WMSPersonModel.currentWeight"] unsignedIntegerValue];
    _targetWeight = [[aDecoder decodeObjectForKey:@"WMSPersonModel.targetWeight"] unsignedIntegerValue];
    _stride = [[aDecoder decodeObjectForKey:@"WMSPersonModel.stride"] unsignedIntegerValue];
    
    return self;
}

@end
