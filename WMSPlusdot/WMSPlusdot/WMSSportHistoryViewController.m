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

#import "WMSSportDatabase.h"
#import "WMSSportModel.h"

#import "WMSAdaptiveMacro.h"
#import "NSDate+Formatter.h"

#define LEFT_INTERVAL   35.f
#define BOTTOM_INTERVAL 30.f
#define POINTER_INTERVAL 37.f
#define LEVEL_LINE_NUMBER 10
#define X_COORDINATE_NUMBER         24

#define OneDayTimeInterval    (24*60*60)
#define DateFormat            @"yyyy/MM/dd"

@interface WMSSportHistoryViewController ()
{
    __weak IBOutlet UILabel *_labelStep;
}

@property (nonatomic, strong) PNPlot *plot;

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
    
    [self initNavBarView];
    [self initChartView];
    [self setupControl];
    [self setLabelDateText:self.showDate];
    //[self reloadView];
    [self adaptiveIphone4];
    
    _labelStep.text = NSLocalizedString(@"Step", nil);
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

- (void)setChartViewYmax:(float)max
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
            return [NSDate formatDate:date withFormat:formart];
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

@end
