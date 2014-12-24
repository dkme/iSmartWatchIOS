//
//  WMSSyncDataView.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-12.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMSSyncDataView : UIView

@property (strong, nonatomic, readonly) UILabel *labelTip;

@property (strong, nonatomic, readonly) UIImageView *imageView;

@property (strong, nonatomic, readonly) UIButton *buttonSync;

- (void)setLabelEnergyFont:(UIFont *)font;

- (void)setEnergy:(NSUInteger)energy;

- (void)startAnimating;

- (void)stopAnimating;

@end
