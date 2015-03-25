//
//  GGIViewController.h
//  Camera
//
//  Created by Sir on 14-9-27.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GGIViewControllerDelegate;

@interface GGIViewController : UIViewController

@property (nonatomic,weak) id<GGIViewControllerDelegate>delegate;
@property (strong, nonatomic, readonly) UIView *liveView;
@property (nonatomic, readonly) UILabel *textLabel;

- (void)takePhoto;

@end

@protocol GGIViewControllerDelegate <NSObject>

@optional
- (void)GGIViewController:(GGIViewController *)viewController didClickImage:(UIImage *)image;
- (void)GGIViewControllerDidClose:(GGIViewController *)viewController;

@end
