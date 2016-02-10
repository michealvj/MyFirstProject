//
//  Incident.m
//  Newstracker
//
//  Created by Micheal on 08/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "Incident.h"

@implementation Incident

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.incidentID forKey:@"incidentID"];
    [aCoder encodeObject:self.incidentName forKey:@"incidentName"];
    [aCoder encodeObject:self.incidentAddress forKey:@"incidentAddress"];
    [aCoder encodeObject:self.incidentDescription forKey:@"incidentDescription"];
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        self.incidentID = [aDecoder decodeObjectForKey:@"incidentID"];
        self.incidentName = [aDecoder decodeObjectForKey:@"incidentName"];
        self.incidentAddress = [aDecoder decodeObjectForKey:@"incidentAddress"];
        self.incidentDescription = [aDecoder decodeObjectForKey:@"incidentDescription"];
        CLLocationDegrees latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        CLLocationDegrees longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    return self;
}

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
