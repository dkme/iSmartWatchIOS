//
//  WMSClockCell.h
//  WMSPlusdot
//
//  Created by Sir on 15-1-12.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMSClockCellDelegage;

@interface WMSClockCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *myTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *myDetailTextLabel;
@property (weak, nonatomic) IBOutlet UISwitch *mySwitch;
@property (weak, nonatomic) id<WMSClockCellDelegage> delegate;

@end

@protocol WMSClockCellDelegage<NSObject>

@optional
- (void)clockCell:(WMSClockCell *)clockCell didClickSwitch:(UISwitch *)sw;

@end