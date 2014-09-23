//
//  WMSPerson.h
//  WMSPlusdot
//
//  Created by John on 14-9-3.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSPerson : NSObject

@property (nonatomic, assign) NSUInteger weight;

@property (nonatomic, assign) NSUInteger height;

@property (nonatomic, assign) NSUInteger gender;

@property (nonatomic, strong) NSString *birthday;

@property (nonatomic, strong) NSString *format;

@property (nonatomic, assign) NSUInteger stride;

@property (nonatomic, assign) NSUInteger metric;

@end
