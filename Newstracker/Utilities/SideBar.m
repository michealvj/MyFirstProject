//
//  SideBar.m
//  mfsidemenu
//
//  Created by Michel on 11/4/15.
//  Copyright (c) 2015 Micheal. All rights reserved.
//

#import "SideBar.h"
#import "MFSideMenuContainerViewController.h"
#import "MFSideMenu.h"
#import "AppDelegate.h"
#import "MapViewController.h"
#import "UIBarButtonItem+utils.h"
#import "UIColor+myColors.h"

#define leftViewController @"SideMenuViewController"
#define MainViewController @"MapViewController"


#define menuScale 0.7

@implementation SideBar
@synthesize selfObject;

+ (SideBar *)sharedInstance
{
    static SideBar *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[SideBar alloc] init];
    });
    return model;
}

- (void)setUpImage:(NSString *)imageName WithTarget:(UIViewController *)objectname
{
    UIImage *menu = [UIImage imageNamed:imageName];
    UIButton* menu_BUT = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, menu.size.width*menuScale, menu.size.height*menuScale)];
    menu_BUT.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [menu_BUT setImage:menu forState:UIControlStateNormal];
    [menu_BUT addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    //Left navigation
    UIBarButtonItem *menubar = [[UIBarButtonItem alloc] initWithCustomView:menu_BUT];
    objectname.navigationItem.leftBarButtonItem = menubar;
    selfObject = objectname;
    
}
- (void)setUpSideMenu
{
    AppDelegate *appdel = [[UIApplication sharedApplication] delegate];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *leftSideMenuViewController = [storyboard instantiateViewControllerWithIdentifier:leftViewController];
    
    UIViewController *navigation = [storyboard instantiateViewControllerWithIdentifier:MainViewController];
    
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:navigation];
    // leftsideview *left = [[leftsideview alloc] init];
    
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:nav
                                                    leftMenuViewController:leftSideMenuViewController
                                                    rightMenuViewController:nil];
    
    appdel.window.rootViewController=container;
    
}

- (void)toggleMenu
{
    [selfObject.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (void)setUpSearchBarWithTarget:(UIViewController *)objectname WithCreateButtonAction:(void (^)())createBlock
{
    self.createIncidentBlock = createBlock;
    MapViewController *objname = (MapViewController *)objectname;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, objectname.view.bounds.size.width-115, 44)];
    searchBar.placeholder = @"Search Location";
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.delegate = objname;
    
    //Left navigation
//    UIBarButtonItem *createBut = [UIBarButtonItem initWithImage:@"createIncident.png" WithScale:0.7 WithPadding:10 isLeftSide:NO];
//    [createBut setTarget:objectname];
    
    UIBarButtonItem *searchBut = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    
    UIImage *imageName = [UIImage imageNamed:@"createIncident.png"];
    UIButton* buttonName = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imageName.size.width*menuScale+8, imageName.size.height*menuScale)];
    
    buttonName.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    [buttonName setImage:imageName forState:UIControlStateNormal];
    [buttonName addTarget:self action:@selector(createAction) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *createBut = [[UIBarButtonItem alloc] initWithCustomView:buttonName];
    
    objectname.navigationItem.rightBarButtonItems = @[createBut, searchBut];
    selfObject = objectname;
    
}

- (void)createAction
{
    self.createIncidentBlock();
}

- (void)setUpCustomViewWithTarget:(UIViewController *)objectname
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    button.titleLabel.text = @"Create\nIncident";
    button.titleLabel.font = [UIFont fontWithName:@"Roboto Regular" size:6.0];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.minimumScaleFactor = 8.0f/12.0f;
    button.titleLabel.clipsToBounds = YES;
    button.titleLabel.backgroundColor = [UIColor clearColor];
    button.titleLabel.textColor = [UIColor redColor];
    button.titleLabel.userInteractionEnabled = YES;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *createBut = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    objectname.navigationItem.rightBarButtonItem = createBut;
    selfObject = objectname;
}

@end
