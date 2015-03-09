//
//  WMSAlertView.h
//  WMSPlusdot
//
//  Created by Sir on 15-2-3.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMSAlertViewDelegate;

@interface WMSAlertView : UIView

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) id<WMSAlertViewDelegate> delegate;
@property (strong, nonatomic) NSString *code;


+ (id)alertViewWithText:(NSString *)text
             detailText:(NSString *)detailText
        leftButtonTitle:(NSString *)leftTitle
       rightButtonTitle:(NSString *)rightTitle;

- (CGRect)updateSubviews;

@end

@protocol WMSAlertViewDelegate <NSObject>

@optional
- (void)alertView:(WMSAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
