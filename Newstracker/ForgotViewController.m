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

#import "ForgotViewController.h"
#import "LoginViewController.h"
#import "ModalObjects.h"
#import "utils.h"
#import "MapViewController.h"
#import <POP.h>

@interface ForgotViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@end

@implementation ForgotViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.submitButton.layer setBorderColor:BUTTON_STROKE.CGColor];
    [self.submitButton.layer setBorderWidth:1.0];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
    [self navigationBarSetup];
    [self gradientBackground];
    self.contentView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [self transitionAnimation];
    [self setPlaceHolderText:@"Enter registered email address" ForTextField:self.emailTextField];
}

- (void)navigationBarSetup
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)setPlaceHolderText:(NSString *)placeHolder ForTextField:(UITextField *)textField
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:placeHolder attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    textField.attributedPlaceholder = str;
}

- (void)gradientBackground
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)TOPCOLOR.CGColor, (id)BOTCOLOR.CGColor, nil];
    [self.view.layer insertSublayer:gradient atIndex:0];

}

- (void)transitionAnimation
{
    POPBasicAnimation *scale = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scale.duration = 1.0;
    scale.delegate = self;
    scale.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.1, 0.1)];
    scale.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
    scale.name = @"size";
    [self.contentView.layer pop_addAnimation:scale forKey:@"size"];
}


- (IBAction)submitClicked:(id)sender
{
    if ([self.emailTextField hasText]) {
        [WebServiceHandler sharedInstance].delegate = self;
        [[WebServiceHandler sharedInstance] getPasswordForEmailID:self.emailTextField.text];
    }
    else {
        [[CodeSnip sharedInstance] showAlert:@"News Crew Tracker" withMessage:@"Enter valid address" withTarget:self];
    }
}

- (IBAction)backToLogin:(id)sender
{
    LoginViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.navigationController pushViewController:nav animated:YES];
}
#pragma mark - WebserviceHandler Delegate

- (void)showErrorAlertWithTitle:(NSString *)title WithMessage:(NSString *)message
{
    UIAlertController *alert = [[CodeSnip sharedInstance] createAlertWithAction:title withMessage:message withCancelButton:@"Retry" withTarget:self];
    [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        LoginViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:nav animated:YES];
        
    }]];
}

- (void)didReceiveUserData:(NSDictionary *)data
{
    UIAlertController *alert = [[CodeSnip sharedInstance] createAlertWithAction:@"News Crew Tracker" withMessage:data[@"Message"] withCancelButton:nil withTarget:self];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LoginViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:nav animated:YES];
        
    }]];
}


- (void)requestFailedWithError:(NSError *)error
{
    [[CodeSnip sharedInstance] showAlert:@"Network Error" withMessage:[error localizedDescription] withTarget:self];
}

#pragma mark - Textfield delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldFrame = self.emailTextField.frame;
    [self.scrollView setContentOffset:CGPointMake(0, CGRectGetMinY(textFieldFrame)-100) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
}
@end
