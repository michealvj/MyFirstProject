//
//  MyPushView.m
//  Newstracker
//
//  Created by Micheal on 05/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import "MyPushView.h"

@implementation MyPushView
@synthesize pushView, pushLabel, appDel, sentMessage;

- (id)initWithTitle:(NSString *)title WithMessage:(NSString *)message;
{
    self = [super init];
    
    NSString *finalMessage = [NSString stringWithFormat:@"%@\n%@", title, message];
    
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:finalMessage];
    [attributedMessage addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Roboto-Medium" size:15.0] range:NSMakeRange(0, title.length)];
    [attributedMessage addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Roboto-Regular" size:13.0] range:NSMakeRange(title.length+1, message.length)];
    sentMessage = attributedMessage;
    self.title = title;
    self.message = message;
    return self;
}

- (void)addTarget:(id)target action:(SEL)selector
{
    appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (!pushView) {
        pushView = [[MyPushView alloc] init];
        pushView.frame = CGRectMake(0, -70, appDel.window.frame.size.width, 70);
        pushView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.9];
        pushView.userInteractionEnabled = true;

        pushView.userInfo = self.userInfo;
        pushView.title = self.title;
        pushView.message = self.message;
        
        [appDel.window.rootViewController.view addSubview:pushView];
        UIImageView * logoimage = [[UIImageView alloc]initWithFrame:CGRectMake(10,20 ,20,20)];
        logoimage.image = [UIImage imageNamed:@"pushIcon.png"];
        logoimage.layer.cornerRadius = 4.0f;
        logoimage.clipsToBounds = YES;
        [pushView addSubview:logoimage];
        
        pushLabel = [[UILabel alloc]initWithFrame:CGRectMake(logoimage.frame.size.width+20,20, pushView.frame.size.width-30, pushView.frame.size.height-5)];
        pushLabel.numberOfLines= 3;
        pushLabel = [[UILabel alloc]initWithFrame:CGRectMake(logoimage.frame.size.width+20,20, pushView.frame.size.width-(logoimage.frame.size.width+20+10), pushView.frame.size.height-5)];
        pushLabel.textColor = [UIColor whiteColor];
        pushLabel.numberOfLines= 2;
        [pushView addSubview:pushLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:target
                   action:selector
         forControlEvents:UIControlEventTouchUpInside];
        
        button.frame = CGRectMake(0, 0, pushView.frame.size.width, pushView.frame.size.height);
        button.userInteractionEnabled = YES;
        [pushView addSubview:button];
        
        pushLabel.userInteractionEnabled = true;
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMessage:)];
//        tap.delegate = self;
//        tap.cancelsTouchesInView = YES;
//        tap.numberOfTapsRequired = 1;
//        [pushView addGestureRecognizer:tap];
//        [pushLabel addGestureRecognizer:tap];
//        
        
    }
    if (pushView.frame.origin.x>=0) {
        [self hideAndShowPushViewWithMessage:sentMessage];
    }
    else {
        pushLabel.attributedText = sentMessage;
        [pushLabel sizeToFit];
        [self showPushView];
    }
}



- (void)showPushView
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        NSLog(@"showing pushview");
       pushView.frame = CGRectMake(0, 0, appDel.window.frame.size.width, 70);
    }
                     completion:^(BOOL finished)
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self hidePushView];
         });
     }];
}

- (void)hidePushView
{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        NSLog(@"hiding pushview");
        pushView.frame = CGRectMake(0, -70, appDel.window.frame.size.width, 70);
    }
                     completion:^(BOOL finished)
     {
         
     }];
}

- (void)hideAndShowPushViewWithMessage:(NSAttributedString *)message
{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        NSLog(@"hiding pushview");
        pushView.frame = CGRectMake(appDel.window.frame.origin.x, -70, appDel.window.frame.size.width, 70);
    }
                     completion:^(BOOL finished)
     {
         pushLabel.attributedText= message;
         [pushLabel sizeToFit];
         [self showPushView];
     }];
}

@end
