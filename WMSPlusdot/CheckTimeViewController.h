//
//  CheckTimeViewController.h
//  WMSPlusdot
//
//  Created by guogee mac on 15/5/21.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TurntableView.h"
#import "RFSegmentView.h"

@interface CheckTimeViewController : UIViewController <RFSegmentViewDelegate>

@property (weak, nonatomic) IBOutlet TurntableView *turntableView;

@property (weak, nonatomic) IBOutlet RFSegmentView *segmentView;

@property (weak, nonatomic) IBOutlet UIButton *button1h;
@property (weak, nonatomic) IBOutlet UIButton *button2h;
@property (weak, nonatomic) IBOutlet UIButton *button3h;

@property (weak, nonatomic) IBOutlet UILabel *describeLabel;

@end
