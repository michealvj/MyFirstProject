//
//  FoodItems.h
//  rottichennai
//
//  Created by Micheal on 24/11/15.
//  Copyright (c) 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FoodItems : NSObject
+ (FoodItems *)sharedInstance;
-(NSArray *)getFoodItems;

@property NSString *itemname;
@property NSString *quantity;
@property NSString *descvalue;
@property NSString *price;
@property NSString *combotype;
@property NSString *imageurl;


@end
