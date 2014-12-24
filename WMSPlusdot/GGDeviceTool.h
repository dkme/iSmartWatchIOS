//
//  GGDeviceTool.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-18.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGDeviceTool : NSObject

+ (id)sharedInstance;

- (void)startWebcamFlicker;

- (void)stopWebcamFlicker;

@end
