//
//  Tutorials.m
//  Newstracker
//
//  Created by Micheal on 15/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import "Tutorials.h"

@implementation Tutorials

- (NSArray *)getTutorials
{
    Tutorials *tutorial1 = [Tutorials new];
    tutorial1.title = @"How to create incident?";
    tutorial1.desc = @"Tap on \"+\" button which is placed in the top right corner";
    tutorial1.imageName = @"one-min.png";
    
    Tutorials *tutorial2 = [Tutorials new];
    tutorial2.title = @"How to view incident details?";
    tutorial2.desc = @"The circle on the map indicates the incident location. Tap on the red circle to view incident details";
    tutorial2.imageName = @"three-min.png";

    Tutorials *tutorial3 = [Tutorials new];
    tutorial3.title = @"How to view user details?";
    tutorial3.desc = @"Tap on any of the user map location pins to see user details";
    tutorial3.imageName = @"four-min.png";

    Tutorials *tutorial4 = [Tutorials new];
    tutorial4.title = @"How to view the list of users in same location?";
    tutorial4.desc = @"Tap on the map location pin to view the list of users in the same location";
    tutorial4.imageName = @"five-min.png";

    Tutorials *tutorial5 = [Tutorials new];
    tutorial5.title = @"How to find distance b/w user and incident?";
    tutorial5.desc = @"Tap on incident and then on user pin or vice versa to find the distance. The time taken to reach the incident is shown at the bottom";
    tutorial5.imageName = @"two-min.png";

    Tutorials *tutorial6 = [Tutorials new];
    tutorial6.title = @"User visibility setting";
    tutorial6.desc = @"Only group managers can only see user locations or alternatively all users can see each other";
    tutorial6.imageName = @"six.png";
    
    NSArray *allTutorials;
    if ([UserDefaults isManager]) {
       allTutorials = @[tutorial1, tutorial2, tutorial3, tutorial4, tutorial5, tutorial6];
    }
    else {
        allTutorials = @[tutorial1, tutorial2, tutorial3, tutorial4, tutorial5];
    }

    return allTutorials;
}
@end
