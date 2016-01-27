//
//  LocationTracker.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationShareModel.h"
#import "CodeSnip.h"
#import "utils.h"
#import "GroupMember.h"
#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;

@property (strong,nonatomic) LocationShareModel * shareModel;

@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;

+ (CLLocationManager *)sharedLocationManager;
+ (LocationTracker *)sharedInstance;

- (void)startLocationTracking;
- (void)stopLocationTracking;
- (void)updateLocationToServer;

//My methods
@property (retain, strong) GMSMapView *gmapView;
@property (retain, strong) GMSMarker *currentMarker;

- (GMSMarker *)addCurrentMarkerWithTitle:(GroupMember *)member WithSnippet:(NSString *)snippet onMap:(GMSMapView *)mapView;
- (CLLocationManager *)getCurrentLocation;
@end
