//
//  MapViewHelper.h
//  Newstracker
//
//  Created by Micheal on 02/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceHandler.h"
#import "ModalObjects.h"
#import <POP.h>
#import "SearchTableViewController.h"

@import GoogleMaps;

@interface MapViewHelper : NSObject <GMSMapViewDelegate, SearchAddressDelegate, POPAnimationDelegate>

@property (nonatomic, strong) GMSMapView *gmapView;
@property (nonatomic, strong) GMSMarker *gmarker;
@property (assign, nonatomic) float time;
@property (retain, strong) UIViewController *selfObject;

+ (MapViewHelper *)sharedInstance;

- (GMSMapView *)createMapWithCoordinate:(CLLocationCoordinate2D)coordinate WithFrame:(CGRect)frame onTarget:(UIViewController *)selfObject;

- (GMSMarker *)addSimpleMarkerWithTitle:(NSString *)title WithSnippet:(NSString *)snippet WithCoordinate:(CLLocationCoordinate2D)coordinate onMap:(GMSMapView *)mapView;

- (GMSMarker *)addMarkerWithTitle:(GroupMember *)member WithSnippet:(NSString *)snippet WithCoordinate:(CLLocationCoordinate2D)coordinate onMap:(GMSMapView *)mapView;

- (GMSMarker *)addIncidentMarkerWithTitle:(Incident *)incident WithSnippet:(NSString *)snippet WithCoordinate:(CLLocationCoordinate2D)coordinate onMap:(GMSMapView *)mapView;

- (GMSMarker *)addSearchIncidentMarkerWithTitle:(Incident *)incident WithSnippet:(NSString *)snippet WithCoordinate:(CLLocationCoordinate2D)coordinate onMap:(GMSMapView *)mapView;

- (void)showGoogleSearchBaronTarget:(UIViewController *)selfObject;

@end
