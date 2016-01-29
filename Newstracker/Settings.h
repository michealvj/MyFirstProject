//
//  Settings.h
//  Newstracker
//
//  Created by Micheal on 29/01/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Settings : NSObject

+ (Settings *)sharedInstance;

@property (nonatomic,retain) NSString *mapLocation;
@property (nonatomic,assign) CLLocationCoordinate2D mapCoordinate;
@property (nonatomic,retain) NSString *incidentDeletionTime;
@property (nonatomic,retain) NSString *logoutTime;
@property (nonatomic,retain) NSString *gpsTime;
@property (nonatomic,assign) BOOL isAutomaticDeletionEnabled;
@property (nonatomic,assign) BOOL isManager;
@property (nonatomic,assign) BOOL isVisibleToOtherUsers;

@end
