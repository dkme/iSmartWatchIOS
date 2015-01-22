//
//  WMSContent1ViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-22.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GGIAnnulusView;

@interface WMSContent1ViewController : UIViewController
{
    //需本地化的UIView
    __weak IBOutlet UILabel *_labelTitle;
    __weak IBOutlet UILabel *_labelMySleep;
    __weak IBOutlet UILabel *_labelDeepsleep;
    __weak IBOutlet UILabel *_labelLightsleep;
    __weak IBOutlet UILabel *_labelWakeup;
    
    __weak IBOutlet UILabel *_labelHour0;
    __weak IBOutlet UILabel *_labelMinute0;
    __weak IBOutlet UILabel *_labelHour1;
    __weak IBOutlet UILabel *_labelMinute1;
    __weak IBOutlet UILabel *_labelHour2;
    __weak IBOutlet UILabel *_labelMinute2;
    __weak IBOutlet UILabel *_labelHour3;
    __weak IBOutlet UILabel *_labelMinute3;
}
@property (weak, nonatomic) IBOutlet UIButton *buttonLeft;
@property (weak, nonatomic) IBOutlet UIButton *buttonRight;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrev;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonClock;
@property (weak, nonatomic) IBOutlet UIButton *buttonHistory;

@property (weak, nonatomic) IBOutlet UILabel *labelDate;

@property (weak, nonatomic) IBOutlet UILabel *labelSleepHour;
@property (weak, nonatomic) IBOutlet UILabel *labelSleepMinute;
@property (weak, nonatomic) IBOutlet UILabel *labelDeepsleepHour;
@property (weak, nonatomic) IBOutlet UILabel *labelDeepsleepMinute;
@property (weak, nonatomic) IBOutlet UILabel *labelLightSleepHour;
@property (weak, nonatomic) IBOutlet UILabel *labelLightSleepMinute;
@property (weak, nonatomic) IBOutlet UILabel *labelWakeupSleepHour;
@property (weak, nonatomic) IBOutlet UILabel *labelWakeupSleepMinute;

@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet GGIAnnulusView *annulusView;


- (IBAction)showLeftViewAction:(id)sender;
- (IBAction)showRightViewAction:(id)sender;
- (IBAction)prevDateAction:(id)sender;
- (IBAction)nextDateAction:(id)sender;
- (IBAction)gotoMyClockViewAction:(id)sender;
- (IBAction)gotoMyHistoryViewAction:(id)sender;

- (void)syncData;

@end
