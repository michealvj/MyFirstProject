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
    NSLog(@"%f,%f:%f,%f", initialSettings.mapCoordinate.latitude, initialSettings.mapCoordinate.longitude, finalSettings.mapCoordinate.latitude, finalSettings.mapCoordinate.longitude);
    NSLog(@"%@:%@", initialSettings.mapLocation, finalSettings.mapLocation);
    NSLog(@"%@:%@", initialSettings.gpsTime, finalSettings.gpsTime);
    NSLog(@"%@:%@", initialSettings.logoutTime, finalSettings.logoutTime);
    NSLog(@"%@:%@", initialSettings.incidentDeletionTime, finalSettings.incidentDeletionTime);
    NSLog(@"%i:%i", initialSettings.isAutomaticDeletionEnabled, finalSettings.isAutomaticDeletionEnabled);
    NSLog(@"%i:%i", initialSettings.isVisibleToOtherUsers, finalSettings.isVisibleToOtherUsers);
    BOOL isChanged;
    if (initialSettings.incidentDeletionTime&&initialSettings.isVisibleToOtherUsers&&initialSettings.isAutomaticDeletionEnabled) {
        isChanged = ![finalSettings.incidentDeletionTime isEqualToString:initialSettings.incidentDeletionTime]||
        !finalSettings.isAutomaticDeletionEnabled == initialSettings.isAutomaticDeletionEnabled||
        !finalSettings.isVisibleToOtherUsers == initialSettings.isVisibleToOtherUsers;
    }
    else {
        isChanged = NO;
    }
    
    return isChanged;
}


@end
