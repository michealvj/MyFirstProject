//
//  TodayViewController.m
//  BackgroundWidget
//
//  Created by Micheal on 12/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>


@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *sharedUserID = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dci.Newstracker"];
    
    if ([sharedUserID valueForKey:@"userID"]) {
        self.widgetLabel.text = @"Location tracking is on";
    }
    else {
        self.widgetLabel.text = @"To see today's incidents, please login";
    }
//    NCWidgetController *widgetController = [NCWidgetController widgetController];
//    
//    [widgetController setHasContent:isLogin forWidgetWithBundleIdentifier:@"com.dci.Newstracker.BackgroundWidget"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    completionHandler(NCUpdateResultNewData);
    
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins
{
    margins.bottom = 13.0;
    return margins;
}

@end
