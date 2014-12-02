//
//  WMSGuideVC.h
//  WMSPlusdot
//
//  Created by Sir on 14-12-2.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSGuideVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonCenter;
@property (weak, nonatomic) IBOutlet UIButton *buttonLeft;
@property (weak, nonatomic) IBOutlet UIButton *buttonRight;
@property (weak, nonatomic) IBOutlet UIView *topView;

- (IBAction)centerBtnAction:(id)sender;
- (IBAction)leftBtnAction:(id)sender;
- (IBAction)rightBtnAction:(id)sender;

+ (id)guide;

@end
