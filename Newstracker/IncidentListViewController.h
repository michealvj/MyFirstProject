//
//  IncidentListViewController.h
//  Newstracker
//
//  Created by Micheal on 15/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceHandler.h"
#import "MapViewController.h"
#import "ModalObjects.h"
#import "MyProtocolMethod.h"

@interface IncidentListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, WebServiceHandlerDelegate, MyProtocolDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) id<MyProtocolDelegate> delegate;


@end
