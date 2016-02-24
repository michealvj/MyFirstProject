//
//  CurrentLocation.m
//  Newstracker
//
//  Created by Micheal on 03/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "CurrentLocation.h"


@implementation CurrentLocation
@synthesize gmapView;
@synthesize currentMarker;

+ (CurrentLocation *)sharedInstance
{
    static CurrentLocation *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[CurrentLocation alloc] init];
    });
    return model;
}

- (CLLocationManager *)getCurrentLocation
{
    self.locationManager.delegate = self;
    
    //Getting User Location
    if(self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
//        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [self.locationManager requestAlwaysAuthorization];
    }
    if ([self.locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)])
    {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    [self.locationManager startUpdatingLocation];
    
    return self.locationManager;
}

- (GMSMarker *)addCurrentMarkerWithTitle:(GroupMember *)member WithSnippet:(NSString *)snippet onMap:(GMSMapView *)mapView
{
    CLLocationManager *currentLocation = [[CurrentLocation sharedInstance] getCurrentLocation];
    CLLocationCoordinate2D currentCoordinate = currentLocation.location.coordinate;

    NSArray *names = member.userNames;
    
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    [userData setObject:member.userID forKey:@"userID"];
    [userData setObject:member.userNames forKey:@"userName"];
    
    NSString *userName = names[0];
    
    currentMarker = [GMSMarker markerWithPosition:currentCoordinate];
    currentMarker.title = userName;
    currentMarker.userData = userData;
    currentMarker.appearAnimation = YES;
    currentMarker.icon = [[CodeSnip sharedInstance] getUserIconForTitle:currentMarker.title];
    currentMarker.infoWindowAnchor = CGPointMake(0.5, 0.5);
    currentMarker.snippet = @"Currentuser";
    currentMarker.map = mapView;
    self.gmapView = mapView;

    return currentMarker;
}

- (void)updateCurrentLocation:(CLLocation *)newLocation
{
    CLLocationManager *currentLocation = [[CurrentLocation sharedInstance] getCurrentLocation];
    CLLocationCoordinate2D currentCoordinate = currentLocation.location.coordinate;

    currentMarker.position = currentCoordinate;
    
}


#pragma mark - CLLocationDelegate method

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"NEW LOC: %@", newLocation);
    [self updateCurrentLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);
}

@end
