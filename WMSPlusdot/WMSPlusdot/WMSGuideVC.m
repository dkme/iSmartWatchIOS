//
//  WMSGuideVC.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-2.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSGuideVC.h"
#import "WMSAppDelegate.h"
#import "WMSMyAccountViewController.h"

#import "EAIntroPage.h"
#import "EAIntroView.h"
#import "WMSAppConfig.h"
#import "WMSHelper.h"

#define INTRO_CONTENT_OFFSET    (iPhone5?30.f:30.f+568-480-40)
#define INTRO_BUTTON_TAG        100

@interface WMSGuideVC ()<EAIntroDelegate>
@property (nonatomic,strong) UIView *bottomView;
@end

@implementation WMSGuideVC

#pragma mark - Getter/Setter

#pragma mark - Life Cycle
+ (id)guide
{
    WMSGuideVC *vc = [[WMSGuideVC alloc] initWithNibName:@"WMSGuideVC" bundle:nil];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.backgroundColor = [UIColor redColor];
    //[self setupControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showIntroView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}

#pragma mark - Private Methods
- (void)setupControl
{
    [self.buttonCenter setTitle:NSLocalizedString(@"进入", nil) forState:UIControlStateNormal];
    [self.buttonLeft setTitle:NSLocalizedString(@"注册", nil) forState:UIControlStateNormal];
    [self.buttonRight setTitle:NSLocalizedString(@"跳过", nil) forState:UIControlStateNormal];
}

- (void)showIntroView
{
    NSArray *images = nil;
    NSString *languageType = [WMSAppConfig systemLanguage];
    if ([languageType isEqualToString:kLanguageChinese]) {
        images = @[@"intro_page1.png",
                   //@"intro_page2.png",
                   @"intro_page3.png",
                   @"intro_page4.png",
                   ];
    } else {
        images = @[@"intro_page1_b.png",
                   //@"intro_page2_b.png",
                   @"intro_page3_b.png",
                   @"intro_page4_b.png",
                   ];
    }
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.bgImage = [UIImage imageNamed:images[0]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:images[1]];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.bgImage = [UIImage imageNamed:images[2]];
    
//    EAIntroPage *page4 = [EAIntroPage page];
//    page4.bgImage = [UIImage imageNamed:images[3]];
    
    NSArray *pages = @[page1,page2,page3,/*page4*/];
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:pages];
    intro.swipeToExit = NO;
    intro.skipButton.hidden = YES;
    intro.delegate = self;
    
    UIImage *image = [UIImage imageNamed:@"intro_enter.png"];
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(image.size.width/2.0, image.size.height/2.0);
    frame.origin.x = (ScreenWidth-frame.size.width)/2.0;
    frame.origin.y = ScreenHeight-frame.size.height-10.0;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [UIColor clearColor];
    button.tag = INTRO_BUTTON_TAG;
    button.alpha = 0;
    [button setTitle:@"Go" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(enterMainView:) forControlEvents:UIControlEventTouchUpInside];
    [intro addSubview:button];
    
    [intro showInView:self.view animateDuration:0];
}

#pragma mark - Action
- (void)enterMainView:(id)sender {
    WMSMyAccountViewController *vc = [[WMSMyAccountViewController alloc] init];
    MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:vc];
    vc.isNewUser = YES;
    WMSAppDelegate *appDelegate = [WMSAppDelegate appDelegate];
    appDelegate.window.rootViewController = nav;
    UIView *view = [vc view];
    view.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        view.alpha = 1.0;
    }];

    [WMSHelper finishFirstLaunchApp];
}

- (IBAction)centerBtnAction:(id)sender {
    WMSAppDelegate *appDelegate = [WMSAppDelegate appDelegate];
    appDelegate.window.rootViewController = [appDelegate loginNavigationCtrl];
    UIView *view = [[appDelegate loginNavigationCtrl] view];
    view.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)leftBtnAction:(id)sender {
}

- (IBAction)rightBtnAction:(id)sender {
}

#pragma mark - EAIntroDelegate
- (void)intro:(EAIntroView *)introView didScrollToPageIndex:(NSInteger)currentPageIndex
{
    UIButton *btn = (UIButton *)[introView viewWithTag:INTRO_BUTTON_TAG];
    if (currentPageIndex == [introView.pages count]-1) {
        [UIView animateWithDuration:0.5 animations:^{
            btn.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            btn.alpha = 0;
        }];
    }
    DEBUGLog(@"didScrollToPageIndex，index:%d",currentPageIndex);
}
- (void)introDidFinish:(EAIntroView *)introView
{
    DEBUGLog(@"introDidFinish");
}

@end
