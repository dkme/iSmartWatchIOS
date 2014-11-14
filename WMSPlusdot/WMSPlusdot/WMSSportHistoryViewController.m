//
//  WMSSportHistoryViewController.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-26.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSportHistoryViewController.h"
#import "WMSContent2ViewController.h"

#import "WMSNavBarView.h"
#import "PNLineChartView.h"
#import "PNPlot.h"
#import "PNBarChartView.h"
#import "PNBar.h"

#import "WMSSportDatabase.h"
#import "WMSSportModel.h"
#import "WMSPersonModel.h"

#import "WMSAdaptiveMacro.h"
#import "NSDate+Formatter.h"
#import "WMSConstants.h"
#import "WMSHistoryVCHelper.h"
#import "WMSUserInfoHelper.h"

#define X_COORDINATE_NUMBER         24

#define Y_MAX_DEFAULT   10000

#define TAG_BOTTOM_LABEL_STEPS      1000
#define TAG_BOTTOM_LABEL_CALORIE    1001
#define TAG_BOTTOM_LABEL_DISTANCE   1002

#define OneDayTimeInterval    (24*60*60)
#define DateFormat            @"yyyy/MM/dd"

@interface WMSSportHistoryViewController ()<PNBarChartViewDelegate>
{
    __weak IBOutlet UILabel *_labelStep;
}

@property (nonatomic, strong) PNPlot *plot;
@property (nonatomic, strong) PNBarChartView *barChartView;
@property (nonatomic, strong) PNBar *pnBar;
@property (nonatomic, strong) WMSSportDatabase *dataBase;
@property (nonatomic, strong) NSDate *earliestDate;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation WMSSportHistoryViewController

#pragma mark - Getter/Setter
- (PNPlot *)plot
{
    if (!_plot) {
        _plot = [[PNPlot alloc] init];
        _plot.lineColor = [UIColor whiteColor];
        _plot.lineWidth = 1.5;
    }
    return _plot;
}

- (PNBarChartView *)barChartView
{
    if (!_barChartView) {
        CGFloat originY = _navBarView.frame.origin.y+_navBarView.frame.size.height+10;
        CGRect frame = CGRectMake(0, originY, ScreenWidth, 320);
        _barChartView = [[PNBarChartView alloc] initWithFrame:frame];
    }
    return _barChartView;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        CGFloat originY = _barChartView.frame.origin.y+_barChartView.frame.size.height;
        CGRect viewFrame = CGRectMake(0, originY, ScreenWidth, ScreenHeight-originY);
        _bottomView = [[UIView alloc] initWithFrame:viewFrame];
        _bottomView.backgroundColor = [UIColor clearColor];
        
        CGRect labelFrame = CGRectMake(0, (viewFrame.size.height-40)/2.0-70, ScreenWidth, 40);
        UILabel *labelSteps = [[UILabel alloc] initWithFrame:labelFrame];
        labelSteps.textColor = [UIColor darkGrayColor];
        labelSteps.textAlignment = NSTextAlignmentCenter;
        labelSteps.tag = TAG_BOTTOM_LABEL_STEPS;
        
        CGRect labelCalorieFrame = CGRectZero;
        labelCalorieFrame.origin = CGPointMake(40, labelFrame.origin.y+labelFrame.size.height+0);
        labelCalorieFrame.size = CGSizeMake(ScreenWidth-labelCalorieFrame.origin.x, 35);
        UILabel *labelCalorie = [[UILabel alloc] initWithFrame:labelCalorieFrame];
        labelCalorie.textColor = [UIColor darkGrayColor];
        labelCalorie.textAlignment = NSTextAlignmentLeft;
        labelCalorie.tag = TAG_BOTTOM_LABEL_CALORIE;
        
        CGRect labelDistanceFrame = CGRectZero;
        labelDistanceFrame.origin = CGPointMake(labelCalorieFrame.origin.x, labelCalorieFrame.origin.y+labelCalorieFrame.size.height+25);
        labelDistanceFrame.size = CGSizeMake(ScreenWidth-labelDistanceFrame.origin.x, 35);
        UILabel *labelDistance = [[UILabel alloc] initWithFrame:labelDistanceFrame];
        labelDistance.textColor = [UIColor darkGrayColor];
        labelDistance.textAlignment = NSTextAlignmentLeft;
        labelDistance.tag = TAG_BOTTOM_LABEL_DISTANCE;
        
        [_bottomView addSubview:labelSteps];
        [_bottomView addSubview:labelCalorie];
        [_bottomView addSubview:labelDistance];
    }
    return _bottomView;
}

- (void)setBottomLabelSteps:(NSUInteger)steps
{
    NSString *stepStr = [NSString stringWithFormat:@"%u",steps];
    NSString *describe = NSLocalizedString(@"本月累计步数", nil);
    NSString *unit = NSLocalizedString(@"步", nil);
    NSString *str = [NSString stringWithFormat:@"%@%@%@",describe,stepStr,unit];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = describe.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = stepStr.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(35.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = unit.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    UILabel *label = (UILabel *)[self.bottomView viewWithTag:TAG_BOTTOM_LABEL_STEPS];
    label.attributedText = text;
    label.adjustsFontSizeToFitWidth = YES;
}
- (void)setBottomLabelCalorie:(NSUInteger)calorie
{
    NSString *calorieStr = [NSString stringWithFormat:@"%u",calorie];
    NSString *describe = NSLocalizedString(@"累计消耗", nil);
    NSString *unit = NSLocalizedString(@"卡路里", nil);
    NSString *str = [NSString stringWithFormat:@"%@%@%@",describe,calorieStr,unit];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = describe.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = calorieStr.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(35.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = unit.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    UILabel *label = (UILabel *)[self.bottomView viewWithTag:TAG_BOTTOM_LABEL_CALORIE];
    label.attributedText = text;
    label.adjustsFontSizeToFitWidth = YES;
}
- (void)setBottomLabelDistance:(NSUInteger)distance
{
    NSUInteger dis = Rounded(distance/100.0/1000.0);
    NSString *distanceStr = [NSString stringWithFormat:@"%u",dis];
    NSString *describe = NSLocalizedString(@"累计里程", nil);
    NSString *unit = NSLocalizedString(@"公里", nil);
    NSString *str = [NSString stringWithFormat:@"%@%@%@",describe,distanceStr,unit];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    NSUInteger loc,len;
    loc = 0;
    len = describe.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = distanceStr.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(35.0) range:NSMakeRange(loc, len)];
    loc += len;
    len = unit.length;
    [text addAttribute:NSFontAttributeName value:Font_DINCondensed(17.0) range:NSMakeRange(loc, len)];
    
    UILabel *label = (UILabel *)[self.bottomView viewWithTag:TAG_BOTTOM_LABEL_DISTANCE];
    label.attributedText = text;
    label.adjustsFontSizeToFitWidth = YES;
}

- (void)setLabelDateText:(NSDate *)date
{
    self.showDate = date;
    
    self.labelDate.text = [self stringWithDate:date andFormart:DateFormat];
}

- (void)setLabelOnedayStepsValue:(WMSSportModel *)model
{
    float percent = 0;
    int steps = 0;
    if (model) {
        percent = model.sportSteps*1.0/model.targetSteps;
        steps = (int)model.sportSteps;
    }
    
    self.labelOnedaySteps.text = [NSString stringWithFormat:@"%d",steps];
    self.labelDescribe.text = [NSString stringWithFormat:@"%@%.0f%%",NSLocalizedString(@"完成目标的",nil),percent*100];
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
    
//    CGRect frame = self.chartView.frame;
//    frame.origin.y -= 60;
//    self.chartView.frame = frame;
    self.dataBase = [WMSSportDatabase sportDatabase];
    self.earliestDate = [self.dataBase queryEarliestDate];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.barChartView];
    [self.view addSubview:self.bottomView];
    
    [self initNavBarView];
    //[self initChartView];
    [self initBarChartView];
    [self setupControl];
    [self setLabelDateText:self.showDate];
    [self adaptiveIphone4];
    
    //[self reloadView];
    //_labelStep.text = NSLocalizedString(@"Step", nil);
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"%@ dealloc",[self class]);
}

#pragma mark - Private Methods
- (void)setupControl
{
    [self.buttonPrev setTitle:@"" forState:UIControlStateNormal];
    [self.buttonPrev setBackgroundImage:[UIImage imageNamed:@"main_date_prev_a.png"] forState:UIControlStateNormal];
    [self.buttonPrev setBackgroundImage:[UIImage imageNamed:@"main_date_prev_b.png"] forState:UIControlStateHighlighted];
    
    [self.buttonNext setTitle:@"" forState:UIControlStateNormal];
    [self.buttonNext setBackgroundImage:[UIImage imageNamed:@"main_date_next_a.png"] forState:UIControlStateNormal];
    [self.buttonNext setBackgroundImage:[UIImage imageNamed:@"main_date_next_b.png"] forState:UIControlStateHighlighted];
}

- (void)reloadView
{
//    self.showDate = [NSDate date];
//    self.labelDate.text = [self stringWithDate:[NSDate date] andFormart:DateFormat];
}

- (void)adaptiveIphone4
{
    if (iPhone4s) {
        UIView *dateView = self.labelDate.superview;
        CGRect frame = dateView.frame;
        frame.origin.y -= TIP_VIEW_MOVE_HEIGHT;
        dateView.frame = frame;
        
        frame = self.chartView.frame;
        frame.origin.y -= TIP_VIEW_MOVE_HEIGHT;
        self.chartView.frame = frame;
        
        frame = self.labelOnedaySteps.superview.frame;
        frame.origin.y -= 50;
        self.labelOnedaySteps.superview.frame = frame;
    }
}

- (void)initNavBarView
{
    self.navBarView.backgroundColor = UICOLOR_DEFAULT;
    self.navBarView.labelTitle.text = NSLocalizedString(@"运动记录",nil);
    self.navBarView.labelTitle.font = Font_DINCondensed(20.f);
    
    [self.navBarView.buttonLeft setTitle:@"" forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_a.png"] forState:UIControlStateNormal];
    [self.navBarView.buttonLeft setBackgroundImage:[UIImage imageNamed:@"back_btn_b.png"] forState:UIControlStateHighlighted];
    [self.navBarView.buttonLeft addTarget:self action:@selector(buttonLeftClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initChartView
{
    self.chartView.min = 0;
    [self setChartViewYmax:MAX_SPORT_STEPS/X_COORDINATE_NUMBER];
    self.chartView.numberOfVerticalElements = LEVEL_LINE_NUMBER;
    self.chartView.horizontalLineInterval = self.chartView.bounds.size.height/(LEVEL_LINE_NUMBER+1) - 1;
    
    NSArray *xAxisValues = @[@"1", @"2", @"3",@"4", @"5", @"6",@"7", @"8", @"9",@"10", @"11",@"12", @"13",@"14", @"15", @"16",@"17", @"18",@"19",@"20",@"21",@"22", @"23", @"24"];
    self.chartView.xAxisValues = xAxisValues;
    self.chartView.axisLeftLineWidth = LEFT_INTERVAL;
    self.chartView.axisBottomLinetHeight = BOTTOM_INTERVAL;
    self.chartView.pointerInterval = POINTER_INTERVAL;
    self.chartView.axisLineWidth = 1.0;
    self.chartView.xAxisFontColor = [UIColor whiteColor];
    self.chartView.horizontalLinesColor = [UIColor whiteColor];
    self.chartView.backgroundColor = UICOLOR_DEFAULT;
    
    [self updateView:self.showDate];
}

- (void)initBarChartView
{
    self.barChartView.min = 0;
    [self setBarChartViewYmax:Y_MAX_DEFAULT];
    self.barChartView.numberOfVerticalElements = LEVEL_LINE_NUMBER;
    self.barChartView.horizontalLineInterval = self.barChartView.bounds.size.height/(LEVEL_LINE_NUMBER+1) - 1;
    self.barChartView.axisLeftLineWidth = LEFT_INTERVAL;
    self.barChartView.axisBottomLinetHeight = BOTTOM_INTERVAL;
    self.barChartView.pointerInterval = POINTER_INTERVAL;
    self.barChartView.axisLineWidth = 1.0;
    self.barChartView.xAxisFontColor = [UIColor darkGrayColor];
    self.barChartView.horizontalLinesColor = [UIColor clearColor];
    self.barChartView.yAxisFontColor = [UIColor clearColor];
    self.barChartView.backgroundColor = [UIColor clearColor];
    self.barChartView.xAxisValues = [WMSHistoryVCHelper xAxisValuesFromEarliestDate:self.earliestDate currentDate:[NSDate systemDate]];
    self.barChartView.chartIntervalToYAxis = CHART_INTERVAL_TO_YAXIS;
    self.barChartView.delegate = self;
    
    [self drawChart];
}

- (void)drawChart
{
    NSArray *values = [self plottingValues];
    NSArray *tags = [WMSHistoryVCHelper xAxisShowMonthsFromEarliestDate:self.earliestDate currentDate:[NSDate systemDate]];
    NSInteger selectedMonth = [NSDate monthOfDate:[NSDate systemDate]];
    long max = [self yAxisMaxValueFromValues:values];
    [self setBarChartViewYmax:max];
    
    _pnBar = [[PNBar alloc] init];
    _pnBar.barWidth = PNBAR_WIDTH;
    _pnBar.barColor = UICOLOR_DEFAULT;
    _pnBar.selectedBarColor = [UIColor orangeColor];
    _pnBar.barDefaultHeight = BAR_DEFAULT_HEIGHT;
    [self.pnBar setPlottingValues:values];
    [self.pnBar setBarTags:tags];
    [self.pnBar setBarSelectedTag:selectedMonth];
    [self.barChartView clearPlot];
    [self.barChartView addPlot:self.pnBar];
}

- (NSArray *)plottingValues
{
    NSDate *startDate =[WMSHistoryVCHelper chartStartDateFromEarliestDate:self.earliestDate currentDate:[NSDate systemDate]];
    NSDate *endDate = [NSDate systemDate];
    NSUInteger currentYear = [NSDate yearOfDate:[NSDate systemDate]];
    NSMutableArray *yAxisValues = [NSMutableArray arrayWithCapacity:12];
    for (NSUInteger i=[NSDate monthOfDate:startDate];i<=[NSDate monthOfDate:endDate];i++)
    {
        NSArray *array = [self.dataBase querySportDataWithYear:currentYear month:i];
        long sum_sportSteps = 0;
        for (WMSSportModel *model in array) {
            sum_sportSteps += model.sportSteps;
        }
        [yAxisValues addObject:@(sum_sportSteps)];
    }
    return yAxisValues;
}

- (long)yAxisMaxValueFromValues:(NSArray *)values
{
    long max = 0;
    for (NSNumber *obj in values) {
        long value = [obj longValue];
        if (max < value) {
            max = value;
        }
    }
    return max;
}

- (void)setBarChartViewYmax:(long)max
{
    if (max > MAX_SPORT_STEPS/X_COORDINATE_NUMBER) {
        self.barChartView.max = max;
    } else {
        self.barChartView.max = MAX_SPORT_STEPS/X_COORDINATE_NUMBER;
    }
    self.barChartView.interval = (self.barChartView.max-self.barChartView.min)/LEVEL_LINE_NUMBER;
    NSMutableArray *yAxisValues = [NSMutableArray arrayWithCapacity:1];
    for (int i=0; i<LEVEL_LINE_NUMBER+1; i++) {
        NSString *str = [NSString stringWithFormat:@"%f", self.barChartView.min+self.barChartView.interval*i];
        [yAxisValues addObject:str];
    }
    self.barChartView.yAxisValues = yAxisValues;
    self.barChartView.floatNumberFormatterString = @"%.0f";
}

//弃用
- (void)setChartViewYmax:(long)max
{
    if (max > MAX_SPORT_STEPS/X_COORDINATE_NUMBER) {
        self.chartView.max = max;
    } else {
        self.chartView.max = MAX_SPORT_STEPS/X_COORDINATE_NUMBER;
    }
    self.chartView.interval = (self.chartView.max-self.chartView.min)/LEVEL_LINE_NUMBER;
    NSMutableArray *yAxisValues = [NSMutableArray arrayWithCapacity:1];
    for (int i=0; i<LEVEL_LINE_NUMBER+1; i++) {
        NSString *str = [NSString stringWithFormat:@"%f", self.chartView.min+self.chartView.interval*i];
        [yAxisValues addObject:str];
    }
    self.chartView.yAxisValues = yAxisValues;
    self.chartView.floatNumberFormatterString = @"%.0f";
}

- (void)updateChartViewWithSportModel:(WMSSportModel *)model
{
    NSArray *values = [self perHourDataForSportModel:model];
    float max = [self perHourMaxDataForSportModel:model];
    
    [self.chartView.plots removeAllObjects];
    [self.plot setPlottingValues:values];
    [self.chartView addPlot:self.plot];
    [self setChartViewYmax:max];
    
}
- (NSArray *)perHourDataForSportModel:(WMSSportModel *)model
{
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:24];
    for (int i=0; i<model.dataLength; i++) {
        [datas addObject:@(model.perHourData[i])];
    }
    
    return datas;
}
//24小时中的最大的一个数据
- (float)perHourMaxDataForSportModel:(WMSSportModel *)model
{
    int max = 0;
    for (int i=0; i<model.dataLength; i++) {
        if (max < model.perHourData[i]) {
            max = model.perHourData[i];
        }
    }
    return max;
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

- (void)updateView:(NSDate *)date
{
    WMSSportDatabase *db = [WMSSportDatabase sportDatabase];
    NSArray *sportModels = [db querySportData:date];
    WMSSportModel *model = nil;
    if ([sportModels count] > 0) {
        model = [sportModels objectAtIndex:0];
    }
    
    [self setLabelOnedayStepsValue:model];
    [self updateChartViewWithSportModel:model];
    [self.chartView update];
}


#pragma mark - Action
- (IBAction)prevDateAction:(id)sender {
//    self.showDate = [NSDate dateWithTimeInterval:OneDayTimeInterval*-1.0 sinceDate:self.showDate];
//    
//    self.labelDate.text = [self stringWithDate:self.showDate andFormart:DateFormat];
    NSDate *date = [NSDate dateWithTimeInterval:OneDayTimeInterval*-1.0 sinceDate:self.showDate];
    [self setLabelDateText:date];
    
    [self updateView:self.showDate];
}

- (IBAction)nextDateAction:(id)sender {
    if (NSDateModeToday == [NSDate compareDate:self.showDate]) {
        return;
    }
//    self.showDate = [NSDate dateWithTimeInterval:OneDayTimeInterval sinceDate:self.showDate];
//    self.labelDate.text = [self stringWithDate:self.showDate andFormart:DateFormat];
    
    NSDate *date = [NSDate dateWithTimeInterval:OneDayTimeInterval sinceDate:self.showDate];
    [self setLabelDateText:date];
    
    [self updateView:self.showDate];
}

- (void)buttonLeftClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PNBarChartViewDelegate
- (void)barChartView:(PNBarChartView *)chartView didSelectBarTag:(NSInteger)barTag atPNBar:(PNBar *)pnBar
{
    if (chartView != self.barChartView) {
        return;
    }
    int index = 0;
    for (int i=0; i<[pnBar.barTags count]; i++) {
        if (barTag == [pnBar.barTags[i] integerValue]) {
            index = i;
            break;
        }
    }
    if (index < [pnBar.plottingValues count]) {
        long steps = [pnBar.plottingValues[index] longValue];
        WMSPersonModel *model = [WMSUserInfoHelper readPersonInfo];
        NSUInteger weight = [model currentWeight];//kg
        NSUInteger stride = [model stride];//cm
        long calorie = Rounded(Calorie(weight, steps));//cal
        long distance = steps * stride;//cm
        [self setBottomLabelSteps:steps];
        [self setBottomLabelCalorie:calorie];
        [self setBottomLabelDistance:distance];
    }
}

@end
