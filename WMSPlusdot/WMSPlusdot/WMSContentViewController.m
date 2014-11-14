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

#import "WMSSyncDataView.h"
#import "WMSMySportView.h"
#import "MBProgressHUD.h"

#import "WMSSportModel.h"
#import "WMSDeviceModel.h"
#import "WMSMyAccessory.h"
#import "WMSSportDatabase.h"
#import "WMSPersonModel.h"

#import "NSDate+Formatter.h"
#import "WMSAdaptiveMacro.h"
#import "WMSConstants.h"
#import "WMSUserInfoHelper.h"

#define TARGET_STEPS    20000

@interface WMSContentViewController ()
{
    //需本地化
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

@property (strong, nonatomic) NSDate *showDate;

@property (strong, nonatomic) WMSBleControl *bleControl;
@property (assign, nonatomic) BOOL isHasBeenSyncData;//标志是否已经同步过运动数据
@property (strong, nonatomic) NSMutableArray *everydaySportDataArray;
@end

@implementation WMSContentViewController

#pragma mark - Getter
- (WMSSyncDataView *)syncDataView
{
    if (!_syncDataView) {
        _syncDataView = [[WMSSyncDataView alloc] initWithFrame:TipViewFrame];
        _syncDataView.backgroundColor = [UIColor clearColor];
        
        _syncDataView.labelTip.text = NSLocalizedString(@"智能手表已连接",nil);
        _syncDataView.labelTip.font = Font_DINCondensed(17.0);
        
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

#pragma mark - Setter
- (void)setSportStepsValue:(NSUInteger)steps
{
    NSString *unit = NSLocalizedString(@"Step",nil);
    NSString *str = [NSString stringWithFormat:@"%u%@",steps,unit];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = str.length-unit.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(45.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = unit.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    //[self.labelCurrentSteps setText:[NSString stringWithFormat:@"%u",steps]];
    [self.labelCurrentSteps setAttributedText:text];
    [self.labelCurrentSteps setAdjustsFontSizeToFitWidth:YES];
    [self.mySportView setSportSteps:steps];
    
}
- (void)setTargetStepsValue:(NSUInteger)steps
{
    NSString *describe = NSLocalizedString(@"Target",nil);
    NSString *value = [NSString stringWithFormat:@"%u",steps];
    NSString *unit = NSLocalizedString(@"Step",nil);
    NSString *str = [NSString stringWithFormat:@"%@: %@ %@",describe,value,unit];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = describe.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = @": ".length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = value.length+@" ".length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(25.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = unit.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    //[self.labelTargetSetps setText:[NSString stringWithFormat:@"%u",steps]];
    [self.labelTargetSetps setAttributedText:text];
    [self.labelTargetSetps setAdjustsFontSizeToFitWidth:YES];
    [self.mySportView setTargetSetps:(int)steps];
}
- (void)setSportTimeValue:(NSUInteger)minute
{
    NSString *hour = [NSString stringWithFormat:@"%lu",minute/60];
    NSString *mu = [NSString stringWithFormat:@"%lu",minute%60];
    NSString *hourLbl = NSLocalizedString(@"Hour",nil);
    NSString *muLbl = NSLocalizedString(@"Minutes",nil);
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
    //distance的单位是cm
    int dis_m = Rounded(distance/100.0);//单位为m
    dis_m += 5;
    NSUInteger gewei = dis_m%10;
    dis_m -= gewei;//对个位进行4舍5入
    
    NSString *distanceLbl = [NSString stringWithFormat:@"%g",dis_m/1000.0];
    NSString *unit = NSLocalizedString(@"距离单位",nil);
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
    NSString *unit = NSLocalizedString(@"热量单位",nil);
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

#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view addSubview:self.syncDataView];
    [self.view addSubview:self.tipView];
    [self.view addSubview:self.hud];
    
    [self setupControl];
    [self localizableView];
    [self adaptiveIphone4];
    [self reloadView];
    
    //
    [self bleOperation];
    //[self appWillEnterForeground:nil];
    if ([WMSMyAccessory isBindAccessory] == NO) {
        [self showTip:NSLocalizedString(TIP_NO_BINDING, nil)];
    } else {
        [self handleScanPeripheralFinish:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DEBUGLog(@"viewDidAppear %@",NSStringFromClass([self class]));
    self.navigationController.navigationBarHidden = YES;
    
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
//?????
    if (self.isShowBindVC) {
        return;
    }
    if (self.isHasBeenSyncData == NO) {
        [self.bleControl.settingProfile setCurrentDate:[NSDate date] completion:^(BOOL success)
        {
            [self startSyncSportData];
        }];
    }
    
    //更新电池电量
    [self readDeviceInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"ContentViewController dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    _labelMySport.text = NSLocalizedString(@"My sports",nil);
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
    self.showDate = [NSDate systemDate];
    self.labelDate.text = [self stringWithDate:self.showDate andFormart:DateFormat];
    
    [self setTargetStepsValue:TARGET_STEPS];
    [self setSportStepsValue:0];
    [self setSportTimeValue:0];
    [self setSportDistanceValue:0];
    [self setSportCalorieValue:0];
    
    self.isHasBeenSyncData = NO;
}

- (NSString *)stringWithDate:(NSDate *)date andFormart:(NSString *)formart
{
    switch ([NSDate compareDate:date]) {
        case NSDateModeToday:
            return NSLocalizedString(@"Today",nil);
        case NSDateModeYesterday:
            return NSLocalizedString(@"Yesterday",nil);
        case NSDateModeTomorrow:
            return NSLocalizedString(@"Today",nil);
        case NSDateModeUnknown:
            return [NSDate stringFromDate:date format:formart];
        default:
            return nil;
    }
    return nil;
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
    //    DEBUGLog(@"sportDataArray:%@",self.everydaySportDataArray);
    
    WMSSportModel *sportModel = nil;
//    for (WMSSportModel *model in self.everydaySportDataArray) {
//        if ([NSDate daysOfDuringDate:self.showDate andDate:model.sportDate] == 0)
//        {
//            DEBUGLog(@"两个日期是同一天");
//            sportModel = model;
//            break;
//        }
//    }
    
    //从数据库中查询数据
    NSArray *results = [[WMSSportDatabase sportDatabase] querySportData:self.showDate];
    if (results.count > 0) {
        sportModel = results[0];
    }
    
    if (sportModel) {
        [self setTargetStepsValue:sportModel.targetSteps];
        [self setSportStepsValue:sportModel.sportSteps];
        [self setSportTimeValue:sportModel.sportMinute];
        [self setSportDistanceValue:sportModel.sportDistance];
        [self setSportCalorieValue:sportModel.sportCalorie];
    } else {
        [self setTargetStepsValue:TARGET_STEPS];
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
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(UserInfoFile)];
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


#pragma mark - Data
- (void)savaSportDate:(NSDate *)date steps:(NSUInteger)steps durations:(NSUInteger)durations perHourData:(UInt16 *)perHourData dataLength:(NSUInteger)dataLength
{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSUInteger stride = [userDefaults integerForKey:@"stride"];
//    NSUInteger weight = [userDefaults integerForKey:@"currentWeight"];
    WMSPersonModel *model = [WMSUserInfoHelper readPersonInfo];
    NSUInteger stride = model.stride;
    NSUInteger weight = model.currentWeight;
    NSUInteger distances = stride * steps;//单位为cm
    NSUInteger calorie = Rounded(Calorie(weight,steps));
    //DEBUGLog(@"sava sportDate:%@",date);
    
    ////获得目标步数
    WMSLeftViewController *leftVC = (WMSLeftViewController *)self.sideMenuViewController.leftMenuViewController;
    WMSContent2ViewController *setTargetVC = nil;
    //DEBUGLog(@"leftVC.contentVCArray:%@",leftVC.contentVCArray);
    for (UIViewController *vcObject in leftVC.contentVCArray) {
        if ([vcObject class] == [WMSContent2ViewController class]) {
            setTargetVC = (WMSContent2ViewController *)vcObject;
            break;
        }
    }
    NSUInteger targetSteps = (setTargetVC ? setTargetVC.sportTargetSteps : TARGET_STEPS);
    
    WMSSportModel *sportModel = [[WMSSportModel alloc] initWithSportDate:date sportTargetSteps:targetSteps sportSteps:steps sportMinute:durations sportDistance:distances sportCalorie:calorie perHourData:perHourData dataLength:dataLength];
    
    NSArray *results = [[WMSSportDatabase sportDatabase] querySportData:date];
    DEBUGLog(@"query results:");
    for (WMSSportModel *obj in results) {
        DEBUGLog(@"\t\t\t %@",[obj.sportDate.description substringToIndex:10]);
    }
    
    if (results && results.count>0) {//若数据库中已存在该日期的数据，则更新数据库
        [[WMSSportDatabase sportDatabase] updateSportData:sportModel];
    } else {
        [[WMSSportDatabase sportDatabase] insertSportData:sportModel];
    }
    
    
    [self.everydaySportDataArray addObject:sportModel];
}

#pragma mark - 数据库
- (void)dataBase
{
    
}

#pragma mark - Action
- (IBAction)showLeftViewAction:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];

}
- (IBAction)showRightViewAction:(id)sender {
    [self.sideMenuViewController presentRightMenuViewController];
}

- (IBAction)prevDateAction:(id)sender {
    self.showDate = [NSDate dateWithTimeInterval:OneDayTimeInterval*-1.0 sinceDate:self.showDate];
    //DEBUGLog(@"newDate:%@,%f,%f",[newDate description],[self.showDate timeIntervalSinceNow],OneDayTimeInterval*-1.0);
    
    self.labelDate.text = [self stringWithDate:self.showDate andFormart:DateFormat];
    
    [self updateView];
}

- (IBAction)nextDateAction:(id)sender {
    if (NSDateModeToday == [NSDate compareDate:self.showDate]) {
        return;
    }
    self.showDate = [NSDate dateWithTimeInterval:OneDayTimeInterval sinceDate:self.showDate];
    self.labelDate.text = [self stringWithDate:self.showDate andFormart:DateFormat];
    
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
    //设置时间，读取设备信息，同步运动数据
    [self showTipView:NO];
    [self.bleControl.settingProfile setCurrentDate:[NSDate date] completion:^(BOOL success)
     {
         DEBUGLog(@"设置系统时间%@",success?@"成功":@"失败");
         [self readDeviceInfo];
         
         [self startSyncSportData];
     }];
}

- (void)readDeviceInfo
{
    [self.bleControl.deviceProfile readDeviceInfoWithCompletion:^(NSUInteger batteryEnergy, NSUInteger version, NSUInteger todaySteps, NSUInteger todaySportDurations, NSUInteger endSleepMinute, NSUInteger endSleepHour, NSUInteger sleepDurations, DeviceWorkStatus workStatus, BOOL success)
     {
         DEBUGLog(@"电池电量：%d",batteryEnergy);
         [WMSDeviceModel deviceModel].batteryEnergy = batteryEnergy;
         [self.syncDataView setCellElectricQuantity:batteryEnergy];
     }];
}

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
//         DEBUGLog(@"====>date:%@,steps:%d,durations:%d,surplusDays:%d",sportdate,todaySteps,todaySportDurations,surplusDays);
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
    //[self.hud setLabelText:NSLocalizedString(@"同步完成", nil)];
    [self.hud hide:YES afterDelay:0];
    
    [self updateView];
}

#pragma mark - 蓝牙操作
- (void)bleOperation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidDisConnectPeripheral:) name:WMSBleControlPeripheralDidDisConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedConnectPeripheral:) name:WMSBleControlPeripheralConnectFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScanPeripheralFinish:) name:WMSBleControlScanFinish object:nil];
    
    self.bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
}

- (void)scanAndConnectPeripheral
{
    DEBUGLog(@"》》Scanning %@",NSStringFromClass([self class]));
    [self.bleControl scanForPeripheralsByInterval:SCAN_PERIPHERAL_INTERVAL
                                       completion:^(NSArray *peripherals)
     {
         //DEBUGLog(@"scaned Peripheral:%@",[[[peripherals lastObject] cbPeripheral] identifier]);
         if ([self.bleControl isConnecting]) {
             return ;
         }
         LGPeripheral *p = [peripherals lastObject];
         if ([WMSMyAccessory isBindAccessory]) {
             if  (p &&
                 [p.cbPeripheral.name isEqualToString:WATCH_NAME] &&
                 [p.UUIDString isEqualToString:[WMSMyAccessory identifierForbindAccessory]])
             {
                 [self.bleControl connect:p];
             }
         }
//         else if (p && [p.cbPeripheral.name isEqualToString:WATCH_NAME]) {
//             [self.bleControl connect:p];
//         }
     }];
}

//Handle
- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"蓝牙连接成功 %@",NSStringFromClass([self class]));
    
    if (self.isShowBindVC) {//若在绑定配件，连接成功，该VC不做任何操作(下同)
        return;
    }
    DEBUGLog(@"操作。。。。。");
    [self connectedOperation];
}
- (void)handleDidDisConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"连接断开 %@",NSStringFromClass([self class]));
    
    if (self.isShowBindVC) {
        return;
    }
    [self showTipView:YES];
    [self.hud hide:YES afterDelay:0];
    [self.syncDataView stopAnimating];
    
    [self scanAndConnectPeripheral];
}
- (void)handleFailedConnectPeripheral:(NSNotification *)notification
{
    DEBUGLog(@"连接失败 %@",NSStringFromClass([self class]));
    
    if (self.isShowBindVC) {
        return;
    }
    [self showTipView:YES];
    [self.hud hide:YES afterDelay:0];
    [self.syncDataView stopAnimating];
    
    [self scanAndConnectPeripheral];
}

- (void)handleScanPeripheralFinish:(NSNotification *)notification
{
    DEBUGLog(@"扫描结束 %@, isConnecting:%d, isConnected:%d",NSStringFromClass([self class]),self.bleControl.isConnecting, self.bleControl.isConnected);
    if ([self.bleControl isConnecting] || [self.bleControl isConnected]) {
        DEBUGLog(@"handleScanPeripheralFinish return");
        return ;
    }
    
    if (self.isShowBindVC) {
        return;
    }
    [self showTipView:YES];
    [self scanAndConnectPeripheral];
}


#pragma mark -  Notification
- (void)appWillEnterForeground:(NSNotification *)notification
{
//    switch (self.bleControl.bleState) {
//        case BleStatePoweredOff:
//        {
//            if (self.isShowBindVC) {
//                return;
//            }
//            [self showTipView:YES];
//            [self.hud hide:YES afterDelay:0];
//            [self.syncDataView stopAnimating];
//            break;
//        }
//            
//        default:
//            break;
//    }
    if ([self.bleControl isConnected] == NO) {
//        if (self.isShowBindVC) {
//            return;
//        }
//        [self showTipView:YES];
//        [self.hud hide:YES afterDelay:0];
//        [self.syncDataView stopAnimating];
        
        [self handleScanPeripheralFinish:nil];
    } else {
        
    }
    
    
    [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    self.alertView = nil;
    switch (self.bleControl.bleState) {
        case BleStateUnsupported:
        {
            _alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"您的设备不支持BLE4.0",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",nil) otherButtonTitles:nil];
            [_alertView show];
            break;
        }
        case BleStatePoweredOff:
        {
            _alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"您的蓝牙已关闭，请在“设置-蓝牙”中将其打开",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",nil) otherButtonTitles:nil];
            [_alertView show];
            break;
        }
        default:
            break;
    }
}

@end
