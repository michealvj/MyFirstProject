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

#define kSendGroupMessage @"Send groupwide message"
#define kMapArea @"Map area"
#define kGPSSettings @"GPS settings"
#define kAutoLogout @"Auto logout"
#define kAutoLogoutTime @"Automatic logout time"
#define kAutoDeleteIncident @"Auto delete incidents"
#define kIncidentDeleteTime @"Incident deletion time"
#define kAllUsersCanSee @"All users can see each other"

@interface SettingsViewController ()
{
    NSMutableArray *settingsTitles, *settingsImages;
    NSString *gpsTime, *logoutTime, *incidentDeleteTime;
    NSIndexPath *selectedIndexPath;
    BOOL isAutomaticIncidentDeletionEnabled;
    BOOL isAutomaticLogoutEnabled;
    BOOL isVisibleToOtherUsers;
    Settings *initialSettings;
    UIBarButtonItem *saveButton;
}
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingsTableView.hidden = YES;
    self.settingsTableView.alwaysBounceVertical = NO;
    
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
        isAutomaticLogoutEnabled = settings.isAutomaticLogoutEnabled;
        initialSettings = settings;
        [self addDatasource];

    } WithError:^(NSString *error) {
        initialSettings=nil;
        [[CodeSnip sharedInstance] showAlert:@"News Crew Tracker" withMessage:error withTarget:self];
    }];
    
}

- (void)resetUnSavedSettings
{
    logoutTime = initialSettings.logoutTime;
    incidentDeleteTime = initialSettings.incidentDeletionTime;
    isAutomaticIncidentDeletionEnabled = initialSettings.isAutomaticDeletionEnabled;
    isVisibleToOtherUsers = initialSettings.isVisibleToOtherUsers;
    isAutomaticLogoutEnabled = initialSettings.isAutomaticLogoutEnabled;
    [self addDatasource];
}

- (void)addDatasource
{
    
    settingsTitles = [[NSMutableArray alloc] initWithArray:@[kSendGroupMessage,
                                                             kMapArea,
                                                             kGPSSettings,
                                                             kAutoLogout,
                                                             kAutoLogoutTime,
                                                             kAutoDeleteIncident,
                                                             kIncidentDeleteTime,
                                                             kAllUsersCanSee]];
    
    settingsImages = [[NSMutableArray alloc] initWithArray:@[@"groupmessage.png",
                                                             @"maparea.png",
                                                             @"gps.png",
                                                             @"automaticlogout.png",
                                                             @"automaticlogout.png",
                                                             @"incidentdeletion.png",
                                                             @"incidentdeletion.png",
                                                             @"eye.png"]];
    

    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    
    if (!isAutomaticLogoutEnabled) {
        [mutableIndexSet addIndex:LogoutTime];
    }
    if (!isAutomaticIncidentDeletionEnabled) {
        [mutableIndexSet addIndex:IncidentDeletionTime];
    }
    if (![UserDefaults isManager]) {
        [mutableIndexSet addIndex:AllUserCanSee];
    }
    if (mutableIndexSet.count>0) {
        [settingsTitles removeObjectsAtIndexes:mutableIndexSet];
        [settingsImages removeObjectsAtIndexes:mutableIndexSet];
    }
    
//    if (!isAutomaticLogoutEnabled&&!isAutomaticIncidentDeletionEnabled&&![UserDefaults isManager]) {
//        [settingsTitles removeObjectAtIndex:LogoutTime];
//        [settingsImages removeObjectAtIndex:LogoutTime];
//        [settingsTitles removeObjectAtIndex:AllUserCanSee];
//        [settingsImages removeObjectAtIndex:AllUserCanSee];
//        [settingsTitles removeObjectAtIndex:LogoutTime];
//        [settingsImages removeObjectAtIndex:LogoutTime];
//    }
//    else if (!isAutomaticIncidentDeletionEnabled&&![UserDefaults isManager]) {
//        [settingsTitles removeObjectAtIndex:AllUserCanSee];
//        [settingsImages removeObjectAtIndex:AllUserCanSee];
//        [settingsTitles removeObjectAtIndex:LogoutTime];
//        [settingsImages removeObjectAtIndex:LogoutTime];
//    }
//    else if (!isAutomaticIncidentDeletionEnabled) {
//        [settingsTitles removeObjectAtIndex:LogoutTime];
//        [settingsImages removeObjectAtIndex:LogoutTime];
//    }
//    else if (![UserDefaults isManager]) {
//        [settingsTitles removeObjectAtIndex:AllUserCanSee];
//        [settingsImages removeObjectAtIndex:AllUserCanSee];
//    }
    
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
    saveSettings.isAutomaticLogoutEnabled = isAutomaticLogoutEnabled;
    saveSettings.incidentDeletionTime = incidentDeleteTime;
    saveSettings.logoutTime = logoutTime;
    saveSettings.gpsTime = GPSTime;
    
    return saveSettings;
}

- (IBAction)OnOffSwitch:(UISwitch *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.settingsTableView];
    NSIndexPath *indexPath = [self.settingsTableView indexPathForRowAtPoint:buttonPosition];
    
    NSIndexPath *addIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:0];
    
    UITableViewCell *selectedCell = [self.settingsTableView cellForRowAtIndexPath:indexPath];
    UILabel *title = (UILabel *)[selectedCell viewWithTag:2];
  
    if ([title.text isEqualToString:kAllUsersCanSee])
    {
        isVisibleToOtherUsers = sender.on;
        [self addDatasource];
    }
    else if ([title.text isEqualToString:kAutoDeleteIncident])
    {
        [self reloadTableViewWithAnimationAtIndexPath:addIndexPath WithTitle:kIncidentDeleteTime WithImage:@"incidentdeletion.png" WithStatus:sender.on];
        isAutomaticIncidentDeletionEnabled = sender.on;
    }
    else if ([title.text isEqualToString:kAutoLogout])
    {
        [self reloadTableViewWithAnimationAtIndexPath:addIndexPath WithTitle:kAutoLogoutTime WithImage:@"automaticlogout.png" WithStatus:sender.on];
        isAutomaticLogoutEnabled = sender.on;
    }
}

- (void)reloadTableViewWithAnimationAtIndexPath:(NSIndexPath *)indexPath WithTitle:(NSString *)title WithImage:(NSString *)image WithStatus:(BOOL)isSwitchOn
{
    [CATransaction begin];
    
    [self.settingsTableView  beginUpdates];
    
    //...
    
    [CATransaction setCompletionBlock: ^{
        // Code to be executed upon completion
        [self addDatasource];
    }];
    
    if (isSwitchOn) {
        [settingsTitles insertObject:title atIndex:indexPath.row];
        [settingsImages insertObject:image atIndex:indexPath.row];
        [self.settingsTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [settingsTitles removeObjectAtIndex:indexPath.row];
        [settingsImages removeObjectAtIndex:indexPath.row];
        [self.settingsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.settingsTableView  endUpdates];
    
    [CATransaction commit];
    
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
    
    if ([title.text isEqualToString:kAutoLogoutTime]) {
        logoutTime = [dateFormat stringFromDate:sdate];
    }
    else if ([title.text isEqualToString:kIncidentDeleteTime]) {
        incidentDeleteTime = [dateFormat stringFromDate:sdate];
    }
    [self.settingsTableView reloadData];
    [self setSaveButton];
}

#pragma mark - Webservice Handler Delegate

- (void)requestFailedWithError:(NSError *)error
{
    [[CodeSnip sharedInstance] showAlert:@"Network Error" withMessage:[error localizedDescription] withTarget:self];
}

- (void)showErrorAlertWithTitle:(NSString *)title WithMessage:(NSString *)message
{
    [[CodeSnip sharedInstance] showAlert:title withMessage:message withTarget:self];
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
    
    NSString *currentCellTitle = [settingsTitles objectAtIndex:indexPath.row];
    
    if ([currentCellTitle isEqualToString:kSendGroupMessage]||[currentCellTitle isEqualToString:kMapArea]) {
        MyIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
        
        UIImageView *settingsImageView = (UIImageView *)[cell viewWithTag:1];
        UILabel *settingsTitleLabel = (UILabel *)[cell viewWithTag:2];
        
        settingsImageView.image = [UIImage imageNamed:[settingsImages objectAtIndex:indexPath.row]];
        settingsTitleLabel.text = [settingsTitles objectAtIndex:indexPath.row];
    }
    
    else if ([currentCellTitle isEqualToString:kGPSSettings]) {
        MyIdentifier = @"Cell1";
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
        
        UIImageView *settingsImageView = (UIImageView *)[cell viewWithTag:1];
        UILabel *settingsTitleLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *settingsValueLabel = (UILabel *)[cell viewWithTag:3];
        
        settingsImageView.image = [UIImage imageNamed:[settingsImages objectAtIndex:indexPath.row]];
        settingsTitleLabel.text = [settingsTitles objectAtIndex:indexPath.row];
        settingsValueLabel.text = gpsTime;
    }

    else if ([currentCellTitle isEqualToString:kAutoLogout]) {
        MyIdentifier = @"Cell3";
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
        [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:isAutomaticLogoutEnabled];
    }

    else if ([currentCellTitle isEqualToString:kAutoLogoutTime]) {
        MyIdentifier = @"Cell2";
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
        [self configureTimeCell:cell AtIndexPath:indexPath];
    }

     else if ([currentCellTitle isEqualToString:kAutoDeleteIncident]) {
         MyIdentifier = @"Cell3";
         cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
         [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:isAutomaticIncidentDeletionEnabled];
     }

     else if ([currentCellTitle isEqualToString:kIncidentDeleteTime]) {
         MyIdentifier = @"Cell2";
         cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
         [self configureTimeCell:cell AtIndexPath:indexPath];
     }

     else if ([currentCellTitle isEqualToString:kAllUsersCanSee]) {
         MyIdentifier = @"Cell3";
         cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
         [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:isVisibleToOtherUsers];
     }

//    else if(isAutomaticLogoutEnabled) {
//        
//    }
//    
//    else if (isAutomaticIncidentDeletionEnabled&&[UserDefaults isManager])
//    {
//        if (indexPath.row==4)
//        {
//            MyIdentifier = @"Cell3";
//            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:YES];
//        }
//        else if (indexPath.row==6)
//        {
//            MyIdentifier = @"Cell3";
//            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:isVisibleToOtherUsers];
//        }
//        else
//        {
//            MyIdentifier = @"Cell2";
//            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//            [self configureTimeCell:cell AtIndexPath:indexPath];
//        }
//    }
//    else if (!isAutomaticIncidentDeletionEnabled&&[UserDefaults isManager])
//    {
//        if (indexPath.row==4)
//        {
//            MyIdentifier = @"Cell3";
//            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:NO];
//        }
//        else if (indexPath.row==5)
//        {
//            MyIdentifier = @"Cell3";
//            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:isVisibleToOtherUsers];
//        }
//        else
//        {
//            MyIdentifier = @"Cell2";
//            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//            [self configureTimeCell:cell AtIndexPath:indexPath];
//        }
//    }
//    else if (isAutomaticIncidentDeletionEnabled) {
//        
//        if (indexPath.row==4)
//        {
//            MyIdentifier = @"Cell3";
//            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//            [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:isAutomaticIncidentDeletionEnabled];
//        }
//        else
//        {
//            MyIdentifier = @"Cell2";
//            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//            [self configureTimeCell:cell AtIndexPath:indexPath];
//        }
//    }
//
//    else {
//        MyIdentifier = @"Cell3";
//        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
//        [self configureSwitchCell:cell AtIndexPath:indexPath WithEnabledStatus:NO];
//    }
    
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
    if ([[settingsTitles objectAtIndex:indexPath.row] isEqualToString:kAutoLogoutTime]) {
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
    if ([title.text isEqualToString:kAutoLogoutTime]) {
        [self showDatePopupView];
    }
    else if ([title.text isEqualToString:kIncidentDeleteTime]) {
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

- (void)enableBlurView
{
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:blurEffectView];
    }
    else {
        self.view.backgroundColor = [UIColor blackColor];
    }
}

@end
