//
//  UserDefaults.m
//  Newstracker
//
//  Created by Micheal on 30/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "UserDefaults.h"

@implementation UserDefaults

+ (void)setUserIDWithValue:(id)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getUserID
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"];
}

+ (void)setLastIncidentIDWithValue:(id)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"incidentID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getLastIncidentID
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"incidentID"];
}

+ (void)setGroupIDWithValue:(id)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"groupID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getGroupID
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"groupID"];
}

+ (void)setGroupNameWithValue:(id)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"groupName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getGroupName
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"groupName"];
}

+ (void)setDeviceTokenWithValue:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getDeviceToken
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];
}

+ (void)setUserTypeWithValue:(id)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"userType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isManager
{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"userType"] isEqualToString:@"Manager"]) {
        return YES;
    }
    else {
        return NO;
    }
}


#pragma mark - Settings Page

+ (void)setGPSTime:(id)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"locationTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getGPSTime
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"locationTime"])
    {
        return [[NSUserDefaults standardUserDefaults] valueForKey:@"locationTime"];
    }
    else
    {
       return @"1";
    }
}

+ (void)setMapCoordinateWithValue:(CLLocationCoordinate2D)value
{
    NSString *keyLat = [NSString stringWithFormat:@"mapLatitude"];
    NSString *keyLng = [NSString stringWithFormat:@"mapLongitude"];
    NSString *lat = [NSString stringWithFormat:@"%f", value.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f", value.longitude];
    
    [[NSUserDefaults standardUserDefaults] setValue:lat forKey:keyLat];
    [[NSUserDefaults standardUserDefaults] setValue:lng forKey:keyLng];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (CLLocationCoordinate2D)getMapLocation
{
    CLLocationCoordinate2D mapLocation;
    NSString *keyLat = [NSString stringWithFormat:@"mapLatitude"];
    NSString *keyLng = [NSString stringWithFormat:@"mapLongitude"];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:keyLat]&&[[NSUserDefaults standardUserDefaults] valueForKey:keyLng])
    {
        NSString *lat = [[NSUserDefaults standardUserDefaults] valueForKey:keyLat];
        NSString *lng = [[NSUserDefaults standardUserDefaults] valueForKey:keyLng];
        
        mapLocation = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
   }
    else
    {
        mapLocation = [LocationTracker sharedLocationManager].location.coordinate;
    }
    return mapLocation;
}

+ (void)setMapAddressWithValue:(NSString *)address
{
    [[NSUserDefaults standardUserDefaults] setValue:address forKey:@"mapAddress"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getMapAddress
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"mapAddress"])
    {
        return [[NSUserDefaults standardUserDefaults] valueForKey:@"mapAddress"];
    }
    else
    {
        return @"";
    }
}


#pragma mark - Logout Clear

+ (void)clearUserID
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userID"];
}

+ (void)clearGroupID
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"groupID"];
}

+ (void)clearGroupName
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"groupName"];
}

+ (void)clearMapAddress
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"mapAddress"];
}

+ (void)clearMapLocation
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"mapLatitude"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"mapLongitude"];
}


+ (BOOL)isLogin
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"userID"]) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - Offline Data storage

+ (void)saveIncidentData:(id)data
{
    NSData *incidentData = [NSKeyedArchiver archivedDataWithRootObject:data];
    [[NSUserDefaults standardUserDefaults] setObject:incidentData forKey:@"allIncidentMarkers"];
}

+ (void)saveMemberData:(id)data
{
    NSData *incidentData = [NSKeyedArchiver archivedDataWithRootObject:data];
    [[NSUserDefaults standardUserDefaults] setObject:incidentData forKey:@"allMemberMarkers"];
}

+ (id)getMemberData
{
    NSData *memberData = [[NSUserDefaults standardUserDefaults] objectForKey:@"allMemberMarkers"];
    NSArray *memberArray = [NSKeyedUnarchiver unarchiveObjectWithData:memberData];
    return memberArray;
}

+ (id)getIncidentData
{
    NSData *incidentData = [[NSUserDefaults standardUserDefaults] objectForKey:@"allIncidentMarkers"];
    NSArray *incidentArray = [NSKeyedUnarchiver unarchiveObjectWithData:incidentData];
    return incidentArray;
}


@end
