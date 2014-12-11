//
//  WMSLoginViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WMSSkipMode) {
    SkipModeDefault = 0x00,
    SkipModeDissmiss = 0x01,
};

@interface WMSLoginViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;

- (IBAction)fogetPasswordAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)signupAction:(id)sender;
- (IBAction)resignResponse:(id)sender;

@property (nonatomic, assign) WMSSkipMode skipMode;

@end
