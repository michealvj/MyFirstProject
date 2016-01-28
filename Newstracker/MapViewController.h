//
//  ViewController.h
//  Newstracker
//
//  Created by Micheal on 02/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "utils.h"
#import "MyProtocolMethod.h"
#import "IncidentListViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController : UIViewController <UISearchBarDelegate,WebServiceHandlerDelegate, MyProtocolDelegate, SearchAddressDelegate, GMSMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

//Map View
@property (weak, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *mapParentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewRightConstraint;

//Notification View (More People)
@property (weak, nonatomic) IBOutlet UIView *notificationMoreView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationMoreBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *notificationMoreTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *notificationMoreTableView;


//Notification View
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UILabel *notificationTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationMinutesLabel;
@property (weak, nonatomic) IBOutlet UIButton *notificationAssignButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationBottomConstraint;

//More People View
@property (weak, nonatomic) IBOutlet UIView *morePeopleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *morePeopleViewLeftConstraint;
@property (weak, nonatomic) IBOutlet UILabel *totalPeopleCount;
@property (weak, nonatomic) IBOutlet UITableView *morePeopleTableView;
@property (retain, nonatomic) NSArray *morePeoplesArray;

//User Detail View
@property (weak, nonatomic) IBOutlet UILabel *userDetailUserName;
@property (weak, nonatomic) IBOutlet UITableView *userDetailTableView;
@property (weak, nonatomic) IBOutlet UIView *userDetailView;
@property (retain, nonatomic) NSMutableArray *userDetailIncidentsArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userDetailTopConstraint;

//New Incident View
@property (weak, nonatomic) IBOutlet UITextView *incidentDetailTitle;
@property (weak, nonatomic) IBOutlet UITextView *incidentDetailAddress;
@property (weak, nonatomic) IBOutlet UITextView *incidentDetailDescription;
@property (weak, nonatomic) IBOutlet UIView *incidentDetailView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *incidentDetailTopConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *incidentDetailScrollView;
@property (weak, nonatomic) IBOutlet UIButton *saveIncidentButton;
@property (weak, nonatomic) IBOutlet UIButton *assignNewUserButton;
@property (weak, nonatomic) IBOutlet UIButton *incidentTitleEditButton;
@property (weak, nonatomic) IBOutlet UIButton *incidentAddressEditButton;
@property (weak, nonatomic) IBOutlet UIButton *incidentDescriptionEditButton;
@property (weak, nonatomic) IBOutlet UIImageView *editTitleImage;
@property (weak, nonatomic) IBOutlet UIImageView *editAddressImage;
@property (weak, nonatomic) IBOutlet UIImageView *editDescriptionImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *incidentTitleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *incidentAddressHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *incidentDescriptionHeight;


//View Incident View
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewIncidentTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewIncidentTitleHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewIncidentAddressHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewIncidentDescriptionHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewIncidentTableHeight;
@property (retain, nonatomic) NSMutableArray *viewIncidentUsersArray;
@property (weak, nonatomic) IBOutlet UIButton *editViewIncidentTitleButton;
@property (weak, nonatomic) IBOutlet UIButton *editViewIncidentAddressButton;
@property (weak, nonatomic) IBOutlet UIButton *editViewIncidentDescriptionButton;

@property (weak, nonatomic) IBOutlet UITextView *viewIncidentTitle;
@property (weak, nonatomic) IBOutlet UITextView *viewIncidentAddress;
@property (weak, nonatomic) IBOutlet UITextView *viewIncidentDescription;
@property (weak, nonatomic) IBOutlet UIView *viewIncidentView;
@property (weak, nonatomic) IBOutlet UIScrollView *viewIncidentScrollView;
@property (weak, nonatomic) IBOutlet UIButton *updateIncidentButton;
@property (weak, nonatomic) IBOutlet UITableView *viewIncidentTableView;

//Add New User View
@property (weak, nonatomic) IBOutlet UIView *addNewUserView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addNewUserTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *addNewUserIncidentTitle;
@property (weak, nonatomic) IBOutlet UITableView *addNewUserTableView;
@property (retain, nonatomic) NSArray *addNewUserArray;


//Delegate Incident
@property (retain, nonatomic) Incident *selectedIncident;
@property (retain, nonatomic) User *selectedUser;
@property (nonatomic) NSTimer* mapRefreshingTimer;

@end

