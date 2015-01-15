//
//  WMSBindingView.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-18.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WMSBindingViewDelegate;

@interface WMSBindingView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) id<WMSBindingViewDelegate> delegate;

+ (id)instanceBindingView;

- (void)adaptiveIphone4;

- (void)show:(BOOL)animated forView:(UIView *)view;
- (void)hidden:(BOOL)animated;

@end

@protocol WMSBindingViewDelegate <NSObject>

@optional
- (void)bindingView:(WMSBindingView *)bindingView didClickBottomButton:(UIButton *)button;

@end