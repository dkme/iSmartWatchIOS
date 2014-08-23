//
//  WMSLoginViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;


- (IBAction)fogetPasswordAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)signupAction:(id)sender;
- (IBAction)resignResponse:(id)sender;

@end
