//
//  WMSActivityRemindViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFAULT_HOUR                8
#define DEFAULT_MINUTE              0
#define DEFAULT_ACTIVITY_INTERVAL   30

//cell所在行的下标
enum {
    StartTimeCell = 1,
    FinishTimeCell,
    IntervalTimeCell,
    RepeatCell,
};

@interface WMSActivityRemindViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UIButton *buttonSync;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)backAction:(id)sender;
- (IBAction)syncSettingAction:(id)sender;

@end
