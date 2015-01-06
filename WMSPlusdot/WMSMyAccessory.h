//
//  WMSMyAccessory.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-16.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AccessoryGeneration) {
    AccessoryGenerationONE = 1,
    AccessoryGenerationTWO = 2,
    AccessoryGenerationUnknown = 0xFFFF,
};

@interface WMSMyAccessory : NSObject

+ (void)bindAccessory:(NSString *)identifier;//被弃用

+ (void)bindAccessoryWith:(NSString *)identifier generation:(AccessoryGeneration)generation;

+ (void)unBindAccessory;

+ (BOOL)isBindAccessory;

+ (AccessoryGeneration)generationForBindAccessory;

+ (NSString *)identifierForbindAccessory;

@end
