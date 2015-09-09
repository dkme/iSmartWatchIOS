//
//  CheckTimeViewController.m
//  WMSPlusdot
//
//  Created by guogee mac on 15/5/21.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "CheckTimeViewController.h"
#import "WMSAppDelegate.h"
#import "Masonry.h"

static const NSUInteger CLOCKWISE_CIRCUIT_NEED_TIME_INTERVAL      = /*15*/0;
static const NSUInteger ANTI_CLOCKWISE_CIRCUIT_NEED_TIME_INTERVAL = /*22*/0;

@interface CheckTimeViewController ()<TurntableViewDelegate>

@property (nonatomic, strong) WMSBleControl *bleControl;

@property (nonatomic, assign, getter=isRotating) BOOL rotating;

@end

@implementation CheckTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupProperty];
    [self setupNavBar];
    [self setupTurntableView];
    [self setupSegmentView];
    [self setupUI];///➕➖
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}


#pragma mark - Setup
- (void)setupProperty
{
    _bleControl = [WMSAppDelegate appDelegate].wmsBleControl;
}
- (void)setupNavBar
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"main_menu_icon_a.png" highImageName:@"main_menu_icon_b.png" target:self action:@selector(clickLeftBarButtonItem:)];
    self.title = NSLocalizedString(@"校对时间", nil);
    
    if (IS_IOS8) {
        ///将导航栏设置为不透明
        UINavigationBar *navBar = self.navigationController.navigationBar;
        navBar.barStyle = UIBarStyleBlack;
        navBar.translucent = NO;
        ///当导航栏为不透明时，不去将布局延伸至Bar所在区域
        self.extendedLayoutIncludesOpaqueBars = NO;
        ///设置视图只覆盖到左、右、下方的区域，而不覆盖上方的区域
        self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    }
    
}
- (void)setupTurntableView
{
    self.turntableView.delegate = self;
}
- (void)setupSegmentView
{
    self.segmentView.delegate = self;
    self.segmentView.items = @[@"+", @"-"];
    self.segmentView.backgroundColor = [UIColor clearColor];
    self.segmentView.tintColor = [UIColor whiteColor];
}
- (void)setupUI
{
    self.view.backgroundColor = UICOLOR_DEFAULT;
    
    self.describeLabel.text = NSLocalizedString(@"转动表盘以调整手表时间", nil);
    
    [self.button1h setTitleColor:UICOLOR_DEFAULT forState:UIControlStateNormal];
    [self.button2h setTitleColor:UICOLOR_DEFAULT forState:UIControlStateNormal];
    [self.button3h setTitleColor:UICOLOR_DEFAULT forState:UIControlStateNormal];
}
- (void)updateButtonsTitle:(NSString *)prefix
{
    [self.button1h setTitle:[prefix stringByAppendingString:@"1h"] forState:UIControlStateNormal];
    [self.button2h setTitle:[prefix stringByAppendingString:@"2h"] forState:UIControlStateNormal];
    [self.button3h setTitle:[prefix stringByAppendingString:@"3h"] forState:UIControlStateNormal];
}

- (void)resetRotating
{
    self.rotating = NO;
}

#pragma mark - Action
- (void)clickLeftBarButtonItem:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)clickedButton:(id)sender {
    NSTimeInterval interval = 0;
    if (sender == self.button1h) {
        interval = 1;
    } else if (sender == self.button2h) {
        interval = 2;
    } else if (sender == self.button3h) {
        interval = 3;
    } else {
        
    }
    if (!self.isRotating) {
        ROTATE_DIRECTION direction = (ROTATE_DIRECTION)self.segmentView.selectedIndex;
        [self.bleControl.settingProfile roughAdjustmentTimeWithDirection:direction timeInterval:interval completion:NULL];
        self.rotating = YES;
        [self performSelector:@selector(resetRotating) withObject:nil afterDelay:interval*(direction==DIRECTION_clockwise?CLOCKWISE_CIRCUIT_NEED_TIME_INTERVAL:ANTI_CLOCKWISE_CIRCUIT_NEED_TIME_INTERVAL)];
    }
}

#pragma mark - RFSegmentViewDelegate
- (void)segmentViewSelectIndex:(NSInteger)index
{
    NSString *prefix = @"";
    switch (index) {
        case 0:
            prefix = @"+";
            break;
        case 1:
            prefix = @"-";
            break;
        default:
            break;
    }
    [self updateButtonsTitle:prefix];
}

#pragma mark - TurntableViewDelegate
- (void)turntableView:(TurntableView *)turntableView didChangeRotateDirection:(RotateDirection)direction
{
    if (direction != unknowDirection && !self.isRotating) {
        [self.bleControl.settingProfile slightAdjustmentTimeWithDirection:DIRECTION_clockwise start:NO completion:NULL];
        
        [self.bleControl.settingProfile slightAdjustmentTimeWithDirection:(ROTATE_DIRECTION)direction start:YES completion:NULL];
        NSLog(@"%@开始", direction==clockwise?@"顺时针":@"逆时针");
    }
}

- (void)turntableViewDidStopRotate:(TurntableView *)turntableView
{
    [self.bleControl.settingProfile slightAdjustmentTimeWithDirection:DIRECTION_clockwise start:NO completion:NULL];
    DEBUGLog(@"旋转结束");
}

@end
