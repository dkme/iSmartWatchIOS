//
//  WMSLoginViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSLoginViewController.h"
#import "WMSSignupViewController.h"

@interface WMSLoginViewController ()

@end

@implementation WMSLoginViewController

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
    
    [self.buttonLogin setBackgroundImage:[UIImage imageNamed:@"login_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonLogin setBackgroundImage:[UIImage imageNamed:@"login_btn_b.png"] forState:UIControlStateSelected];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)fogetPasswordAction:(id)sender {
}

- (IBAction)loginAction:(id)sender {

}

- (IBAction)signupAction:(id)sender {
    WMSSignupViewController *signupVC = [[WMSSignupViewController alloc] initWithNibName:@"WMSSignupViewController" bundle:nil];
    [self.navigationController pushViewController:signupVC animated:YES];
    DEBUGLog(@"sign up");
}

- (IBAction)resignResponse:(id)sender {
    if ([self.textEmail isFirstResponder]) {
       [self.textEmail resignFirstResponder];
    }
    if ([self.textPassword isFirstResponder]) {
        [self.textPassword resignFirstResponder];
    }
}
@end
