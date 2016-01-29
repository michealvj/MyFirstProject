//
//  Settings.m
//  Newstracker
//
//  Created by Micheal on 29/01/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import "Settings.h"

@implementation Settings

+ (Settings *)sharedInstance
{
    static Settings *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[Settings alloc] init];
    });
    return model;
}

@end
