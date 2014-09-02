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
#import "WMSSwitchCell.h"


#define SECTION_NUMBER  3
#define SECTION0_HEADER_HEIGHT  60.f
#define SECTION_HEADER_HEIGHT   50.f

@interface WMSRightViewController ()

@property (strong, nonatomic) NSArray *section1TitleArray;
@property (strong, nonatomic) NSArray *section2TitleArray;
@property (strong, nonatomic) NSArray *section3TitleArray;
@property (strong, nonatomic) NSArray *headerTitleArray;

@end

@implementation WMSRightViewController

#pragma mark - Property Getter Method
- (NSArray *)section1TitleArray
{
    if (!_section1TitleArray) {
        _section1TitleArray = @[NSLocalizedString(@"Telephone",nil),
                                NSLocalizedString(@"SMS",nil),
                                NSLocalizedString(@"Email",nil),
                                NSLocalizedString(@"Battery",nil)
                                ];
    }
    return _section1TitleArray;
}
- (NSArray *)section2TitleArray
{
    if (!_section2TitleArray) {
        _section2TitleArray = @[NSLocalizedString(@"WeiXin",nil),
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
        _section3TitleArray = @[NSLocalizedString(@"Take photos",nil)
                                ];
    }
    return _section3TitleArray;
}
- (NSArray *)headerTitleArray
{
    if (!_headerTitleArray) {
        _headerTitleArray = @[NSLocalizedString(@"Remind Setting",nil),
                              NSLocalizedString(@"Social contact",nil),
                              @""
                              ];
    }
    return _headerTitleArray;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            
            return cell;
        }
        case 2:
        {
            NSString *CellIdentifier = [NSString stringWithFormat:@"section%d%d",indexPath.section,indexPath.row];
            [self.tableView registerClass:[UITableViewCell class]forCellReuseIdentifier:CellIdentifier];
            
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_a.png"]];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_menu_bg_b.png"]];
            
            NSString *txt = [self.section3TitleArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [@"             " stringByAppendingString:txt];
            cell.textLabel.textColor = [UIColor whiteColor];
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
            return SECTION_HEADER_HEIGHT;
            
        default:
            break;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = CGRectMake(145, 20, 75, 20);
    if (section == 0) {
        frame = CGRectMake(145, 30, 75, 20);
    }
    UIView *myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.textColor=[UIColor whiteColor];
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
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        DEBUGLog(@"Take photos");
    }
}


@end
