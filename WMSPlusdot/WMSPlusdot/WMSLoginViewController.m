//
//  WMSLoginViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSLoginViewController.h"
#import "WMSSignupViewController.h"
#import "WMSHTTPRequest.h"
#import "MBProgressHUD.h"
#import "WMSAppDelegate.h"

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Login_bg.png"]];
    
    self.textPassword.secureTextEntry = YES;
    self.textPassword.delegate = self;
    self.textEmail.delegate = self;
    
    [self.buttonLogin setBackgroundImage:[UIImage imageNamed:@"login_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonLogin setBackgroundImage:[UIImage imageNamed:@"login_btn_b.png"] forState:UIControlStateSelected];
    [self.viewEmail setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_menu_bg_a.png"]]];
    [self.viewPassword setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_menu_bg_a.png"]]];
    
    [self localizableView];
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
    [self.buttonFogetPassword setTitleEdgeInsets:UIEdgeInsetsMake(20, 0, 0, 0)];
    [self.buttonLogin setTitle:NSLocalizedString(@"登陆", nil) forState:UIControlStateNormal];
    
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
    NSDictionary *writeData = @{@"userName":self.textEmail.text,@"password":self.textPassword.text};
    BOOL res = [writeData writeToFile:FilePath(UserInfoFile) atomically:YES];
    DEBUGLog(@"保存登陆信息%@",res?@"成功":@"失败");
    [WMSAppDelegate appDelegate].window.rootViewController = (UIViewController *)[WMSAppDelegate appDelegate].reSideMenu;
    [WMSAppDelegate appDelegate].loginNavigationCtrl = nil;
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
    
    //self.textEmail.text = @"Sir";
    //self.textPassword.text = @"123456";
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
