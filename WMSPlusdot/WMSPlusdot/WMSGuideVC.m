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

#import "WMSHelper.h"

#define INTRO_CONTENT_OFFSET    (iPhone5?30.f:30.f+568-480)
#define INTRO_BUTTON_TAG        100

@interface WMSGuideVC ()<EAIntroDelegate>
@property (nonatomic,strong) UIView *bottomView;
@end

@implementation WMSGuideVC

#pragma mark - Getter/Setter
- (UIView *)bottomView
{
    if (!_bottomView) {
        CGSize viewSize = iPhone5?CGSizeMake(ScreenWidth, 88):CGSizeZero;
        CGPoint viewOrigin = iPhone5?CGPointMake(0, ScreenHeight-viewSize.height):CGPointZero;
        CGRect viewFrame = (CGRect){viewOrigin,viewSize};
        _bottomView = [[UIView alloc] initWithFrame:viewFrame];
        
        CGSize lineSize = CGSizeMake(1, 20);
        CGPoint lineOrigin = CGPointMake((ScreenWidth-lineSize.width)/2.0, ScreenHeight-10-lineSize.height);
        CGRect lineFrame = (CGRect){lineOrigin,lineSize};
        UIView *dividingLine = [[UIView alloc] initWithFrame:lineFrame];
        
        CGSize btnSize = CGSizeMake(90, 40);
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = (CGRect){lineOrigin.x-20-btnSize.width,lineOrigin.y,btnSize};
        //rightBtn.frame = (CGRect){,,btnSize};
        
    }
    return nil;
}

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
    [self setupControl];
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
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Hello world";
    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    page1.bgImage = [UIImage imageNamed:@"1"];
    page1.titleImage = [UIImage imageNamed:@"original"];
    page1.titlePositionY += INTRO_CONTENT_OFFSET;
    page1.descPositionY += INTRO_CONTENT_OFFSET;
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"This is page 2";
    page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
    page2.bgImage = [UIImage imageNamed:@"2"];
    page2.titleImage = [UIImage imageNamed:@"supportcat"];
    page2.titlePositionY += INTRO_CONTENT_OFFSET;
    page2.descPositionY += INTRO_CONTENT_OFFSET;
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"This is page 3";
    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
    page3.bgImage = [UIImage imageNamed:@"3"];
    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
    page3.titlePositionY += INTRO_CONTENT_OFFSET;
    page3.descPositionY += INTRO_CONTENT_OFFSET;
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"This is page 4";
    page4.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
    page4.bgImage = [UIImage imageNamed:@"4"];
    page4.titleImage = [UIImage imageNamed:@"femalecodertocat"];
    page4.titlePositionY += INTRO_CONTENT_OFFSET;
    page4.descPositionY += INTRO_CONTENT_OFFSET;
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.topView.bounds andPages:@[page1,page2,page3,page4]];
    intro.swipeToExit = NO;
    intro.skipButton.hidden = YES;
    intro.pageControlY += INTRO_CONTENT_OFFSET;
    intro.delegate = self;
    
    CGSize btnSize = CGSizeMake(150, 40);
    CGPoint btnOrigin = CGPointMake((intro.frame.size.width-btnSize.width)/2.0, intro.frame.size.height-btnSize.height-10);
    btnOrigin.y = (iPhone5?btnOrigin.y:btnOrigin.y-(568-480));
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = (CGRect){btnOrigin,btnSize};
    button.backgroundColor = [UIColor redColor];
    button.tag = INTRO_BUTTON_TAG;
    button.alpha = 0;
    [button addTarget:self action:@selector(enterMainView:) forControlEvents:UIControlEventTouchUpInside];
    [intro addSubview:button];
    
    [intro showInView:self.topView animateDuration:0];
}

#pragma mark - Action
- (void)enterMainView:(id)sender {
    WMSMyAccountViewController *vc = [[WMSMyAccountViewController alloc] init];
    vc.isNewUser = YES;
    WMSAppDelegate *appDelegate = [WMSAppDelegate appDelegate];
    appDelegate.window.rootViewController = vc;
    UIView *view = [vc view];
    view.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        view.alpha = 1.0;
    }];

    //[WMSHelper finishFirstLaunchApp];
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
        [UIView animateWithDuration:1.0 animations:^{
            btn.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:1.0 animations:^{
            btn.alpha = 0;
        }];
    }
}

@end
