//
//  MyNavigationViewController.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-13.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "MyNavigationController.h"

@implementation MyNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //如果现在push的不是栈顶控制器，那么久隐藏tabbar工具条
    if (self.viewControllers.count>0) {
        viewController.hidesBottomBarWhenPushed=YES;

        //拦截push操作，设置导航栏的左上角和右上角按钮
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"back_btn_a.png" highImageName:@"back_btn_b.png" target:self action:@selector(back:)];
        //viewController.navigationItem.rightBarButtonItem=[UIBarButtonItem itemWithImageName:@"navigationbar_more" highImageName:@"navigationbar_more_highlighted" target:self action:@selector(more)];

    }
    [super pushViewController:viewController animated:animated];
}

- (void)back:(id)sender
{
//#warning 这里用的是self, 因为self就是当前正在使用的导航控制器
    [self popViewControllerAnimated:YES];
}

@end
