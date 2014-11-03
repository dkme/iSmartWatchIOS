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

@implementation UIViewController (Tip)

- (BOOL)checkoutWithIsBind:(BOOL)bindYesOrNo
               isConnected:(BOOL)connectedYesOrNo
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
    hud.mode = MBProgressHUDModeText;
    if ([self class] == [WMSRightViewController class]) {
        //hud.xOffset = HUD_SHOW_RIGHT_VC_X_OFFSET;
    }
    hud.yOffset = HUD_LOCATED_BOTTOM_Y_OFFSET;
    hud.minSize = HUD_LOCATED_BOTTOM_SIZE;
    hud.labelText = @"";
    if (bindYesOrNo == NO) {
        hud.labelText = NSLocalizedString(TIP_NO_BINDING, nil);
    }
    else if (connectedYesOrNo == NO) {
        hud.labelText = NSLocalizedString(TIP_NO_CONNECTION, nil);
    }
    if ([hud.labelText isEqualToString:@""] == NO) {
        [self.view.window addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep(1);
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
    hud.yOffset = HUD_LOCATED_BOTTOM_Y_OFFSET;
    hud.minSize = HUD_LOCATED_BOTTOM_SIZE;
    hud.labelText = tip;
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

@end
