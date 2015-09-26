//
//  WMSSmartClockViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WMSAlarmClockModel;

#define DEFAULT_START_HOUR          8
#define DEFAULT_START_MINUTE        0
#define DEFAULT_SNOOZE_MINUTE       5

//cell所在行的下标
enum {
    SmartClockTimeCell = 1,
    SmartClockSleepTimeCell,
    SmartClockRepeatCell = SmartClockSleepTimeCell,
};

@interface WMSSmartClockViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) WMSAlarmClockModel *clockModel;

@end
