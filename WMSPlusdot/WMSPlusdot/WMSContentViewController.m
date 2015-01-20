//
//  WMSContentViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-20.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSContentViewController.h"
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "WMSAppDelegate.h"
#import "WMSLeftViewController.h"
#import "WMSActivityRemindViewController.h"
#import "WMSBindingAccessoryViewController.h"
#import "WMSContent2ViewController.h"
#import "WMSSportHistoryViewController.h"
#import "WMSLoginViewController.h"
#import "WMSMyAccountViewController.h"
#import "UIViewController+Tip.h"
#import "UIViewController+Update.h"
#import "WMSUpdateVC.h"

#import "WMSSyncDataView.h"
#import "WMSMySportView.h"
#import "MBProgressHUD.h"

#import "WMSSportModel.h"
#import "WMSDeviceModel.h"
#import "WMSDeviceModel+Configure.h"
#import "WMSMyAccessory.h"
#import "WMSSportDatabase.h"
#import "WMSPersonModel.h"

#import "NSDate+Formatter.h"
#import "WMSAdaptiveMacro.h"
#import "WMSConstants.h"
#import "WMSUserInfoHelper.h"
#import "WMSHelper.h"
#import "WMSPostNotificationHelper.h"
#import "WMSHTTPRequest.h"

@interface WMSContentViewController ()
{
    //需本地化
    __weak IBOutlet UILabel *_labelTitle;
    __weak IBOutlet UILabel *_labelMySport;
    __weak IBOutlet UILabel *_labelStep;
    __weak IBOutlet UILabel *_labelStep2;
    __weak IBOutlet UILabel *_labelMuBiao;
    __weak IBOutlet UILabel *_labelRanShao;
    __weak IBOutlet UILabel *_labelJuli;
    __weak IBOutlet UILabel *_labelShiJian;
    __weak IBOutlet UILabel *_labelHour;
    __weak IBOutlet UILabel *_labelMinute;
}

@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet WMSMySportView *mySportView;

@property (strong, nonatomic) WMSSyncDataView *syncDataView;
@property (strong, nonatomic) UIView *tipView;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) NSDate *showDate;

@property (assign, nonatomic) BOOL isVisible;//是否可见（当前显示的是否是该控制器）
@property (assign, nonatomic) BOOL isNeedUpdate;//是否需要更新界面

@property (strong, nonatomic) WMSBleControl *bleControl;
@property (assign, nonatomic) BOOL isHasBeenSyncData;//标志是否已经同步过运动数据
@property (strong, nonatomic) NSMutableArray *everydaySportDataArray;
@end

@implementation WMSContentViewController
{
    NSUInteger _targetSteps;
    
    BOOL _isStartDFU;//是否准备升级了
    BOOL _postNotifyFlag;//发送本地通知的一个标志
}

#pragma mark - Getter
- (WMSSyncDataView *)syncDataView
{
    if (!_syncDataView) {
        _syncDataView = [[WMSSyncDataView alloc] initWithFrame:TipViewFrame];
        _syncDataView.backgroundColor = [UIColor clearColor];
        
        _syncDataView.labelTip.text = NSLocalizedString(@"智能手表已连接",nil);
        _syncDataView.labelTip.font = Font_DINCondensed(17.0);
        [_syncDataView setLabelEnergyFont:Font_DINCondensed(15.0)];
        
        UIImage *image = [UIImage imageNamed:@"zq_sync_btn.png"];
        CGRect frame = _syncDataView.imageView.frame;
        frame.size = CGSizeMake(image.size.width/2.0, image.size.height/2.0);
        _syncDataView.imageView.image = image;
        _syncDataView.imageView.frame = frame;

        [_syncDataView.buttonSync setTitle:NSLocalizedString(@"同步",nil) forState:UIControlStateNormal];
        [_syncDataView.buttonSync.titleLabel setFont:Font_DINCondensed(17.0)];
        [_syncDataView.buttonSync addTarget:self action:@selector(syncDataAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _syncDataView;
}
- (UIView *)tipView
{
    if (!_tipView) {
        _tipView = [[UIView alloc] initWithFrame:TipViewFrame];
        _tipView.backgroundColor = [UIColor clearColor];
        
        UILabel *labelTip = [[UILabel alloc] initWithFrame:CGRectMake(_tipView.bounds.size.width/2-100, (_tipView.bounds.size.height-30)/2, 150, 30)];
        labelTip.text = NSLocalizedString(@"正在连接您的手表", nil);
        labelTip.textAlignment = NSTextAlignmentRight;
        labelTip.textColor = [UIColor whiteColor];
        labelTip.font = Font_DINCondensed(17.0);
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(labelTip.frame.origin.x+labelTip.frame.size.width+15, (_tipView.bounds.size.height-37)/2, 37, 37)];
        [indicatorView startAnimating];
        
        [_tipView addSubview:labelTip];
        [_tipView addSubview:indicatorView];
    }
    return _tipView;
}
- (MBProgressHUD *)hud
{
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.labelText = NSLocalizedString(@"努力同步数据中...", nil);
        _hud.minSize = MBProgressHUD_MinSize;
    }
    return _hud;
}
- (UIImageView *)imageView
{
    if (!_imageView) {
        UIImage *image = [UIImage imageNamed:@"main_menu_target_icon_b.png"];
        CGSize size = CGSizeMake(image.size.width/2.0, image.size.height/2.0);
        CGRect rect = self.labelTargetSetps.frame;
        CGPoint origin = CGPointMake(rect.origin.x+13, rect.origin.y+(rect.size.height-size.height)/2-5);
        _imageView = [[UIImageView alloc] initWithFrame:(CGRect){origin,size}];
        _imageView.image = image;
    }
    return _imageView;
}

- (NSMutableArray *)everydaySportDataArray
{
    if (!_everydaySportDataArray) {
        _everydaySportDataArray = [NSMutableArray new];
    }
    return _everydaySportDataArray;
}

- (BOOL)isShowBindVC
{
    return ![WMSMyAccessory isBindAccessory];
}
//是否在绑定配件
- (BOOL)isBindingVC
{
    return ![WMSMyAccessory isBindAccessory];
}

#pragma mark - Setter
- (void)setSportStepsValue:(NSUInteger)steps
{
    //NSString *unit = NSLocalizedString(@"Step",nil);
    NSString *str = [NSString stringWithFormat:@"%u",steps];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = str.length;//-unit.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(55.0) range:NSMakeRange(loc, len)];
//    loc += len;
//    len = unit.length;
//    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    //[self.labelCurrentSteps setText:[NSString stringWithFormat:@"%u",steps]];
    [self.labelCurrentSteps setAttributedText:text];
    [self.labelCurrentSteps setAdjustsFontSizeToFitWidth:YES];
    [self.mySportView setSportSteps:(int)steps];
    
}
- (void)setTargetStepsValue:(NSUInteger)steps
{
    //NSString *describe = NSLocalizedString(@"Target",nil);
    NSString *value = [NSString stringWithFormat:@"%u",steps];
    //NSString *unit = NSLocalizedString(@"Step",nil);
    //NSString *str = [NSString stringWithFormat:@"%@: %@ %@",describe,value,unit];
    NSString *str = [NSString stringWithFormat:@"     %@",value];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
//    loc = 0;
//    len = describe.length;
//    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
//    loc += len;
//    len = @": ".length;
//    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc =0;//+= len;
    len = value.length;//+@" ".length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(25.0) range:NSMakeRange(loc, len)];
//    loc += len;
//    len = unit.length;
//    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    //[self.labelTargetSetps setText:[NSString stringWithFormat:@"%u",steps]];
    [self.labelTargetSetps setAttributedText:text];
    [self.labelTargetSetps setAdjustsFontSizeToFitWidth:YES];
    [self.mySportView setTargetSetps:(int)steps];
}
- (void)setSportTimeValue:(NSUInteger)minute
{
    NSString *hour = [NSString stringWithFormat:@"%u",minute/60];
    NSString *mu = [NSString stringWithFormat:@"%u",minute%60];
    NSString *hourLbl = NSLocalizedString(@"Hour",nil);
    NSString *muLbl = NSLocalizedString(@"Minutes",nil);
    if (minute/60 <= 0) {
        hour = @"";
        hourLbl = @"";
    }
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@",hour,hourLbl,mu,muLbl];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = hour.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(35.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = hourLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = mu.length;//+@" ".length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(35.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = muLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    //[self.labelTimeValue setText:[NSString stringWithFormat:@"%u",minute]];
    //[self.labelTimeValue setText:[NSString stringWithFormat:@"%@",hour]];
    //[self.labelTimeMinuteValue setText:[NSString stringWithFormat:@"%u",mu]];
    [self.labelTimeValue setAttributedText:text];
    [self.labelTimeValue setAdjustsFontSizeToFitWidth:YES];
}
- (void)setSportDistanceValue:(NSUInteger)distance
{
    NSString *unit = nil;
    //distance的单位是cm
    int dis_m = Rounded(distance/100.0);//单位为m
    NSUInteger value = 0;
    //distance<1000m,单位用m，>1000m,单位用km
    if (dis_m < 1000) {
        value = dis_m;
        unit = NSLocalizedString(@"米", nil);
    } else {
        value = dis_m + 5;
        NSUInteger gewei = value%10;
        value -= gewei;//对个位进行4舍5入
        value = Rounded(dis_m/1000.0);//单位为km
        unit = NSLocalizedString(@"公里", nil);
    }
    
    NSString *distanceLbl = [NSString stringWithFormat:@"%g",value*1.0];
    //NSString *unit = NSLocalizedString(@"距离单位",nil);
    NSString *str = [NSString stringWithFormat:@"%@%@",distanceLbl,unit];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = distanceLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(35.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = unit.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    [self.labelDistanceValue setAttributedText:text];
    [self.labelDistanceValue setAdjustsFontSizeToFitWidth:YES];
    //[self.labelDistanceValue setText:[NSString stringWithFormat:@"%g",distance/1000.0]];//km
}
- (void)setSportCalorieValue:(NSUInteger)calorie
{
    NSString *calorieLbl = [NSString stringWithFormat:@"%u",calorie];
    NSString *unit = NSLocalizedString(@"大卡",nil);
    NSString *str = [NSString stringWithFormat:@"%@%@",calorieLbl,unit];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = calorieLbl.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(35.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = unit.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    [self.labelBurnValue setAttributedText:text];
    [self.labelBurnValue setAdjustsFontSizeToFitWidth:YES];
    //[self.labelBurnValue setText:[NSString stringWithFormat:@"%u",calorie]];
}

- (void)setLabelShowDate:(NSDate *)date
{
    self.showDate = date;
    self.labelDate.text = [WMSHelper describeWithDate:date andFormart:DateFormat];
}

#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self registerForNotifications];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _targetSteps = [WMSHelper readTodayTargetSteps];
    
    [self.view addSubview:self.syncDataView];
    [self.view addSubview:self.tipView];
    [self.view addSubview:self.hud];
    [self.mySportView addSubview:self.imageView];
    [self setupControl];
    [self localizableView];
    [self adaptiveIphone4];
    
    //////////////////
    [self reloadView];
    [self checkAppUpdate];
    
    //
    [self bleOperation];
    if ([WMSMyAccessory isBindAccessory] == NO) {
        [self showTip:NSLocalizedString(TIP_NO_BINDING, nil)];
    } else {
        [self handleScanPeripheralFinish:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeDidChange:) name:NSSystemClockDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DEBUGLog(@"viewDidAppear %@",NSStringFromClass([self class]));
    self.navigationController.navigationBarHidden = YES;
    
    self.isVisible = YES;
    if (self.isNeedUpdate && self.bleControl.isConnected) {
        [self startSyncSportData];
    }
    self.isNeedUpdate = NO;
    
    //更新状态
    if ([WMSMyAccessory isBindAccessory] == NO) {
        [self showTipView:2];
    } else {
        //若已绑定手表
        if ([self.bleControl isConnected]) {
            [self showTipView:NO];
        } else {
            [self showTipView:YES];
        }
    }
    
    //更新目标步数
    NSUInteger newTarget = [self targetSteps];
    if (_targetSteps != newTarget) {
        _targetSteps = newTarget;
        if (NSDateModeToday == [NSDate compareDate:self.showDate]) {
            [self updateView];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"ContentViewController dealloc");
    
    [self unregisterFromNotifications];
}

#pragma mark - Methods
- (void)setupControl
{
    [self.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_a.png"] forState:UIControlStateNormal];
    [self.buttonLeft setBackgroundImage:[UIImage imageNamed:@"main_menu_icon_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonRight setTitle:@"" forState:UIControlStateNormal];
    [self.buttonRight setBackgroundImage:[UIImage imageNamed:@"main_setting_icon_a.png"] forState:UIControlStateNormal];
    [self.buttonRight setBackgroundImage:[UIImage imageNamed:@"main_setting_icon_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonPrev setTitle:@"" forState:UIControlStateNormal];
    [self.buttonPrev setBackgroundImage:[UIImage imageNamed:@"main_date_prev_a.png"] forState:UIControlStateNormal];
    [self.buttonPrev setBackgroundImage:[UIImage imageNamed:@"main_date_prev_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonNext setTitle:@"" forState:UIControlStateNormal];
    [self.buttonNext setBackgroundImage:[UIImage imageNamed:@"main_date_next_a.png"] forState:UIControlStateNormal];
    [self.buttonNext setBackgroundImage:[UIImage imageNamed:@"main_date_next_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonTarget setTitle:@"" forState:UIControlStateNormal];
    [self.buttonTarget setBackgroundImage:[UIImage imageNamed:@"main_target_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonTarget setBackgroundImage:[UIImage imageNamed:@"main_target_btn_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonHistory setTitle:@"" forState:UIControlStateNormal];
    [self.buttonHistory setBackgroundImage:[UIImage imageNamed:@"main_history_btn_a.png"] forState:UIControlStateNormal];
    [self.buttonHistory setBackgroundImage:[UIImage imageNamed:@"main_history_btn_b.png"] forState:UIControlStateHighlighted];
}

- (void)localizableView
{
    _labelTitle.text = NSLocalizedString(@"My sport", nil);
    _labelMySport.text = NSLocalizedString(@"当前步数",nil);
    _labelStep.text = NSLocalizedString(@"Step",nil);
    _labelStep2.text = NSLocalizedString(@"Step",nil);
    _labelMuBiao.text = NSLocalizedString(@"Target",nil);
    _labelRanShao.text = NSLocalizedString(@"Burn",nil);
    _labelJuli.text = NSLocalizedString(@"Distance",nil);
    _labelShiJian.text = NSLocalizedString(@"Time",nil);
    _labelHour.text = NSLocalizedString(@"Hour",nil);
    _labelMinute.text = NSLocalizedString(@"Minutes",nil);
}

- (void)adaptiveIphone4
{
    if (iPhone5) {
        return;
    }
    CGRect frame = self.dateView.frame;
    frame.origin.y -= DATE_VIEW_MOVE_HEIGHT;
    self.dateView.frame = frame;
    
    frame = self.syncDataView.frame;
    frame.origin.y -= TIP_VIEW_MOVE_HEIGHT;
    self.syncDataView.frame = frame;
    frame = self.tipView.frame;
    frame.origin.y -= TIP_VIEW_MOVE_HEIGHT;
    self.tipView.frame = frame;
    
    frame = self.mySportView.frame;
    frame.origin.y -= SPORT_SLEEP_VIEW_MOVE_HEIGHT;
    self.mySportView.frame = frame;
    
    frame = self.buttonTarget.frame;
    frame.origin.y -= BOTTOM_BUTTON_MOVE_HEIGHT;
    self.buttonTarget.frame = frame;
    frame = self.buttonHistory.frame;
    frame.origin.y -= BOTTOM_BUTTON_MOVE_HEIGHT;
    self.buttonHistory.frame = frame;
    
    frame = self.bottomView.frame;
    frame.origin.y -= BOTTOM_VIEW_MOVE_HEIGHT;
    self.bottomView.frame = frame;
    
    frame = self.labelBurnValue.frame;
    frame.origin.y -= BOTTOM_LABEL_MOVE_HEIGHT;
    self.labelBurnValue.frame = frame;
    frame = self.labelDistanceValue.frame;
    frame.origin.y -= BOTTOM_LABEL_MOVE_HEIGHT;
    self.labelDistanceValue.frame = frame;
    frame = self.labelTimeValue.frame;
    frame.origin.y -= BOTTOM_LABEL_MOVE_HEIGHT;
    self.labelTimeValue.frame = frame;
}

- (void)reloadView
{
    [self setLabelShowDate:[NSDate systemDate]];
    
    [self updateView];
    
    self.isHasBeenSyncData = NO;
}

- (void)checkAppUpdate
{
    [self checkUpdateWithAPPID:APP_ID completion:^(DetectResultValue isCanUpdate)
    {
        DEBUGLog(@"^^^^^%@----->%d[%p]",[self class],isCanUpdate,&isCanUpdate);
        if (isCanUpdate == DetectResultCanUpdate) {
            [self showUpdateAlertViewWithTitle:ALERTVIEW_TITLE message:ALERTVIEW_MESSAGE cancelButtonTitle:ALERTVIEW_CANCEL_TITLE okButtonTitle:ALERTVIEW_OK_TITLE];
        }
    }];
}

//是否显示TipView，0表示显示syncDataView，1表示显示tipView，2表示两者都不显示
- (void)showTipView:(int)show
{
    if (show == 0) {
        [self.syncDataView setHidden:NO];
        [self.tipView setHidden:YES];
    } else if(show == 1) {
        [self.syncDataView setHidden:YES];
        [self.tipView setHidden:NO];
    } else if(show == 2) {
        [self.syncDataView setHidden:YES];
        [self.tipView setHidden:YES];
    }
}

//更新界面上的数据
- (void)updateView
{
    WMSSportModel *model = nil;
    
    if (self.bleControl && [self.bleControl isConnected]) {
        //从数据库中查询数据
        NSArray *results = [[WMSSportDatabase sportDatabase] querySportData:self.showDate];
        if (results.count > 0) {
            model = results[0];
        }
    }
    
    if (model) {
        if (NSDateModeToday == [NSDate compareDate:self.showDate]) {
            [self setTargetStepsValue:_targetSteps];
        } else {
            [self setTargetStepsValue:model.targetSteps];
        }
        [self setSportStepsValue:model.sportSteps];
        [self setSportTimeValue:model.sportMinute];
        [self setSportDistanceValue:model.sportDistance];
        [self setSportCalorieValue:model.sportCalorie];
    } else {
        if (NSDateModeToday == [NSDate compareDate:self.showDate]) {
            [self setTargetStepsValue:_targetSteps];
        } else {
            [self setTargetStepsValue:DEFAULT_TARGET_STEPS];
        }
        [self setSportStepsValue:0];
        [self setSportTimeValue:0];
        [self setSportDistanceValue:0];
        [self setSportCalorieValue:0];
    }
}

//跳转到绑定界面，只调用一次
- (void)presentBindingVC
{
    static int callCount = 0;
    if (callCount >= 1) {
        return;
    }
    callCount++;
    
    //若为测试账号，不跳转到绑定界面
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(FILE_LOGIN_INFO)];
    NSString *userName = [readData objectForKey:@"userName"];
    NSString *password = [readData objectForKey:@"password"];
    if ([@"test" isEqualToString:userName] &&
        [@"123456" isEqualToString:password])
    {
        self.isShowBindVC = NO;
        [self scanAndConnectPeripheral];
        return;
    }
    
    
    if ([WMSMyAccessory isBindAccessory] == NO) {
        self.isShowBindVC = YES;
        WMSBindingAccessoryViewController *vc = [[WMSBindingAccessoryViewController alloc] init];
        [self presentViewController:vc animated:NO completion:nil];
    } else {
        self.isShowBindVC = NO;
        
        [self scanAndConnectPeripheral];
    }
}

- (void)presentPersonInfoVC
{
    static int callCount = 0;
    if (callCount >= 1) {
        return;
    }
    callCount++;
    
    WMSMyAccountViewController *vc = [[WMSMyAccountViewController alloc] init];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)presentLoginVC
{
    static int callCount = 0;
    if (callCount >= 1) {
        return;
    }
    callCount++;
    
    WMSLoginViewController *loginVC = [[WMSLoginViewController alloc] initWithNibName:@"WMSLoginViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    nav.navigationBarHidden = YES;
    [self presentViewController:nav animated:NO completion:nil];
}

- (NSUInteger)targetSteps
{
    WMSLeftViewController *leftVC = (WMSLeftViewController *)self.sideMenuViewController.leftMenuViewController;
    WMSContent2ViewController *setTargetVC = nil;
    for (UIViewController *vcObject in leftVC.contentVCArray) {
        if ([vcObject class] == [WMSContent2ViewController class]) {
            setTargetVC = (WMSContent2ViewController *)vcObject;
            break;
        }
    }
    NSUInteger targetSteps = ( setTargetVC ? setTargetVC.sportTargetSteps : [WMSHelper readTodayTargetSteps] );
    return targetSteps;
}

- (void)checkFirmwareUpdate
{
//    [WMSHTTPRequest detectionFirmwareUpdate:^(double newVersion, NSString *describe, NSString *strURL)
//     {
//         if ([WMSDeviceModel deviceModel].version < newVersion) {
//             [WMSHTTPRequest downloadFirmwareUpdateFileStrURL:strURL completion:^(BOOL success)
//              {
//                  //do something
//                  DEBUGLog(@"下载%@",success?@"成功":@"失败");
//              }];
//         }
//     }];
}

#pragma mark - Data
- (void)savaSportDate:(NSDate *)date steps:(NSUInteger)steps durations:(NSUInteger)durations perHourData:(UInt16 *)perHourData dataLength:(NSUInteger)dataLength
{
    WMSPersonModel *model = [WMSUserInfoHelper readPersonInfo];
    NSUInteger stride = model.stride;
    NSUInteger weight = model.currentWeight;
    NSUInteger distances = stride * steps;//单位为cm
    NSUInteger calorie = Rounded(Calorie(weight,steps));
    NSUInteger targetSteps = [self targetSteps];
    
    WMSSportModel *sportModel = [[WMSSportModel alloc] initWithSportDate:date sportTargetSteps:targetSteps sportSteps:steps sportMinute:durations sportDistance:distances sportCalorie:calorie perHourData:perHourData dataLength:dataLength];
    NSArray *results = [[WMSSportDatabase sportDatabase] querySportData:date];
    if (results && results.count>0) {//若数据库中已存在该日期的数据，则更新数据库
        [[WMSSportDatabase sportDatabase] updateSportData:sportModel];
    } else {
        [[WMSSportDatabase sportDatabase] insertSportData:sportModel];
    }
    
    [self.everydaySportDataArray addObject:sportModel];
}


#pragma mark - Action
- (IBAction)showLeftViewAction:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}
- (IBAction)showRightViewAction:(id)sender {
    [self.sideMenuViewController presentRightMenuViewController];
}

- (IBAction)prevDateAction:(id)sender {
    NSDate *date = [NSDate dateWithTimeInterval:OneDayTimeInterval*-1.0 sinceDate:self.showDate];
    [self setLabelShowDate:date];
    
    [self updateView];
}
- (IBAction)nextDateAction:(id)sender {
    if (NSDateModeToday == [NSDate compareDate:self.showDate]) {
        return;
    }
    NSDate *date = [NSDate dateWithTimeInterval:OneDayTimeInterval sinceDate:self.showDate];
    [self setLabelShowDate:date];
    
    [self updateView];
}

- (IBAction)gotoMyTargetViewAction:(id)sender {
    WMSActivityRemindViewController *VC = [[WMSActivityRemindViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)gotoMyHistoryViewAction:(id)sender {
    WMSSportHistoryViewController *historyVC = [[WMSSportHistoryViewController alloc] initWithNibName:@"WMSSportHistoryViewController" bundle:nil];
    historyVC.showDate = self.showDate;
    [self.navigationController pushViewController:historyVC animated:YES];
}

- (void)syncDataAction:(id)sender {
    if (![self.bleControl isConnected]) {
        return;
    }
    
    [self startSyncSportData];
}

#pragma mark - 收发数据
- (void)connectedOperation
{
    if (![WMSMyAccessory isBindAccessory]) {
        return ;
    }
    [WMSDeviceModel setDeviceDate:self.bleControl completion:^{
        [WMSDeviceModel readDevicedetailInfo:self.bleControl completion:^(NSUInteger energy, NSUInteger version, DeviceWorkStatus workStatus, NSUInteger deviceID, BOOL isPaired) {
            if (!isPaired) {
                [self.bleControl bindSettingCMD:BindSettingCMDMandatoryBind completion:^(BOOL success) {}];
            }
        }];
    }];
}
//- (void)readDeviceInfo
//{
//    [self.bleControl.deviceProfile readDeviceInfoWithCompletion:^(NSUInteger batteryEnergy, NSUInteger version, NSUInteger todaySteps, NSUInteger todaySportDurations, NSUInteger endSleepMinute, NSUInteger endSleepHour, NSUInteger sleepDurations, DeviceWorkStatus workStatus, BOOL success)
//     {
//         DEBUGLog(@"电池电量：%d",batteryEnergy);
//         //batteryEnergy = 100;
//         [self.syncDataView setEnergy:batteryEnergy];
//         [WMSDeviceModel deviceModel].batteryEnergy = batteryEnergy;
//         [WMSDeviceModel deviceModel].version = version;
//         [self checkFirmwareUpdate];
//     }];
//}

- (void)startSyncSportData
{
    self.isHasBeenSyncData = YES;
    [self.syncDataView startAnimating];
    [self.hud show:YES];
    
    [self.bleControl.deviceProfile syncDeviceSportDataWithCompletion:^(NSString *sportdate, NSUInteger todaySteps, NSUInteger todaySportDurations, NSUInteger surplusDays, UInt16 *PerHourData, NSUInteger dataLength)
     {
         DEBUGLog(@"====>date:%@,steps:%d,durations:%d,surplusDays:%d",sportdate,todaySteps,todaySportDurations,surplusDays);
//         DEBUGLog(@"====>Per Hour Data:");
//         printf("\t\t{");
//         for (int i=0; i<dataLength; i++) {
//             printf("%d ",PerHourData[i]);
//         }
//         printf("}\n");
         
         //保存数据
         [self savaSportDate:[NSDate dateFromString:sportdate format:@"yyyy-MM-dd"] steps:todaySteps durations:todaySportDurations perHourData:PerHourData dataLength:dataLength];
         
         if (surplusDays <= 1) {//同步完成
             [self stopSyncSportData];
             return ;
         }
         
         [self continueSyncSportData];
     }];
}
- (void)continueSyncSportData
{
    [self.bleControl.deviceProfile syncDeviceSportDataWithCompletion:^(NSString *sportdate, NSUInteger todaySteps, NSUInteger todaySportDurations, NSUInteger surplusDays, UInt16 *PerHourData, NSUInteger dataLength)
     {
         DEBUGLog(@"====>date:%@,steps:%d,durations:%d,surplusDays:%d",sportdate,todaySteps,todaySportDurations,surplusDays);
//         DEBUGLog(@"====>Per Hour Data:");
//         printf("\t\t{");
//         for (int i=0; i<dataLength; i++) {
//             printf("%d ",PerHourData[i]);
//         }
//         printf("}\n");
         
         
         NSDate *date = [NSDate dateFromString:sportdate format:@"yyyy-MM-dd"];
         //保存数据
         [self savaSportDate:date steps:todaySteps durations:todaySportDurations perHourData:PerHourData dataLength:dataLength];
         
         if (surplusDays <= 1) {//同步完成
             [self stopSyncSportData];
             return ;
         }
         
         [self continueSyncSportData];
     }];
}

- (void)stopSyncSportData
{
    [self.syncDataView stopAnimating];
    [self.hud hide:YES afterDelay:0];
    
    [self setLabelShowDate:[NSDate systemDate]];
    [self updateView];
}

#pragma mark - 蓝牙操作
- (void)bleOperation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidDisConnectPeripheral:) name:WMSBleControlPeripheralDidDisConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedConnectPeripheral:) name:WMSBleControlPeripheralConnectFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScanPeripheralFinish:) name:WMSBleControlScanFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUpdatedBLEState:) name:WMSBleControlBluetoothStateUpdated object:nil];
    
    self.bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
}

- (void)scanAndConnectPeripheral
{
    switch ([self.bleControl bleState]) {
        case WMSBleStateResetting:
        case WMSBleStatePoweredOff:
            return;
        default:
            break;
    }
    if ([self.bleControl isConnecting] ||
        [self.bleControl isConnected])
    {
        return ;
    }
    if (_isStartDFU==YES) {
        return ;
    }
    
    DEBUGLog(@"》》Scanning %@",NSStringFromClass([self class]));
    [self.bleControl scanForPeripheralsByInterval:SCAN_PERIPHERAL_INTERVAL
                                       completion:^(NSArray *peripherals)
     {
         if ([self.bleControl isConnecting]) {
             return ;
         }
         LGPeripheral *p = [peripherals lastObject];
         if ([WMSMyAccessory isBindAccessory]) {
             NSString *uuid = [WMSMyAccessory identifierForbindAccessory];
//             BOOL flag = [p.cbPeripheral.name isEqualToString:WATCH_NAME] ||
//                         [p.cbPeripheral.name isEqualToString:WATCH_NAME2];
             if (/*flag && */[p.UUIDString isEqualToString:uuid])
             {
                 [self.bleControl connect:p];
             }
         }
     }];
}

//Handle
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"蓝牙连接成功 %@",NSStringFromClass([self class]));
    
    [self connectedOperation];
    
    [self showTipView:NO];
    //若该视图控制器不可见，则不同步数据，等到该界面显示时同步
    if (self.isVisible) {
        [self startSyncSportData];
        self.isNeedUpdate = NO;
    } else {
        self.isNeedUpdate = YES;
    }
    
    [WMSPostNotificationHelper cancelAllNotification];
    _postNotifyFlag = YES;
}
- (void)handleDidDisConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"连接断开 %@",NSStringFromClass([self class]));
    
    [[WMSDeviceModel deviceModel] resetDevice];
    
    [self showTipView:YES];
    [self.hud hide:YES afterDelay:0];
    [self.syncDataView stopAnimating];
    //若在进行绑定配件（没有绑定配件），则不进行扫描连接操作
    if ([self isBindingVC] == NO)
    {
        [self scanAndConnectPeripheral];
    }
    
    if (_postNotifyFlag) {
        [WMSPostNotificationHelper postNotifyWithAlartBody:NSLocalizedString(@"蓝牙连接已断开", nil)];
        _postNotifyFlag = NO;
    }
}
- (void)handleFailedConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"连接失败 %@",NSStringFromClass([self class]));
    
    [self showTipView:YES];
    [self.hud hide:YES afterDelay:0];
    [self.syncDataView stopAnimating];
    //若在进行绑定配件（没有绑定配件），则不进行扫描连接操作
    if ([self isBindingVC] == NO)
    {
        [self scanAndConnectPeripheral];
    }
}
- (void)handleScanPeripheralFinish:(NSNotification *)notification
{
    DEBUGLog(@"扫描结束 %@, isConnecting:%d, isConnected:%d",NSStringFromClass([self class]),self.bleControl.isConnecting, self.bleControl.isConnected);
    
    if ([self isBindingVC] == NO) {
        [self scanAndConnectPeripheral];
    }
}

- (void)handleUpdatedBLEState:(NSNotification *)notification
{
    DEBUGLog(@"%@ %s",self.class,__FUNCTION__);
    switch ([self.bleControl bleState]) {
        case WMSBleStateResetting:
        case WMSBleStatePoweredOff:
        {
            if ([WMSMyAccessory isBindAccessory]) {
                [self showTipView:YES];
            } else {
                [self showTipView:2];
            }
            [self.hud hide:YES afterDelay:0];
            [self.syncDataView stopAnimating];
            break;
        }
        case WMSBleStatePoweredOn:
            [self handleScanPeripheralFinish:nil];
            break;
        default:
            break;
    }
}


#pragma mark -  Notifications
- (void)registerForNotifications
{
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralDidStartDFU:) name:WMSUpdateVCStartDFU object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peripheralDidEndDFU:) name:WMSUpdateVCEndDFU object:nil];
}
- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)appWillResignActive:(NSNotification *)notification
{
    [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    [self setAlertView:nil];
}
- (void)appDidBecomeActive:(NSNotification *)notification
{
    if ([self.bleControl isConnected] == NO) {
        [self handleScanPeripheralFinish:nil];
    }
    
    [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    [self setAlertView:nil];
    switch (self.bleControl.bleState) {
        case WMSBleStateUnsupported:
        {
            _alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"您的设备不支持BLE4.0",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",nil) otherButtonTitles:nil];
            [_alertView show];
            break;
        }
        case WMSBleStatePoweredOff:
        {
            _alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"您的蓝牙已关闭，请在“设置-蓝牙”中将其打开",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",nil) otherButtonTitles:nil];
            [_alertView show];
            break;
        }
        default:
            break;
    }
}

- (void)peripheralDidStartDFU:(NSNotification *)notification
{
    _isStartDFU = YES;
}
- (void)peripheralDidEndDFU:(NSNotification *)notification
{
    _isStartDFU = NO;
    
    //唤醒扫描
    [self scanAndConnectPeripheral];
}

- (void)timeDidChange:(NSNotification *)notification
{
    DEBUGLog(@"%s",__FUNCTION__);
}

@end
