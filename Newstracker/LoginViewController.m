//
//  LoginViewController.m
//  Newstracker
//
//  Created by Micheal on 04/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#define TOPCOLOR [UIColor colorWithRed:36.0f/255.0f green:198.0f/255.0f blue:220.0f/255.0f alpha:1.0f]
#define BOTCOLOR [UIColor colorWithRed:18.0f/255.0f green:82.0f/255.0f blue:190.0f/255.0f alpha:1.0f]
#define BUTTON_STROKE [UIColor colorWithRed:87.0f/255.0f green:177.0f/255.0f blue:239.0f/255.0f alpha:1.0f]

#import "LoginViewController.h"
#import "ModalObjects.h"
#import "utils.h"
#import "MapViewController.h"
#import "ForgotViewController.h"
#import "AppDelegate.h"
#import <POP.h>

@interface LoginViewController ()
{
    BOOL isMovedUp;
}
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.loginButton.layer setBorderColor:BUTTON_STROKE.CGColor];
    [self.loginButton.layer setBorderWidth:1.0];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
    [self navigationBarSetup];
    [self gradientBackground];
    
    [self setPlaceHolderText:@"Enter your email" ForTextField:self.emailTextField];
    [self setPlaceHolderText:@"Password" ForTextField:self.passwordTextField];
    isMovedUp = NO;
 }

- (void)setPlaceHolderText:(NSString *)placeHolder ForTextField:(UITextField *)textField
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:placeHolder attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    textField.attributedPlaceholder = str;
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

- (IBAction)loginClicked:(id)sender
{
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
   if ([self.emailTextField hasText]&&[self.passwordTextField hasText]) {
        [WebServiceHandler sharedInstance].delegate = self;
        [[WebServiceHandler sharedInstance] getCurrentUserDetailsForEmailID:self.emailTextField.text AndPassword:self.passwordTextField.text];
    }
    else {
        [[CodeSnip sharedInstance] showAlert:@"News Crew Tracker" withMessage:@"Some fields are empty" withTarget:self];
    }
}

- (IBAction)forgetPasswordClicked:(id)sender
{
    POPBasicAnimation *opacity = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacity.duration = 1.0;
    opacity.fromValue = @(1);
    opacity.toValue = @(0);
    opacity.name = @"disappear";
    
    POPBasicAnimation *scale = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scale.duration = 1.0;
    scale.delegate = self;
    scale.toValue = [NSValue valueWithCGSize:CGSizeMake(4, 4)];
    scale.name = @"size";
    
    [self.contentView.layer pop_addAnimation:opacity forKey:@"disappear"];
    [self.contentView.layer pop_addAnimation:scale forKey:@"size"];

}
#pragma mark - Pop animation delegate

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    if ([anim.name isEqualToString:@"size"]) {
        ForgotViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotViewController"];
        [self.navigationController pushViewController:nav animated:NO];
    }
}

#pragma mark - WebserviceHandler Delegate

- (void)didReceiveUserData:(NSDictionary *)data
{
    NSLog(@"received data: %@", data);
    if ([data[@"Status"]isEqualToString:@"Success"])
    {
        NSString *userID = data[@"Message"][@"UserId"];
        NSString *groupID = data[@"Message"][@"GroupId"];
        NSString *groupName = data[@"Message"][@"GroupName"];
        NSString *userType = data[@"Message"][@"UserType"];
       
        [UserDefaults setUserIDWithValue:userID];
        [UserDefaults setGroupIDWithValue:groupID];
        [UserDefaults setGroupNameWithValue:groupName];
        [UserDefaults setUserTypeWithValue:userType];
        
        AppDelegate *appdel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appdel.locationUpdateTimer invalidate];
        [appdel backgroundLocationUpdate];

        [[SideBar sharedInstance] setUpSideMenu];
    }
    else if ([data[@"Status"]isEqualToString:@"Failed"])
    {
        [[CodeSnip sharedInstance] showAlert:@"Failed" withMessage:data[@"Message"] withTarget:self];
    }
}


- (void)requestFailedWithError:(NSError *)error
{
    [[CodeSnip sharedInstance] showAlert:@"Network Error" withMessage:[error localizedDescription] withTarget:self];
}

- (void)showErrorAlertWithTitle:(NSString *)title WithMessage:(NSString *)message
{
    [[CodeSnip sharedInstance] showAlert:title withMessage:message withTarget:self];
}

#pragma mark - Textfield delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self moveScrollviewUp];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self moveScrollviewDown];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.emailTextField]) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
        [self moveScrollviewUp];

    }
    else {
        [textField resignFirstResponder];
        [self moveScrollviewDown];
    }
    return YES;
}

- (void)moveScrollviewUp
{
    CGRect textFieldFrame = self.emailTextField.frame;
    if (!isMovedUp) {
        [self.scrollView setContentOffset:CGPointMake(0, CGRectGetMinY(textFieldFrame)-40) animated:YES];
        isMovedUp = YES;
    }

}

- (void)moveScrollviewDown
{
    if (isMovedUp) {
        isMovedUp = NO;
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
   
}

@end
