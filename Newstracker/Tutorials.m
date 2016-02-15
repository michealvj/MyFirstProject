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
    tutorial1.title = @"Title 1";
    tutorial1.desc = @"descripton 1";
    tutorial1.imageName = @"one-min.png";
    
    Tutorials *tutorial2 = [Tutorials new];
    tutorial2.title = @"Title 2";
    tutorial2.desc = @"descripton 2";
    tutorial2.imageName = @"two-min.png";

    Tutorials *tutorial3 = [Tutorials new];
    tutorial3.title = @"Title 3";
    tutorial3.desc = @"descripton 3";
    tutorial3.imageName = @"three-min.png";

    Tutorials *tutorial4 = [Tutorials new];
    tutorial4.title = @"Title 4";
    tutorial4.desc = @"descripton 4";
    tutorial4.imageName = @"four-min.png";

    Tutorials *tutorial5 = [Tutorials new];
    tutorial5.title = @"Title 5";
    tutorial5.desc = @"descripton 5";
    tutorial5.imageName = @"five-min.png";
    
    NSArray *allTutorials = @[tutorial1, tutorial2, tutorial3, tutorial4, tutorial5];
    return allTutorials;
}
@end
