//
//  GroupMember.m
//  Newstracker
//
//  Created by Micheal on 03/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "GroupMember.h"

@implementation GroupMember

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.userID forKey:@"userid"];
    [aCoder encodeObject:self.userNames forKey:@"userNames"];
    [aCoder encodeObject:self.reachablity forKey:@"reachablity"];
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        self.userID = [aDecoder decodeObjectForKey:@"userid"];
        self.userNames = [aDecoder decodeObjectForKey:@"userNames"];
        self.reachablity = [aDecoder decodeObjectForKey:@"reachablity"];
        CLLocationDegrees latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        CLLocationDegrees longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    return self;
}


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
