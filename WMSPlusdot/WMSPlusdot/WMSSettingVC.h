//
//  WMSSettingVC.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-8.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WMSNavBarView;

@interface WMSSettingVC : UIViewController

@property (weak, nonatomic) IBOutlet WMSNavBarView *navBarView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,getter=isNeedUpdateView) BOOL needUpdateView;

@end
