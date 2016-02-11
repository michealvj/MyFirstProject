//
//  CodeSnip.h
//  rottichennai
//
//  Created by Micheal on 01/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CodeSnip : NSObject
+ (CodeSnip *)sharedInstance;
- (void)showAlert:(NSString *)title withMessage:(NSString *)message withTarget:(id)objname;
- (UIAlertController *)createAlertWithAction:(NSString *)title withMessage:(NSString *)message withCancelButton:(NSString *)cancel withTarget:(id)objname;
- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size;
- (UIImage *)getMemberIconForTitle:(NSString *)title;
- (UIImage *)getMemberSelectedIconForTitle:(NSString *)title;
- (UIImage *)getUnreachMemberIconForTitle:(NSString *)title;
- (UIImage *)getUnreachMemberSelectedIconForTitle:(NSString *)title;
- (UIImage *)getUserIconForTitle:(NSString *)title;
- (UIImage *)getUserSelectedIconForTitle:(NSString *)title;
- (UIImage *)getGroupMemberIconForTitle:(NSString *)title WithCount:(int)count;
- (UIImage *)getGroupMemberSelectedIconForTitle:(NSString *)title WithCount:(int)count;
@end
