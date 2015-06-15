//
//  WMSStackManager.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/6/10.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMSMyTimers;

@interface WMSStackManager : NSObject

@property (nonatomic, strong, readonly) WMSMyTimers *myTimers;


///向stack中压入元素
- (BOOL)pushObj:(id)obj toStackOfTimeID:(int)timeID;

///从stack推出元素
- (id)popObjFromStackOfTimeID:(int)timeID;

@end
