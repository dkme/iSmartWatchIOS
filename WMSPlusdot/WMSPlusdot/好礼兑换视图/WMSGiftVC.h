//
//  WMSGiftVC.h
//  WMSPlusdot
//
//  Created by Sir on 15-1-28.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGTopMenu.h"

@interface WMSGiftVC : UIViewController<UITableViewDelegate,GGTopMenuDelegate>
@property (weak, nonatomic) IBOutlet GGTopMenu *topMenu;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
