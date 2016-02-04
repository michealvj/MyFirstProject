//
//  SettingsViewController.h
//  Newstracker
//
//  Created by Micheal on 21/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, WebServiceHandlerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerBottomConstraint;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView *datePopupView;

@end
