//
//  WMSWebVC.m
//  WMSPlusdot
//
//  Created by Sir on 14-12-9.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSWebVC.h"

#import "WMSNavBarView.h"

@interface WMSWebVC ()<UIWebViewDelegate>
{
    UIView *_foreGroundView;
    UIActivityIndicatorView *_indicatorView;
}

@end

@implementation WMSWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupNavBarView];
    [self setupWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}

#pragma mark - setup UI
- (void)setupNavBarView
{
    self.navBarView.backgroundColor = UICOLOR_DEFAULT;
    self.navBarView.labelTitle.text = self.navBarTitle;
    self.navBarView.labelTitle.font = Font_DINCondensed(20.0);
    [self.navBarView.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_a.png"] forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_b.png"] forState:UIControlStateHighlighted];
    [self.navBarView.buttonLeft addTarget:self action:@selector(buttonLeftClicked:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)setupWebView
{
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:_strRequestURL]];
    [self.webView setDelegate:self];
    [self.webView loadRequest:request];
}

#pragma mark - Action
- (void)buttonLeftClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //创建UIActivityIndicatorView背底半透明View
    _foreGroundView = [[UIView alloc] initWithFrame:webView.frame];
    [_foreGroundView setBackgroundColor:[UIColor blackColor]];
    [_foreGroundView setAlpha:0.5];
    [self.view addSubview:_foreGroundView];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [_indicatorView setCenter:self.view.center];
    [_indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [_foreGroundView addSubview:_indicatorView];
    
    [_indicatorView startAnimating];
    DEBUGLog(@"%s",__FUNCTION__);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_indicatorView stopAnimating];
    [_indicatorView removeFromSuperview];
    [_foreGroundView removeFromSuperview];
    _indicatorView = nil;
    _foreGroundView = nil;
    DEBUGLog(@"%s",__FUNCTION__);
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DEBUGLog(@"%s",__FUNCTION__);
    [self webViewDidFinishLoad:nil];
}

@end
