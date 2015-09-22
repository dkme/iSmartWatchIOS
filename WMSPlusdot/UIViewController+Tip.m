//
//  UIViewController+Tip.m
//  WMSPlusdot
//
//  Created by Sir on 14-10-28.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "UIViewController+Tip.h"
#import "WMSRightViewController.h"
#import "WMSAppDelegate.h"

#import "MBProgressHUD.h"

#import "WMSConstants.h"

#define HUD_TAG         10000

@implementation UIViewController (Tip)

- (BOOL)checkoutWithIsBind:(BOOL)bindYesOrNo
               isConnected:(BOOL)connectedYesOrNo
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
    hud.mode = MBProgressHUDModeText;
    //hud.animationType = MBProgressHUDAnimationZoomIn;
    if ([self class] == [WMSRightViewController class]) {
        //hud.xOffset = HUD_SHOW_RIGHT_VC_X_OFFSET;
    }
    hud.yOffset = HUD_LOCATED_BOTTOM_Y_OFFSET;
    hud.minSize = HUD_LOCATED_BOTTOM_SIZE;
    hud.labelText = @"";
    hud.labelFont = [UIFont boldSystemFontOfSize:15.f];
    if (bindYesOrNo == NO) {
        hud.labelText = NSLocalizedString(TIP_NO_BINDING, nil);
    }
    else if (connectedYesOrNo == NO) {
        hud.labelText = NSLocalizedString(TIP_NO_CONNECTION, nil);
    }
    if ([hud.labelText isEqualToString:@""] == NO) {
        [self.view.window addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep(1.0);
        } completionBlock:^{
            [hud removeFromSuperview];
        }];
        return NO;
    }
    
    return YES;
}

- (void)showOperationSuccessTip:(NSString *)tip
{
    //MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[WMSAppDelegate appDelegate].window];
    hud.mode = MBProgressHUDModeText;
    //hud.animationType = MBProgressHUDAnimationZoomIn;
    hud.yOffset = HUD_LOCATED_BOTTOM_Y_OFFSET;
    hud.minSize = HUD_LOCATED_BOTTOM_SIZE;
    hud.labelText = tip;
    hud.labelFont = [UIFont boldSystemFontOfSize:15.f];
    //[self.view.window addSubview:hud];
    [[WMSAppDelegate appDelegate].window addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}

- (void)showTip:(NSString *)tip
{
    [self showOperationSuccessTip:tip];
}

- (void)showHUDAtViewCenter:(NSString *)text
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[WMSAppDelegate appDelegate].window];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.yOffset = HUD_LOCATED_CENTER_Y_OFFSET;
    if (text && text.length>0) {
        hud.minSize = HUD_LOCATED_CENTER_SIZE;
    }
    hud.labelText = text;
    hud.tag = HUD_TAG;
    [[WMSAppDelegate appDelegate].window addSubview:hud];
    [hud show:YES];
}
- (void)showHUDAtViewCenterWithText:(NSString *)text
                         detailText:(NSString *)detailText
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[WMSAppDelegate appDelegate].window];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.yOffset = HUD_LOCATED_CENTER_Y_OFFSET;
    hud.minSize = HUD_LOCATED_CENTER_SIZE;
    hud.labelText = text;
    hud.detailsLabelText = detailText;
    hud.tag = HUD_TAG;
    [[WMSAppDelegate appDelegate].window addSubview:hud];
    [hud show:YES];
}

- (void)hideHUDAtViewCenter
{
    NSArray *subViews = [[WMSAppDelegate appDelegate].window subviews];
    for (UIView *view in subViews) {
        if ([view class] == [MBProgressHUD class] &&
            view.tag == HUD_TAG) {
            MBProgressHUD *hud = (MBProgressHUD *)view;
            [hud removeFromSuperview];
        }
    }
}

@end
