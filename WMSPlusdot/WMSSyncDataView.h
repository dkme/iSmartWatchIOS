//
//  WMSSyncDataView.h
//  WMSPlusdot
//
//  Created by Sir on 14-9-12.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WMSSyncDataViewDelegate;

@interface WMSSyncDataView : UIView

@property (strong, nonatomic, readonly) UILabel *labelTip;

@property (strong, nonatomic, readonly) UIImageView *imageView;

@property (strong, nonatomic, readonly) UIButton *buttonSync;

@property (nonatomic, weak) id<WMSSyncDataViewDelegate> delegate;

- (void)setLabelEnergyFont:(UIFont *)font;

- (void)setEnergy:(NSUInteger)energy;

- (void)startAnimating;

- (void)stopAnimating;

+ (id)defaultSyncDataView;

@end

@protocol WMSSyncDataViewDelegate <NSObject>

@optional
- (void)syncDataView:(WMSSyncDataView *)syncView didClickSyncButton:(UIButton *)button;

@end





