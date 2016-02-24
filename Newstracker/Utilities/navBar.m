//
//  navBar.m
//  rottichennai
//
//  Created by Micheal on 23/11/15.
//  Copyright (c) 2015 Micheal. All rights reserved.
//

#import "navBar.h"
#import "MapViewController.h"
#import "UIColor+myColors.h"
#import <MFSideMenu.h>
#import <MFSideMenuContainerViewController.h>

#define menuSpace 20
#define menuScale 0.6

@implementation navBar
{
    void (^DeleteBlock)(void);
    void (^SaveBlock)(void);
    void (^MenuBlock)(void);
    void (^MessageComposeBlock)(void);
}

@synthesize selfObject;
@synthesize currentImage;

+ (navBar *)sharedInstance
{
    static navBar *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[navBar alloc] init];
    });
    return model;
}

- (void)setUpImageWithTarget:(UIViewController *)objectname withImage:(NSString *)name leftSide:(BOOL)isLeftSide
{
    UIBarButtonItem *barButton = [self customiseButtonWithImage:name withSide:isLeftSide];
    currentImage = name;
    if (isLeftSide)
    {
        objectname.navigationItem.leftBarButtonItem = barButton;
    }
    else
    {
        objectname.navigationItem.rightBarButtonItem = barButton;
    }
    selfObject = objectname;
}

- (void)setUpTitle:(NSString *)title WithTarget:(UIViewController *)objectname
{
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(200,8,280,30)];
    navLabel.text = title;
    [navLabel setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:17.0]];
    navLabel.textColor = [UIColor blackColor];
    objectname.navigationItem.titleView = navLabel;
}


- (void)setUpImageWithTarget:(UIViewController *)objectname withImages:(NSArray *)names leftSide:(BOOL)isLeftSide
{
    NSMutableArray *barButtons = [[NSMutableArray alloc] init];
    for (NSString *imagename in names)
    {
        UIBarButtonItem *barButton = [self customiseButtonWithImage:imagename withSide:isLeftSide];
        [barButtons addObject:barButton];
        currentImage = imagename;
    }
    
    if (isLeftSide)
    {
        objectname.navigationItem.leftBarButtonItems = barButtons;
    }
    else
    {
        objectname.navigationItem.rightBarButtonItems = barButtons;
    }
    selfObject = objectname;

}

- (UIBarButtonItem *)customiseButtonWithImage:(NSString *)image withSide:(BOOL)isLeftSide
{
    currentImage = image;
    UIImage *imageName = [UIImage imageNamed:image];
    UIButton* buttonName = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imageName.size.width*menuScale+menuSpace, imageName.size.height*menuScale)];
    
    buttonName.imageEdgeInsets = isLeftSide ? UIEdgeInsetsMake(0, 0, 0, menuSpace) : UIEdgeInsetsMake(0, menuSpace, 0, 0);
    [self setSelectorWithName:buttonName];
    [buttonName setImage:imageName forState:UIControlStateNormal];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:buttonName];
    return barButton;
}

- (void)setSelectorWithName:(UIButton *)buttonName
{
    if ([currentImage isEqualToString:@"ltarrow.png"])
    {
        [buttonName addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([currentImage isEqualToString:@"home.png"])
    {
        [buttonName addTarget:self action:@selector(homePressed:) forControlEvents:UIControlEventTouchUpInside];
    }

}

- (void)backPressed:(UIButton *)sender
{
    [selfObject.navigationController popViewControllerAnimated:YES];
}

- (void)homePressed:(UIButton *)sender
{
    MapViewController *nav = [selfObject.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [selfObject.navigationController pushViewController:nav animated:YES];
}

- (UIBarButtonItem *)setMenuImageWithScale:(float)scale WithPadding:(float)padding isLeftSide:(BOOL)isLeftSide WithAction:(void (^)(void))success
{
    UIImage *image = [UIImage imageNamed:@"menu.png"];
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width*scale+padding, image.size.height*scale)];
    button.imageEdgeInsets = isLeftSide ? UIEdgeInsetsMake(0, 0, 0, padding) : UIEdgeInsetsMake(0, padding, 0, 0);
    
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
    
    MenuBlock = success;

    //Left navigation
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButton;
}

- (UIBarButtonItem *)setSaveImageWithScale:(float)scale WithPadding:(float)padding isLeftSide:(BOOL)isLeftSide WithAction:(void (^)(void))success
{

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Save" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:17.0f];
    button.tintColor = [UIColor myBlueColor];
    [button sizeToFit];
    [button addTarget:self action:@selector(saveClicked) forControlEvents:UIControlEventTouchUpInside];
    
    SaveBlock = success;
    
    //Left navigation
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButton;
}

- (UIBarButtonItem *)setDeleteIncidentWithScale:(float)scale WithPadding:(float)padding isLeftSide:(BOOL)isLeftSide WithAction:(void (^)(void))success
{
    UIImage *image = [UIImage imageNamed:@"deleteIncident.png"];
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width*scale+padding, image.size.height*scale)];
    button.imageEdgeInsets = isLeftSide ? UIEdgeInsetsMake(0, 0, 0, padding) : UIEdgeInsetsMake(0, padding, 0, 0);
    
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(deleteIncidentClicked) forControlEvents:UIControlEventTouchUpInside];
    
    DeleteBlock = success;
    
    //Left navigation
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButton;
}

- (UIBarButtonItem *)setComposeMessageWithScale:(float)scale WithPadding:(float)padding isLeftSide:(BOOL)isLeftSide WithAction:(void (^)(void))success
{
    UIImage *image = [UIImage imageNamed:@"new.png"];
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width*scale+padding, image.size.height*scale)];
    button.imageEdgeInsets = isLeftSide ? UIEdgeInsetsMake(0, 0, 0, padding) : UIEdgeInsetsMake(0, padding, 0, 0);
    
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(messageComposeClicked) forControlEvents:UIControlEventTouchUpInside];
    
    MessageComposeBlock = success;
    
    //Left navigation
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButton;
}

- (void)menuClicked
{
    MenuBlock();
}

- (void)saveClicked
{
    SaveBlock();
}

- (void)deleteIncidentClicked
{
    DeleteBlock();
}

- (void)messageComposeClicked
{
    MessageComposeBlock();
}


@end
