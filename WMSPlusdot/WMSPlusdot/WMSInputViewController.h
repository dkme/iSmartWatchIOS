//
//  WMSInputViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSInputViewController : UIViewController

@property (nonatomic) int selectIndex;
@property (strong,nonatomic) NSString *VCTitle;

@property (nonatomic) int startTimeHour;
@property (nonatomic) int startTimeMinute;
@property (nonatomic) int finishTimeHour;
@property (nonatomic) int finishTimeMinute;
@property (nonatomic) int intervalMinute;
@property (nonatomic,strong) NSMutableArray *selectedWeekArray;//存放7个BOOL值，表示周一至周日，yes表示选中，no表示没选中

@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;

- (IBAction)backAction:(id)sender;

@end
