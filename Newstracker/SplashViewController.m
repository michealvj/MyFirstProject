//
//  SplashViewController.m
//  Newstracker
//
//  Created by Micheal on 15/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//
#define TOPCOLOR [UIColor colorWithRed:36.0f/255.0f green:198.0f/255.0f blue:220.0f/255.0f alpha:1.0f]
#define BOTCOLOR [UIColor colorWithRed:18.0f/255.0f green:82.0f/255.0f blue:190.0f/255.0f alpha:1.0f]

#import "SplashViewController.h"
#import "LoginViewController.h"
#import "MapViewController.h"
#import "UserDefaults.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.compassImage.alpha = 0;
    self.titleLabel.alpha = 0;
    [self navigationBarSetup];
    [self gradientBackground];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self rotateImage];
}
-(void)rotateImage
{
    self.compassImage.hidden = NO;
    
//    POPSpringAnimation *scale = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//    scale.beginTime = CACurrentMediaTime()+1.0;
//    scale.springBounciness = 8.0f;
//    scale.springSpeed = 10.0f;
//    scale.fromValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
//    scale.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
//    scale.name = @"size";
//    [self.compassImage.layer pop_addAnimation:scale forKey:@"pop"];
    POPBasicAnimation *alpha = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    alpha.beginTime = CACurrentMediaTime();
    alpha.delegate = self;
    alpha.duration = 0.5;
    alpha.fromValue = @(0);
    alpha.toValue = @(1);
    alpha.name = @"appearImage";
    [self.compassImage.layer pop_addAnimation:alpha forKey:@"appearImage"];
    
    
    POPDecayAnimation *rotationRight = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotationRight.beginTime = CACurrentMediaTime();
    rotationRight.velocity = @(-5);
    rotationRight.name = @"rotationRight";
    rotationRight.delegate = self;
    [self.compassImage.layer pop_addAnimation:rotationRight forKey:@"rotationRight"];

    POPDecayAnimation *rotation = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotation.beginTime = CACurrentMediaTime()+1.0;
    rotation.velocity = @(288);
    rotation.name = @"rotation";
    rotation.delegate = self;
    [self.compassImage.layer pop_addAnimation:rotation forKey:@"rotation"];

    POPBasicAnimation *opacity = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacity.beginTime = CACurrentMediaTime()+3.5;
    opacity.delegate = self;
    opacity.duration = 1.0;
    opacity.fromValue = @(0);
    opacity.toValue = @(1);
    opacity.name = @"appear";
    [self.titleLabel.layer pop_addAnimation:opacity forKey:@"appear"];

 
}

- (void)navigationBarSetup
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)gradientBackground
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)TOPCOLOR.CGColor, (id)BOTCOLOR.CGColor, nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    if ([anim.name isEqualToString:@"rotation"]) {
     }
    else if ([anim.name isEqualToString:@"appear"])
    {
        if ([UserDefaults isLogin]) {
           [[SideBar sharedInstance] setUpSideMenu];
        }
        else {
            LoginViewController *navigate = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self.navigationController pushViewController:navigate animated:YES];
        }
        
    }
}
@end
