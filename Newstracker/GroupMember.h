//
//  MembersDetails.h
//  Newstracker
//
//  Created by Micheal on 03/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleMaps;

@interface GroupMember : NSObject

@property (nonatomic,retain) NSArray *userID;
@property (nonatomic,retain) NSArray *userNames;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSString *reachablity;

+ (GroupMember *)sharedInstance;
- (NSArray *)getGroupMember;
@end
