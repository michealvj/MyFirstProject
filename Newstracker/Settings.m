//
//  Settings.m
//  Newstracker
//
//  Created by Micheal on 29/01/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import "Settings.h"

@implementation Settings

+ (Settings *)sharedInstance
{
    static Settings *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[Settings alloc] init];
    });
    return model;
}

- (BOOL)isSettingsChanged:(Settings *)finalSettings WithInitialSettings:(Settings *)initialSettings
{
    BOOL isChanged;
    if (initialSettings!=nil)
    {
        isChanged = ![finalSettings.incidentDeletionTime isEqualToString:initialSettings.incidentDeletionTime]||
        !finalSettings.isAutomaticDeletionEnabled == initialSettings.isAutomaticDeletionEnabled||
        !finalSettings.isVisibleToOtherUsers == initialSettings.isVisibleToOtherUsers||
        ![finalSettings.logoutTime isEqualToString: initialSettings.logoutTime];
        
        NSLog(@"Settings changed");
    }
    else {
        isChanged = NO;
        NSLog(@"Settings not changed");
    }
    
    return isChanged;
}


@end
