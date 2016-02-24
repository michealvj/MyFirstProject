//
//  SideBar.h
//  mfsidemenu
//
//  Created by Michel on 11/4/15.
//  Copyright (c) 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^CreateIncidentBlock) ();

@interface SideBar : NSObject
+ (SideBar *)sharedInstance;
- (void)setUpSideMenu;
- (void)setUpImage:(NSString *)imageName WithTarget:(id)objectname;
- (void)setUpCustomViewWithTarget:(UIViewController *)objectname;

- (void)setUpSearchBarWithTarget:(UIViewController *)objectname WithCreateButtonAction:(void (^)())createBlock;
@property (nonatomic, strong) CreateIncidentBlock createIncidentBlock;

@property (nonatomic, strong) UIViewController *selfObject;
@end
