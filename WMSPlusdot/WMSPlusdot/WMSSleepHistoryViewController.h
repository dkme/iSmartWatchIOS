//
//  WMSSleepHistoryViewController.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-27.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WMSNavBarView;
@class PNBarChartView;

@interface WMSSleepHistoryViewController : UIViewController

@property (weak, nonatomic) IBOutlet WMSNavBarView *navBarView;
@property (weak, nonatomic) IBOutlet PNBarChartView *barChartView;

@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrev;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (strong, nonatomic) NSDate *showDate;

- (IBAction)prevDateAction:(id)sender;
- (IBAction)nextDateAction:(id)sender;

@end
