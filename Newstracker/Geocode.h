//
//  Geocode.h
//  Newstracker
//
//  Created by Micheal on 07/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleMaps;

@interface Geocode : NSObject

@property (nonatomic,assign) NSString *address;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

+ (Geocode *)sharedInstance;

@end
