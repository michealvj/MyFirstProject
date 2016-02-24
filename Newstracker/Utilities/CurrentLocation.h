//
//  CurrentLocation.h
//  Newstracker
//
//  Created by Micheal on 03/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "utils.h"
#import "WebServiceHandler.h"
#import "GroupMember.h"
@import GoogleMaps;

@interface CurrentLocation : NSObject <CLLocationManagerDelegate>
@property (retain, strong) CLLocationManager *locationManager;
@property (retain, strong) GMSMapView *gmapView;
@property (retain, strong) GMSMarker *currentMarker;

+ (CurrentLocation *)sharedInstance;
- (CLLocationManager *)getCurrentLocation;
- (GMSMarker *)addCurrentMarkerWithTitle:(GroupMember *)member WithSnippet:(NSString *)snippet onMap:(GMSMapView *)mapView;
@end
