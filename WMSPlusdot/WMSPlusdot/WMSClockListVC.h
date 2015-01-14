//
//  WMSClockListVC.h
//  WMSPlusdot
//
//  Created by Sir on 15-1-9.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSClockListVC : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;


@end
