//
//  SettingsViewController.m
//  Newstracker
//
//  Created by Micheal on 21/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "SettingsViewController.h"
#import "SideBar.h"
#import "MFSideMenuContainerViewController.h"
#import "MFSideMenu.h"
#import "GroupMessageViewController.h"
#import "MapAreaViewController.h"
#import "UIColor+myColors.h"
#import "UIBarButtonItem+utils.h"
#import "Settings.h"
#import <POP.h>

@interface SettingsViewController ()
{
    NSMutableArray *settingsTitles, *settingsImages;
    NSString *gpsTime, *logoutTime, *incidentDeleteTime;
    NSIndexPath *selectedIndexPath;
    BOOL isAutomaticIncidentDeletionEnabled;
    BOOL isVisibleToOtherUsers;
    Settings *initialSettings;
    UIBarButtonItem *saveButton;
}
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingsTableView.hidden = YES;
    self.datePickerBottomConstraint.constant = -self.datePopupView.frame.size.height;
    
    [self navigationBarSetup];
 
    [self loadInitialSettings];
}

- (void)navigationBarSetup
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Settings";
    
    saveButton = [[navBar sharedInstance] setSaveImageWithScale:0.7 WithPadding:1.0 isLeftSide:YES WithAction:^{
        [self saveFinalSettings];
    }];
    saveButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIBarButtonItem *menuBar = [[navBar sharedInstance] setMenuImageWithScale:0.7 WithPadding:1.0 isLeftSide:YES WithAction:^{
        if (![[Settings sharedInstance] isSettingsChanged:[self getFinalSettings] WithInitialSettings:initialSettings]) {
            [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
        }
        else {
            UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self saveFinalSettings];
                
            }];
            
            UIAlertAction *unsaveAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self resetUnSavedSettings];
                
            }];
            
            UIAlertController *alert = [[CodeSnip sharedInstance] createAlertWithAction:@"Settings not saved" withMessage:@"Do you want to save the changes?" withCancelButton:nil withTarget:self];
            [alert addAction:saveAction];
            [alert addAction:unsaveAction];
        }
    }];
    self.navigationItem.leftBarButtonItem = menuBar;

    
//    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(saveFinalSettings)];
    

}

- (void)loadInitialSettings
{
    [[WebServiceHandler sharedInstance] getSettingsWithSuccess:^(Settings *settings) {
        self.settingsTableView.hidden = NO;
        gpsTime = settings.gpsTime;
        logoutTime = settings.logoutTime;
        incidentDeleteTime = settings.incidentDeletionTime;
        isAutomaticIncidentDeletionEnabled = settings.isAutomaticDeletionEnabled;
        isVisibleToOtherUsers = settings.isVisibleToOtherUsers;
        initialSettings = settings;
        [self addDatasource];

    } WithError:^(NSString *error) {
        [[CodeSnip sharedInstance] showAlert:@"News Crew Tracker" withMessage:error withTarget:self];
    }];
    
}

- (void)resetUnSavedSettings
{
    logoutTime = initialSettings.logoutTime;
    incidentDeleteTime = initialSettings.incidentDeletionTime;
    isAutomaticIncidentDeletionEnabled = initialSettings.isAutomaticDeletionEnabled;
    isVisibleToOtherUsers = initialSettings.isVisibleToOtherUsers;
    [self addDatasource];
}

- (void)addDatasource
{
    settingsTitles = [[NSMutableArray alloc] initWithArray:@[@"Send groupwide message",
                                                             @"Map area",
                                                             @"GPS settings",
                                                             @"Automatic logout time",
                                                             @"Auto delete incidents",
                                                             @"Incident deletion time",
                                                             @"All users can see each other"]];
    
    settingsImages = [[NSMutableArray alloc] initWithArray:@[@"groupmessage.png",
                                                             @"maparea.png",
                                                             @"gps.png",
                                                             @"automaticlogout.png",
                                                             @"incidentdeletion.png",
                                                             @"incidentdeletion.png",
                                                             @"eye.png"]];
    
    if (!isAutomaticIncidentDeletionEnabled&&![UserDefaults isManager]) {
        [settingsTitles removeObjectAtIndex:6];
        [settingsImages removeObjectAtIndex:6];
        [settingsTitles removeObjectAtIndex:5];
        [settingsImages removeObjectAtIndex:5];
    }
    else if (!isAutomaticIncidentDeletionEnabled) {
        [settingsTitles removeObjectAtIndex:5];
        [settingsImages removeObjectAtIndex:5];
    }
    else if (![UserDefaults isManager]) {
        [settingsTitles removeObjectAtIndex:6];
        [settingsImages removeObjectAtIndex:6];
    }
    
    [self.settingsTableView reloadData];
    [self setSaveButton];
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

- (void)saveFinalSettings
{
    [WebServiceHandler sharedInstance].delegate = self;
    [[WebServiceHandler sharedInstance] saveSettings:[self getFinalSettings]];
}

- (void)didSaveSettings
{
    initialSettings = [self getFinalSettings];
    [self setSaveButton];
}

- (void)requestFailedWithError:(NSError *)error
{
    [[CodeSnip sharedInstance] showAlert:@"Network Error" withMessage:[error localizedDescription] withTarget:self];
}

- (void)showErrorAlertWithTitle:(NSString *)title WithMessage:(NSString *)message
{
    [[CodeSnip sharedInstance] showAlert:title withMessage:message withTarget:self];
}

- (void)setSaveButton
{
    if ([[Settings sharedInstance] isSettingsChanged:[self getFinalSettings] WithInitialSettings:initialSettings]) {
        saveButton.enabled = YES;
    }
    else {
        saveButton.enabled = NO;
    }

}

- (Settings *)getFinalSettings
{
    NSString *mapLatitude = [NSString stringWithFormat:@"%f", [UserDefaults getMapLocation].latitude];
    NSString *mapLongitude = [NSString stringWithFormat:@"%f", [UserDefaults getMapLocation].longitude];
    
    NSString *min = [[UserDefaults getGPSTime] intValue]==1 ? @"min":@"mins";
    NSString *GPSTime = [NSString stringWithFormat:@"%@ %@", [UserDefaults getGPSTime], min];
    
    
    Settings *saveSettings = [Settings new];
    saveSettings.mapCoordinate = CLLocationCoordinate2DMake([mapLatitude doubleValue], [mapLongitude doubleValue]);
    saveSettings.mapLocation = [UserDefaults getMapAddress];
    saveSettings.isVisibleToOtherUsers = isVisibleToOtherUsers;
    saveSettings.isAutomaticDeletionEnabled = isAutomaticIncidentDeletionEnabled;
    saveSettings.incidentDeletionTime = incidentDeleteTime;
    saveSettings.logoutTime = logoutTime;
    saveSettings.gpsTime = GPSTime;
    
    return saveSettings;
}

- (IBAction)OnOffSwitch:(UISwitch *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.settingsTableView];
    NSIndexPath *indexPath = [self.settingsTableView indexPathForRowAtPoint:buttonPosition];
    NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
    
    UITableViewCell *selectedCell = [self.settingsTableView cellForRowAtIndexPath:indexPath];
    UILabel *title = (UILabel *)[selectedCell viewWithTag:2];
  
    if ([title.text isEqualToString:@"All users can see each other"])
    {
        isVisibleToOtherUsers = sender.on;
        [self addDatasource];
    }
    else if ([title.text isEqualToString:@"Auto delete incidents"])
    {
        [self showOrHideIncidentTime:sender AtIndexPath:insertIndexPath];
    }
}

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
    [self setSaveButton];
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
    
    else if (isAutomaticIncidentDeletionEnabled&&[UserDefaults isManager])
    {
        if (indexPath.row==4)
        {
            MyIdentifier = @"Cell3";
            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:YES];
        }
        else if (indexPath.row==6)
        {
            MyIdentifier = @"Cell3";
            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:isVisibleToOtherUsers];
        }
        else
        {
            MyIdentifier = @"Cell2";
            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
            [self configureTimeCell:cell AtIndexPath:indexPath];
        }
    }
    else if (!isAutomaticIncidentDeletionEnabled&&[UserDefaults isManager])
    {
        if (indexPath.row==4)
        {
            MyIdentifier = @"Cell3";
            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:NO];
        }
        else if (indexPath.row==5)
        {
            MyIdentifier = @"Cell3";
            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:isVisibleToOtherUsers];
        }
        else
        {
            MyIdentifier = @"Cell2";
            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
            [self configureTimeCell:cell AtIndexPath:indexPath];
        }
    }
    else if (isAutomaticIncidentDeletionEnabled) {
        
        if (indexPath.row==4)
        {
            MyIdentifier = @"Cell3";
            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:isAutomaticIncidentDeletionEnabled];
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
//        settingsImageView.alpha = 1.0;
//        settingsTitleLabel.textColor = [UIColor blackColor];
    }
    else
    {
        [settingsSwitch setOn:NO];
//        settingsImageView.alpha = 0.5;
//        settingsTitleLabel.textColor = [UIColor lightGrayColor];
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
    
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveFinalSettings];

    }];
    
    UIAlertAction *continueGroupAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        GroupMessageViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupMessageViewController"];
        [self resetUnSavedSettings];
        [self.navigationController pushViewController:nav animated:YES];
        
    }];

    UIAlertAction *continueMapAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MapAreaViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"MapAreaViewController"];
      [self resetUnSavedSettings];
      [self.navigationController pushViewController:nav animated:YES];
        
    }];

    switch (indexPath.row) {
            
        case 0:
        {
            if ([[Settings sharedInstance] isSettingsChanged:[self getFinalSettings] WithInitialSettings:initialSettings])
            {
                NSLog(@"Changes Made");
                UIAlertController *alert = [[CodeSnip sharedInstance] createAlertWithAction:@"Settings not saved" withMessage:@"Do you want to continue without saving the changes?" withCancelButton:nil withTarget:self];
               [alert addAction:saveAction];
               [alert addAction:continueGroupAction];
            }
            else {
                NSLog(@"No Changes");
                GroupMessageViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupMessageViewController"];
                [self.navigationController pushViewController:nav animated:YES];
            }
            
            break;
        }
        case 1:
        {
            if ([[Settings sharedInstance] isSettingsChanged:[self getFinalSettings] WithInitialSettings:initialSettings])
            {
                NSLog(@"Changes Made");
                UIAlertController *alert = [[CodeSnip sharedInstance] createAlertWithAction:@"Settings not saved" withMessage:@"Do you want to continue without saving the changes?" withCancelButton:nil withTarget:self];
                [alert addAction:saveAction];
                [alert addAction:continueMapAction];
            }
            else {
                NSLog(@"No Changes");
                MapAreaViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"MapAreaViewController"];
                nav.settings = [self getFinalSettings];
                [self.navigationController pushViewController:nav animated:YES];
            }
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
        [self resetTimer];
        [self.settingsTableView reloadData];
        [self setSaveButton];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"5 mins" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        gpsTime = @"5 mins";
        [UserDefaults setGPSTime:@"5"];
        [self resetTimer];
        [self.settingsTableView reloadData];
        [self setSaveButton];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"15 mins" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        gpsTime = @"15 mins";
        [UserDefaults setGPSTime:@"15"];
        [self resetTimer];
        [self.settingsTableView reloadData];
        [self setSaveButton];
   }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetTimer
{
    AppDelegate *appdel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appdel.locationUpdateTimer invalidate];
    [appdel backgroundLocationUpdate];
}

@end
