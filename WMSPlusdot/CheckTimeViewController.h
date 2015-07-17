//
//  CheckTimeViewController.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/5/21.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckTimeViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;

@end
