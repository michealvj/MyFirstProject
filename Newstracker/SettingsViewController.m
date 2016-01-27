//
//  SettingsViewController.m
//  Newstracker
//
//  Created by Micheal on 21/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "SettingsViewController.h"
#import "SideBar.h"
#import "GroupMessageViewController.h"
#import "MapAreaViewController.h"
#import "UIColor+myColors.h"
#import <POP.h>

@interface SettingsViewController ()
{
    NSMutableArray *settingsTitles, *settingsImages;
    NSString *gpsTime, *logoutTime, *incidentDeleteTime;
    NSIndexPath *selectedIndexPath;
    BOOL isAutomaticLogoutEnabled, isAutomaticIncidentDeletionEnabled;
}
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datePickerBottomConstraint.constant = -self.datePopupView.frame.size.height;
    
    [self navigationBarSetup];
    [self loadInitialSettings];
    [self addDatasource];
}

- (void)navigationBarSetup
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Settings";
    [[SideBar sharedInstance] setUpImage:@"menu.png" WithTarget:self];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSettings)];
    saveButton.tintColor = [UIColor myBlueColor];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)loadInitialSettings
{
    NSString *min = [[UserDefaults getGPSTime] intValue]==1 ? @"min":@"mins";
    gpsTime = [NSString stringWithFormat:@"%@ %@", [UserDefaults getGPSTime], min];
    logoutTime = @"12:00 AM";
    incidentDeleteTime = @"12:00 AM";
    isAutomaticIncidentDeletionEnabled = NO;
    isAutomaticLogoutEnabled = NO;
}

- (void)addDatasource
{
    settingsTitles = [[NSMutableArray alloc] initWithArray:@[@"Send groupwide message",
                                                             @"Map area",
                                                             @"GPS settings",
                                                             @"Automatic logout time",
                                                             @"Auto delete incidents",
                                                             @"Incident deletion time"]];
    
    settingsImages = [[NSMutableArray alloc] initWithArray:@[@"groupmessage.png",
                                                             @"maparea.png",
                                                             @"gps.png",
                                                             @"automaticlogout.png",
                                                             @"incidentdeletion.png",
                                                             @"incidentdeletion.png"]];
    
//    if (!isAutomaticIncidentDeletionEnabled&&!isAutomaticLogoutEnabled) {
//        [settingsTitles removeObjectAtIndex:6];
//        [settingsImages removeObjectAtIndex:6];
//        [settingsTitles removeObjectAtIndex:4];
//        [settingsImages removeObjectAtIndex:4];
//    }
    if (!isAutomaticIncidentDeletionEnabled) {
        [settingsTitles removeObjectAtIndex:5];
        [settingsImages removeObjectAtIndex:5];
    }
//    else if (!isAutomaticLogoutEnabled) {
//        [settingsTitles removeObjectAtIndex:4];
//        [settingsImages removeObjectAtIndex:4];
//    }
    
    [self.settingsTableView reloadData];
}

#pragma mark - Pop animation Methods

- (void)showDatePopupView
{
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 5.0f;
    layoutAnimation.toValue = @(0);
    [self.datePickerBottomConstraint pop_addAnimation:layoutAnimation forKey:@"notification"];
}

- (void)hideDatePopupView
{
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 5.0f;
    layoutAnimation.toValue = @(-self.datePopupView.bounds.size.height);
    [self.datePickerBottomConstraint pop_addAnimation:layoutAnimation forKey:@"notification"];
}

#pragma mark - IBActions

- (void)saveSettings
{
    [[WebServiceHandler sharedInstance] saveSettings];
}

- (IBAction)OnOffSwitch:(UISwitch *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.settingsTableView];
    NSIndexPath *indexPath = [self.settingsTableView indexPathForRowAtPoint:buttonPosition];
    NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
    
    UITableViewCell *selectedCell = [self.settingsTableView cellForRowAtIndexPath:indexPath];
    UILabel *title = (UILabel *)[selectedCell viewWithTag:2];
  
//    if ([title.text isEqualToString:@"Automatic logout"])
//    {
//        [self showOrHideLogoutTime:sender AtIndexPath:insertIndexPath];
//    }
    if ([title.text isEqualToString:@"Auto delete incidents"])
    {
        [self showOrHideIncidentTime:sender AtIndexPath:insertIndexPath];
    }
}

//- (void)showOrHideLogoutTime:(UISwitch *)sender AtIndexPath:(NSIndexPath *)indexPath
//{
//    if (sender.on) {
//        isAutomaticLogoutEnabled = YES;
//        [self addDatasource];
//    }
//    else {
//        isAutomaticLogoutEnabled = NO;
//        [self addDatasource];
//    }
//}

- (void)showOrHideIncidentTime:(UISwitch *)sender AtIndexPath:(NSIndexPath *)indexPath
{
    if (sender.on) {
        isAutomaticIncidentDeletionEnabled = YES;
        
        [self addDatasource];
    }
    else {
        isAutomaticIncidentDeletionEnabled = NO;
        [self addDatasource];
    }
}


- (IBAction)cancelButtonPressed:(id)sender {
    [self hideDatePopupView];
}

- (IBAction)doneButtonPressed:(id)sender
{
    [self hideDatePopupView];
    NSDate *sdate = self.datePicker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm a"];
    
    UITableViewCell *selectedCell = [self.settingsTableView cellForRowAtIndexPath:selectedIndexPath];
    
    UILabel *title = (UILabel *)[selectedCell viewWithTag:2];
    
    if ([title.text isEqualToString:@"Automatic logout time"]) {
        logoutTime = [dateFormat stringFromDate:sdate];
    }
    else if ([title.text isEqualToString:@"Incident deletion time"]) {
        incidentDeleteTime = [dateFormat stringFromDate:sdate];
    }
    [self.settingsTableView reloadData];
}

#pragma mark - Tableview delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return settingsTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *MyIdentifier;
    UITableViewCell *cell;
    if (indexPath.row<=1) {
        MyIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
        
        UIImageView *settingsImageView = (UIImageView *)[cell viewWithTag:1];
        UILabel *settingsTitleLabel = (UILabel *)[cell viewWithTag:2];
        
        settingsImageView.image = [UIImage imageNamed:[settingsImages objectAtIndex:indexPath.row]];
        settingsTitleLabel.text = [settingsTitles objectAtIndex:indexPath.row];
    }
    
    else if (indexPath.row==2) {
        MyIdentifier = @"Cell1";
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
        
        UIImageView *settingsImageView = (UIImageView *)[cell viewWithTag:1];
        UILabel *settingsTitleLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *settingsValueLabel = (UILabel *)[cell viewWithTag:3];
        
        settingsImageView.image = [UIImage imageNamed:[settingsImages objectAtIndex:indexPath.row]];
        settingsTitleLabel.text = [settingsTitles objectAtIndex:indexPath.row];
        settingsValueLabel.text = gpsTime;
    }
    else if (indexPath.row==3) {
        MyIdentifier = @"Cell2";
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
        [self configureTimeCell:cell AtIndexPath:indexPath];
    }
//    else if (isAutomaticIncidentDeletionEnabled&&isAutomaticLogoutEnabled)
//    {
//        if (indexPath.row==3||indexPath.row==5)
//        {
//            MyIdentifier = @"Cell3";
//            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:YES];
//        }
//        else
//        {
//            MyIdentifier = @"Cell2";
//            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//            [self configureTimeCell:cell AtIndexPath:indexPath];
//        }
//    }
//    else if (isAutomaticLogoutEnabled) {
//        if (indexPath.row==3||indexPath.row==5)
//        {
//            MyIdentifier = @"Cell3";
//            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//            BOOL isEnabled = indexPath.row==3?YES:NO;
//            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:isEnabled];
//        }
//        else
//        {
//            MyIdentifier = @"Cell2";
//            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//            [self configureTimeCell:cell AtIndexPath:indexPath];
//        }
//    }
    else if (isAutomaticIncidentDeletionEnabled) {
        
        if (indexPath.row==3||indexPath.row==4)
        {
            MyIdentifier = @"Cell3";
            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
            BOOL isEnabled = indexPath.row==3?NO:YES;
            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:isEnabled];
        }
        else
        {
            MyIdentifier = @"Cell2";
            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
            [self configureTimeCell:cell AtIndexPath:indexPath];
        }
    }

    else {
        MyIdentifier = @"Cell3";
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
        [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:NO];
    }
    
    return cell;
}

- (void)configureSwitchCell:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath WithEnabledStatus:(BOOL)isEnabled
{
    UIImageView *settingsImageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *settingsTitleLabel = (UILabel *)[cell viewWithTag:2];
    UISwitch *settingsSwitch = (UISwitch *)[cell viewWithTag:3];
    
    settingsImageView.image = [UIImage imageNamed:[settingsImages objectAtIndex:indexPath.row]];
    settingsTitleLabel.text = [settingsTitles objectAtIndex:indexPath.row];
    
    if (isEnabled)
    {
        [settingsSwitch setOn:YES];
        settingsImageView.alpha = 1.0;
        settingsTitleLabel.textColor = [UIColor blackColor];
    }
    else
    {
        [settingsSwitch setOn:NO];
        settingsImageView.alpha = 0.5;
        settingsTitleLabel.textColor = [UIColor lightGrayColor];
    }
}

- (void)configureTimeCell:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *settingsImageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *settingsTitleLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *settingsValueLabel = (UILabel *)[cell viewWithTag:3];
    
    settingsImageView.image = [UIImage imageNamed:[settingsImages objectAtIndex:indexPath.row]];
    settingsTitleLabel.text = [settingsTitles objectAtIndex:indexPath.row];
    if (indexPath.row==3) {
        settingsValueLabel.text = logoutTime;
    }
    else {
        settingsValueLabel.text = incidentDeleteTime;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [self.settingsTableView cellForRowAtIndexPath:indexPath];
    UILabel *title = (UILabel *)[selectedCell viewWithTag:2];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndexPath = indexPath;
    [self hideDatePopupView];
    switch (indexPath.row) {
        case 0:
        {
            GroupMessageViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupMessageViewController"];
            [self.navigationController pushViewController:nav animated:YES];
            break;
        }
        case 1:
        {
            MapAreaViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"MapAreaViewController"];
            [self.navigationController pushViewController:nav animated:YES];
            break;
        }
        case 2:
        {
            [self showTimeActionSheet];
            break;
        }
        default:
            break;
    }
    if ([title.text isEqualToString:@"Automatic logout time"]) {
        [self showDatePopupView];
    }
    else if ([title.text isEqualToString:@"Incident deletion time"]) {
        [self showDatePopupView];
    }
}

#pragma mark - Actionsheet delegate

- (void)showTimeActionSheet
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Choose the Time for GPS Sharing" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"1 min" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        gpsTime = @"1 min";
        [UserDefaults setGPSTime:@"1"];
        [self.settingsTableView reloadData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"5 mins" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        gpsTime = @"5 mins";
        [UserDefaults setGPSTime:@"5"];
        [self.settingsTableView reloadData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"15 mins" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        gpsTime = @"15 mins";
        [UserDefaults setGPSTime:@"15"];
        [self.settingsTableView reloadData];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
