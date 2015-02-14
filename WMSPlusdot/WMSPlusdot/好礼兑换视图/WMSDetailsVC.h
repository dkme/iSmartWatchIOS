//
//  WMSDetailsVC.h
//  WMSPlusdot
//
//  Created by Sir on 15-2-4.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSDetailsVC : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *ruleTextView;
@property (weak, nonatomic) IBOutlet UILabel *multiplierLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *getBeanLabel;
@property (weak, nonatomic) IBOutlet UILabel *myBeanLabel;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

@end
