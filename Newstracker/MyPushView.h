//
//  MyPushView.h
//  Newstracker
//
//  Created by Micheal on 05/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MyPushView : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *pushView;
@property (nonatomic, strong) UILabel *pushLabel;
@property (nonatomic, strong) NSAttributedString *sentMessage;
@property (nonatomic, strong) AppDelegate *appDel;
- (id)initWithTitle:(NSString *)title WithMessage:(NSString *)message;
- (void)show;
@end
