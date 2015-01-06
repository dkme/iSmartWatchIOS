//
//  WMSWeekPicker.h
//  WMSPlusdot
//
//  Created by Sir on 15-1-5.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMSWeekPickerDelegate;

@interface WMSWeekPicker : UIView

@property (nonatomic, assign) NSUInteger componentNumbers;
@property (nonatomic, assign) CGSize componentSize;
@property (nonatomic, assign) CGFloat componentIntervalWidth;
@property (nonatomic, assign) CGFloat firstComponentLeftInterval;
@property (nonatomic, strong) NSArray *componentTitles;
@property (nonatomic, strong) NSArray *componentStates;//取值YES/NO
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat borderSelectedWidth;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *borderSelectedColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *textSelectedColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, weak) id<WMSWeekPickerDelegate> delegate;

- (void)reloadView;

@end

@protocol WMSWeekPickerDelegate <NSObject>

@optional
- (void)weekPicker:(WMSWeekPicker *)weekPicker didClickComponent:(NSUInteger)index;

@end
