//
//  Message.m
//  Newstracker
//
//  Created by Micheal on 08/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import "Message.h"

@implementation Message

+ (Message *)sharedInstance
{
    static Message *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[Message alloc] init];
    });
    return model;
}

@end
