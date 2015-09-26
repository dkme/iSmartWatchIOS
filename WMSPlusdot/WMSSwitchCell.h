//
//  WMSSwitchCell.h
//  WMSPlusdot
//
//  Created by John on 14-8-21.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMSSwitchCellDelegage;

@interface WMSSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *myLabelText;
@property (weak, nonatomic) IBOutlet UISwitch *mySwitch;
@property (weak, nonatomic) id<WMSSwitchCellDelegage> delegate;

- (void)configureCellWithText:(NSString *)text switchOn:(BOOL)on;

@end

@protocol WMSSwitchCellDelegage<NSObject>

@optional
- (void)switchCell:(WMSSwitchCell *)switchCell didClickSwitch:(UISwitch *)sw;

@end
