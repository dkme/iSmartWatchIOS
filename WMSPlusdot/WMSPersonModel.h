//
//  WMSPersonModel.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-11.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSPersonModel : NSObject<NSCoding>

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSDate *birthday;

/**
 *  1表示男，0表示女
 */
@property (nonatomic, assign) NSUInteger gender;

/**
 *  单位cm
 */
@property (nonatomic, assign) NSUInteger height;

/**
 *  单位kg
 */
@property (nonatomic, assign) NSUInteger currentWeight;

@property (nonatomic, assign) NSUInteger targetWeight;

@property (nonatomic, assign) NSUInteger stride;//单位cm

- (id)initWithName:(NSString *)name
             image:(UIImage *)image
          birthday:(NSDate *)birthday
            gender:(NSUInteger)gender
            height:(NSUInteger)height
     currentWeight:(NSUInteger)currentWeight
      targetWeight:(NSUInteger)targetWeight
            stride:(NSUInteger)stride;

@end
