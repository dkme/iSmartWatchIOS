//
//  WMSMyAccessory.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-16.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMSMyAccessory : NSObject

+ (void)bindAccessory:(NSString *)identifier;

+ (void)unBindAccessory;

+ (BOOL)isBindAccessory;

+ (NSString *)identifierForbindAccessory;

@end
