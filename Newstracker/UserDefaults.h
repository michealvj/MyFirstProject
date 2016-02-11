//
//  UserDefaults.h
//  Newstracker
//
//  Created by Micheal on 30/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationTracker.h"

@interface UserDefaults : NSObject
+ (void)setUserIDWithValue:(id)value;
+ (void)setLastIncidentIDWithValue:(id)value;
+ (void)setGroupIDWithValue:(id)value;
+ (void)setGroupNameWithValue:(id)value;
+ (void)setMapCoordinateWithValue:(CLLocationCoordinate2D)value;
+ (void)setDeviceTokenWithValue:(NSString *)token;
+ (void)setGPSTime:(id)value;
+ (void)setMapAddressWithValue:(NSString *)address;
+ (void)setUserTypeWithValue:(id)value;

+ (id)getUserID;
+ (id)getLastIncidentID;
+ (id)getGroupID;
+ (id)getGroupName;
+ (id)getGPSTime;
+ (id)getDeviceToken;
+ (CLLocationCoordinate2D)getMapLocation;
+ (id)getMapAddress;

+ (BOOL)isLogin;
+ (BOOL)isManager;

+ (void)clearUserID;
+ (void)clearGroupID;
+ (void)clearGroupName;
+ (void)clearMapAddress;
+ (void)clearMapLocation;
+ (void)clearOfflineDatas;

+ (void)saveIncidentData:(id)data;
+ (void)saveMemberData:(id)data;

+ (id)getIncidentData;
+ (id)getMemberData;
@end
