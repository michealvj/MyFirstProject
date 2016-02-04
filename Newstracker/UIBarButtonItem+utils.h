//
//  UIBarButtonItem+utils.h
//  Newstracker
//
//  Created by Micheal on 28/01/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^mySuccess)(void);
@interface UIBarButtonItem (utils)
+(UIBarButtonItem *)initWithImage:(NSString *)imageName WithScale:(float)scale WithPadding:(float)padding isLeftSide:(BOOL)isLeftSide WithCompletionHandler:(void (^)(void))success;
@property (nonatomic) mySuccess successBlock;
@end
