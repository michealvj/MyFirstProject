//
//  User.m
//  Newstracker
//
//  Created by Micheal on 21/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "User.h"

@implementation User

+ (User *)sharedInstance
{
    static User *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[User alloc] init];
    });
    return model;
}

- (NSArray *)getUserDetails
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    NSArray *userId = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8"];
    NSArray *usernames = @[@"Micheal",@"Gowtham", @"Aravind", @"Vishnu", @"Peter", @"Manoj", @"Infant", @"Balaji"];
    NSArray *status = @[@"Online", @"Offline", @"Online", @"Online", @"Offline", @"Online", @"Offline", @"Offline"];
    NSArray *incidents = @[@[@"Fire Accident", @"Accident"],
                           @[@"Fire Accident", @"Boxing Match", @"Golf Tournament"],
                           @[@"Golf Tournament"],
                           @[@"Fire Accident"],
                           @[@"Boxing Match"],
                           @[@"Golf Tournament"],
                           @[@"Fire Accident"],
                           @[@"Boxing Match"]];
    
    for (int i = 0; i<usernames.count; i++) {
        
        User *detail = [User new];
        detail.userName = usernames[i];
        detail.userID = userId[i];
        detail.incidentsAssigned = incidents[i];
        detail.status = status[i];
        [list addObject:detail];
    }
    
    return list;
}

@end
