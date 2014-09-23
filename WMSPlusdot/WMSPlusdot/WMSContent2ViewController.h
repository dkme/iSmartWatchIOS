//
//  WMSContent2ViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-23.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MIN_SPORT_STEPS     6000

@interface WMSContent2ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonLeft;
@property (weak, nonatomic) IBOutlet UIButton *buttonRight;

@property (weak, nonatomic) IBOutlet UILabel *labelMySteps;
@property (weak, nonatomic) IBOutlet UILabel *labelModeType;

- (IBAction)showLeftViewAction:(id)sender;
- (IBAction)showRightViewAction:(id)sender;

@property (nonatomic) NSUInteger sportTargetSteps;

@end
