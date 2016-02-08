//
//  SideMenuViewController.h
//  Newstracker
//
//  Created by Micheal on 08/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalObjects.h"
#import "MFSidemenu.h"

#import "MapViewController.h"
#import "OnlineOfflineViewController.h"
#import "IncidentListViewController.h"
#import "LoginViewController.h"
#import "SettingsViewController.h"
#import "MessageViewController.h"

@interface SideMenuViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, WebServiceHandlerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;

@end
