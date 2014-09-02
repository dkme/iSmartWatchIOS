//
//  WMSAccountViewController.h
//  WMSPlusdot
//
//  Created by John on 14-8-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSAccountViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UIButton *buttonEdit;
@property (weak, nonatomic) IBOutlet UIButton *buttonExit;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDescribe;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (IBAction)backAction:(id)sender;
- (IBAction)editAction:(id)sender;
- (IBAction)exitAction:(id)sender;

@end
