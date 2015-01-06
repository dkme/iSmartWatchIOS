//
//  WMSInputView.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-29.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMSInputViewDelegate;

@interface WMSInputView : UIView

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (weak, nonatomic) id<WMSInputViewDelegate>delegate;
@property (strong, nonatomic, readonly) UIResponder *responder;

- (id)initWithLeftItemTitle:(NSString *)leftTitle
             RightItemTitle:(NSString *)rightTitle;

- (void)show:(BOOL)animated;

- (void)hidden:(BOOL)animated;

- (void)show:(BOOL)animated forView:(UIView *)responseView;

@end

@protocol WMSInputViewDelegate <NSObject>

@optional
- (void)inputView:(WMSInputView *)inputView didClickLeftItem:(UIBarButtonItem *)item;//被弃用

- (void)inputView:(WMSInputView *)inputView didClickRightItem:(UIBarButtonItem *)item;//被弃用

- (void)inputView:(WMSInputView *)inputView forView:(UIView *)responseView didClickLeftItem:(UIBarButtonItem *)item;
- (void)inputView:(WMSInputView *)inputView forView:(UIView *)responseView didClickRightItem:(UIBarButtonItem *)item;

@end
