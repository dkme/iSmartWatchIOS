//
//  WMSMyAccessoryViewController.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-15.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const WMSBindAccessorySuccess;

@interface WMSMyAccessoryViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)showBindingTip:(BOOL)successOrFail;
@end
