//
//  WMSMySleepView.h
//  WMSPlusdot
//
//  Created by John on 14-8-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSMySleepView : UIView

- (void)setSleepTime:(int)minute;
- (BOOL)setDeepSleepTime:(int)deepSleepMinute andLightSleepTime:(int)lightSleepMinute andWakeupTime:(int)wakeupMinute;

@end
