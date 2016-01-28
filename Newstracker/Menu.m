//
//  Menu.m
//  Newstracker
//
//  Created by Micheal on 08/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "Menu.h"

@implementation Menu

+ (Menu *)sharedInstance
{
    static Menu *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[Menu alloc] init];
    });
    return model;
}

- (NSArray *)getMenuList
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSArray *menuArray = @[@"Region Map", @"Online/Offline Users", @"Incident List", @"Settings", @"Log out"];
    NSArray *menuImageArray = @[@"map.png", @"user.png", @"incident.png", @"settings.png", @"logout.png"];

    
    for (int i = 0; i<menuArray.count; i++) {
       
        Menu *detail = [Menu new];
        detail.menuTitle = menuArray[i];
        detail.menuImage = menuImageArray[i];
        
        [list addObject:detail];
    }
    
    return list;
}


@end
