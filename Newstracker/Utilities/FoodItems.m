//
//  FoodItems.m
//  rottichennai
//
//  Created by Micheal on 24/11/15.
//  Copyright (c) 2015 Micheal. All rights reserved.
//

#import "FoodItems.h"

@implementation FoodItems
+ (FoodItems *)sharedInstance
{
    static FoodItems *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[FoodItems alloc] init];
    });
    return model;
}

-(NSArray *)getFoodItems
{
    FoodItems *item1 = [FoodItems new];
    item1.itemname = @"Plain Dosa";
    item1.descvalue = @"Golden Brown Crispy rice and lentil pancake glaced with Oil & ghee";
    item1.imageurl = @"one.jpg";
    item1.quantity = @"7.30Am to 10.30 Pm";
    item1.price = @"50.00";
    
    FoodItems*item2=[FoodItems new];
    item2.itemname = @"Wheat Onion Dosa";
    item2.descvalue = @"Chakki ground whole wheat flour dosa topped with onion & corriander";
    item2.imageurl = @"two.jpg";
    item2.quantity = @"7.30 Am to 10.30 pm";
    item2.price = @"69.00";
    
    FoodItems*item3=[FoodItems new];
    item3.itemname = @"Almond Rawa Masala dosa";
    item3.descvalue = @"Special rawa dosa laced with crunchy almond flakes stuffed with house special masala";
    item3.imageurl = @"three.jpg";
    item3.quantity = @"4 pm to 10.30 pm";
    item3.price = @"175.00";
    
    FoodItems*item4=[FoodItems new];
    item4.itemname = @" Veettu Dosa - 2 Nos ";
    item4.descvalue = @"Aachi Home stlye Pluffy Dosa";
    item4.imageurl = @"four.jpg";
    item4.quantity = @" 7.30Am to 10.30 Pm";
    item4.price = @"53.00";
    
    FoodItems*item5=[FoodItems new];
    item5.itemname = @"Ghee Cone Dosa";
    item5.descvalue = @"Irressistable!!! Aroma of freshly melted Ghee on crispy dosa folded in cone shape";
    item5.imageurl = @"five.jpg";
    item5.quantity = @" 7.30 am to 10.30 pm";
    item5.price = @"95.00";
    
    FoodItems*item6=[FoodItems new];
    item6.itemname = @"Rawa masala dhosa";
    item6.descvalue = @"Irressistable!!! Aroma of freshly melted Ghee on crispy dosa folded in cone shape";
    item6.imageurl = @"six.jpg";
    item6.quantity = @" 7.30 am to 10.30 pm";
    item6.price = @"95.00";
    
    
    NSArray *returnarray = [NSArray arrayWithObjects:item1,item2,item3,item4,item5,item6,nil];
    return returnarray;
}
@end
