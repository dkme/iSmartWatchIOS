//
//  TurntableVIew.h
//  CoreAnimationDemo
//
//  Created by avcon on 13-1-17.
//  Copyright (c) 2013年 avcon. All rights reserved.
//

//一个可以拖拽转动的view
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol TurntableViewDelegate;

typedef NS_ENUM(NSInteger, RotateDirection) {
    clockwise           = 0,
    anticlockwise       = 1,
};

@interface TurntableView : UIView

@property (nonatomic, weak) id<TurntableViewDelegate> delegate;

@end


@protocol TurntableViewDelegate <NSObject>

@optional
- (void)turntableViewDidRotate:(TurntableView *)turntableView byRotateDirection:(RotateDirection)direction;

@end