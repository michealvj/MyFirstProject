//
//  TimeDistance.m
//  Newstracker
//
//  Created by Micheal on 09/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "TimeDistance.h"

@implementation TimeDistance

+ (TimeDistance *)sharedInstance
{
    static TimeDistance *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[TimeDistance alloc] init];
    });
    return model;
}

@end
