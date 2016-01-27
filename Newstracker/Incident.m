//
//  Incident.m
//  Newstracker
//
//  Created by Micheal on 08/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "Incident.h"

@implementation Incident

+ (Incident *)sharedInstance
{
    static Incident *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[Incident alloc] init];
    });
    return model;
}

- (NSArray *)getIncidents
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSArray *incidents = @[@"Boxing Match", @"Fire Accident", @"Golf Tournament"];
    NSArray *latitude = @[@"9.920255", @"9.920255", @"9.9190215"];
    NSArray *longitude = @[@"78.1455549", @"78.147749", @"78.1454861"];
    
    for (int i = 0; i<incidents.count; i++) {
        NSString *lat = latitude[i];
        NSString *lng = longitude[i];
        
        Incident *detail = [Incident new];
        detail.incidentName = incidents[i];
        detail.coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
        
        [list addObject:detail];
    }
    
    return list;
}

@end
