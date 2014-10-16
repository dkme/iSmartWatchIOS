//
//  WMSSignupViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSignupViewController.h"
#import "WMSHTTPRequest.h"
#import "WMSRegularExpressions.h"
#import "MBProgressHUD.h"

@interface WMSSignupViewController ()<MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewEmail;
@property (weak, nonatomic) IBOutlet UIView *viewUsername;
@property (weak, nonatomic) IBOutlet UIView *viewPassword;
@property (weak, nonatomic) IBOutlet UIView *viewConfirmPassword;
@property (weak, nonatomic) IBOutlet UILabel *labelLogin;


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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Login_bg.png"]];
    
    self.textPassword.secureTextEntry = YES;
    self.textConfirmPassword.secureTextEntry = YES;
    self.textPassword.delegate = self;
    self.textConfirmPassword.delegate = self;
    self.textEmail.delegate = self;
    self.textUserName.delegate = self;
    
    [self.buttonSignup setBackgroundImage:[UIImage imageNamed:@"login_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonSignup setBackgroundImage:[UIImage imageNamed:@"login_btn_b.png"] forState:UIControlStateSelected];
    [self.viewEmail setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_menu_bg_a.png"]]];
    [self.viewUsername setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_menu_bg_a.png"]]];
    [self.viewPassword setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_menu_bg_a.png"]]];
    [self.viewConfirmPassword setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_menu_bg_a.png"]]];
    
    [self localizableView];
    
}

- (void)dealloc
{
    DEBUGLog(@"%@ dealloc",[self class]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)localizableView
{
    for (UIView *view in self.viewEmail.subviews) {
        if ([view class] == [UILabel class]) {
            UILabel *labelEamil = (UILabel *)view;
            labelEamil.text = NSLocalizedString(@"邮箱", nil);
            break;
        }
    }
    for (UIView *view in self.viewUsername.subviews) {
        if ([view class] == [UILabel class]) {
            UILabel *labelUsername = (UILabel *)view;
            labelUsername.text = NSLocalizedString(@"用户名", nil);
            break;
        }
    }
    for (UIView *view in self.viewPassword.subviews) {
        if ([view class] == [UILabel class]) {
            UILabel *labelPassword = (UILabel *)view;
            labelPassword.text = NSLocalizedString(@"密码", nil);
            break;
        }
    }
    for (UIView *view in self.viewConfirmPassword.subviews) {
        if ([view class] == [UILabel class]) {
            UILabel *labelConfirmPassword = (UILabel *)view;
            labelConfirmPassword.text = NSLocalizedString(@"确认密码", nil);
            break;
        }
    }
    [self.buttonSignup setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    [self.labelLogin setText:NSLocalizedString(@"登陆", nil)];
}

- (BOOL)checkout
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    //hud.labelFont = Font_DINCondensed(10.0);
    hud.mode = MBProgressHUDModeText;
    hud.minSize = CGSizeMake(250, 60);
    //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
    //hud.yOffset = ScreenHeight/2.0-60;
    //hud.xOffset = 0;
    [self.view addSubview:hud];
    
    BOOL flag = YES;
    NSString *email = self.textEmail.text;
    NSString *userName = self.textUserName.text;
    NSString *password = self.textPassword.text;
    NSString *confirmPwd = self.textConfirmPassword.text;
    BOOL res_email = [WMSRegularExpressions validateEmail:email];
    BOOL res_userName = [WMSRegularExpressions validateUserName:userName];
    if ([email isEqualToString:@""]) {
        [hud setLabelText:NSLocalizedString(@"请输入邮箱", nil)];
        flag = NO;
    }
    else if (!res_email) {
        [hud setLabelText:NSLocalizedString(@"请输入正确的邮箱", nil)];
        flag = NO;
    }
    else if ([userName isEqualToString:@""]) {
        [hud setLabelText:NSLocalizedString(@"请输入用户名", nil)];
        flag = NO;
    }
    else if (!res_userName) {
        [hud setLabelText:NSLocalizedString(@"请输入正确的用户名", nil)];
        flag = NO;
    }
    else if ([password isEqualToString:@""]) {
        [hud setLabelText:NSLocalizedString(@"请输入密码", nil)];
        flag = NO;
    }
    else if ([confirmPwd isEqualToString:@""] ||
             ![confirmPwd isEqualToString:password])
    {
        [hud setLabelText:NSLocalizedString(@"两次输入的密码不同，请重新输入", nil)];
        flag = NO;
    }
    
    if (!flag) {
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep(1);
        } completionBlock:^{
            [hud removeFromSuperview];
        }];
    }
    return flag;
}


#pragma mark - Action
- (IBAction)signupAction:(id)sender {
    [self.textEmail resignFirstResponder];
    [self.textUserName resignFirstResponder];
    [self.textPassword resignFirstResponder];
    [self.textConfirmPassword resignFirstResponder];
    
    if (![self checkout]) {
        return;
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    //hud.labelFont = Font_DINCondensed(10.0);
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.minSize = CGSizeMake(250, 120);
    hud.delegate = self;
    //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
    //hud.yOffset = ScreenHeight/2.0-60;
    //hud.xOffset = 0;
    [self.view addSubview:hud];
    //[hud setLabelText:NSLocalizedString(@"aaaa", nil)];
    [hud show:YES];
    
    NSString *parameter = [NSString stringWithFormat:@"Email=%@&UserName=%@&UserPwd=%@&MobileNo=%@",self.textEmail.text,self.textUserName.text,self.textPassword.text,@"13760272342"];
    [WMSHTTPRequest registerRequestParameter:parameter completion:^(BOOL result, int errorNO,NSError *error)
    {
        DEBUGLog(@"result=%d,errorNO=%d",result,errorNO);
        if (result) {
            [hud setLabelText:NSLocalizedString(@"注册成功", nil)];
        } else {
            if (errorNO == 10001) {
                [hud setLabelText:NSLocalizedString(@"用户名以存在", nil)];
            } else if (errorNO == 10002) {
                [hud setLabelText:NSLocalizedString(@"邮箱以备注册", nil)];
            } else {
                [hud setLabelText:NSLocalizedString(@"注册失败", nil)];
            }
        }
        [hud hide:YES afterDelay:1];
    }];
}

- (IBAction)loginAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)resignResponse:(id)sender {
    [self.textEmail resignFirstResponder];
    [self.textUserName resignFirstResponder];
    [self.textPassword resignFirstResponder];
    [self.textConfirmPassword resignFirstResponder];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DEBUGLog(@"UITextFieldDelegate");
    
    if (self.textEmail == textField) {
        [self.textUserName becomeFirstResponder];
    } else if(self.textUserName == textField) {
        [self.textPassword becomeFirstResponder];
    } else if (self.textPassword == textField) {
        [self.textConfirmPassword becomeFirstResponder];
    } else if (self.textConfirmPassword == textField) {
        [self.textConfirmPassword resignFirstResponder];
    }
    
    return YES;
}


#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
}

@end
