//
//  PrivacyViewController.h
//  Newstracker
//
//  Created by Micheal on 23/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideBar.h"
#import "CodeSnip.h"

@interface PrivacyViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (nonatomic, strong) NSString *navigationTitle;
@end
