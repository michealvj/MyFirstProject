//
//  LoginViewController.h
//  Newstracker
//
//  Created by Micheal on 04/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceHandler.h"
@import GoogleMaps;

@interface LoginViewController : UIViewController <WebServiceHandlerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
