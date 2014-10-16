//
//  WMSSportHistoryViewController.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-26.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PNLineChartView;
@class WMSNavBarView;

@interface WMSSportHistoryViewController : UIViewController

@property (weak, nonatomic) IBOutlet WMSNavBarView *navBarView;
@property (weak, nonatomic) IBOutlet PNLineChartView *chartView;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelOnedaySteps;
@property (weak, nonatomic) IBOutlet UILabel *labelDescribe;

@property (weak, nonatomic) IBOutlet UIButton *buttonPrev;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;

@property (strong, nonatomic) NSDate *showDate;

- (IBAction)prevDateAction:(id)sender;
- (IBAction)nextDateAction:(id)sender;

@end
