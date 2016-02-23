//
//  SideMenuViewController.m
//  Newstracker
//
//  Created by Micheal on 08/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//
#define TOPCOLOR [UIColor colorWithRed:36.0f/255.0f green:198.0f/255.0f blue:220.0f/255.0f alpha:1.0f]
#define BOTCOLOR [UIColor colorWithRed:18.0f/255.0f green:82.0f/255.0f blue:190.0f/255.0f alpha:1.0f]

#import "SideMenuViewController.h"

@interface SideMenuViewController ()
{
    NSArray *menuArray;
}
@end

@implementation SideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)BOTCOLOR.CGColor, (id)TOPCOLOR.CGColor, nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    menuArray = [[Menu sharedInstance] getMenuList];
    self.groupNameLabel.text = [UserDefaults getGroupName];

}

#pragma mark - Collectionview delegate and datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return menuArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *MyIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MyIdentifier forIndexPath:indexPath];
    
    Menu *menulist = [menuArray objectAtIndex:indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    
    titleLabel.text = menulist.menuTitle;
    imageView.image = [UIImage imageNamed:menulist.menuImage];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            MapViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            NSArray *controllers = [NSArray arrayWithObject:nav];
            navigationController.viewControllers = controllers;
            [navigationController popViewControllerAnimated:YES];
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            break;
        }
        case 1:
        {
            OnlineOfflineViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"OnlineOfflineViewController"];
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            NSArray *controllers = [NSArray arrayWithObject:nav];
            navigationController.viewControllers = controllers;
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            break;
        }
        case 2:
        {
            IncidentListViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"IncidentListViewController"];
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            NSArray *controllers = [NSArray arrayWithObject:nav];
            navigationController.viewControllers = controllers;
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            break;
        }
        case 3:
        {
            SettingsViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            NSArray *controllers = [NSArray arrayWithObject:nav];
            navigationController.viewControllers = controllers;
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            break;
        }
        case 4:
        {
            MessageViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            NSArray *controllers = [NSArray arrayWithObject:nav];
            navigationController.viewControllers = controllers;
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            break;
        }
        case 5:
        {
            [UserDefaults showTutorials];
            MapViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            NSArray *controllers = [NSArray arrayWithObject:nav];
            navigationController.viewControllers = controllers;
            [navigationController popViewControllerAnimated:YES];
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

            break;
       }
        case 6:
        {
            PrivacyViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyViewController"];
            nav.navigationTitle = @"Privacy Policy";
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            NSArray *controllers = [NSArray arrayWithObject:nav];
            navigationController.viewControllers = controllers;
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            break;
        }
        case 7:
        {
            PrivacyViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyViewController"];
            nav.navigationTitle = @"Terms & Conditions";
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            NSArray *controllers = [NSArray arrayWithObject:nav];
            navigationController.viewControllers = controllers;
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            break;
        }
        case 8:
        {
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            [WebServiceHandler sharedInstance].delegate = self;
            [[WebServiceHandler sharedInstance] logOffUser];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - Webservice Handler Delegate

- (void)requestFailedWithError:(NSError *)error
{
    [[CodeSnip sharedInstance] showAlert:@"News Crew Tracker" withMessage:[error localizedDescription] withTarget:self];
}

- (void)showErrorAlertWithTitle:(NSString *)title WithMessage:(NSString *)message
{
    [[CodeSnip sharedInstance] showAlert:title withMessage:message withTarget:self];
}

- (void)didLogOffUser:(NSString *)message
{
    LoginViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:nav];
    navigationController.viewControllers = controllers;
    [[CodeSnip sharedInstance] showAlert:@"News Crew Tracker" withMessage:message withTarget:self];
    
    [UserDefaults clearUserID];
    [UserDefaults clearGroupID];
    [UserDefaults clearGroupName];
    [UserDefaults clearMapAddress];
    [UserDefaults clearMapLocation];
    [UserDefaults clearOfflineDatas];
    
    [[LocationTracker sharedLocationManager] stopUpdatingLocation];
    AppDelegate *appdel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appdel.locationUpdateTimer invalidate];
}

@end
