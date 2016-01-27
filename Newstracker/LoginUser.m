//
//  LoginUser.m
//  Newstracker
//
//  Created by Micheal on 04/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "LoginUser.h"

@implementation LoginUser

+ (LoginUser *)sharedInstance
{
    static LoginUser *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[LoginUser alloc] init];
    });
    return model;
}

- (NSArray *)getLoginUser
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSArray *usernames = @[@"Micheal", @"Gowtham", @"Aravind"];
    NSArray *latitude = @[@"9.92328", @"9.9195599", @"9.9194156"];
    NSArray *longitude = @[@"78.1466664", @"78.1469453", @"78.1500334"];
    
    
    return list;
}


@end
