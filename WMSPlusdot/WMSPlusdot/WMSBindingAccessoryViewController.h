//
//  WMSBindingAccessoryViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-23.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSBindingAccessoryViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonLeft;
@property (weak, nonatomic) IBOutlet UIButton *buttonRight;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *labelBLEStatus;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewBLEStatus;

@property (assign, nonatomic) int generation;//第一款为1，第二款为2

- (IBAction)showLeftViewAction:(id)sender;
- (IBAction)showRightViewAction:(id)sender;

- (void)dismissVC;

@end
