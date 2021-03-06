//
//  WMSMyAccountViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-29.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSMyAccountViewController.h"
#import "WMSBindingAccessoryViewController.h"
#import "WMSLeftViewController.h"
#import "RESideMenu.h"
#import "WMSAppDelegate.h"

#import "MBProgressHUD.h"
#import "WMSInputView.h"

#import "WMSMyAccessory.h"
#import "WMSPersonModel.h"

#import "WMSUserInfoHelper.h"
#import "NSDate+Formatter.h"
#import "UIImage+QuartzProc.h"

#define DatePickerHeight                216.f
#define ToolbarHeight                   44.f

#define HeightViewIndex                 100
#define BirthdayViewIndex               101
#define CurrentWeightViewIndex          102
#define TargetWeightViewIndex           103

static const int HeightMinValue         =100;
static const int HeightMaxValue         =300;
static const int WeightMinValue         =35;
static const int WeightMaxValue         =220;

#define HeightUnit                      @"cm"
#define WeightUnit                      @"kg"
#define SEX_MAN                         1
#define SEX_WOMAN                       0

#define COMPONENT_NUMBER                2
#define COMPONENT_WIDTH                 50.f

#define ButtonSavaFrame ( CGRectMake((ScreenWidth-610/2.0)/2, (ScreenHeight-99/2.0-30), 610/2.0, 99/2.0) )

@interface WMSMyAccountViewController ()<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,WMSInputViewDelegate>
{
    //本地化
    __weak IBOutlet UILabel *labelTip2;
    __weak IBOutlet UILabel *labelShenGao;
    __weak IBOutlet UILabel *labelShengRi;
    __weak IBOutlet UILabel *labelTiZhong1;
    __weak IBOutlet UILabel *labelTiZhong2;
}

@property (strong, nonatomic) UIButton *buttonSava;

@property (strong, nonatomic) WMSInputView *myInputView;
@property (strong, nonatomic) UIDatePicker *myDatePicker;
@property (strong, nonatomic) UIToolbar *myToolbar;
@property (strong, nonatomic) NSArray *pickerViewComponent2Array;

@property (strong, nonatomic) NSMutableArray *heightArray;
@property (strong, nonatomic) NSMutableArray *weightArray;

//身高view，生日view，当前体重view，目标体重view，index分别为100，101，102，103
@property (nonatomic) int clickedViewIndex;
@end

@implementation WMSMyAccountViewController
{
    NSUInteger mySex;//1表示男，0表示女
    NSUInteger myHeight;
    NSUInteger myBirthdayYear;
    NSUInteger myBirthdayMonth;
    NSUInteger myBirthdayDay;
    NSUInteger myCurrentWeight;
    NSUInteger myTargetWeight;
    NSString *myName;
    NSDate *myBirthday;
    UIImage *myImage;
}

#pragma mark - Getter
- (WMSInputView *)myInputView
{
    if (!_myInputView) {
        _myInputView= [[WMSInputView alloc] initWithLeftItemTitle:NSLocalizedString(@"Cancel", nil) RightItemTitle:NSLocalizedString(@"Confirm",nil)];
        _myInputView.pickerView.backgroundColor = [UIColor whiteColor];
        _myInputView.pickerView.delegate = self;
        _myInputView.pickerView.dataSource = self;
        _myInputView.delegate = self;
        [_myInputView hidden:NO];
    }
    return _myInputView;
}
- (UIDatePicker *)myDatePicker
{
    if (!_myDatePicker) {
        _myDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, DatePickerHeight)];
        _myDatePicker.datePickerMode = UIDatePickerModeDate;
        _myDatePicker.backgroundColor = [UIColor whiteColor];
    }
    return _myDatePicker;
}
- (UIToolbar *)myToolbar
{
    if (!_myToolbar) {
        _myToolbar = [[UIToolbar alloc] init];
        _myToolbar.frame = (CGRect){0,ScreenHeight,ScreenWidth,ToolbarHeight};
        _myToolbar.barTintColor = [UIColor whiteColor];
        _myToolbar.backgroundColor = [UIColor whiteColor];
        
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked:)];
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Confirm",nil) style:UIBarButtonItemStyleDone target:self action:@selector(confirmClicked:)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *buttons = @[leftBarButton,flexibleSpace,rightBarButton];
        [_myToolbar setItems:buttons animated:YES];
    }
    return _myToolbar;
}

- (UIButton *)buttonSava
{
    if (!_buttonSava) {
        _buttonSava = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonSava.backgroundColor = [UIColor clearColor];
        _buttonSava.frame = ButtonSavaFrame;
        [_buttonSava setTitle:NSLocalizedString(@"保存信息", nil) forState:UIControlStateNormal];
        [_buttonSava setBackgroundImage:[UIImage imageNamed:@"sava_info_btn_a.png"] forState:UIControlStateNormal];
        [_buttonSava setBackgroundImage:[UIImage imageNamed:@"sava_info_btn_b.png"] forState:UIControlStateHighlighted];
        [_buttonSava addTarget:self action:@selector(savaInfoAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _buttonSava;
}

- (NSMutableArray *)heightArray
{
    if (!_heightArray) {
        _heightArray = [[NSMutableArray alloc] init];
        for (int i=HeightMinValue; i<=HeightMaxValue; i++) {
            [_heightArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _heightArray;
}
- (NSMutableArray *)weightArray
{
    if (!_weightArray) {
        _weightArray = [[NSMutableArray alloc] init];
        for (int i=WeightMinValue; i<=WeightMaxValue; i++) {
            [_weightArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _weightArray;
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
    
    [self setupProperty];
    [self setupView];
    [self setupNavigationBar];
    [self setupControl];
    [self updateViews];
    [self localized];
    [self adaptiveIphone4];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DEBUGLog(@"WMSMyAccountViewController dealloc");
    self.textFieldName.delegate = nil;
}

#pragma mark - Setup
- (void)setupView
{
    self.textFieldName.text = @"";
    self.textFieldName.placeholder = NSLocalizedString(@"Please enter a nickname", nil);
    self.textFieldName.font = [UIFont systemFontOfSize:25.f];
    self.textFieldName.delegate = self;
    if (self.isNewUser) {
        [self.view addSubview:self.buttonSava];
    }
    [self.view addSubview:self.myInputView];
    [self.view addSubview:self.myDatePicker];
    [self.view addSubview:self.myToolbar];
}
- (void)setupNavigationBar
{
    self.title = NSLocalizedString(@"个人信息",nil);
    if (!self.isNewUser) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem defaultItemWithTarget:self action:@selector(backAction:)];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}
- (void)setupControl
{
    [self.buttonMan setTitle:@"" forState:UIControlStateNormal];
    [self.buttonMan setBackgroundImage:[UIImage imageNamed:@"unselect_man.png"] forState:UIControlStateNormal];
    [self.buttonMan addTarget:self action:@selector(buttonManClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonWoman setTitle:@"" forState:UIControlStateNormal];
    [self.buttonWoman setBackgroundImage:[UIImage imageNamed:@"unselect_woman.png"] forState:UIControlStateNormal];
    [self.buttonWoman addTarget:self action:@selector(buttonWomanClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)localized
{
    labelTip2.text = NSLocalizedString(@"Please enter the character signature",nil);
    labelShenGao.text = NSLocalizedString(@"Height",nil);
    labelShengRi.text = NSLocalizedString(@"Birthday",nil);
    labelTiZhong1.text = NSLocalizedString(@"Current weight",nil);
    labelTiZhong2.text = NSLocalizedString(@"Target weight",nil);
}

- (void)adaptiveIphone4
{
    if (iPhone5) {
        return;
    }
    CGRect frame = self.centerView.frame;
    frame.origin.y -= 20;
    self.centerView.frame = frame;
    
    frame = self.bottomView.frame;
    frame.origin.y -= 30;
    self.bottomView.frame = frame;
    
    frame = self.buttonSava.frame;
    frame.origin.y += 25;
    self.buttonSava.frame = frame;
}

//更新对应的视图
- (void)updateViews
{
    self.textFieldName.text = myName;
    if (myImage) {
        self.imageViewUserImage.image = myImage;
    }
    if (mySex == SEX_MAN) {
        self.labelSex.text = NSLocalizedString(@"Male",nil);
        [self.buttonMan setBackgroundImage:[UIImage imageNamed:@"select_man.png"] forState:UIControlStateNormal];
        [self.buttonWoman setBackgroundImage:[UIImage imageNamed:@"unselect_woman.png"] forState:UIControlStateNormal];
    } else if (mySex == SEX_WOMAN) {
        self.labelSex.text = NSLocalizedString(@"Female",nil);
        [self.buttonWoman setBackgroundImage:[UIImage imageNamed:@"select_woman.png"] forState:UIControlStateNormal];
        [self.buttonMan setBackgroundImage:[UIImage imageNamed:@"unselect_man.png"] forState:UIControlStateNormal];
    }
    self.labelHeightValue.text = [NSString stringWithFormat:@"%ld%@",(unsigned long)myHeight,NSLocalizedString(@"cm",nil)];
    self.labelCurrentWeight.text = [NSString stringWithFormat:@"%ld%@",(unsigned long)myCurrentWeight,NSLocalizedString(@"kg",nil)];
    self.labelTargetWeight.text = [NSString stringWithFormat:@"%ld%@",(unsigned long)myTargetWeight,NSLocalizedString(@"kg",nil)];
    self.labelBirthdayYear.text = [NSString stringWithFormat:@"%ld%@",(unsigned long)myBirthdayYear,NSLocalizedString(@"Year",nil)];
    self.labelBirthdayMonth.text = [NSString stringWithFormat:@"%ld%@%ld%@",(unsigned long)myBirthdayMonth,NSLocalizedString(@"Month",nil),(unsigned long)myBirthdayDay,NSLocalizedString(@"Day",nil)];
}

- (void)setupProperty
{
    WMSPersonModel *model = [WMSUserInfoHelper readPersonInfo];
    myName = model.name;
    mySex = model.gender;
    myHeight = model.height;
    myCurrentWeight = model.currentWeight;
    myTargetWeight = model.targetWeight;
    myImage = model.image;
    NSDate *birthday = model.birthday;
    myBirthdayYear = [NSDate yearOfDate:birthday];
    myBirthdayMonth = [NSDate monthOfDate:birthday];
    myBirthdayDay = [NSDate dayOfDate:birthday];
}
//保存用户信息
- (void)savaPersonInfoBirthday:(NSDate *)birthday stride:(NSUInteger)stride
{
    WMSPersonModel *personModel = [[WMSPersonModel alloc] initWithName:myName image:myImage birthday:birthday gender:mySex height:myHeight currentWeight:myCurrentWeight targetWeight:myTargetWeight stride:stride];
    
    [WMSUserInfoHelper savaPersonInfo:personModel];
}


#pragma mark - 隐藏与显示输入视图
- (BOOL)isShowDatePicker
{
    if (self.myDatePicker.frame.origin.y == ScreenHeight) {
        return NO;
    } else {
        return YES;
    }
    return YES;
}
- (void)showDatePicker:(BOOL)show
{
    CGPoint or = self.myDatePicker.frame.origin;
    float offset = self.myDatePicker.bounds.size.height;
    if (show) {
        if (or.y == ScreenHeight) {
            or.y -= offset;
            self.myDatePicker.frame = (CGRect){or,self.myDatePicker.bounds.size};
        }
    } else {
        if (or.y == ScreenHeight - offset) {
            or.y += offset;
            self.myDatePicker.frame = (CGRect){or,self.myDatePicker.bounds.size};
        }
    }
}
//判断self.myPickerView是否显示
- (BOOL)isShowToolbar
{
    if (self.myToolbar.frame.origin.y == ScreenHeight) {
        return NO;
    } else {
        return YES;
    }
    return YES;
}
//显示或隐藏self.myToolbar
- (void)showToolbar:(BOOL)show
{
    CGPoint or = self.myToolbar.frame.origin;
    float offset = ToolbarHeight + DatePickerHeight;
    if (show) {
        if (or.y == ScreenHeight) {
            or.y -= offset;
            self.myToolbar.frame = (CGRect){or,self.myToolbar.bounds.size};
        }
    } else {
        if (or.y == ScreenHeight - offset) {
            or.y += offset;
            self.myToolbar.frame = (CGRect){or,self.myToolbar.bounds.size};
        }
    }
}
- (BOOL)isShowInputView
{
    if ([self isShowToolbar]) {
        return YES;
    } else {
        return NO;
    }
}
//显示或隐藏InputView
- (void)showInputView:(BOOL)show
{
    if (show) {
        [self showToolbar:show];
        if (self.clickedViewIndex != BirthdayViewIndex) {
        } else {
            [self showDatePicker:show];
        }
    } else {
        [self showToolbar:show];
        [self showDatePicker:show];
    }
}

//使self.textFieldName失去第一响应者
- (void)textFieldNameResignFirstResponder
{
    if ([self.textFieldName isFirstResponder]) {
        [self.textFieldName resignFirstResponder];
    }
    myName = self.textFieldName.text;
}

//校验昵称是否为空
- (BOOL)checkUserName
{
    if (myName == nil || [@"" isEqualToString:myName]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        //hud.labelFont = Font_DINCondensed(10.0);
        hud.labelText = NSLocalizedString(@"个性签名不能为空", nil);
        hud.mode = MBProgressHUDModeText;
        hud.minSize = CGSizeMake(250, 60);
        //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
        hud.yOffset = ScreenHeight/2.0-60;
        hud.xOffset = 0;
        [self.view addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep(1);
        } completionBlock:^{
            [hud removeFromSuperview];
        }];
        
        return NO;
    }
    return YES;
}

#pragma mark - 相机，相片库
- (void)openCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return ;
    }
    UIImagePickerControllerSourceType sourceType;
    sourceType=UIImagePickerControllerSourceTypeCamera;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    //设置图像选取控制器的类型为静态图像
    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
    picker.allowsEditing=YES;
    picker.showsCameraControls = YES;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)openPhotoLibrary
{
    UIImagePickerControllerSourceType sourceType;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return ;
    }
    
    sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.allowsEditing=YES;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - Action
- (void)backAction:(id)sender
{
    WMSLeftViewController *leftVC = (WMSLeftViewController *)((RESideMenu *)self.presentingViewController).leftMenuViewController;
    [leftVC setUserImage:myImage];
    [leftVC setUserNickname:myName];
    
    [self savaInfoAction:nil];
}

- (void)buttonManClicked:(id)sender
{
    self.labelSex.text = NSLocalizedString(@"Man",nil);
    mySex = 1;
    self.labelSex.text = NSLocalizedString(@"Male",nil);
    [self.buttonMan setBackgroundImage:[UIImage imageNamed:@"select_man.png"] forState:UIControlStateNormal];
    [self.buttonWoman setBackgroundImage:[UIImage imageNamed:@"unselect_woman.png"] forState:UIControlStateNormal];
}
- (void)buttonWomanClicked:(id)sender
{
    self.labelSex.text = NSLocalizedString(@"Woman",nil);
    mySex = 0;
    self.labelSex.text = NSLocalizedString(@"Female",nil);
    [self.buttonWoman setBackgroundImage:[UIImage imageNamed:@"select_woman.png"] forState:UIControlStateNormal];
    [self.buttonMan setBackgroundImage:[UIImage imageNamed:@"unselect_man.png"] forState:UIControlStateNormal];
}

- (IBAction)imageViewClicked:(id)sender {
    DEBUGLog(@"选取头像");
    //警告
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take picture", nil),NSLocalizedString(@"选取照片", nil), nil];//没有红色按钮
    [actionSheet showInView:self.view];
}

- (IBAction)heightClicked:(id)sender {
    self.clickedViewIndex = HeightViewIndex;
    [self textFieldNameResignFirstResponder];
    if ([self isShowInputView]) {
        [self showInputView:NO];
    }
    
    NSInteger row = myHeight-HeightMinValue;
    [self.myInputView show:YES forView:self.labelHeightValue];
    [self.myInputView.pickerView selectRow:row inComponent:0 animated:NO];
}
- (IBAction)currentWeightClicked:(id)sender {
    self.clickedViewIndex = CurrentWeightViewIndex;
    [self textFieldNameResignFirstResponder];
    if ([self isShowInputView]) {
        [self showInputView:NO];
    }
    
    NSInteger row = myCurrentWeight-WeightMinValue;
    [self.myInputView show:YES forView:self.labelCurrentWeight];
    [self.myInputView.pickerView selectRow:row inComponent:0 animated:NO];
}
- (IBAction)targetWeightClicked:(id)sender {
    self.clickedViewIndex = TargetWeightViewIndex;
    [self textFieldNameResignFirstResponder];
    if ([self isShowInputView]) {
        [self showInputView:NO];
    }
    
    NSInteger row = myTargetWeight-WeightMinValue;
    [self.myInputView show:YES forView:self.labelTargetWeight];
    [self.myInputView.pickerView selectRow:row inComponent:0 animated:NO];
}

- (IBAction)birthdayClicked:(id)sender {
    self.clickedViewIndex = BirthdayViewIndex;
    [self textFieldNameResignFirstResponder];
    [self.myInputView hidden:NO];
    
    if ([self isShowInputView]) {
        [UIView animateWithDuration:0.5 animations:^{
            [self showInputView:NO];
        }];
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self showInputView:YES];
    }];
    
    NSString *datestring = [NSString stringWithFormat:@"%04d-%02d-%02d",
                            myBirthdayYear,myBirthdayMonth,myBirthdayDay];
    NSDate *newdate = [NSDate dateFromString:datestring format:@"yyyy-MM-dd"];
    [self.myDatePicker setDate:newdate animated:NO];
}

- (void)cancelClicked:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        [self showInputView:NO];
    }];
}
- (void)confirmClicked:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        [self showInputView:NO];
    }];
    
    if (self.clickedViewIndex == BirthdayViewIndex) {
        NSDate *date = self.myDatePicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];//@"yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.dateFormat = @"yyyy";
        NSString *strYear = [dateFormatter stringFromDate:date];
        dateFormatter.dateFormat = @"MM";
        NSString *strMonth = [dateFormatter stringFromDate:date];
        dateFormatter.dateFormat = @"dd";
        NSString *strDay = [dateFormatter stringFromDate:date];
        self.labelBirthdayYear.text = [NSString stringWithFormat:@"%@%@",strYear,NSLocalizedString(@"Year",nil)];
        self.labelBirthdayMonth.text = [NSString stringWithFormat:@"%@%@%@%@",strMonth,NSLocalizedString(@"Month",nil),strDay,NSLocalizedString(@"Day",nil)];
        
        myBirthdayYear = [strYear intValue];
        myBirthdayMonth = [strMonth intValue];
        myBirthdayDay = [strDay intValue];
        
        return;
    }
}

- (void)savaInfoAction:(id)sender
{
    //校验姓名是否为空
    if ([self checkUserName] == NO) {
        return;
    }
    
    NSString *strBirthday = [NSString stringWithFormat:@"%04d-%02d-%02d",
                             myBirthdayYear,myBirthdayMonth,myBirthdayDay];
    float floatStride = StrideWithGender(mySex, myHeight);
    int stride = Rounded(floatStride);
    NSDate *birthday = [NSDate dateFromString:strBirthday format:@"yyyy-MM-dd"];
    [self savaPersonInfoBirthday:birthday stride:stride];
    
    if (self.isNewUser) {
        [WMSAppDelegate appDelegate].window.rootViewController = (UIViewController *)[WMSAppDelegate appDelegate].reSideMenu;
        UIView *view = [WMSAppDelegate appDelegate].reSideMenu.view;
        view.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            view.alpha = 1.0;
        } completion:^(BOOL finished) {
            [WMSAppDelegate appDelegate].loginNavigationCtrl = nil;
            [[WMSAppDelegate appDelegate].window makeKeyAndVisible];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //判断是静态图像还是视频
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];//获取用户编辑之后的图像
        //UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //将该图像保存到媒体库中
        //UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
        
        //显示用户image
        CGSize toSize = CGSizeZero;
        toSize.width = self.imageViewUserImage.bounds.size.width*2;
        toSize.height = self.imageViewUserImage.bounds.size.height*2;
        self.imageViewUserImage.image = [image resizeImageToSize:toSize resizeMode:quartzImageResizeAspectFit];
        myImage = self.imageViewUserImage.image;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DEBUGLog(@"actionSheet buttonIndex:%d",buttonIndex);
    if (buttonIndex == 0) {//拍照
        [self openCamera];
    } else if (buttonIndex == 1) {//选取照片
        [self openPhotoLibrary];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        ;
    } else if (buttonIndex == 1) {//保存数据，关闭视图
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        
        WMSBleControl *bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
        
        NSString *strBirthday = [NSString stringWithFormat:@"%04d-%02d-%02d",
                                myBirthdayYear,myBirthdayMonth,myBirthdayDay];
        float floatStride = StrideWithGender(mySex, myHeight);
        int stride = Rounded(floatStride);
        
        
        [bleControl.settingProfile setPersonInfoWithWeight:myCurrentWeight withHeight:myHeight withGender:mySex withBirthday:strBirthday withDateFormat:@"yyyy-MM-dd" withStride:stride withMetric:LengthUnitTypeMetricSystem withCompletion:^(BOOL success)
        {
            DEBUGLog(@"设置个人信息%@",success?@"成功":@"失败");
            
            NSDate *birthday = [NSDate dateFromString:strBirthday format:@"yyyy-MM-dd"];
            
            [self savaPersonInfoBirthday:birthday stride:stride];
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self isShowInputView]) {
        [self showInputView:NO];
    }
    [self.myInputView hidden:NO];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self textFieldNameResignFirstResponder];
    return YES;
}

#pragma mark - UIPickerViewDataSource
//返回有几个部分
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return COMPONENT_NUMBER;
}
//返回pickerView的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger count = 0;
    if (self.clickedViewIndex == HeightViewIndex) {
        count = self.heightArray.count;
    } else if (self.clickedViewIndex == CurrentWeightViewIndex) {
        count = self.weightArray.count;
    } else if (self.clickedViewIndex == TargetWeightViewIndex) {
        count = self.weightArray.count;
    }
    
    if (component == 0) {
        return count;
    }
    return 1;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0) {
        return COMPONENT_WIDTH;
    }
    return COMPONENT_WIDTH;
}
//返回值写入pickerView中
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.clickedViewIndex == HeightViewIndex) {
        if (component == 0) {
            return self.heightArray[row];
        }
        return HeightUnit;
        
    } else if (self.clickedViewIndex == CurrentWeightViewIndex ||
               self.clickedViewIndex == TargetWeightViewIndex) {
        if (component == 0) {
            return self.weightArray[row];
        }
        return WeightUnit;
    }
    
    return nil;
}
#pragma mark - WMSInputViewDelegate
- (void)inputView:(WMSInputView *)inputView forView:(UIView *)responseView didClickRightItem:(UIBarButtonItem *)item
{
    NSInteger row = [inputView.pickerView selectedRowInComponent:0];
    if (responseView == self.labelHeightValue) {
        myHeight = [self.heightArray[row] intValue];
        self.labelHeightValue.text = [NSString stringWithFormat:@"%ld%@",(unsigned long)myHeight,NSLocalizedString(@"cm",nil)];
    } else if (responseView == self.labelCurrentWeight) {
        myCurrentWeight = [self.weightArray[row] intValue];
        self.labelCurrentWeight.text = [NSString stringWithFormat:@"%ld%@",(unsigned long)myCurrentWeight,NSLocalizedString(@"kg",nil)];
    } else if (responseView == self.labelTargetWeight) {
        myTargetWeight = [self.weightArray[row] intValue];
        self.labelTargetWeight.text = [NSString stringWithFormat:@"%ld%@",(unsigned long)myTargetWeight,NSLocalizedString(@"kg",nil)];
    } else {}
}

@end
