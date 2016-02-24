//
//  MapViewHelper.m
//  Newstracker
//
//  Created by Micheal on 02/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "MapViewHelper.h"
#import "MapViewController.h"
#import "ModalObjects.h"
#import "utils.h"
#import "MemberIcon.h"
#import <POP.h>

@implementation MapViewHelper
@synthesize gmapView,selfObject;

+ (MapViewHelper *)sharedInstance
{
    static MapViewHelper *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[MapViewHelper alloc] init];
    });
    return model;
}

#pragma mark - Maps and marker methods

- (GMSMapView *)createMapWithCoordinate:(CLLocationCoordinate2D)coordinate WithFrame:(CGRect)frame onTarget:(MapViewController *)objectname
{
    gmapView.delegate = self;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:MAPZOOM];
    frame = CGRectMake(0, 0, frame.size.width, frame.size.height-64);
    gmapView = [GMSMapView mapWithFrame:frame camera:camera];
    gmapView.myLocationEnabled = NO;
    
    gmapView.delegate = self;
     [objectname.mapParentView addSubview:gmapView];
    return gmapView;
}

- (GMSMarker *)addSimpleMarkerWithTitle:(NSString *)title WithSnippet:(NSString *)snippet WithCoordinate:(CLLocationCoordinate2D)coordinate onMap:(GMSMapView *)mapView
{
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
    marker.snippet = snippet;
    marker.title = title;
    marker.appearAnimation = YES;
    marker.icon = [[CodeSnip sharedInstance] image:[UIImage imageNamed:@"bluepin.png"] scaledToSize:CGSizeMake(30.0f, 50.0f)];
    marker.map = mapView;
    return marker;
}

- (GMSMarker *)addMarkerWithTitle:(GroupMember *)member WithSnippet:(NSString *)snippet WithCoordinate:(CLLocationCoordinate2D)coordinate onMap:(GMSMapView *)mapView
{
    NSArray *userIDs = member.userID;
    NSArray *names = member.userNames;
    
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    [userData setObject:member.userID forKey:@"userID"];
    [userData setObject:member.userNames forKey:@"userName"];
   
    NSString *userName = names[0];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
    marker.snippet = snippet;
    marker.appearAnimation = NO;
    marker.title = userName;
    marker.userData = userData;
    
    if ([member.reachablity isEqualToString:@"YES"]) {
        if (member.userNames.count==1) {
            marker.icon =  MEMBER;
            marker.snippet = @"Member";
        }
        else {
            marker.icon =  GROUP_MEMBER;
            marker.snippet = @"GroupMember";
        }
    }
    else {
        marker.icon =  UNREACH_MEMBER;
        marker.snippet = @"UnreachMember";
    }
    marker.infoWindowAnchor = kGMSMarkerDefaultInfoWindowAnchor;
    marker.map = gmapView;
    return marker;
}

- (GMSMarker *)addIncidentMarkerWithTitle:(Incident *)incident WithSnippet:(NSString *)snippet WithCoordinate:(CLLocationCoordinate2D)coordinate onMap:(GMSMapView *)mapView
{
    NSDictionary *userData = @{@"incidentID": incident.incidentID,
                               @"incidentName": incident.incidentName,
                               @"incidentAddress": incident.incidentAddress,
                               @"incidentDescription": incident.incidentDescription};
    
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
    marker.title = incident.incidentName;
    marker.appearAnimation = NO;
    UIImage *iconImage = INCIDENT;
    marker.icon = iconImage;
    marker.infoWindowAnchor = kGMSMarkerDefaultInfoWindowAnchor;
    marker.userData = userData;
    marker.snippet = @"Incident";
    marker.map = gmapView;
    self.gmarker = marker;
    
//    POPBasicAnimation *layoutAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
//    layoutAnimation.duration = 1.0;
//    layoutAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.5, 0.5)];
//    layoutAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(2, 2)];
//    layoutAnimation.repeatForever = YES;
//    [marker.layer pop_addAnimation:layoutAnimation forKey:@"morepeople"];
   
    
    return marker;
}

- (GMSMarker *)addSearchIncidentMarkerWithTitle:(Incident *)incident WithSnippet:(NSString *)snippet WithCoordinate:(CLLocationCoordinate2D)coordinate onMap:(GMSMapView *)mapView
{
    NSDictionary *userData = @{@"incidentID": incident.incidentID,
                               @"incidentName": incident.incidentName,
                               @"incidentAddress": incident.incidentAddress,
                               @"incidentDescription": incident.incidentDescription};
    
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
    marker.title = incident.incidentName;
    marker.appearAnimation = YES;
    marker.icon = INCIDENT;
    marker.infoWindowAnchor = kGMSMarkerDefaultInfoWindowAnchor;
    marker.userData = userData;
    marker.snippet = @"Incident";
    marker.map = gmapView;
    self.gmarker = marker;
    
    GMSCameraUpdate *incidentCamera = [GMSCameraUpdate setTarget:coordinate];
    [gmapView animateWithCameraUpdate:incidentCamera];
    return marker;
    
}

#pragma mark - Autocomplete methods

- (void)showGoogleSearchBaronTarget:(UIViewController *)object
{
    SearchTableViewController *nav = [object.storyboard instantiateViewControllerWithIdentifier:@"SearchTableViewController"];
    nav.delegate = self;
    [object presentViewController:nav animated:NO completion:nil];
}

#pragma mark - AutoComplete delegate methods

- (void)didSelectAddress:(NSString *)placeID
{
    // Do something with the selected place.
    
    NSString *geocodeURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@", placeID, GOOGLE_SERVER_KEY1];
    
    [[WebServiceHandler sharedInstance] getGeocodeForURL:geocodeURL];
}



@end
