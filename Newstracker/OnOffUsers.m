//
//  OnOffUsers.m
//  Newstracker
//
//  Created by Micheal on 15/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "OnOffUsers.h"

@implementation OnOffUsers

+ (OnOffUsers *)sharedInstance
{
    static OnOffUsers *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[OnOffUsers alloc] init];
    });
    return model;
}

- (NSArray *)getOnlineUser
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSArray *onlineUserNames = @[@"Micheal", @"Naga Harshan", @"Manoj K", @"Vishnu Prasath", @"Iyapparaj"];
   
    for (int i = 0; i<onlineUserNames.count; i++) {
        NSString *onlineUser = onlineUserNames[i];
       
        OnOffUsers *user = [OnOffUsers new];
        user.userName = onlineUser;
        user.status = @"online";
        [list addObject:user];
    }
    
    return list;
}

- (NSArray *)getOfflineUser
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSArray *offlineUserNames = @[@"Aravind", @"Balaji", @"Jegan", @"Gowtham", @"Gowtham Raj"];
    
    for (int i = 0; i<offlineUserNames.count; i++) {
        NSString *offlineUser = offlineUserNames[i];
        
        OnOffUsers *user = [OnOffUsers new];
        user.userName = offlineUser;
        user.status = @"offline";
        [list addObject:user];
    }
    
    return list;
}

@end
