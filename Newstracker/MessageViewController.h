//
//  MessageViewController.h
//  Newstracker
//
//  Created by Micheal on 08/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalObjects.h"
#import "CodeSnip.h"
#import "SideBar.h"
#import "WebServiceHandler.h"
#import "UserDefaults.h"
#import "GroupMessageViewController.h"

@interface MessageViewController : UIViewController <WebServiceHandlerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;

@end
