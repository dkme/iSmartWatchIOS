//
//  WMSContent1ViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-22.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSContent1ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonLeft;
@property (weak, nonatomic) IBOutlet UIButton *buttonRight;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrev;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonClock;
@property (weak, nonatomic) IBOutlet UIButton *buttonHistory;

@property (weak, nonatomic) IBOutlet UILabel *labelDate;


- (IBAction)showLeftViewAction:(id)sender;
- (IBAction)showRightViewAction:(id)sender;
- (IBAction)prevDateAction:(id)sender;
- (IBAction)nextDateAction:(id)sender;
- (IBAction)gotoMyClockViewAction:(id)sender;
- (IBAction)gotoMyHistoryViewAction:(id)sender;

- (void)syncData;

@end
