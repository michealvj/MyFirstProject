//
//  MapAreaViewController.h
//  Newstracker
//
//  Created by Micheal on 28/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "utils.h"

@interface MapAreaViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, WebServiceHandlerDelegate>
@property (weak, nonatomic) IBOutlet UIView *mapParentView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@end
