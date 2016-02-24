//
//  navBar.h
//  rottichennai
//
//  Created by Micheal on 23/11/15.
//  Copyright (c) 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface navBar : NSObject

@property UIViewController *selfObject;
@property (nonatomic,strong) NSString *currentImage;

+ (navBar *)sharedInstance;
- (void)setUpImageWithTarget:(UIViewController *)objectname withImage:(NSString *)name leftSide:(BOOL)isLeftSide;
- (void)setUpImageWithTarget:(UIViewController *)objectname withImages:(NSArray *)name leftSide:(BOOL)isLeftSide;
- (void)setUpTitle:(NSString *)title WithTarget:(UIViewController *)objectname;
- (UIBarButtonItem *)customiseButtonWithImage:(NSString *)image withSide:(BOOL)isLeftSide;

- (UIBarButtonItem *)setMenuImageWithScale:(float)scale WithPadding:(float)padding isLeftSide:(BOOL)isLeftSide WithAction:(void (^)(void))success;
- (UIBarButtonItem *)setSaveImageWithScale:(float)scale WithPadding:(float)padding isLeftSide:(BOOL)isLeftSide WithAction:(void (^)(void))success;
- (UIBarButtonItem *)setDeleteIncidentWithScale:(float)scale WithPadding:(float)padding isLeftSide:(BOOL)isLeftSide WithAction:(void (^)(void))success;
- (UIBarButtonItem *)setComposeMessageWithScale:(float)scale WithPadding:(float)padding isLeftSide:(BOOL)isLeftSide WithAction:(void (^)(void))success;
@end
