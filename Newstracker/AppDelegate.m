//
//  AppDelegate.m
//  Newstracker
//
//  Created by Micheal on 02/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//


#import "AppDelegate.h"
#import "MyPushView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:18.0f/255.0f green:82.0f/255.0f blue:190.0f/255.0f alpha:1.0f]];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.7f]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    [GMSServices provideAPIKey:GOOGLE_API_KEY];

    //Push Notification
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                         | UIUserNotificationTypeBadge
                                                                                         | UIUserNotificationTypeSound) categories:nil];
    [application registerUserNotificationSettings:settings];
    
    [self backgroundLocationUpdate];

    return YES;
}

- (void)backgroundLocationUpdate
{
    UIAlertAction *moveToSettings = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        
        UIAlertController *alert = [[CodeSnip sharedInstance] createAlertWithAction:@"Enable Background App Refresh" withMessage:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh" withCancelButton:@"Cancel" withTarget:self.window.rootViewController];
        
        [alert addAction:moveToSettings];

    }
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        
        UIAlertController *alert = [[CodeSnip sharedInstance] createAlertWithAction:@"Enable Background App Refresh" withMessage:@"The functions of this app are limited because the Background App Refresh is disable." withCancelButton:@"Cancel" withTarget:self.window.rootViewController];
        
        [alert addAction:moveToSettings];
     }
    
    else{
        
        self.locationTracker = [[LocationTracker alloc]init];
        [self.locationTracker startLocationTracking];
        
        //Send the best location to server every 60 seconds
        //You may adjust the time interval depends on the need of your app.
        self.locationUpdateTimer =
        [NSTimer scheduledTimerWithTimeInterval:[self getSettingsTime]
                                         target:self
                                       selector:@selector(updateLocation)
                                       userInfo:nil
                                        repeats:YES];
        NSLog(@"Will Update Location after %f seconds", [self getSettingsTime]);
    }

}

- (NSTimeInterval)getSettingsTime
{
    int mins = [[UserDefaults getGPSTime] intValue];
    NSTimeInterval time = mins*60;
    return time;
}

-(void)updateLocation
{
    NSLog(@"updateLocation");
    [self.locationTracker updateLocationToServer];
}

-(void)refreshMap
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateActive)
    {
        if ([UserDefaults isLogin]) {
            NSLog(@"refreshingMap");
            [[WebServiceHandler sharedInstance] getMemberAndIncidentDetails];
        }
    }
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString * devToken = [NSString stringWithFormat:@"%@",deviceToken];
    devToken = [devToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    devToken = [devToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    devToken = [devToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"My token is: %@", devToken);
    [UserDefaults setDeviceTokenWithValue:devToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}




- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *pushMessage = userInfo[@"aps"][@"alert"];
    NSString *userName = userInfo[@"SendBy"];
    NSString *time = [userInfo[@"sent"] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString *alertTitle = [NSString stringWithFormat:@"%@\n%@", userName, time];
    
    NSLog(@"Push Message: %@", userInfo);
    
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
       MyPushView *push = [[MyPushView alloc] initWithTitle:@"News Crew Tracker" WithMessage:pushMessage];
       push.userInfo = @{@"SendBy": userName, @"sent": time};;
       [push addTarget:self action:@selector(showMessage:)];
        
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate date];
        localNotification.userInfo = @{@"SendBy": userName, @"sent": time};
        localNotification.alertTitle = @"News Crew Tracker";
        localNotification.alertBody = pushMessage;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
        
    else
    {
        [[CodeSnip sharedInstance] showAlert:alertTitle withMessage:pushMessage withTarget:self.window.rootViewController];
    }
}

- (void)showMessage:(id)tap
{
    MyPushView *pushView = (MyPushView *)[tap superview];
    NSLog(@"hai");
    NSDictionary *userInfo = pushView.userInfo;
    NSString *userName = userInfo[@"SendBy"];
    NSString *time = userInfo[@"sent"];
    NSString *alertTitle = [NSString stringWithFormat:@"%@\n%@", userName, time];
    
    [[CodeSnip sharedInstance] showAlert:alertTitle withMessage:pushView.message withTarget:self.window.rootViewController];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        NSLog(@"hiding pushview");
        pushView.frame = CGRectMake(0, -70, self.window.frame.size.width, 70);
    }
                     completion:^(BOOL finished)
     {
         
     }];

}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification
{
    if (application.applicationState != UIApplicationStateActive )
    {
        NSDictionary *userInfo = notification.userInfo;
        NSString *userName = userInfo[@"SendBy"];
        NSString *time = userInfo[@"sent"];
        NSString *alertTitle = [NSString stringWithFormat:@"%@\n%@", userName, time];
        
        [[CodeSnip sharedInstance] showAlert:alertTitle withMessage:notification.alertBody withTarget:self.window.rootViewController];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"app resign active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"app enter background");

    NSTimeInterval remainingTime = self.locationUpdateTimer.fireDate.timeIntervalSinceNow;
    NSString *time = remainingTime>60 ? [NSString stringWithFormat:@"%.f minutes", remainingTime/60] : [NSString stringWithFormat:@"%.f seconds", remainingTime];
    NSLog(@"Will Update Location after %@", time);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"app enter foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"app become active");
   
    NSTimeInterval remainingTime = self.locationUpdateTimer.fireDate.timeIntervalSinceNow;
    NSString *time = remainingTime>60 ? [NSString stringWithFormat:@"%.f minutes", remainingTime/60] : [NSString stringWithFormat:@"%.f seconds", remainingTime];
    NSLog(@"Will Update Location after %@", time);

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.

    NSLog(@"app will terminate");
    [self saveContext];
}



#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.dci.Newstracker" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Newstracker" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Newstracker.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
