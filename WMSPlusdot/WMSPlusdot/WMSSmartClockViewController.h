//
//  WMSSmartClockViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

//cell所在行的下标
enum {
    SmartClockTimeCell = 1,
    SmartClockSleepTimeCell,
    SmartClockRepeatCell,
};

@interface WMSSmartClockViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)backAction:(id)sender;

@end
