//
//  OnlineOfflineViewController.h
//  Newstracker
//
//  Created by Micheal on 15/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//
#define GREYTEXTCOLOR [UIColor colorWithRed:168.0f/255.0f green:168.0f/255.0f blue:168.0f/255.0f alpha:1.0f]

#import <UIKit/UIKit.h>
#import "utils.h"
#import "MapViewController.h"

@interface OnlineOfflineViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, WebServiceHandlerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *UserSegmentControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
