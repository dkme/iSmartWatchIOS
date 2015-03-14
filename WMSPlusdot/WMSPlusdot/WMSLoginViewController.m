//
//  WMSLoginViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSLoginViewController.h"
#import "WMSSignupViewController.h"
#import "WMSSettingVC.h"
#import "WMSAppDelegate.h"

#import "MBProgressHUD.h"

#import "WMSHTTPRequest.h"
#import "WMSAppConfig.h"

@interface WMSLoginViewController ()<MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewEmail;
@property (weak, nonatomic) IBOutlet UIView *viewPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonFogetPassword;
@property (weak, nonatomic) IBOutlet UILabel *labelSignup;

@end

@implementation WMSLoginViewController

#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _skipMode = SkipModeDefault;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    [self localizableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"%@ dealloc",[self class]);
}

#pragma mark - Setup
- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Login_bg.png"]];
    self.textPassword.secureTextEntry = YES;
    self.textPassword.delegate = self;
    self.textEmail.delegate = self;
    
    [self.viewEmail setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_menu_bg_a.png"]]];
    [self.viewPassword setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_menu_bg_a.png"]]];
    
    [self.buttonLogin setBackgroundImage:[UIImage imageNamed:@"login_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonLogin setBackgroundImage:[UIImage imageNamed:@"login_btn_b.png"] forState:UIControlStateSelected];
    [self.buttonCancel setBackgroundImage:[UIImage imageNamed:@"zq_sound_no_a.png"] forState:UIControlStateNormal];
    [self.buttonCancel setBackgroundImage:[UIImage imageNamed:@"zq_sound_no_b.png"] forState:UIControlStateSelected];
}

- (void)localizableView
{
    for (UIView *view in self.viewEmail.subviews) {
        if ([view class] == [UILabel class]) {
            UILabel *labelEamil = (UILabel *)view;
            //labelEamil.text = NSLocalizedString(@"邮箱", nil);
            labelEamil.text = NSLocalizedString(@"用户名", nil);
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
    [self.buttonFogetPassword setTitle:NSLocalizedString(@"忘记密码？", nil) forState:UIControlStateNormal];
    [self.buttonFogetPassword.titleLabel setFont:Font_System(15.0)];
    [self.buttonFogetPassword.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.buttonLogin setTitle:NSLocalizedString(@"登陆", nil) forState:UIControlStateNormal];
    [self.buttonLogin.titleLabel setFont:Font_System(15.0)];
    
    [self.labelSignup setText:NSLocalizedString(@"注册", nil)];
}

- (void)adaptiveIphone4
{
    if (iPhone5) {
        return;
    }
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
    
    NSString *userName = self.textEmail.text;
    NSString *pwd = self.textPassword.text;
    BOOL flag = YES;
    if ([userName isEqualToString:@""]) {
        hud.labelText = NSLocalizedString(@"请输入用户名", nil);
        flag = NO;
    }
    else if ([pwd isEqualToString:@""]) {
        hud.labelText = NSLocalizedString(@"请输入密码", nil);
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

- (void)loginSuccessed
{
    BOOL res = [WMSAppConfig savaLoginUserName:self.textEmail.text password:self.textPassword.text];
    DEBUGLog(@"保存登陆信息%@",res?@"成功":@"失败");
    
    if (self.skipMode == SkipModeDissmiss) {
        [self dismissViewControllerAnimated:YES completion:^{
//            UINavigationController *nav = (UINavigationController *)self.presentingViewController;
//            WMSSettingVC *vc = (WMSSettingVC *)nav.viewControllers[0];
//            vc.needUpdateView = YES;
        }];
    } else {
        WMSAppDelegate *appDelegate = [WMSAppDelegate appDelegate];
        appDelegate.window.rootViewController = (UIViewController *)appDelegate.reSideMenu;
        UIView *view = appDelegate.reSideMenu.view;
        view.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            view.alpha = 1.0;
        }];
        appDelegate.loginNavigationCtrl = nil;
        [appDelegate.window makeKeyAndVisible];
    }
}


#pragma mark - Action
- (IBAction)fogetPasswordAction:(id)sender {
}

- (IBAction)loginAction:(id)sender {
    [self.textEmail resignFirstResponder];
    [self.textPassword resignFirstResponder];
    
    if (![self checkout]) {
        return;
    }

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.minSize = CGSizeMake(250, 120);
    hud.delegate = self;
    //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
    //hud.yOffset = ScreenHeight/2.0-60;
    //hud.xOffset = 0;
    [self.view addSubview:hud];
    [hud show:YES];

    NSString *parameter = [NSString stringWithFormat:@"UserName=%@&UserPwd=%@",self.textEmail.text,self.textPassword.text];
    [WMSHTTPRequest loginRequestParameter:parameter completion:^(BOOL result, NSDictionary *info, NSError *error)
    {
        DEBUGLog(@"result:%d",result);
        if (result) {
            hud.labelText = NSLocalizedString(@"登陆成功", nil);
            [hud hide:YES];
            [self loginSuccessed];
            return ;
        } else if (!result && error==nil) {
            hud.labelText = NSLocalizedString(@"登陆失败", nil);
        } else if (error) {
            hud.labelText = NSLocalizedString(@"网络请求超时", nil);
        }
        [hud hide:YES afterDelay:1];
    }];
}

- (IBAction)signupAction:(id)sender {
    WMSSignupViewController *signupVC = [[WMSSignupViewController alloc] initWithNibName:@"WMSSignupViewController" bundle:nil];
    [self.navigationController pushViewController:signupVC animated:YES];
    DEBUGLog(@"sign up");
}

- (IBAction)resignResponse:(id)sender {
    [self.textEmail resignFirstResponder];
    [self.textPassword resignFirstResponder];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DEBUGLog(@"UITextFieldDelegate");
    
    if (self.textEmail == textField) {
        [self.textPassword becomeFirstResponder];
    } else if (self.textPassword == textField) {
        [self.textPassword resignFirstResponder];
    }
    
    return YES;
}


#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
}

@end
