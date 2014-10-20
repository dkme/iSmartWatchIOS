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
#import "WMSAppDelegate.h"

@interface WMSSignupViewController ()<MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewEmail;
@property (weak, nonatomic) IBOutlet UIView *viewUsername;
@property (weak, nonatomic) IBOutlet UIView *viewPassword;
@property (weak, nonatomic) IBOutlet UIView *viewConfirmPassword;
@property (weak, nonatomic) IBOutlet UILabel *labelLogin;
@property (strong, nonatomic) IBOutlet UIButton *buttonProtocol;
@property (strong, nonatomic) IBOutlet UIButton *buttonBox;

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
    
    [self.buttonProtocol setTitle:NSLocalizedString(@"隐私条款", nil) forState:UIControlStateNormal];
    [self.buttonProtocol setTitleColor:UIColorFromRGBAlpha(0x18B2FA, 1) forState:UIControlStateNormal];
    [self.buttonBox setTitle:NSLocalizedString(@"注册代表您同意", nil) forState:UIControlStateNormal];
    
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

- (void)loginSuccessed
{
    NSDictionary *writeData = @{@"userName":self.textUserName.text,@"password":self.textPassword.text};
    BOOL res = [writeData writeToFile:FilePath(UserInfoFile) atomically:YES];
    DEBUGLog(@"保存登陆信息%@",res?@"成功":@"失败");
    [WMSAppDelegate appDelegate].window.rootViewController = (UIViewController *)[WMSAppDelegate appDelegate].reSideMenu;
    [WMSAppDelegate appDelegate].loginNavigationCtrl = nil;
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
    
    NSString *parameter = [NSString stringWithFormat:@"Email=%@&UserName=%@&UserPwd=%@&MobileNo=%@",self.textEmail.text,self.textUserName.text,self.textPassword.text,@""];
    [WMSHTTPRequest registerRequestParameter:parameter completion:^(BOOL result, int errorNO,NSError *error)
    {
        DEBUGLog(@"result=%d,errorNO=%d",result,errorNO);
        if (result) {
            [hud setLabelText:NSLocalizedString(@"注册成功", nil)];
            [hud hide:YES];
            [self loginSuccessed];
            return ;
        } else if (!result && error==nil) {
            if (errorNO == 10001) {
                [hud setLabelText:NSLocalizedString(@"用户名已存在", nil)];
            } else if (errorNO == 10002) {
                [hud setLabelText:NSLocalizedString(@"邮箱已经注册", nil)];
            } else {
                [hud setLabelText:NSLocalizedString(@"注册失败", nil)];
            }
        } else if (error) {
            hud.labelText = NSLocalizedString(@"网络请求超时", nil);
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

- (IBAction)protocolAction:(id)sender {
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"procotol" ofType:@"txt"];
    NSString *text = [NSString stringWithContentsOfFile:filePath
                                               encoding:NSUTF8StringEncoding
                                                  error:&error];
    // If there are no results, something went wrong
    if (text == nil) {
        // an error occurred
        DEBUGLog(@"Error reading text file. %@", [error localizedFailureReason]);
    }
    DEBUGLog(@"text:%@",text);
    
    
    UIScrollView * vi = [[UIScrollView alloc]init];
    vi.tag = 12345;
    vi.frame = CGRectMake(0, iOS6?-20:0, 320, iPhone5?568:480);
    vi.backgroundColor = [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1];
    vi.contentSize = CGSizeMake(0, 960);
    [self.view addSubview:vi];
    
    UITextView * txt = [[UITextView alloc]init];
    txt.frame = CGRectMake(8, 20, 304, 860);
    txt.text = text;
    txt.userInteractionEnabled = NO;
    txt.backgroundColor = [UIColor clearColor];
    txt.font = [UIFont systemFontOfSize:13.0];
    [vi addSubview:txt];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 8;
    btn.frame = CGRectMake(8, (iOS6?870+20:870)-100, 304, 45);
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(okCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = iPhone5?[UIColor colorWithRed:109/255.0 green:169/255.0 blue:28/255.0 alpha:1]:[UIColor colorWithRed:100/255.0 green:191/255.0 blue:28/255.0 alpha:1];
    btn.titleLabel.font = Font_DINCondensed(20.0);
    [vi addSubview:btn];
}
- (void)okCancelAction:(id)sender
{
    UIScrollView * vi = (UIScrollView*)[self.view viewWithTag:12345];
    [vi removeFromSuperview];
}

- (IBAction)checkBoxAction:(id)sender {
//    UIImage *image = [self.buttonBox imageForState:UIControlStateNormal];
//    if ([image isEqual:[UIImage imageNamed:@"check.png"]]) {
//        [self.buttonBox setBackgroundColor:[UIColor whiteColor]];
//    } else {
//        [self.buttonBox setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
//    }
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
