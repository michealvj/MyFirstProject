//
//  ViewController.m
//  Newstracker
//
//  Created by Micheal on 02/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "MapViewController.h"
#import "utils.h"
#import "ModalObjects.h"
#import "UIColor+myColors.h"
#import "UserAssignTableButton.h"
#import <POP.h>

#define TOPCOLOR [UIColor colorWithRed:36.0f/255.0f green:198.0f/255.0f blue:220.0f/255.0f alpha:1.0f]
#define BOTCOLOR [UIColor colorWithRed:18.0f/255.0f green:82.0f/255.0f blue:190.0f/255.0f alpha:1.0f]

#define INCIDENT_TITLE @"Type incident title here..."
#define INCIDENT_ADDRESS @"Tap to search incident location..."
#define INCIDENT_DESCRIPTION @"Type incident description here..."


@import GoogleMaps;

@interface MapViewController ()
{
    GMSPolyline *polyline;
    GMSMapView *gmapView;
    GMSMarker *gmarker, *currentMarker, *selectedIncidentMarker, *updatedIncidentMarker, *selectedUserMarker;
    NSMutableArray *allMemberMarkers, *allIncidentMarkers;
    NSArray *allDetailMorePeople;
    CLLocationCoordinate2D searchedLocation;
    NSString *clickedSearch;
    NSArray *firstNavigationItems;
    NSIndexPath *selectedIndexPath;
    UIButton *selectedAssignButton;
    NSString *userIDFromNotification, *incidentIDFromNotification;
    NSArray *userIDsFromNotification, *userNamesFromNotification, *isAssignedArray;
    
    BOOL showAlert, isAddNewUser, isUnassignFromViewIncident, isUpdatedIncident, isNotificationForMorePeople;
    int selectedUserIndex;
}

@property (weak, nonatomic) IBOutlet UIButton *myLocationButton;
@end

@implementation MapViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [SVProgressHUD showInfoWithStatus:@"Loading Map"];
    [super viewDidLoad];
    
    [self initialiseMapview];
    [self navigationBarSetup];
    
    //setting delegates
    [WebServiceHandler sharedInstance].delegate = self;

    //Adding Marker
    [[WebServiceHandler sharedInstance] getMemberAndIncidentDetails];
    
    //setting Flags
    showAlert = NO;
    isAddNewUser = NO;
    isUnassignFromViewIncident = NO;
    isUpdatedIncident = YES;
    isNotificationForMorePeople = NO;
}


- (IBAction)MyLocation:(id)sender {

    CLLocationManager *location = [[[LocationTracker alloc] init]getCurrentLocation];
    if (location)
    {
        [gmapView animateToLocation:location.location.coordinate];
    }
}

#pragma mark - Navigation Setup

- (void)navigationBarSetup
{
    self.navigationController.navigationBar.barTintColor =[UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    [[SideBar sharedInstance] setUpImage:@"menu.png" WithTarget:self];
    [[SideBar sharedInstance] setUpSearchBarWithTarget:self];
    
    UIBarButtonItem *createButton = self.navigationItem.rightBarButtonItems[0];
    [createButton setAction:@selector(createNewIncident)];
    
    
    firstNavigationItems = self.navigationItem.rightBarButtonItems;
}

- (void)createIncidentNavigationBar
{
    UIBarButtonItem *createButton = self.navigationItem.rightBarButtonItems[0];
    createButton.tintColor = [UIColor myBlueColor];
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = createButton;
    self.navigationItem.title = @"Create Incident";
}

- (void)viewIncidentNavigationBar:(NSString *)navTitle
{
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteIncident:)];
    deleteButton.tintColor = [UIColor myBlueColor];
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = deleteButton;
    self.navigationItem.title = navTitle;
}


- (void)userIncidentNavigationBar:(NSString *)userName
{
    UIBarButtonItem *createButton = self.navigationItem.rightBarButtonItems[0];
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItem = createButton;
    self.navigationItem.title = [NSString stringWithFormat:@"%@'s Incident", userName];
}

- (void)resetNavigationBar
{
    self.navigationItem.rightBarButtonItems = firstNavigationItems;
    self.navigationItem.title = nil;
}

#pragma mark - Helper Methods

- (void)animateMarkerToBottom:(GMSMarker *)marker
{
    [gmapView animateToLocation:marker.position];
    CGPoint mapPoint = [gmapView.projection pointForCoordinate:marker.position];
    CGPoint newPoint = CGPointMake(mapPoint.x, mapPoint.y-(self.view.frame.size.height/2)+75);
    CLLocationCoordinate2D coordinate = [gmapView.projection coordinateForPoint:newPoint];
    [gmapView animateToLocation:coordinate];
}

- (void)animateMarkerToLeft:(GMSMarker *)marker
{
    [gmapView animateToLocation:marker.position];
    CGPoint mapPoint = [gmapView.projection pointForCoordinate:marker.position];
    CGPoint newPoint = CGPointMake(mapPoint.x+(self.view.frame.size.width/2)-75, mapPoint.y-25);
    CLLocationCoordinate2D coordinate = [gmapView.projection coordinateForPoint:newPoint];
    [gmapView animateToLocation:coordinate];
}


- (void)initialiseMapview
{
    //Get current Location
    CLLocationCoordinate2D setLocation = [UserDefaults getMapLocation];
    
    //Setting Mapview
    gmapView = [[MapViewHelper sharedInstance] createMapWithCoordinate:setLocation WithFrame:self.view.frame onTarget:self];
    gmapView.delegate = self;
    
    [self.mapParentView bringSubviewToFront:self.myLocationButton];
    [self.mapParentView bringSubviewToFront:self.notificationView];
    [self.mapParentView bringSubviewToFront:self.morePeopleView];
    [self.mapParentView bringSubviewToFront:self.userDetailView];
    [self.mapParentView bringSubviewToFront:self.incidentDetailView];
    [self.mapParentView bringSubviewToFront:self.viewIncidentView];
    [self.mapParentView bringSubviewToFront:self.addNewUserView];
    [self.mapParentView bringSubviewToFront:self.notificationMoreView];
    
    [self setConstraintsForAnimation];
}

- (void)setConstraintsForAnimation
{
    //For Animation
    self.notificationBottomConstraint.constant = -self.notificationView.frame.size.height;
    self.notificationMoreBottomConstraint.constant = -self.notificationMoreView.frame.size.height;
    self.morePeopleViewLeftConstraint.constant = -self.morePeopleView.frame.size.width;
    self.userDetailTopConstraint.constant = -self.userDetailView.frame.size.height-100;
    self.incidentDetailTopConstraint.constant = -self.incidentDetailView.frame.size.height-100;
    self.viewIncidentTopConstraint.constant = -self.viewIncidentView.frame.size.height-100;
    self.addNewUserTopConstraint.constant = -self.addNewUserView.frame.size.height-100;
    
    
//    self.notificationBottomConstraint.constant = -2000;
//    self.morePeopleViewLeftConstraint.constant = -2000;
//    self.userDetailTopConstraint.constant = -2000;
//    self.incidentDetailTopConstraint.constant = -2000;
//    self.viewIncidentTopConstraint.constant = -2000;
//    self.addNewUserTopConstraint.constant = -2000;
    
}

- (void)resetAllIncidentMarkers
{
    for (GMSMarker *incMarker in allIncidentMarkers)
    {
        if ([incMarker.snippet isEqualToString:@"IncidentSelected"]) {
            incMarker.icon = INCIDENT;
            incMarker.snippet = @"Incident";
        }
    }
    gmapView.selectedMarker = nil;
}

- (void)resetAllMemberMarkers
{
    for (GMSMarker *memberMarker in allMemberMarkers)
    {
        if ([memberMarker.snippet isEqualToString:@"MemberSelected"])
        {
            memberMarker.icon = [[CodeSnip sharedInstance] getMemberIconForTitle:memberMarker.title];
            memberMarker.snippet = @"Member";
        }
        else if ([memberMarker.snippet isEqualToString:@"UnreachMemberSelected"])
        {
            memberMarker.icon = [[CodeSnip sharedInstance] getUnreachMemberIconForTitle:memberMarker.title];
            memberMarker.snippet = @"UnreachMember";
        }
        else if ([memberMarker.snippet isEqualToString:@"GroupMemberSelected"])
        {
            NSArray *names = [memberMarker.userData valueForKey:@"userName"];
            memberMarker.icon = [[CodeSnip sharedInstance] getGroupMemberIconForTitle:memberMarker.title WithCount:(int)names.count];
            memberMarker.snippet = @"GroupMember";
        }
    }
}

- (void)resetCurrentUserMarker
{
    currentMarker.snippet = @"Currentuser";
    currentMarker.icon = [[CodeSnip sharedInstance] getUserIconForTitle:currentMarker.title];
}

#pragma mark - GMSMapviewdelegate methods

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self resetAllMemberMarkers];
    [self resetCurrentUserMarker];
    [self resetAllIncidentMarkers];
    [self hideOtherViews:nil];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    
    if ([marker.snippet isEqualToString:@"Member"])
    {
        [self resetAllMemberMarkers];
        [self resetCurrentUserMarker];
        [self showDistanceDetailsForMember:marker];
        NSString *userName = marker.title;
        marker.icon = MEMBER_SELECTED;
        marker.snippet = @"MemberSelected";
    }
    else if ([marker.snippet isEqualToString:@"MemberSelected"])
    {
        
        NSLog(@"username: %@",marker.title);
        //Show User Details
        NSString *userID = [[marker.userData valueForKey:@"userID"] firstObject];
        selectedUserMarker = marker;
        [[WebServiceHandler sharedInstance] getUsersIncidentForUserID:userID];
        [self animateMarkerToBottom:marker];
    }
    if ([marker.snippet isEqualToString:@"UnreachMember"])
    {
        [self resetAllMemberMarkers];
        [self resetCurrentUserMarker];
        [self showDistanceDetailsForMember:marker];
        NSString *userName = marker.title;
        marker.icon = UNREACH_MEMBER_SELECTED;
        marker.snippet = @"UnreachMemberSelected";
    }
    else if ([marker.snippet isEqualToString:@"UnreachMemberSelected"])
    {
        
        NSLog(@"Unreached username: %@",marker.title);
        //Show unreach username Details
        NSString *userID = [[marker.userData valueForKey:@"userID"] firstObject];
        selectedUserMarker = marker;
        [[WebServiceHandler sharedInstance] getUsersIncidentForUserID:userID];
        [self animateMarkerToBottom:marker];
    }
    
    if ([marker.snippet isEqualToString:@"GroupMember"])
    {
        NSArray *names = [marker.userData valueForKey:@"userName"];
        [self resetAllMemberMarkers];
        [self resetCurrentUserMarker];
        [self showDistanceDetailsForMember:marker];
        selectedUserMarker = marker;
        NSString *userName = marker.title;
        marker.icon = GROUP_MEMBER_SELECTED;
        marker.snippet = @"GroupMemberSelected";
    }
    else if ([marker.snippet isEqualToString:@"GroupMemberSelected"])
    {
        NSLog(@"groupmembers: %@",marker.userData);
        //Show Side Bar With Group Member Details
        [self loadMorePeopleViewForMarker:marker];
        [self showMorePeopleView];
        [self animateMarkerToLeft:marker];
    }
    if ([marker.snippet isEqualToString:@"Incident"])
    {
        [self resetAllIncidentMarkers];
        [self showDistanceDetailsForIncident:marker];
        [gmapView setSelectedMarker:marker];
        marker.snippet = @"IncidentSelected";
        
    }
    else if ([marker.snippet isEqualToString:@"IncidentSelected"])
    {
        NSLog(@"Incident: %@",marker.title);
    }
    if ([marker.snippet isEqualToString:@"Currentuser"])
    {
        [self resetAllMemberMarkers];
        [self resetCurrentUserMarker];
        [self showDistanceDetailsForMember:marker];
        marker.icon = CURRENTUSER_SELECTED;
        marker.snippet = @"CurrentuserSelected";
    }
    else if ([marker.snippet isEqualToString:@"CurrentuserSelected"])
    {
        NSLog(@"current user: %@",marker.title);
        //Show Current user details
        NSString *userID = [[marker.userData valueForKey:@"userID"] firstObject];
        selectedUserMarker = marker;
        [[WebServiceHandler sharedInstance] getUsersIncidentForUserID:userID];
        [self animateMarkerToBottom:marker];
        
    }
    //    gmapView.selectedMarker = marker;
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    //Show Incident Details
    selectedIncidentMarker = marker;
    [self loadViewIncidentViewForMarker:marker];
    
    [self showViewIncidentView];
}

- (void)showPath:(NSString *)polyLinePath
{
    GMSPath *path = [GMSPath pathFromEncodedPath:polyLinePath];
    polyline.map = nil;
    polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeColor = [UIColor redColor];
    polyline.strokeWidth = 5.f;
    polyline.map = gmapView;
    
}

#pragma mark - search bar delegate method

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    clickedSearch = @"searchBar";
    [self hideIncidentDetailView];
    [[MapViewHelper sharedInstance] showGoogleSearchBaronTarget:self];
}


#pragma mark - Webservice Handler delegate method

- (void)requestLoadedWithGeocodeData:(id)data
{
    //Geocode data
    Geocode *model = data;
    
    if ([clickedSearch isEqualToString:@"searchBar"])
    {
        [gmapView animateToLocation:model.coordinate];
    }
    else if([clickedSearch isEqualToString:@"newAddress"])
    {
        [gmapView animateToLocation:model.coordinate];
        [self loadCreateIncidentViewWithData:model];
    }
    else if([clickedSearch isEqualToString:@"updateAddress"])
    {
        [gmapView animateToLocation:model.coordinate];
        [self loadViewIncidentViewWithData:model];
    }
}

- (void)requestLoadedWithTimeDistanceData:(id)data
{
    //TimeDistance data
    TimeDistance *model = data;

//    [self showPath:model.polyLine];
    
    NSAttributedString *time = [self customiseTime:model.duration];
    
    if (showAlert)
    {
        [self addNewUserAlertWithTime:model];
    }
    else if (isNotificationForMorePeople)
    {
        NSLog(@"%@", userNamesFromNotification);
        self.notificationMoreTimeLabel.attributedText = time;
        [self loadAndShowMorePeopleView];
    
    }
    else
    {
        //Loading Notification View
        self.notificationMinutesLabel.attributedText = time;
        [[WebServiceHandler sharedInstance] checkIfAssigedForUserID:userIDFromNotification AndIncidentID:incidentIDFromNotification];
    }
}

- (void)isUserAssignedToIncident:(NSArray *)assignedArray
{
    //For Notification view
    if (assignedArray.count==1)
    {
        NSString *isAssigned = [assignedArray firstObject];
        self.notificationAssignButton.hidden = NO;
        if ([isAssigned isEqualToString:@"Assign"])
        {
            NSLog(@"%@", isAssigned);
            self.notificationAssignButton.selected = NO;
            [self.notificationAssignButton setBackgroundColor:[UIColor whiteColor]];
        }
        else if ([isAssigned isEqualToString:@"Unassign"])
        {
            NSLog(@"%@", isAssigned);
            self.notificationAssignButton.selected = YES;
            [self.notificationAssignButton setBackgroundColor:[UIColor colorWithRed:21.0f/255.0f green:88.0f/255.0f blue:200.0f/255.0f alpha:1.0f]];
        }
        [self showNotificationView];

    }
    //For Notification More View
    else
    {
        isAssignedArray = assignedArray;
        [self.notificationMoreTableView reloadData];
        [self showNotificationMoreView];
    }
}

- (void)didSelectAddress:(NSString *)address
{
    self.assignNewUserButton.enabled = YES;
    self.assignNewUserButton.alpha = 1.0;

    self.incidentDetailAddress.text = address;
    self.incidentDetailAddress.userInteractionEnabled = NO;
    self.incidentAddressEditButton.selected = NO;
    
    [self.incidentDetailTitle resignFirstResponder];
    [self.incidentDetailAddress resignFirstResponder];
    [self.incidentDetailDescription resignFirstResponder];
    
    [self sizeToFitViewIncident];
}

- (void)didCreateNewIncident:(Incident *)incident
{
    [self.incidentDetailTitle resignFirstResponder];
    [self.incidentDetailAddress resignFirstResponder];
    [self.incidentDetailDescription resignFirstResponder];
    
    [[CodeSnip sharedInstance] showAlert:incident.incidentName withMessage:@"Incident Created Successfully" withTarget:self];
    
    //Plot new incident in Map
    MapViewHelper *map = [MapViewHelper sharedInstance];
    GMSMarker *incidentMarker = [map addSearchIncidentMarkerWithTitle:incident WithSnippet:nil WithCoordinate:searchedLocation onMap:gmapView];
    [allIncidentMarkers addObject:incidentMarker];
    gmapView.selectedMarker = incidentMarker;
    
    //show view Incident view
    selectedIncidentMarker = incidentMarker;
    [self loadViewIncidentViewForMarker:incidentMarker];
    [self showViewIncidentView];
}

- (void)didDeleteIncident
{
    [self hideViewIncidentView];
    [self hideAddNewUserView];
    [[CodeSnip sharedInstance] showAlert:selectedIncidentMarker.title withMessage:@"Incident Deleted Successfully" withTarget:self];
    selectedIncidentMarker.map = nil;
    [allIncidentMarkers removeObject:selectedIncidentMarker];
}

- (void)didUpdateIncident
{
    isUpdatedIncident = YES;
    [self hideViewIncidentView];
    [self.incidentDetailTitle resignFirstResponder];
    [self.incidentDetailAddress resignFirstResponder];
    [self.incidentDetailDescription resignFirstResponder];
    
    //Delete old incident in Map
    selectedIncidentMarker.map = nil;
    [allIncidentMarkers removeObject:selectedIncidentMarker];
    
    //Plot updated incident in Map
    updatedIncidentMarker.title = updatedIncidentMarker.userData[@"incidentName"];
    updatedIncidentMarker.snippet = @"Incident";
    updatedIncidentMarker.map = gmapView;
    [allIncidentMarkers addObject:updatedIncidentMarker];
    gmapView.selectedMarker = updatedIncidentMarker;
    
    [self animateMarkerToBottom:updatedIncidentMarker];

    
    [[CodeSnip sharedInstance] showAlert:updatedIncidentMarker.title withMessage:@"Incident Updated Successfully" withTarget:self];
}

- (void)didGetIncidentNearUser:(id)data
{
    if (isAddNewUser)
    {
        self.addNewUserArray = data;
        [self.addNewUserTableView reloadData];
        [self loadAddNewUserViewForMarker];
        [self showAddNewUserView];
    }
    else
    {
        self.viewIncidentUsersArray = [[NSMutableArray alloc] init];
        for (User *user in data)
        {
            if (user.isAssigned)
            {
                [self.viewIncidentUsersArray addObject:user];
            }
        }
        [self.viewIncidentTableView reloadData];
        self.viewIncidentTableHeight.constant = self.viewIncidentTableView.contentSize.height+10;
    }
}

- (void)didAssignIncident
{
    //Assign Incident
    selectedAssignButton.selected = !selectedAssignButton.selected;
    [selectedAssignButton setBackgroundColor:[UIColor colorWithRed:21.0f/255.0f green:88.0f/255.0f blue:200.0f/255.0f alpha:1.0f]];
    [self popAnimationForButton:selectedAssignButton];
}

- (void)didUnassignIncident
{
    //Is Clicked from user table view
    if ([[[[selectedAssignButton superview] superview] superview]isKindOfClass:[UITableViewCell class]])
    {
        UITableViewCell *clickedCell = (UITableViewCell *)[[[selectedAssignButton superview] superview] superview];
        NSIndexPath *clickedButtonIndexPath = [self.userDetailTableView indexPathForCell:clickedCell];
        
        //Deleting TableCell
        [self.userDetailIncidentsArray removeObjectAtIndex:clickedButtonIndexPath.row];
        [self.userDetailTableView deleteRowsAtIndexPaths:@[clickedButtonIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    }
    //Is clicked from View Incident
    else if (isUnassignFromViewIncident)
    {
        UITableViewCell *clickedCell = (UITableViewCell *)[[selectedAssignButton superview] superview];
        NSIndexPath *clickedButtonIndexPath = [self.viewIncidentTableView indexPathForCell:clickedCell];
        
        //Deleting TableCell
        
        [CATransaction begin];
        
        [self.viewIncidentTableView  beginUpdates];
        
        //...
        
        [CATransaction setCompletionBlock: ^{
            // Code to be executed upon completion
            [self.viewIncidentTableView reloadData];
            self.viewIncidentTableHeight.constant = self.viewIncidentTableView.contentSize.height+8;
        }];
        
        [self.viewIncidentUsersArray removeObjectAtIndex:clickedButtonIndexPath.row];
        [self.viewIncidentTableView deleteRowsAtIndexPaths:@[clickedButtonIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.viewIncidentTableView  endUpdates];
        
        [CATransaction commit];
    }
    //Is clicked from notification view|user assign view
    else
    {
        selectedAssignButton.selected = !selectedAssignButton.selected;
        [selectedAssignButton setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)didReceiveUserIncidents:(id)data
{
    NSArray *incidentsArray = data;
    if (!incidentsArray.count==0)
    {
        Incident *incident = data[0];
        NSLog(@"%@", incident.incidentID);
        if ([incident.incidentID isEqualToString:@"00000000-0000-0000-0000-000000000000"])
        {
            data = nil;
            [self loadUserDetailViewForIncidents:data];
            [self showUserDetailView:selectedUserMarker.title];
        }
        else
        {
            if ([selectedUserMarker.snippet isEqualToString:@"GroupMemberSelected"]||
                [selectedUserMarker.snippet isEqualToString:@"GroupMember"])
            {
                NSDictionary *userData = selectedUserMarker.userData;
                NSArray *userNames = userData[@"userName"];
                [self loadUserDetailViewForIncidents:data];
                [self showUserDetailView:[userNames objectAtIndex:selectedUserIndex]];
            }
            else
            {
                [self loadUserDetailViewForIncidents:data];
                [self showUserDetailView:selectedUserMarker.title];
            }
        }

    }
    else
    {
        if ([selectedUserMarker.snippet isEqualToString:@"GroupMemberSelected"]||
            [selectedUserMarker.snippet isEqualToString:@"GroupMember"])
        {
            NSDictionary *userData = selectedUserMarker.userData;
            NSArray *userNames = userData[@"userName"];
            data = nil;
            [self loadUserDetailViewForIncidents:data];
            [self showUserDetailView:[userNames objectAtIndex:selectedUserIndex]];
        }
        else
        {
            [self loadUserDetailViewForIncidents:data];
            [self showUserDetailView:selectedUserMarker.title];
        }
       
    }
}

- (void)didReceiveIncidentDetails:(NSArray *)data
{
    allIncidentMarkers = [[NSMutableArray alloc] init];
   for (Incident *incident in data)
    {
        gmarker = [[MapViewHelper sharedInstance] addIncidentMarkerWithTitle:incident WithSnippet:nil WithCoordinate:incident.coordinate onMap:gmapView];
        [allIncidentMarkers addObject:gmarker];
    }
   
    //If Selected from Incidents List
    if (self.selectedIncident!=nil)
    {
        [self loadIncidentDetailForIncident:self.selectedIncident];
        self.selectedIncident = nil;
    }
    [self.mapRefreshingTimer invalidate];
    self.mapRefreshingTimer =
    [NSTimer scheduledTimerWithTimeInterval:[self getSettingsTime]
                                     target:self
                                   selector:@selector(refreshMap)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)didReceiveMemberDetails:(NSArray *)data
{
    [gmapView clear];
    allMemberMarkers = [[NSMutableArray alloc] init];
    for (GroupMember *member in data)
    {
        if ([[member.userID firstObject] isEqualToString:[UserDefaults getUserID]])
        {
            currentMarker = [[[LocationTracker alloc] init] addCurrentMarkerWithTitle:member WithSnippet:nil onMap:gmapView];
        }
        else
        {
            gmarker = [[MapViewHelper sharedInstance] addMarkerWithTitle:member WithSnippet:nil WithCoordinate:member.coordinate onMap:gmapView];
        }
        [allMemberMarkers addObject:gmarker];
    }
   
    //If Selected from Online/Offline List
    if (self.selectedUser!=nil)
    {
        [self loadUserDetailForUser:self.selectedUser];
        self.selectedUser = nil;
    }
}
- (void)requestFailedWithError:(NSError *)error
{
    [[CodeSnip sharedInstance] showAlert:@"Network Error" withMessage:[error localizedDescription] withTarget:self];
}

- (void)showErrorAlertWithTitle:(NSString *)title WithMessage:(NSString *)message
{
    [[CodeSnip sharedInstance] showAlert:title withMessage:message withTarget:self];
}

#pragma mark - Refreshing Map

- (NSTimeInterval)getSettingsTime
{
    int mins = 1;
    NSTimeInterval time = mins*60;
    return time;
}

-(void)refreshMap
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateActive)
    {
        if ([UserDefaults isLogin]) {
            NSLog(@"refreshingMap");
            [[WebServiceHandler sharedInstance] refreshMap];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.mapRefreshingTimer invalidate];
    self.mapRefreshingTimer = nil;
}


#pragma mark - Notification View (More People)

- (void)loadAndShowMorePeopleView
{
    NSString *userIDs = [userIDsFromNotification componentsJoinedByString:@"~"];
    [[WebServiceHandler sharedInstance] checkIfAssigedForUserID:userIDs AndIncidentID:incidentIDFromNotification];
}

- (IBAction)closeNotificationMoreView:(id)sender
{
    [self resetAllIncidentMarkers];
    [self resetAllMemberMarkers];
    [self hideNotificationMoreView];
}

- (IBAction)assignFromNotificationMore:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.notificationMoreTableView];
    NSIndexPath *clickedButtonIndexPath = [self.notificationMoreTableView indexPathForRowAtPoint:buttonPosition];

    isUnassignFromViewIncident = NO;
    selectedAssignButton = sender;
    if (sender.selected)
    {
        //Unassign Incident
        [[WebServiceHandler sharedInstance] unassignIncident:incidentIDFromNotification forUserID:[userIDsFromNotification objectAtIndex:clickedButtonIndexPath.row]];
    }
    else
    {
        //Assign Incident
        [[WebServiceHandler sharedInstance] assignIncident:incidentIDFromNotification forUserID:[userIDsFromNotification objectAtIndex:clickedButtonIndexPath.row]];
    }
}

#pragma mark - Notification View

- (IBAction)assignFromNotification:(UIButton *)sender
{
    isUnassignFromViewIncident = NO;
    selectedAssignButton = sender;
    if (sender.selected)
    {
        //Unassign Incident
        [[WebServiceHandler sharedInstance] unassignIncident:incidentIDFromNotification forUserID:userIDFromNotification];
    }
    else
    {
        //Assign Incident
        [[WebServiceHandler sharedInstance] assignIncident:incidentIDFromNotification forUserID:userIDFromNotification];
    }

}

- (NSMutableAttributedString *)customiseTime:(NSString *)time
{
    if ([time containsString:@"days"])
    {
        time = [time stringByReplacingOccurrencesOfString:@"days" withString:@"days\n"];
    }
    else if ([time containsString:@"day"])
    {
        time = [time stringByReplacingOccurrencesOfString:@"day" withString:@"day\n"];
    }
    else if ([time containsString:@"hours"])
    {
        time = [time stringByReplacingOccurrencesOfString:@"hours" withString:@"hrs\n"];
    }
    else if ([time containsString:@"hour"])
    {
        time = [time stringByReplacingOccurrencesOfString:@"hour" withString:@"hr\n"];
    }
    
    NSMutableAttributedString *smallSize = [[NSMutableAttributedString alloc] initWithString:time];
    
    if ([time containsString:@"days"])
    {
        NSString *rangeString = @"days";
        [self addSmallFontAttribute:smallSize ForString:time ForRangeString:rangeString];
    }
    else if ([time containsString:@"day"])
    {
        NSString *rangeString = @"day";
        [self addSmallFontAttribute:smallSize ForString:time ForRangeString:rangeString];
        
    }
    
    if ([time containsString:@"hrs"])
    {
        NSString *rangeString = @"hrs";
        [self addSmallFontAttribute:smallSize ForString:time ForRangeString:rangeString];
    }
    else if ([time containsString:@"hr"])
    {
        NSString *rangeString = @"hr";
        [self addSmallFontAttribute:smallSize ForString:time ForRangeString:rangeString];
    }
    
    if ([time containsString:@"mins"])
    {
        NSString *rangeString = @"mins";
        [self addSmallFontAttribute:smallSize ForString:time ForRangeString:rangeString];
    }
    else if ([time containsString:@"min"])
    {
        NSString *rangeString = @"min";
        [self addSmallFontAttribute:smallSize ForString:time ForRangeString:rangeString];
    }
    
    return smallSize;
}

- (void)addSmallFontAttribute:(NSMutableAttributedString *)smallSize ForString:(NSString *)string ForRangeString:(NSString *)rangeString
{
    [smallSize addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:self.notificationMinutesLabel.font.fontName size:18.0]
                      range:[string rangeOfString:rangeString]];
}

- (void)findDistanceFromMarker:(GMSMarker *)marker1 ToMarker:(GMSMarker *)marker2
{
    [self hideNotificationView];
    [self hideNotificationMoreView];
    self.notificationAssignButton.hidden = YES;
    showAlert = NO;
    NSString *distanceURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false",marker1.position.latitude,marker1.position.longitude,marker2.position.latitude,marker2.position.longitude];
    [[WebServiceHandler sharedInstance] getTimeDistanceForURL:distanceURL];
    NSArray *names = [marker1.userData valueForKey:@"userName"];
    
    if (names.count>1)
    {
        isNotificationForMorePeople = YES;
        userIDsFromNotification = [marker1.userData valueForKey:@"userID"];
        userNamesFromNotification = [marker1.userData valueForKey:@"userName"];
//        self.notificationTextLabel.text = [NSString stringWithFormat:@"%@ (+%i)", marker1.title, (int)names.count-1];
    }
    else
    {
        isNotificationForMorePeople = NO;
        self.notificationTextLabel.text = [NSString stringWithFormat:@"%@", marker1.title];
        userIDFromNotification = [[marker1.userData valueForKey:@"userID"] firstObject];
        
    }
    incidentIDFromNotification = [marker2.userData valueForKey:@"incidentID"];
    
}

- (void)findDistanceFromLocation:(CLLocationCoordinate2D)fromLocation ToLocation:(CLLocationCoordinate2D)toLocation
{
    NSString *distanceURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false",fromLocation.latitude,fromLocation.longitude,toLocation.latitude,toLocation.longitude];
    [[WebServiceHandler sharedInstance] getTimeDistanceForURL:distanceURL];
}

- (void)showDistanceDetailsForIncident:(GMSMarker *)incidentMarker
{
    for (GMSMarker *memberMarker in allMemberMarkers)
    {
        if ([memberMarker.snippet isEqualToString:@"MemberSelected"])
        {
            [self findDistanceFromMarker:memberMarker ToMarker:incidentMarker];
        }
        else if ([memberMarker.snippet isEqualToString:@"UnreachMemberSelected"])
        {
            [self findDistanceFromMarker:memberMarker ToMarker:incidentMarker];
        }
        else if ([memberMarker.snippet isEqualToString:@"GroupMemberSelected"])
        {
            [self findDistanceFromMarker:memberMarker ToMarker:incidentMarker];
        }
        else if ([currentMarker.snippet isEqualToString:@"CurrentuserSelected"])
        {
            [self findDistanceFromMarker:currentMarker ToMarker:incidentMarker];
        }
    }
}

- (void)showDistanceDetailsForMember:(GMSMarker *)memberMarker
{
    for (GMSMarker *incidentMarker in allIncidentMarkers)
    {
        if ([incidentMarker.snippet isEqualToString:@"IncidentSelected"])
        {
            [self findDistanceFromMarker:memberMarker ToMarker:incidentMarker];
        }
    }
}



#pragma mark - Add New User View

- (void)addNewUserAlertWithTime:(TimeDistance *)destination
{
    User *selectedUser = [self.addNewUserArray objectAtIndex:selectedIndexPath.row];
    NSString *incidentID = selectedIncidentMarker.userData[@"incidentID"];
    
    
    NSString *title = [NSString stringWithFormat:@"%@ to Incident", selectedUser.userName];
    NSString *message = [NSString stringWithFormat:@"%@ | %@", destination.distance, destination.duration];
    
    UIAlertController *alert = [[CodeSnip sharedInstance] createAlertWithAction:title withMessage:message withCancelButton:@"Cancel" withTarget:self];
    
    if (selectedAssignButton.selected)
    {
        [alert addAction:[UIAlertAction actionWithTitle:@"Unassign" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
        {
            //Unassign Incident
            [[WebServiceHandler sharedInstance] unassignIncident:incidentID forUserID:selectedUser.userID];
        }]];
    }
    else
    {
        [alert addAction:[UIAlertAction actionWithTitle:@"Assign" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
        {
            //Assign Incident
            [[WebServiceHandler sharedInstance] assignIncident:incidentID forUserID:selectedUser.userID];
        }]];
    }
}

- (void)loadAddNewUserViewForMarker
{
    self.addNewUserIncidentTitle.text = selectedIncidentMarker.title;
}

- (IBAction)assignOrUnassign:(UIButton *)sender
{
    isUnassignFromViewIncident = NO;
    selectedAssignButton = sender;
    
    UITableViewCell *selectedCell = (UITableViewCell *)[[sender superview] superview];
    selectedIndexPath = [self.addNewUserTableView indexPathForCell:selectedCell];
    
    User *user = [self.addNewUserArray objectAtIndex:selectedIndexPath.row];
    
    NSString *incidentID = selectedIncidentMarker.userData[@"incidentID"];
    
    if (sender.selected)
    {
        //Unassign Incident
        [[WebServiceHandler sharedInstance] unassignIncident:incidentID forUserID:user.userID];
    }
    else
    {
        //Assign Incident
        [[WebServiceHandler sharedInstance] assignIncident:incidentID forUserID:user.userID];
    }
}

- (IBAction)duration:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.addNewUserTableView];
    NSIndexPath *indexPath = [self.addNewUserTableView indexPathForRowAtPoint:buttonPosition];
    
    UITableViewCell *selectedCell = (UITableViewCell *)[[sender superview] superview];
    
    NSLog(@"button clicked: %ld", (long)indexPath.row);
    
    selectedAssignButton = (UIButton *)[selectedCell viewWithTag:2];
    
    selectedIndexPath = indexPath;
    User *selectedUser = [self.addNewUserArray objectAtIndex:indexPath.row];
    showAlert = YES;
    [self findDistanceFromLocation:selectedIncidentMarker.position ToLocation:selectedUser.coordinate];


}


- (IBAction)closeAssignUserView:(id)sender
{
    [self hideAddNewUserView];
    [self loadViewIncidentViewForMarker:selectedIncidentMarker];
    [self showViewIncidentView];
}


#pragma mark - More People View

- (void)loadMorePeopleViewForMarker:(GMSMarker *)marker
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.morePeopleView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)BOTCOLOR.CGColor, (id)TOPCOLOR.CGColor, nil];
    [self.morePeopleView.layer insertSublayer:gradient atIndex:0];
    
    allDetailMorePeople = (NSArray *)marker.userData;
    NSArray *totalPeople = [allDetailMorePeople valueForKey:@"userName"];
    self.totalPeopleCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)totalPeople.count];
    self.morePeoplesArray = totalPeople;
    [self.morePeopleTableView reloadData];
}

- (IBAction)closePeopleView:(id)sender {
    [self hideMorePeopleView];
}

#pragma mark - Incident Detail View

- (void)createNewIncident
{
    self.incidentDetailTitle.text = INCIDENT_TITLE;
    self.incidentDetailDescription.text = INCIDENT_DESCRIPTION;
    self.incidentDetailAddress.text = INCIDENT_ADDRESS;
    
    self.incidentTitleEditButton.hidden = YES;
    self.incidentDescriptionEditButton.hidden = YES;
    self.incidentAddressEditButton.hidden = YES;
    
    clickedSearch = @"newAddress";
    [self showIncidentDetailView];
}

- (void)loadCreateIncidentViewWithData:(Geocode *)data
{
    self.incidentDetailAddress.text = data.address;
    searchedLocation = data.coordinate;
    self.incidentDetailAddress.userInteractionEnabled = NO;
    self.incidentAddressEditButton.selected = NO;
    [self.incidentDetailTitle resignFirstResponder];
    [self.incidentDetailAddress resignFirstResponder];
    [self.incidentDetailDescription resignFirstResponder];
}

- (void)loadViewIncidentViewWithData:(Geocode *)data
{
    self.viewIncidentAddress.text = data.address;
    searchedLocation = data.coordinate;
    self.viewIncidentAddress.userInteractionEnabled = NO;
    self.editIncidentAddressButton.selected = NO;
    
    [self.viewIncidentTitle resignFirstResponder];
    [self.viewIncidentAddress resignFirstResponder];
    [self.viewIncidentDescription resignFirstResponder];
    [self sizeToFitViewIncident];
}

- (IBAction)saveIncident:(id)sender
{
    [self.incidentDetailScrollView setContentOffset:CGPointMake(0, 0)];
    if (self.incidentDetailTitle.text.length==0||self.incidentDetailAddress.text.length==0||self.incidentDetailDescription.text.length==0)
    {
        [[CodeSnip sharedInstance] showAlert:@"News Crew Tracker" withMessage:@"One or More Fields are Empty" withTarget:self];
    }
    else if ([self.incidentDetailTitle.text isEqualToString:INCIDENT_TITLE]||[self.incidentDetailAddress.text isEqualToString:INCIDENT_ADDRESS]||[self.incidentDetailDescription.text isEqualToString:INCIDENT_DESCRIPTION])
    {
        [[CodeSnip sharedInstance] showAlert:@"News Crew Tracker" withMessage:@"Enter Valid Details" withTarget:self];
    }
    else
    {
        NSMutableDictionary *createInfo = [[NSMutableDictionary alloc] init];
        
        createInfo[@"IncidentName"] = self.incidentDetailTitle.text;
        createInfo[@"Description"] = self.incidentDetailDescription.text;
        createInfo[@"Latitude"] = [NSString stringWithFormat:@"%f", searchedLocation.latitude];
        createInfo[@"Longitude"] = [NSString stringWithFormat:@"%f", searchedLocation.longitude];
        createInfo[@"AddressLine1"] = self.incidentDetailAddress.text;
        createInfo[@"AddressLine2"] = @"";
        createInfo[@"City"] = @"";
        createInfo[@"State"] = @"";
        createInfo[@"Country"] = @"";
        createInfo[@"ZipCode"] = @"";
        
        [[WebServiceHandler sharedInstance] createIncidentWithParams:createInfo];
        [self hideIncidentDetailView];
    }
}

- (IBAction)assignNewUser:(id)sender
{
    isAddNewUser = YES;
    isUnassignFromViewIncident = NO;

    NSString *incidentID = selectedIncidentMarker.userData[@"incidentID"];
    [[WebServiceHandler sharedInstance] getIncidentNearUser:incidentID];
}

- (IBAction)editIncidentTitle:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        self.incidentDetailTitle.userInteractionEnabled = YES;
        [self.incidentDetailTitle becomeFirstResponder];
    }
    else
    {
        self.incidentDetailTitle.userInteractionEnabled = NO;
        [self.incidentDetailTitle resignFirstResponder];
    }
    
}

- (IBAction)editIncidentAddress:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        self.incidentDetailAddress.userInteractionEnabled = YES;
        [self.incidentDetailAddress becomeFirstResponder];
    }
    else
    {
        self.incidentDetailAddress.userInteractionEnabled = NO;
        [self.incidentDetailAddress resignFirstResponder];
    }
    
}

- (IBAction)editIncidentDescription:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        self.incidentDetailDescription.userInteractionEnabled = YES;
        [self.incidentDetailDescription becomeFirstResponder];
    }
    else
    {
        self.incidentDetailDescription.userInteractionEnabled = NO;
        [self.incidentDetailDescription resignFirstResponder];
        
    }
}

- (IBAction)closeCreateIncidentView:(id)sender
{
    [self resetAllIncidentMarkers];
    [self hideIncidentDetailView];
}

#pragma mark - View Incident View

- (void)deleteIncident:(id)sender
{
    NSString *incidentID = selectedIncidentMarker.userData[@"incidentID"];
    
    UIAlertController *alert = [[CodeSnip sharedInstance] createAlertWithAction:selectedIncidentMarker.title withMessage:@"Are you sure to delete it?" withCancelButton:@"NO" withTarget:self];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
    {
        [[WebServiceHandler sharedInstance] deleteIncidentWithID:incidentID];
        
        NSLog(@"Delete Incident: %@", selectedIncidentMarker.userData[@"incidentID"]);
    }]];
    
}

- (void)loadViewIncidentViewForMarker:(GMSMarker *)incidentMarker
{
    
    self.updateIncidentButton.enabled = NO;
    self.updateIncidentButton.alpha = 0.5;
    isUpdatedIncident = YES;
    
    self.viewIncidentTitle.userInteractionEnabled = NO;
    self.viewIncidentAddress.userInteractionEnabled = NO;
    self.viewIncidentDescription.userInteractionEnabled = NO;

    
    self.editIncidentTitleButton.selected = NO;
    self.editIncidentAddressButton.selected = NO;
    self.editIncidentDescriptionButton.selected = NO;
    
    [self.incidentDetailTitle resignFirstResponder];
    [self.incidentDetailAddress resignFirstResponder];
    [self.incidentDetailDescription resignFirstResponder];

    [self.viewIncidentTitle resignFirstResponder];
    [self.viewIncidentAddress resignFirstResponder];
    [self.viewIncidentDescription resignFirstResponder];

    
    
    self.viewIncidentTitle.text = incidentMarker.title;
    self.viewIncidentAddress.text = incidentMarker.userData[@"incidentAddress"];
    self.viewIncidentDescription.text = incidentMarker.userData[@"incidentDescription"];
    searchedLocation = incidentMarker.position;
    
    [self.viewIncidentScrollView setContentOffset:CGPointMake(0, 0)];
    
    [self sizeToFitViewIncident];
    [self animateMarkerToBottom:incidentMarker];
    
    //Load Array
    [self loadAssignedUser];
//    [self.viewIncidentScrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    
//    if (object == self.viewIncidentScrollView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
//        
//        NSLog(@"%@", change[@"new"]);
//        NSLog(@"%f:%f",self.viewIncidentScrollView.contentOffset.x, self.viewIncidentScrollView.contentOffset.y);
//        //Note that you should track your page index
////        self.viewIncidentScrollView.contentOffset = CGPointMake(self.viewIncidentScrollView.bounds.size.width, self.viewIncidentScrollView.contentOffset.y);
//        
//    } else {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//}

- (void)sizeToFitViewIncident
{
    //Size to Fit
    [self.viewIncidentTitle sizeToFit];
    self.viewIncidentTitleHeightConstraint.constant = self.viewIncidentTitle.frame.size.height;
   
   [self.viewIncidentDescription sizeToFit];
    self.viewIncidentDescriptionHeightConstraint.constant = self.viewIncidentDescription.frame.size.height;
    
   [self.viewIncidentAddress sizeToFit];
   self.viewIncidentAddressHeightConstraint.constant = self.viewIncidentAddress.frame.size.height;
    
}

- (void)loadIncidentDetailForIncident:(Incident *)incident
{
    for (GMSMarker *incidentMarker in allIncidentMarkers)
    {
        NSDictionary *userInfo = incidentMarker.userData;
        if ([userInfo[@"incidentID"] isEqualToString:incident.incidentID])
        {
            selectedIncidentMarker = incidentMarker;
            [gmapView setSelectedMarker:incidentMarker];
            [self loadViewIncidentViewForMarker:selectedIncidentMarker];
            [self showViewIncidentView];
        }
    }
}

- (void)updateIncident
{
    //Set to be updated
    updatedIncidentMarker = selectedIncidentMarker;
    updatedIncidentMarker.position = searchedLocation;
    NSDictionary *updatedInfo = @{@"incidentID": selectedIncidentMarker.userData[@"incidentID"],
                                  @"incidentName": self.viewIncidentTitle.text,
                                  @"incidentAddress": self.viewIncidentAddress.text,
                                  @"incidentDescription": self.viewIncidentDescription.text};
    updatedIncidentMarker.userData=updatedInfo;
    
    NSMutableDictionary *updateInfo = [[NSMutableDictionary alloc] init];
    updateInfo[@"IncidentId"] = selectedIncidentMarker.userData[@"incidentID"];
    updateInfo[@"IncidentName"] = self.viewIncidentTitle.text;
    updateInfo[@"Description"] = self.viewIncidentDescription.text;
    updateInfo[@"Latitude"] = [NSString stringWithFormat:@"%f", searchedLocation.latitude];
    updateInfo[@"Longitude"] = [NSString stringWithFormat:@"%f", searchedLocation.longitude];
    updateInfo[@"AddressLine1"] = self.viewIncidentAddress.text;
    updateInfo[@"AddressLine2"] = @"";
    updateInfo[@"City"] = @"";
    updateInfo[@"State"] = @"";
    updateInfo[@"Country"] = @"";
    updateInfo[@"ZipCode"] = @"";
    
    [[WebServiceHandler sharedInstance] updateIncidentWithParams:updateInfo];
}

- (IBAction)updateIncident:(id)sender
{
    [self updateIncident];
}

- (IBAction)editViewIncidentTitle:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        self.viewIncidentTitle.userInteractionEnabled = YES;
        [self.viewIncidentTitle becomeFirstResponder];
        
        self.updateIncidentButton.enabled = YES;
        self.updateIncidentButton.alpha = 1.0;
        isUpdatedIncident = NO;
    }
    else
    {
        self.viewIncidentTitle.userInteractionEnabled = NO;
        [self.viewIncidentTitle resignFirstResponder];
    }
    
}

- (IBAction)editViewIncidentAddress:(UIButton *)sender {
    
    
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        self.viewIncidentAddress.userInteractionEnabled = YES;
        [self.viewIncidentAddress becomeFirstResponder];
        
        self.updateIncidentButton.enabled = YES;
        self.updateIncidentButton.alpha = 1.0;
        isUpdatedIncident = NO;
    }
    else
    {
        self.viewIncidentAddress.userInteractionEnabled = NO;
        [self.viewIncidentAddress resignFirstResponder];
    }
    
}

- (IBAction)editViewIncidentDescription:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        self.viewIncidentDescription.userInteractionEnabled = YES;
        [self.viewIncidentDescription becomeFirstResponder];
        
        self.updateIncidentButton.enabled = YES;
        self.updateIncidentButton.alpha = 1.0;
        isUpdatedIncident = NO;
    }
    else
    {
        self.viewIncidentDescription.userInteractionEnabled = NO;
        [self.viewIncidentDescription resignFirstResponder];
    }
}

- (void)loadAssignedUser
{

    isAddNewUser = NO;
    NSString *incidentID = selectedIncidentMarker.userData[@"incidentID"];
    [[WebServiceHandler sharedInstance] getIncidentNearUser:incidentID];
}

- (IBAction)unassignUser:(UIButton *)sender
{
    isUnassignFromViewIncident = YES;

    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonIndexPath = [self.viewIncidentTableView indexPathForCell:clickedCell];
    
    NSLog(@"indexpath: %ld",(long)clickedButtonIndexPath.row);
    
    User *selectedUser = [self.viewIncidentUsersArray objectAtIndex:clickedButtonIndexPath.row];
    NSString *userID = selectedUser.userID;
    NSString *incidentID = selectedIncidentMarker.userData[@"incidentID"];
    
    
    UIAlertController *alert = [[CodeSnip sharedInstance] createAlertWithAction:selectedUser.userName withMessage:@"Are you sure to unassign this user?" withCancelButton:@"Cancel" withTarget:self];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Unassign" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
    {
        selectedIndexPath = clickedButtonIndexPath;
        selectedAssignButton = sender;
        [[WebServiceHandler sharedInstance] unassignIncident:incidentID forUserID:userID];
                          
    }]];
}

- (IBAction)closeViewIncidentView:(id)sender
{
    if (isUpdatedIncident)
    {
        [self resetAllIncidentMarkers];
        [self hideViewIncidentView];
    }
    else
    {
        UIAlertController *alert = [[CodeSnip sharedInstance] createAlertWithAction:selectedIncidentMarker.title withMessage:@"This Incident is not updated. Do you want to close it anyway?" withCancelButton:nil withTarget:self];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            [self resetAllIncidentMarkers];
            [self hideViewIncidentView];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
        {
            [self updateIncident];
        }]];

    }
}

#pragma mark - Incident Detail View TextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //    [textView becomeFirstResponder];
    //create Incident
    if ([textView.text isEqualToString:INCIDENT_TITLE]||
        [textView.text isEqualToString:INCIDENT_ADDRESS]||
        [textView.text isEqualToString:INCIDENT_DESCRIPTION])
    {
        textView.text = @"";
    }
    if ([textView isEqual:self.incidentDetailTitle])
    {
        [self.incidentDetailScrollView setContentOffset:CGPointMake(0, 0)];
        
        self.incidentTitleEditButton.hidden = NO;
        self.incidentTitleEditButton.selected = YES;
        self.incidentDetailTitle.userInteractionEnabled = YES;
    }
    else if ([textView isEqual:self.incidentDetailAddress])
    {
        [self.incidentDetailScrollView setContentOffset:CGPointMake(0, 80)];
        
        self.incidentAddressEditButton.hidden = NO;
        self.incidentAddressEditButton.selected = YES;
        self.incidentDetailAddress.userInteractionEnabled = YES;
        
        clickedSearch = @"newAddress";
        [[MapViewHelper sharedInstance] showGoogleSearchBaronTarget:self];
    }
    else if ([textView isEqual:self.incidentDetailDescription])
    {
        [self.incidentDetailScrollView setContentOffset:CGPointMake(0, 180)];
        
        self.incidentDescriptionEditButton.hidden = NO;
        self.incidentDescriptionEditButton.selected = YES;
        self.incidentDetailDescription.userInteractionEnabled = YES;
    }
    
    //View Incident
    if ([textView isEqual:self.viewIncidentTitle])
    {
        
        [self.viewIncidentScrollView setContentOffset:CGPointMake(0, 0)];
        
        self.editIncidentTitleButton.selected = YES;
        self.viewIncidentTitle.userInteractionEnabled = YES;
    }
    else if ([textView isEqual:self.viewIncidentAddress])
    {
        CGPoint scrollPosition = [self.viewIncidentAddress superview].frame.origin;
        [self.viewIncidentScrollView setContentOffset:scrollPosition];
        
        clickedSearch = @"updateAddress";
        [[MapViewHelper sharedInstance] showGoogleSearchBaronTarget:self];
        
        self.editIncidentAddressButton.selected = YES;
        self.viewIncidentAddress.userInteractionEnabled = YES;
    }
    else if ([textView isEqual:self.viewIncidentDescription])
    {
        CGPoint scrollPosition = [self.viewIncidentDescription superview].frame.origin;
        [self.viewIncidentScrollView setContentOffset:CGPointMake(0, scrollPosition.y)];
        
        self.editIncidentDescriptionButton.selected = YES;
        self.viewIncidentDescription.userInteractionEnabled = YES;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    CGSize newSize = textView.contentSize;
    if ([textView.text isEqualToString:@""])
    {
        if ([textView isEqual:self.incidentDetailTitle])
        {
            textView.text = INCIDENT_TITLE;
        }
        else if ([textView isEqual:self.incidentDetailAddress])
        {
            textView.text = INCIDENT_ADDRESS;
        }
        else if ([textView isEqual:self.incidentDetailDescription])
        {
            textView.text = INCIDENT_DESCRIPTION;
        }
        else if ([textView isEqual:self.viewIncidentTitle])
        {
            self.viewIncidentTitleHeightConstraint.constant = newSize.height;
        }
        else if ([textView isEqual:self.viewIncidentAddress])
        {
            self.viewIncidentAddressHeightConstraint.constant = newSize.height;
        }
        else if ([textView isEqual:self.viewIncidentDescription])
        {
            self.viewIncidentDescriptionHeightConstraint.constant = newSize.height;
        }

    }
//    [self.incidentDetailScrollView setContentOffset:CGPointMake(0, 0)];
//    [self.viewIncidentScrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGSize newSize = textView.contentSize;
    CGRect textFrame = textView.frame;
    float diff = newSize.height - textFrame.size.height;
    if (textFrame.size.height!=newSize.height)
    {
        [textView setFrame:CGRectMake(CGRectGetMinX(textFrame), CGRectGetMinY(textFrame), CGRectGetWidth(textFrame), newSize.height)];
        if ([textView isEqual:self.viewIncidentTitle])
        {
            self.viewIncidentTitleHeightConstraint.constant = newSize.height;
        }
        else if ([textView isEqual:self.viewIncidentAddress])
        {
            self.viewIncidentAddressHeightConstraint.constant = newSize.height;
        }
        else if ([textView isEqual:self.viewIncidentDescription])
        {
//            [self sizeToFitViewIncident];
//            CGPoint scrollPosition = [self.viewIncidentScrollView contentOffset];
//            self.viewIncidentDescriptionHeightConstraint.constant = newSize.height;
//            
//            [self.viewIncidentScrollView setContentOffset:CGPointMake(scrollPosition.x, scrollPosition.y+diff+30)];
        }
    }
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    CGSize newSize = textView.contentSize;
    if ([text isEqualToString:@"\n"])
    {
        if ([textView isEqual:self.incidentDetailTitle])
        {
            self.incidentTitleEditButton.selected = NO;
            [self.incidentTitleEditButton resignFirstResponder];
            self.incidentDetailTitle.userInteractionEnabled = NO;
        }
        else if ([textView isEqual:self.incidentDetailAddress])
        {
            self.incidentAddressEditButton.selected = NO;
            [self.incidentAddressEditButton resignFirstResponder];
            self.incidentDetailAddress.userInteractionEnabled = NO;
        }
        else if ([textView isEqual:self.incidentDetailDescription])
        {
            self.incidentDescriptionEditButton.selected = NO;
            [self.incidentDetailDescription resignFirstResponder];
            self.incidentDetailDescription.userInteractionEnabled = NO;
        }
        else if ([textView isEqual:self.viewIncidentTitle])
        {
            self.editViewIncidentTitleButton.selected = NO;
            [self.viewIncidentTitle resignFirstResponder];
            self.viewIncidentTitle.userInteractionEnabled = NO;
        }
        else if ([textView isEqual:self.viewIncidentAddress])
        {
            [self.viewIncidentAddress resignFirstResponder];
            self.editViewIncidentAddressButton.selected = NO;
            self.viewIncidentAddress.userInteractionEnabled = NO;
        }
        else if ([textView isEqual:self.viewIncidentDescription])
        {
            [self.viewIncidentDescription resignFirstResponder];
            self.editViewIncidentDescriptionButton.selected = NO;
            self.viewIncidentDescription.userInteractionEnabled = NO;
        }
        
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - User Detail View

- (void)loadUserDetailForUser:(User *)user
{
    if ([user.userID isEqualToString:[UserDefaults getUserID]])
    {
        [self animateMarkerToBottom:currentMarker];
        selectedUserMarker = currentMarker;
        [[WebServiceHandler sharedInstance] getUsersIncidentForUserID:user.userID];
    }
    else
    {
        for (GMSMarker *userMarker in allMemberMarkers)
        {
            NSDictionary *userInfo = userMarker.userData;
            NSArray *userIDs = userInfo[@"userID"];
            [userIDs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *userID = obj;
                if ([userID isEqualToString:user.userID])
                {
                    [self animateMarkerToBottom:userMarker];
                    selectedUserMarker = userMarker;
                    selectedUserIndex = (int)idx;
                    [[WebServiceHandler sharedInstance] getUsersIncidentForUserID:userID];
                }
            }];
        }
    }
}

- (void)loadUserDetailViewForMarker:(GMSMarker *)marker
{
    [self animateMarkerToBottom:marker];
    NSArray *allUsers = [[User sharedInstance] getUserDetails];
    for (User *user in allUsers)
    {
        NSString *userId = [[marker.userData valueForKey:@"userID"] firstObject];
        if ([user.userID isEqualToString:userId])
        {
            self.userDetailUserName.text = [NSString stringWithFormat:@"Username: %@", user.userName];
            self.userDetailIncidentsArray = [[NSMutableArray alloc] initWithArray:user.incidentsAssigned];
            [self.userDetailTableView setDataSource:self];
            [self.userDetailTableView setDelegate:self];
            [self.userDetailTableView reloadData];
        }
    }
}

- (void)loadUserDetailViewForIncidents:(NSArray *)incidents
{
    if ([selectedUserMarker.snippet isEqualToString:@"GroupMemberSelected"]||
        [selectedUserMarker.snippet isEqualToString:@"GroupMember"])
    {
        NSDictionary *userData = selectedUserMarker.userData;
        NSArray *userNames = userData[@"userName"];
         self.userDetailUserName.text = [NSString stringWithFormat:@"Username: %@", [userNames objectAtIndex:selectedUserIndex]];
    }
    else
    {
        self.userDetailUserName.text = [NSString stringWithFormat:@"Username: %@", selectedUserMarker.title];
    }
    [self animateMarkerToBottom:selectedUserMarker];
    self.userDetailIncidentsArray = [[NSMutableArray alloc] initWithArray:incidents];
    [self.userDetailTableView setDataSource:self];
    [self.userDetailTableView setDelegate:self];
    [self.userDetailTableView reloadData];
}


- (void)loadUserDetailViewAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *allUsers = [[User sharedInstance] getUserDetails];
    NSString *userId = [[allDetailMorePeople valueForKey:@"userID"] objectAtIndex:indexPath.row];
    
    for (User *user in allUsers)
    {
        if ([user.userID isEqualToString:userId])
        {
            
            self.userDetailUserName.text = [NSString stringWithFormat:@"Username: %@", user.userName];
            self.navigationItem.title = [NSString stringWithFormat:@"%@'s Incidents", user.userName];
            self.navigationItem.rightBarButtonItem = nil;
            [[SideBar sharedInstance] setUpCustomViewWithTarget:self];
            
            self.userDetailIncidentsArray = [[NSMutableArray alloc] initWithArray:user.incidentsAssigned];
            [self.userDetailTableView setDataSource:self];
            [self.userDetailTableView setDelegate:self];
            [self.userDetailTableView reloadData];
        }
    }
}

- (IBAction)closeUserDetailView:(id)sender
{
    [self resetAllMemberMarkers];
    [self hideUserDetailView];
}


- (IBAction)viewButtonClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.userDetailTableView];
    NSIndexPath *clickedButtonIndexPath = [self.userDetailTableView indexPathForRowAtPoint:buttonPosition];
    
    NSLog(@"indexpath: %ld",(long)clickedButtonIndexPath.row);
    [self sizeToFitViewIncident];

    Incident *selectedIncident = [self.userDetailIncidentsArray objectAtIndex:clickedButtonIndexPath.row];
    [self loadIncidentDetailForIncident:selectedIncident];
}

- (IBAction)unassignButtonClicked:(id)sender
{
    isUnassignFromViewIncident = NO;

    UITableViewCell *clickedCell = (UITableViewCell *)[[[sender superview] superview] superview];
    NSIndexPath *clickedButtonIndexPath = [self.userDetailTableView indexPathForCell:clickedCell];
    
    NSLog(@"indexpath: %ld",(long)clickedButtonIndexPath.row);
    
    Incident *selectedIncident = [self.userDetailIncidentsArray objectAtIndex:clickedButtonIndexPath.row];
    NSString *incidentID = selectedIncident.incidentID;
    NSString *userID = [[selectedUserMarker.userData objectForKey:@"userID"] firstObject];
    
    
    UIAlertController *alert = [[CodeSnip sharedInstance] createAlertWithAction:selectedIncident.incidentName withMessage:@"Are you sure to unassign this incident?" withCancelButton:@"Cancel" withTarget:self];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Unassign" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
    {
        selectedAssignButton = sender;
        [[WebServiceHandler sharedInstance] unassignIncident:incidentID forUserID:userID];
       
    }]];
    
}


#pragma mark - Tableview delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //More People Tableview
    if ([tableView isEqual:self.morePeopleTableView])
    {
        return self.morePeoplesArray.count;
    }
    
    //User Detail Tableview
    else if ([tableView isEqual:self.userDetailTableView])
    {
        return self.userDetailIncidentsArray.count;
    }
    
    //Add New User Tableview
    else if ([tableView isEqual:self.addNewUserTableView])
    {
        return self.addNewUserArray.count;
    }
    
    //View Incident Tableview
    else if ([tableView isEqual:self.viewIncidentTableView])
    {
        return self.viewIncidentUsersArray.count;
    }
    
    //Notification More Tableview
    else if ([tableView isEqual:self.notificationMoreTableView])
    {
        return userNamesFromNotification.count;
    }

    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *MyIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    
    //More People Tableview
    if ([tableView isEqual:self.morePeopleTableView])
    {
        UILabel *morePeopleName = (UILabel *)[cell viewWithTag:1];
        morePeopleName.text = [self.morePeoplesArray objectAtIndex:indexPath.row];
    }
    
    //User Detail Tableview
    else if ([tableView isEqual:self.userDetailTableView])
    {
        UILabel *incidentName = (UILabel *)[cell viewWithTag:1];
        UIButton *viewButton = (UIButton *)[cell viewWithTag:1];
        UIButton *unassignButton = (UIButton *)[cell viewWithTag:1];
        
        Incident *currentIncident = [self.userDetailIncidentsArray objectAtIndex:indexPath.row];
        
        viewButton.layer.borderColor = [UIColor redColor].CGColor;
        unassignButton.layer.borderColor = [UIColor redColor].CGColor;
        incidentName.text = currentIncident.incidentName;
    }
    
    //Add New User TableView
    else if ([tableView isEqual:self.addNewUserTableView])
    {
        
        User *user = [self.addNewUserArray objectAtIndex:indexPath.row];
        
        UILabel *userNameLabel = (UILabel *)[cell viewWithTag:1];
        UIButton *assignButton = (UIButton *)[cell viewWithTag:2];
        userNameLabel.text = user.userName;
        NSLog(@"%f:%f", user.coordinate.latitude, user.coordinate.longitude);
        if (user.isAssigned)
        {
            assignButton.selected = YES;
            [assignButton setBackgroundColor:[UIColor colorWithRed:21.0f/255.0f green:88.0f/255.0f blue:200.0f/255.0f alpha:1.0f]];
        }
        else
        {
            assignButton.selected = NO;
            [assignButton setBackgroundColor:[UIColor whiteColor]];
        }
    }
    
    //View Incident assign Tableview
    else if ([tableView isEqual:self.viewIncidentTableView])
    {
        User *user = [self.viewIncidentUsersArray objectAtIndex:indexPath.row];
        UILabel *morePeopleName = (UILabel *)[cell viewWithTag:1];
        morePeopleName.text = user.userName;
    }
    
    //Notification More assign Tableview
    else if ([tableView isEqual:self.notificationMoreTableView])
    {
        NSString *userName = [userNamesFromNotification objectAtIndex:indexPath.row];
        UILabel *morePeopleName = (UILabel *)[cell viewWithTag:1];
        UIButton *assignButton = (UIButton *)[cell viewWithTag:2];
        
        morePeopleName.text = userName;
        
        NSString *isAssigned = [isAssignedArray objectAtIndex:indexPath.row];
        if ([isAssigned isEqualToString:@"Assign"])
        {
            assignButton.selected = NO;
            [assignButton setBackgroundColor:[UIColor whiteColor]];
       }
        else if ([isAssigned isEqualToString:@"Unassign"])
        {
            assignButton.selected = YES;
            [assignButton setBackgroundColor:[UIColor colorWithRed:21.0f/255.0f green:88.0f/255.0f blue:200.0f/255.0f alpha:1.0f]];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //More People Tableview
    if ([tableView isEqual:self.morePeopleTableView])
    {
        [self hideMorePeopleView];
        
        NSArray *totalPeopleID = [allDetailMorePeople valueForKey:@"userID"];
        
        selectedIndexPath = indexPath;
        selectedUserIndex = (int)indexPath.row;
        
        [[WebServiceHandler sharedInstance] getUsersIncidentForUserID:[totalPeopleID objectAtIndex:indexPath.row]];

    }
    
    //Add New User TableView
    else if ([tableView isEqual:self.addNewUserTableView])
    {
        
    }

    
    
}
#pragma mark - POP Animation Methods

- (void)hideOtherViews:(UIView *)openedView
{
    if (![openedView isEqual:self.incidentDetailView]) {
        [self hideIncidentDetailView];
    }
    if (![openedView isEqual:self.viewIncidentView]) {
        [self hideViewIncidentView];
    }
    if (![openedView isEqual:self.userDetailView]) {
        [self hideUserDetailView];
    }
    if (![openedView isEqual:self.morePeopleView]) {
        [self hideMorePeopleView];
    }
    if (![openedView isEqual:self.notificationMoreView]) {
        [self hideNotificationMoreView];
    }
    if (![openedView isEqual:self.notificationView]) {
        [self hideNotificationView];
    }
    if (![openedView isEqual:self.addNewUserView]) {
        [self hideAddNewUserView];
    }
}

- (void)popAnimationForButton:(UIButton *)button
{
    POPSpringAnimation *scale = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scale.springSpeed = 60.0f;
    scale.springBounciness = 18.0f;
    scale.fromValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
    scale.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
    scale.name = @"size";
    [button.layer pop_addAnimation:scale forKey:@"pop"];
}

- (void)showNotificationMoreView
{
    [self hideOtherViews:self.notificationMoreView];
    
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 5.0f;
    layoutAnimation.toValue = @(0);
    [self.notificationMoreBottomConstraint pop_addAnimation:layoutAnimation forKey:@"notification"];
}

- (void)hideNotificationMoreView
{
    [self resetNavigationBar];
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 0.0f;
    layoutAnimation.toValue = @(-self.notificationMoreView.bounds.size.height-10);
    [self.notificationMoreBottomConstraint pop_addAnimation:layoutAnimation forKey:@"notification"];
}

- (void)showNotificationView
{
    [self hideOtherViews:self.notificationView];
    
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 5.0f;
    layoutAnimation.toValue = @(0);
    [self.notificationBottomConstraint pop_addAnimation:layoutAnimation forKey:@"notification"];
}

- (void)hideNotificationView
{
    [self resetNavigationBar];
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 0.0f;
    layoutAnimation.toValue = @(-self.notificationView.bounds.size.height);
    [self.notificationBottomConstraint pop_addAnimation:layoutAnimation forKey:@"notification"];
}

- (void)showMorePeopleView
{
    [self hideOtherViews:self.morePeopleView];
    
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 0.0f;
    layoutAnimation.toValue = @(0);
    [self.morePeopleViewLeftConstraint pop_addAnimation:layoutAnimation forKey:@"morepeople"];
}

- (void)hideMorePeopleView
{
    [self resetNavigationBar];
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 0.0f;
    layoutAnimation.toValue = @(-self.morePeopleView.frame.size.width);
    [self.morePeopleViewLeftConstraint pop_addAnimation:layoutAnimation forKey:@"notification"];
    
}

- (void)showUserDetailView:(NSString *)userName
{
    [self hideOtherViews:self.userDetailView];

    [self userIncidentNavigationBar:userName];
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 5.0f;
    layoutAnimation.toValue = @(0);
    [self.userDetailTopConstraint pop_addAnimation:layoutAnimation forKey:@"morepeople"];
}

- (void)hideUserDetailView
{
    [self resetNavigationBar];
    
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 0.0f;
    layoutAnimation.toValue = @(-self.userDetailView.frame.size.height);
    [self.userDetailTopConstraint pop_addAnimation:layoutAnimation forKey:@"notification"];
    
}

- (void)showIncidentDetailView
{
    [self.incidentDetailAddress resignFirstResponder];
    [self.incidentDetailDescription resignFirstResponder];
    [self.incidentDetailTitle resignFirstResponder];
    self.incidentDetailTitle.userInteractionEnabled = YES;
    self.incidentDetailAddress.userInteractionEnabled = YES;
    self.incidentDetailDescription.userInteractionEnabled = YES;
    
    [self hideOtherViews:self.incidentDetailView];
    
    [self createIncidentNavigationBar];
    
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 5.0f;
    layoutAnimation.toValue = @(0);
    [self.incidentDetailTopConstraint pop_addAnimation:layoutAnimation forKey:@"morepeople"];
}

- (void)hideIncidentDetailView
{
    [self resetNavigationBar];
    
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 0.0f;
    layoutAnimation.toValue = @(-self.incidentDetailView.frame.size.height);
    [self.incidentDetailTopConstraint pop_addAnimation:layoutAnimation forKey:@"notification"];
}

- (void)showViewIncidentView
{
    [self hideOtherViews:self.viewIncidentView];
    
    self.viewIncidentTitle.userInteractionEnabled = NO;
    self.viewIncidentAddress.userInteractionEnabled = NO;
    self.viewIncidentDescription.userInteractionEnabled = NO;
    [self viewIncidentNavigationBar:@"Incident Details"];
    
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 5.0f;
    layoutAnimation.toValue = @(0);
    [self.viewIncidentTopConstraint pop_addAnimation:layoutAnimation forKey:@"morepeople"];
}

- (void)hideViewIncidentView
{
    [self resetNavigationBar];
    
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 0.0f;
    layoutAnimation.toValue = @(-self.viewIncidentView.frame.size.height);
    [self.viewIncidentTopConstraint pop_addAnimation:layoutAnimation forKey:@"notification"];
}

- (void)showAddNewUserView
{
    [self hideOtherViews:self.addNewUserView];
    
    [self viewIncidentNavigationBar:@"Assign User"];
    
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 5.0f;
    layoutAnimation.toValue = @(0);
    [self.addNewUserTopConstraint pop_addAnimation:layoutAnimation forKey:@"morepeople"];
}

- (void)hideAddNewUserView
{
    [self resetNavigationBar];
    
    POPSpringAnimation *layoutAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    layoutAnimation.springSpeed = 10.0f;
    layoutAnimation.springBounciness = 0.0f;
    layoutAnimation.toValue = @(-self.addNewUserView.frame.size.height);
    [self.addNewUserTopConstraint pop_addAnimation:layoutAnimation forKey:@"notification"];
}


@end
