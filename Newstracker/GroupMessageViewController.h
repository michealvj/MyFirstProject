//
//  GroupMessageViewController.h
//  Newstracker
//
//  Created by Micheal on 21/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceHandler.h"

@interface GroupMessageViewController : UIViewController <UITextViewDelegate, WebServiceHandlerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *charactersLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@end
