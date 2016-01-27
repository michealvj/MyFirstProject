//
//  User.h
//  Newstracker
//
//  Created by Micheal on 21/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface User : NSObject

@property (nonatomic,retain) NSString *userID;
@property (nonatomic,retain) NSString *userName;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSString *status;
@property (nonatomic,retain) NSArray *incidentsAssigned;
@property (nonatomic,assign) BOOL isAssigned;

+ (User *)sharedInstance;
- (NSArray *)getUserDetails;
@end
