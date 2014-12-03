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

- (void)setLabelElectricQuantityFont:(UIFont *)font;

- (void)setCellElectricQuantity:(NSUInteger)quantity;

- (void)setCellColor:(UIColor *)color;

- (void)startAnimating;

- (void)stopAnimating;

@end
