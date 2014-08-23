//
//  WMSSignupViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSignupViewController.h"

@interface WMSSignupViewController ()

@end

@implementation WMSSignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_bg.png"]];
    
    self.textPassword.secureTextEntry = YES;
    self.textConfirmPassword.secureTextEntry = YES;
    
    [self.buttonSignup setBackgroundImage:[UIImage imageNamed:@"login_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonSignup setBackgroundImage:[UIImage imageNamed:@"login_btn_b.png"] forState:UIControlStateSelected];
    
}

- (void)dealloc
{
    DEBUGLog(@"Sign up VC dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signupAction:(id)sender {
}

- (IBAction)loginAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)resignResponse:(id)sender {
    if ([self.textEmail isFirstResponder]) {
        [self.textEmail resignFirstResponder];
    } else if ([self.textUserName isFirstResponder]) {
        [self.textUserName resignFirstResponder];
    } else if ([self.textPassword isFirstResponder]) {
        [self.textPassword resignFirstResponder];
    } else if ([self.textConfirmPassword isFirstResponder]) {
        [self.textConfirmPassword resignFirstResponder];
    } else {
        ;
    }
}
@end
