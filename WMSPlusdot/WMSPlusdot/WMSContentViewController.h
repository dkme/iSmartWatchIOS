//
//  WMSContentViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WMSMySportView;

@interface WMSContentViewController : UIViewController
{
    //需本地化
    __weak IBOutlet UILabel *_labelTitle;
    __weak IBOutlet UILabel *_labelMySport;
    __weak IBOutlet UILabel *_labelStep;
    __weak IBOutlet UILabel *_labelStep2;
    __weak IBOutlet UILabel *_labelMuBiao;
    __weak IBOutlet UILabel *_labelRanShao;
    __weak IBOutlet UILabel *_labelJuli;
    __weak IBOutlet UILabel *_labelShiJian;
    __weak IBOutlet UILabel *_labelHour;
    __weak IBOutlet UILabel *_labelMinute;
}
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

@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet WMSMySportView *mySportView;


- (IBAction)showLeftViewAction:(id)sender;
- (IBAction)showRightViewAction:(id)sender;
- (IBAction)prevDateAction:(id)sender;
- (IBAction)nextDateAction:(id)sender;
- (IBAction)gotoMyTargetViewAction:(id)sender;
- (IBAction)gotoMyHistoryViewAction:(id)sender;

@property (nonatomic, assign) BOOL isShowBindVC;


- (void)syncData;

@end
