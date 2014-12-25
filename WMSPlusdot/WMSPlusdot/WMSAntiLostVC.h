//
//  WMSAntiLostVC.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-25.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WMSNavBarView;

@interface WMSAntiLostVC : UIViewController

@property (weak, nonatomic) IBOutlet WMSNavBarView *navBarView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *navBarTitle;

@end
