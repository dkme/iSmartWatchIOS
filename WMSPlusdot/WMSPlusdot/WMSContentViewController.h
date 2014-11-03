//
//  WMSContentViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonLeft;
@property (weak, nonatomic) IBOutlet UIButton *buttonRight;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrev;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonTarget;
@property (weak, nonatomic) IBOutlet UIButton *buttonHistory;

@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentSteps;
@property (weak, nonatomic) IBOutlet UILabel *labelTargetSetps;
@property (weak, nonatomic) IBOutlet UILabel *labelBurnValue;
@property (weak, nonatomic) IBOutlet UILabel *labelDistanceValue;
@property (weak, nonatomic) IBOutlet UILabel *labelTimeValue;
@property (weak, nonatomic) IBOutlet UILabel *labelTimeMinuteValue;


- (IBAction)showLeftViewAction:(id)sender;
- (IBAction)showRightViewAction:(id)sender;
- (IBAction)prevDateAction:(id)sender;
- (IBAction)nextDateAction:(id)sender;
- (IBAction)gotoMyTargetViewAction:(id)sender;
- (IBAction)gotoMyHistoryViewAction:(id)sender;

@property (nonatomic, assign) BOOL isShowBindVC;

- (void)scanAndConnectPeripheral;


@end
