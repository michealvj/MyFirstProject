//
//  Geocode.m
//  Newstracker
//
//  Created by Micheal on 07/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "Geocode.h"

@implementation Geocode

+ (Geocode *)sharedInstance
{
    static Geocode *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[Geocode alloc] init];
    });
    return model;
}

@end
