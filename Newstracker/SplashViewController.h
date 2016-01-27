//
//  SplashViewController.h
//  Newstracker
//
//  Created by Micheal on 15/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <POP.h>

@interface SplashViewController : UIViewController <POPAnimationDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *compassImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
