//
//  AppDelegate.h
//  Newstracker
//
//  Created by Micheal on 02/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LocationTracker.h"
#import "SideBar.h"
#import "utils.h"
#import "SVProgressHUD.h"
#import "WebServiceHandler.h"
#import "LocationTracker.h"
#import <POP.h>

@import GoogleMaps;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) NSString *gpushTitle;
@property (strong, nonatomic) NSString *gpushMessage;
- (void)showMessage:(id)tap;

@property (strong, nonatomic) UIWindow *window;


@property LocationTracker *locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;
- (void)backgroundLocationUpdate;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

