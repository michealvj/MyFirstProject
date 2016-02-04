//
//  GroupMessageViewController.m
//  Newstracker
//
//  Created by Micheal on 21/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "GroupMessageViewController.h"
#import "utils.h"
#import <POP.h>

@interface GroupMessageViewController ()
{
    id keyBoardHeight;
}
@end

@implementation GroupMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarSetup];
    self.charactersLabel.text = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

- (void)navigationBarSetup
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Settings";
    [[navBar sharedInstance] setUpImageWithTarget:self withImage:@"ltarrow.png" leftSide:YES];
    [[navBar sharedInstance] setUpImageWithTarget:self withImage:@"home.png" leftSide:NO];
}

- (void)animateConstraint:(NSLayoutConstraint *)constraint WithValue:(id)value
{
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 0.0f;
    layoutAnimation.toValue = value;
    [constraint pop_addAnimation:layoutAnimation forKey:@"show"];

}

- (void)keyboardWillShow:(NSNotification *)notification
{
    keyBoardHeight = @([notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
}

- (IBAction)sendMessage:(id)sender
{
    [self animateConstraint:self.viewBottomConstraint WithValue:@(0)];
    [self.messageTextView resignFirstResponder];
    NSLog(@"Message: %@", self.messageTextView.text);
    [[WebServiceHandler sharedInstance] sendGroupMessage:self.messageTextView.text];
}

#pragma mark - TextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    [self animateConstraint:self.viewBottomConstraint WithValue:keyBoardHeight];
    [textView becomeFirstResponder];
    if ([textView.text isEqualToString:@"Enter Message here..."]) {
        textView.text = @"";
    }
    
}

- (void)resetView
{
    [self animateConstraint:self.viewBottomConstraint WithValue:@(0)];

}

- (void)setPlaceHolderText:(NSString *)placeHolder ForTextField:(UITextField *)textField
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:placeHolder attributes:@{ NSForegroundColorAttributeName : textField.textColor, NSFontAttributeName : textField.font }];
    
    textField.attributedPlaceholder = str;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self resetView];
        self.charactersLabel.text = @"";
        [textView resignFirstResponder];
        return NO;
    }
    else if (textView.text.length==1&&[text isEqualToString:@""])
    {
        [self animateConstraint:self.viewBottomConstraint WithValue:@(0)];
        [textView resignFirstResponder];
        textView.text = @"Enter Message here...";
        return NO;
    }
    else {
        [textView becomeFirstResponder];
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *message = textView.text;
    NSUInteger bytes = [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%lu bytes", (unsigned long)bytes);
    int maxCount = 250;
    if (bytes<maxCount)
    {
        self.charactersLabel.text = [NSString stringWithFormat:@"%lu Characters remaining", maxCount - (unsigned long)bytes];
        [self.charactersLabel setTextColor:[UIColor colorWithRed:21.0f/255.0f green:88.0f/255.0f blue:200.0f/255.0f alpha:1.0f]];
        self.sendButton.userInteractionEnabled = YES;
    }
    else
    {
        self.charactersLabel.text = [NSString stringWithFormat:@"Characters exceeded"];
        [self.charactersLabel setTextColor:[UIColor redColor]];
        self.sendButton.userInteractionEnabled = NO;
    }
}

@end
