//
//  UIBarButtonItem+utils.m
//  Newstracker
//
//  Created by Micheal on 28/01/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import "UIBarButtonItem+utils.h"

@implementation UIBarButtonItem (utils)
@dynamic successBlock;

+ (UIBarButtonItem *)initWithImage:(NSString *)imageName WithScale:(float)scale WithPadding:(float)padding isLeftSide:(BOOL)isLeftSide WithCompletionHandler:(void (^)(void))success
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width*scale+padding, image.size.height*scale)];
    button.imageEdgeInsets = isLeftSide ? UIEdgeInsetsMake(0, 0, 0, padding) : UIEdgeInsetsMake(0, padding, 0, 0);
    
    
    [button setImage:image forState:UIControlStateNormal];
    
    //Left navigation
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [barButton setTarget:self];
    [barButton setAction:@selector(action)];
    
    return barButton;
}

- (void)action
{
    
}

@end
