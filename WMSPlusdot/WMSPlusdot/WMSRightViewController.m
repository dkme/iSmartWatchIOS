//
//  WMSRightViewController.m
//  WMSPlusdot
//
//  Created by John on 14-8-21.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSRightViewController.h"
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "WMSRemindWayViewController.h"
#import "UIViewController+Tip.h"
#import "WMSAppDelegate.h"

#import "WMSSwitchCell.h"
#import "MBProgressHUD.h"

#import "WMSMyAccessory.h"
#import "WMSConstants.h"

#define SECTION_NUMBER  5
#define SECTION0_HEADER_HEIGHT  50.f
#define SECTION_HEADER_HEIGHT   40.f
#define SECTION_HEADER_DEFAULT_HEIGHT   0.1f
#define SECTION_FOOTER_DEFAULT_HEIGHT   0.1f
#define CELL_CONTENT_PREFIX     @"                   "

#define LOW_BATTERY_LEVEL1       0.20f
#define LOW_BATTERY_LEVEL2       0.15f
#define LOW_BATTERY_LEVEL3       0.10f
#define LOW_BATTERY_LEVEL4       0.05f
#define LOW_BATTERY_REMIND_TIMEINTERVAL 20

__weak WMSRightViewController *global_Self = nil;

#define SettingItemsFile    @"settingItems.plist"
#define OtherRemindItemsFile    @"otherRemind.plist"
#define RemindWayFile       @"remindWay.plist"

@interface WMSRightViewController ()<WMSSwitchCellDelegage,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) NSArray *section1TitleArray;
@property (strong, nonatomic) NSArray *section2TitleArray;
@property (strong, nonatomic) NSArray *section3TitleArray;
@property (strong, nonatomic) NSArray *section4TitleArray;
@property (strong, nonatomic) NSArray *section5TitleArray;
@property (strong, nonatomic) NSArray *headerTitleArray;

@property (strong, nonatomic) WMSBleControl *bleControl;
@property (strong, nonatomic) UIImagePickerController *pickerController;

@property (strong, nonatomic) NSArray *settingItemArray;
@property (strong, nonatomic) NSArray *cellIndexPathArray;//与上面的值一一对应

@property (nonatomic,strong) AVAudioPlayer *player;
@end

@implementation WMSRightViewController
{
    SystemSoundID soundID;
}

#pragma mark - Property Getter Method
- (NSArray *)section1TitleArray
{
    if (!_section1TitleArray) {
        _section1TitleArray = @[NSLocalizedString(@"Phone",nil),
                                NSLocalizedString(@"Message",nil),
                                NSLocalizedString(@"Email",nil),
                                NSLocalizedString(@"Battery",nil)
                                ];
    }
    return _section1TitleArray;
}
- (NSArray *)section2TitleArray
{
    if (!_section2TitleArray) {
        _section2TitleArray = @[NSLocalizedString(@"Wechat",nil),
                                NSLocalizedString(@"QQ",nil),
                                NSLocalizedString(@"Facebook",nil),
                                NSLocalizedString(@"Twitter",nil)
                                ];
    }
    return _section2TitleArray;
}
- (NSArray *)section3TitleArray
{
    if (!_section3TitleArray) {
        _section3TitleArray = @[NSLocalizedString(@"震动",nil),
                                NSLocalizedString(@"响铃",nil),
                                NSLocalizedString(@"震动+响铃",nil),
                                ];
    }
    return _section3TitleArray;
}
- (NSArray *)section4TitleArray
{
    if (!_section4TitleArray) {
        _section4TitleArray = @[NSLocalizedString(@"防丢",nil)
                                ];
    }
    return _section4TitleArray;
}
- (NSArray *)section5TitleArray
{
    if (!_section5TitleArray) {
        _section5TitleArray = @[NSLocalizedString(@"拍照",nil)
                                ];
    }
    return _section5TitleArray;
}
- (NSArray *)headerTitleArray
{
    if (!_headerTitleArray) {
        _headerTitleArray = @[NSLocalizedString(@"Remind Setting",nil),
                              NSLocalizedString(@"Social contact",nil),
                              NSLocalizedString(@"提醒方式",nil),
                              NSLocalizedString(@"其他",nil),
                              @"",
                              ];
    }
    return _headerTitleArray;
}

- (NSArray *)settingItemArray//存放保存设置项字典的key
{
    if (!_settingItemArray) {
        _settingItemArray = @[@"Call",@"SMS",@"Email",@"WeiXin",@"QQ",@"Facebook",@"Twitter"];
    }
    return _settingItemArray;
}
- (NSArray *)cellIndexPathArray
{
    if (!_cellIndexPathArray) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:7];
        NSIndexPath *index = nil;
        
        index = [NSIndexPath indexPathForRow:0 inSection:0];
        [indexPaths addObject:index];
        
        index = [NSIndexPath indexPathForRow:1 inSection:0];
        [indexPaths addObject:index];
        
        index = [NSIndexPath indexPathForRow:2 inSection:0];
        [indexPaths addObject:index];
        
        index = [NSIndexPath indexPathForRow:0 inSection:1];
        [indexPaths addObject:index];
        
        index = [NSIndexPath indexPathForRow:1 inSection:1];
        [indexPaths addObject:index];
        
        index = [NSIndexPath indexPathForRow:2 inSection:1];
        [indexPaths addObject:index];
        
        index = [NSIndexPath indexPathForRow:3 inSection:1];
        [indexPaths addObject:index];
        
        _cellIndexPathArray = indexPaths;
    }
    return _cellIndexPathArray;
}


#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_bg.png"]]];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.tableView.style = UITableViewStyleGrouped;
    
    self.bleControl = [[WMSAppDelegate appDelegate] wmsBleControl];
    //    NSDictionary *dic = [[NSDictionary alloc] init];
    //    [dic writeToFile:[self filePath:SettingItemsFile] atomically:YES];
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float level = [[UIDevice currentDevice] batteryLevel];
    DEBUGLog(@"当前手机电量：%f",level);
    //监测电量
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteyChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessConnectPeripheral:) name:WMSBleControlPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidDisConnectPeripheral:) name:WMSBleControlPeripheralDidDisConnect object:nil];
    
    global_Self = self;
    [self loadSoundFile];
    //[self soundAlarm];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DEBUGLog(@"RightViewController viewWillAppear");
    //    self.sideMenuViewController.scaleContentView = NO;
}
- (void)dealloc
{
    DEBUGLog(@"RightViewController dealloc");
    global_Self = nil;
    self.player = nil;
    AudioServicesDisposeSystemSoundID(soundID);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//根据cell的indexPath，得出该cell表示的设置项在字典中的key
- (NSString *)keyForIndexpath:(NSIndexPath *)indexPath
{
    int index = -1;
    for (int i=0; i<[self.cellIndexPathArray count]; i++) {
        NSIndexPath *obj = self.cellIndexPathArray[i];
        if (indexPath.section == obj.section &&
            indexPath.row == obj.row)
        {
            index = i;
            break;
        }
    }
    if (index < 0) {
        return nil;
    }
    return self.settingItemArray[index];
}

///
- (NSString *)filePath:(NSString *)fileName
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [array objectAtIndex:0];
    
    return [path stringByAppendingPathComponent:fileName];
}
- (NSDictionary *)readSettingItemData
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:[self filePath:SettingItemsFile]];
    NSMutableDictionary *mutiDic = [NSMutableDictionary dictionaryWithDictionary:readData];
    if (readData == nil) {
        for (int i=0; i<[self.settingItemArray count]; i++) {
            [mutiDic setObject:@(1) forKey:self.settingItemArray[i]];//默认设置项都为打开状态
        }
    }
    return mutiDic;
}
- (void)savaSettingItemForKey:(NSString *)key object:(NSObject *)object
{
    NSDictionary *readData = [self readSettingItemData];
    NSMutableDictionary *writeData = [NSMutableDictionary dictionaryWithDictionary:readData];
    [writeData setObject:object forKey:key];
    BOOL b = [writeData writeToFile:[self filePath:SettingItemsFile] atomically:YES];
    DEBUGLog(@"保存数据%@",b?@"成功":@"失败");
}

- (BOOL)antiLostStatus
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:[self filePath:OtherRemindItemsFile]];
    return [[readData objectForKey:@"antiLost"] boolValue];
}
- (BOOL)lowBatteryStatus
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:[self filePath:OtherRemindItemsFile]];
    return [[readData objectForKey:@"battery"] boolValue];
}
- (void)setAntiLost:(BOOL)openOrClose
{
    //设置防丢成功，保存设置
    [self.bleControl.settingProfile setAntiLostStatus:YES distance:100 completion:^(BOOL success)
     {
         DEBUGLog(@"设置防丢%@",success?@"成功":@"失败");
         [self showOperationSuccessTip:NSLocalizedString(@"防丢设置成功", nil)];
         NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:[self filePath:OtherRemindItemsFile]];
         NSMutableDictionary *writeData = [NSMutableDictionary dictionaryWithDictionary:readData];
         [writeData setObject:@(openOrClose) forKey:@"antiLost"];
         [writeData writeToFile:[self filePath:OtherRemindItemsFile] atomically:YES];
     }];
}
- (void)setLowBattery:(BOOL)openOrClose
{
    [self showOperationSuccessTip:NSLocalizedString(@"提醒设置成功", nil)];
    //直接保存
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:[self filePath:OtherRemindItemsFile]];
    NSMutableDictionary *writeData = [NSMutableDictionary dictionaryWithDictionary:readData];
    [writeData setObject:@(openOrClose) forKey:@"battery"];
    [writeData writeToFile:[self filePath:OtherRemindItemsFile] atomically:YES];
}

//0：不提醒，1：震动，2：响铃，3：震动+响铃
- (int)readRemindWay
{
    NSDictionary *readData = [NSDictionary dictionaryWithContentsOfFile:FilePath(RemindWayFile)];
    int way = [[readData objectForKey:@"remindWay"] intValue];
    if (readData == nil || way == 0) {
        return 3;//默认“震动+响铃”
    }
    return way;
}
- (void)savaRemindWay:(int)way
{
    NSDictionary *writeData = @{@"remindWay":@(way)};
    [writeData writeToFile:FilePath(RemindWayFile) atomically:YES];
}

- (void)setRemindWay:(int)way
{
    RemindMode mode = way;//way与RemindMode一一对应
    RemindEventsType type = [self remindEventsType];
    [self.bleControl.settingProfile setRemindEventsType:type mode:mode completion:^(BOOL success)
     {
         DEBUGLog(@"提醒方式设置%@",success?@"成功":@"失败");
         [self savaRemindWay:way];
         [self showOperationSuccessTip:NSLocalizedString(@"提醒方式设置成功", nil)];
     }];
}

- (NSUInteger)remindEventsType
{
    NSDictionary *readData = [self readSettingItemData];
    DEBUGLog(@"readData:%@",readData);
    NSArray *values = [readData objectsForKeys:self.settingItemArray notFoundMarker:@"aa"];
    
    NSUInteger events[7] = {RemindEventsTypeCall,RemindEventsTypeSMS,RemindEventsTypeEmail,RemindEventsTypeWeixin,RemindEventsTypeQQ,RemindEventsTypeFacebook,RemindEventsTypeTwitter};
    NSUInteger eventsType = 0x00;
    for (int i=0; i<[values count]; i++) {
        BOOL openOrClose = [[values objectAtIndex:i] boolValue];
        if (openOrClose) {
            eventsType = (eventsType | events[i]);
        }
    }
    return eventsType;
}

- (void)stopLowBatteryRemind
{
    [self.bleControl.settingProfile setStopLowBatteryRemindCompletion:^(BOOL success) {
        DEBUGLog(@"停止低电量提醒成功");
    }];
}

#pragma mark - 声音处理
- (void)loadSoundFile
{
    //    AVAudioSession *session = [AVAudioSession sharedInstance];
    //    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //    [session setActive:YES error:nil];
    //
    //    NSURL *url = [[NSBundle mainBundle] URLForResource: @"嘀嘀报警声"
    //                                                withExtension: @"m4a"];
    //    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"嘀嘀报警声"
                                                withExtension: @"m4a"];
    // Store the URL as a CFURLRef instance
    CFURLRef soundFileURLRef = (__bridge CFURLRef)tapSound;
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (
                                      soundFileURLRef,
                                      &soundID
                                      );
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:tapSound error:nil];
    //DEBUGLog(@"duration:%f",self.player.duration);
}

void systemAudioCallback(SystemSoundID ssID,void* clientData)
{
    //AudioServicesPlaySystemSound(ssID);
    DEBUGLog(@"play vibrate");
    [NSObject cancelPreviousPerformRequestsWithTarget:global_Self selector:@selector(triggerShake) object:nil];
    [global_Self performSelector:@selector(triggerShake) withObject:nil afterDelay:1];
}

- (void)soundAlarm
{
    // 创建播放器
    //    self.player.volume = 1;
    //    self.player.numberOfLoops = 1; //设置音乐播放次数  -1为一直循环
    //    [self.player prepareToPlay];
    //    [self.player play];
    //    DEBUGLog(@"soundAlarm");
    
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, systemAudioCallback, NULL);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    AudioServicesPlaySystemSound(soundID);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopShare) object:nil];
    [self performSelector:@selector(stopShare) withObject:nil afterDelay:self.player.duration];
}

- (void)triggerShake
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
- (void)stopShare
{
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(triggerShake) object:nil];
}

#pragma mark - 遥控拍照
- (void)switchToRemoteMode
{
    [self.bleControl switchToControlMode:ControlModeRemote openOrClose:YES completion:^(BOOL success, NSString *failReason)
     {
         if (success) {//切换模式成功，进入相机界面
             [self showTip:NSLocalizedString(@"切换至拍照模式成功", nil)];
             
             UIImagePickerController *picker = [self openCamera];
             self.pickerController = picker;
             //            [self.bleControl.deviceProfile readDeviceRemoteDataWithCompletion:^(RemoteDataType dataType)
             //            {
             //                DEBUGLog(@"拍照。。。。。。,dataType:0x%X",(int)dataType);
             //                if (RemoteDataTypeTakephoto == dataType) {
             //                    [picker takePicture];
             //                }
             //            }];
         } else {
             [self showTip:NSLocalizedString(@"切换至拍照模式失败", nil)];
         }
     }];
}

- (UIImagePickerController *)openCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return nil;
    }
    UIImagePickerControllerSourceType sourceType;
    sourceType=UIImagePickerControllerSourceTypeCamera;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    //设置图像选取控制器的类型为静态图像
    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
    picker.allowsEditing=NO;
    picker.showsCameraControls = YES;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
    return picker;
}


#pragma mark - Notification
- (void)batteyChanged:(NSNotification *)notification
{
    UIDevice *device = notification.object;
    DEBUGLog(@">>>battery:%f",device.batteryLevel);
    if (device.batteryLevel == LOW_BATTERY_LEVEL1 ||
        device.batteryLevel == LOW_BATTERY_LEVEL2 ||
        device.batteryLevel == LOW_BATTERY_LEVEL3 ||
        device.batteryLevel == LOW_BATTERY_LEVEL4)
    {
        if ([self lowBatteryStatus]) {
            [self.bleControl.settingProfile setStartLowBatteryRemindCompletion:^(BOOL success) {
                DEBUGLog(@"开启低电量提醒成功");
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopLowBatteryRemind) object:nil];
                [self performSelector:@selector(stopLowBatteryRemind) withObject:nil afterDelay:LOW_BATTERY_REMIND_TIMEINTERVAL];
            }];
        }
    }
}

- (void)handleSuccessConnectPeripheral:(NSNotification *)notification
{
    [self.tableView reloadData];
    
    [self.bleControl.deviceProfile readDeviceRemoteDataWithCompletion:^(RemoteDataType dataType)
     {
         DEBUGLog(@"监听到的按键dataType:0x%X",(int)dataType);
         if (RemoteDataTypeTakephoto == dataType) {
             [self.pickerController takePicture];
         }
         else if (RemoteDataTypeFindPhone == dataType) {
             [self soundAlarm];
         }
     }];
    [self.pickerController showTip:NSLocalizedString(@"重新建立了连接", nil)];
}

- (void)handleDidDisConnectPeripheral:(NSNotification *)notification
{
    //[self.tableView reloadData];
    DEBUGLog(@"self.pickerController:%@",self.pickerController);
    [self.pickerController showTip:NSLocalizedString(@"您的连接已断开", nil)];
}


#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //判断是静态图像还是视频
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //UIImage* editedImage = [info objectForKey:UIImagePickerControllerEditedImage];//获取用户编辑之后的图像
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //将该图像保存到媒体库中
        UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.pickerController = nil;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.pickerController = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return SECTION_NUMBER;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return self.section1TitleArray.count;
        case 1:
            return self.section2TitleArray.count;
        case 2:
            return self.section3TitleArray.count;
        case 3:
            return self.section4TitleArray.count;
        case 4:
            return self.section5TitleArray.count;
            
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
            UINib *cellNib = [UINib nibWithNibName:@"WMSSwitchCell" bundle:nil];
            [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
            
            WMSSwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
            
            cell.myLabelText.text = [self.section1TitleArray objectAtIndex:indexPath.row];
            cell.myLabelText.textColor = [UIColor whiteColor];
            cell.myLabelText.font = Font_DINCondensed(18);
            
            if ([self.bleControl isConnected]) {
                NSDictionary *readData = [self readSettingItemData];
                NSString *key = [self keyForIndexpath:indexPath];
                if (key) {
                    cell.mySwitch.on = [[readData objectForKey:key] boolValue];
                    DEBUGLog(@"status:%d",cell.mySwitch.on);
                }
            } else {
                cell.mySwitch.on = NO;
            }
            
            if (indexPath.row == 3) {//电池
                cell.mySwitch.on = [self.bleControl isConnected] ? [self lowBatteryStatus] : NO;
            }
            
            cell.delegate = self;
            
            return cell;
        }
        case 1:
        {
            NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
            UINib *cellNib = [UINib nibWithNibName:@"WMSSwitchCell" bundle:nil];
            [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
            
            WMSSwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
            
            cell.myLabelText.text = [self.section2TitleArray objectAtIndex:indexPath.row];
            cell.myLabelText.textColor = [UIColor whiteColor];
            cell.myLabelText.font = Font_DINCondensed(18);
            
            if ([self.bleControl isConnected]) {
                NSDictionary *readData = [self readSettingItemData];
                NSString *key = [self keyForIndexpath:indexPath];
                if (key) {
                    cell.mySwitch.on = [[readData objectForKey:key] boolValue];
                }
            } else {
                cell.mySwitch.on = NO;
            }
            cell.delegate = self;
            
            return cell;
        }
        case 2:
        {
            NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",(int)indexPath.section,(int)indexPath.row];
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_b.png"]];
            
            NSString *txt = [self.section3TitleArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [CELL_CONTENT_PREFIX stringByAppendingString:txt];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = Font_DINCondensed(18);
            if ([self.bleControl isConnected]) {
                if ([self readRemindWay]-1 == indexPath.row) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            return cell;
        }
        case 3:
        {
            NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
            UINib *cellNib = [UINib nibWithNibName:@"WMSSwitchCell" bundle:nil];
            [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
            WMSSwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
            
            cell.myLabelText.text = [self.section4TitleArray objectAtIndex:indexPath.row];
            cell.myLabelText.textColor = [UIColor whiteColor];
            cell.myLabelText.font = Font_DINCondensed(18);
            cell.mySwitch.on = [self.bleControl isConnected]?[self antiLostStatus]:NO;
            
            cell.delegate = self;
            
            return cell;
        }
        case 4:
        {
            NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
            //[self.tableView registerClass:[UITableViewCell class]forCellReuseIdentifier:CellIdentifier];
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_b.png"]];
            
            NSString *txt = [self.section5TitleArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [CELL_CONTENT_PREFIX stringByAppendingString:txt];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = Font_DINCondensed(18);
            cell.detailTextLabel.text = NSLocalizedString(@"拍摄的照片保存在照片库", nil);
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.font = Font_System(12);//Font_DINCondensed(12);
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
            
        default:
            break;
    }
    
    return nil;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return SECTION0_HEADER_HEIGHT;
        case 1:
        case 2:
        case 3:
            return SECTION_HEADER_HEIGHT;
        case 4:
            return SECTION_HEADER_DEFAULT_HEIGHT;
            
        default:
            break;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return SECTION_FOOTER_DEFAULT_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [tableView rectForHeaderInSection:section].size.height;
    CGRect frame = CGRectMake(80, height-30, 200, 30);
    UIView *myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.font = Font_DINCondensed(18);
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    NSString *title = [self.headerTitleArray objectAtIndex:section];
    
    [titleLabel setText:title];
    [myView addSubview:titleLabel];
    
    return myView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
    BOOL result = [self checkoutWithIsBind:[WMSMyAccessory isBindAccessory] isConnected:self.bleControl.isConnected];
    if (result == NO) {
        return;
    }
    
    if (indexPath.section == 4 && indexPath.row == 0) {
        [self switchToRemoteMode];
        return;
    }
    
    if (indexPath.section == 2) {
        //WMSRemindWayViewController *vc = [[WMSRemindWayViewController alloc] init];
        //vc.title = self.section5TitleArray[indexPath.row];
        //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        //[self presentViewController:nav animated:YES completion:nil];
        
        if ([self readRemindWay] != indexPath.row) {//当提醒方式改变时再去设置
            for (int i=0; i<[self.section3TitleArray count]; i++) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:path];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            UITableViewCell *checkedCell=[self.tableView cellForRowAtIndexPath:indexPath];
            [checkedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
            
            int way = (int)indexPath.row+1;
            [self setRemindWay:way];
        }
        return;
    }
}


#pragma mark - WMSSwitchCellDelegage
- (void)switchCell:(WMSSwitchCell *)switchCell didClickSwitch:(UISwitch *)sw
{
    //    DEBUGLog(@"switchCell.title:%@, sw.on:%d",switchCell.myLabelText.text,sw.on);
    
    BOOL result = [self checkoutWithIsBind:[WMSMyAccessory isBindAccessory] isConnected:self.bleControl.isConnected];
    if (result == NO) {
        sw.on = (sw.on?NO:YES);//保持sw的状态不变
        return;
    }
    //当绑定手表，连接成功后，才能进行后面的操作
    if ([switchCell.myLabelText.text
         isEqualToString:NSLocalizedString(@"Battery", nil)])
    {
        [self setLowBattery:sw.on];
        return;
    }
    if ([switchCell.myLabelText.text
         isEqualToString:NSLocalizedString(@"防丢", nil)])
    {
        [self setAntiLost:sw.on];
        return;
    }
    
    
    NSIndexPath *atIndex = [self.tableView indexPathForCell:switchCell];
    
    NSDictionary *readData = [self readSettingItemData];
    NSArray *values = [readData objectsForKeys:self.settingItemArray notFoundMarker:@"aa"];
    NSUInteger events[7] = {RemindEventsTypeCall,RemindEventsTypeSMS,RemindEventsTypeEmail,RemindEventsTypeWeixin,RemindEventsTypeQQ,RemindEventsTypeFacebook,RemindEventsTypeTwitter};
    NSUInteger eventsType = 0x00;
    NSUInteger type = 0;
    for (int i=0; i<[values count]; i++) {
        NSIndexPath *indexPathObj = [self.cellIndexPathArray objectAtIndex:i];
        if (atIndex.section == indexPathObj.section && atIndex.row == indexPathObj.row)
        {
            type = events[i];
        } else {
            BOOL openOrClose = [[values objectAtIndex:i] boolValue];
            if (openOrClose) {
                eventsType = (eventsType | events[i]);
            }
        }
    }
    if ([sw isOn]) {
        eventsType = (eventsType | type);
    }
    DEBUGLog(@"eventsType:0x%X",(int)eventsType);
    [self.bleControl.settingProfile setRemindEventsType:eventsType completion:^(BOOL success)
     {
         if (success) {
             [self showOperationSuccessTip:NSLocalizedString(@"提醒设置成功", nil)];
             NSString *key = [self keyForIndexpath:atIndex];
             [self savaSettingItemForKey:key object:@([sw isOn])];
         }
     }];
}

@end
