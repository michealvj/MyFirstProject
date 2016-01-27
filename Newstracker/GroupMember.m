//
//  GroupMember.m
//  Newstracker
//
//  Created by Micheal on 03/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "GroupMember.h"

@implementation GroupMember

+ (GroupMember *)sharedInstance
{
    static GroupMember *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[GroupMember alloc] init];
    });
    return model;
}

- (NSArray *)getGroupMember
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    NSArray *userId = @[@[@"1", @"2", @"3", @"4", @"5", @"6"], @[@"7"], @[@"8"]];
    NSArray *usernames = @[@[@"Micheal", @"Gowtham", @"Aravind", @"Vishnu", @"Peter", @"Manoj"], @[@"Infant"], @[@"Balaji"]];
    NSArray *latitude = @[@"9.92328", @"9.9195781", @"9.9228758"];
    NSArray *longitude = @[@"78.1466664", @"78.1507312", @"78.1507937"];
    NSArray *reachable = @[@"YES", @"YES", @"NO"];
    
    
    for (int i = 0; i<usernames.count; i++) {
        NSString *lat = latitude[i];
        NSString *lng = longitude[i];
        
        GroupMember *detail = [GroupMember new];
        detail.userNames =[NSArray arrayWithArray:(NSArray *)usernames[i]];
        detail.userID = [NSArray arrayWithArray:(NSArray *)userId[i]];
        detail.coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
        detail.reachablity = reachable[i];
        
        NSLog(@"%@",detail.userNames);
        [list addObject:detail];
    }
    
    return list;
}
@end
