//
//  WMSSignupViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSSignupViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UITextField *textUserName;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UITextField *textConfirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignup;


- (IBAction)signupAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)resignResponse:(id)sender;

@end
