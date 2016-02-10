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

@interface MyPushView : UIView <UIGestureRecognizerDelegate>
@property (nonatomic, strong) MyPushView *pushView;
@property (nonatomic, strong) UILabel *pushLabel;
@property (nonatomic, strong) NSAttributedString *sentMessage;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) AppDelegate *appDel;
- (id)initWithTitle:(NSString *)title WithMessage:(NSString *)message;
- (void)addTarget:(id)target action:(SEL)selector;
@end
