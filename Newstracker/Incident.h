//
//  Incident.h
//  Newstracker
//
//  Created by Micheal on 08/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleMaps;

@interface Incident : NSObject
@property (nonatomic,retain) NSString *incidentID;
@property (nonatomic,retain) NSString *incidentName;
@property (nonatomic,retain) NSString *incidentAddress;
@property (nonatomic,retain) NSString *incidentDescription;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

+ (Incident *)sharedInstance;
- (NSArray *)getIncidents;
@end
