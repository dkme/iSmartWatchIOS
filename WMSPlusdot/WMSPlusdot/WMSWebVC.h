//
//  WMSWebVC.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-9.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WMSNavBarView;

@interface WMSWebVC : UIViewController

@property (weak, nonatomic) IBOutlet WMSNavBarView *navBarView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) NSString *navBarTitle;
@property (strong, nonatomic) NSString *strRequestURL;

@end
