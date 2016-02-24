
#import "navBar.h"
#import "CoreData.h"
#import "FoodItems.h"
#import "CodeSnip.h"
#import "CurrentLocation.h"
#import "LocationTracker.h"
#import "MapViewHelper.h"
#import "SVProgressHUD.h"
#import "WebServiceHandler.h"
#import "MemberIcon.h"
#import "SideBar.h"
#import "UserDefaults.h"

#define APPNAME @"Newscrew Tracker"
#define GOOGLE_API_KEY @"AIzaSyDBUwzdKrxn2uxSbmK2_HX8GSXnRft0Grw"
#define GOOGLE_SERVER_KEY @"AIzaSyAxdQ6s1n6-HaawEoYj3MxtJxyrBRQskec"
#define GOOGLE_SERVER_KEY1 @"AIzaSyDGYWfO87yXwAmykrIDOy6Tko_WlHp9CP4"


#pragma mark - Icon Image Settings
#define CURRENTUSER [[CodeSnip sharedInstance] getUserIconForTitle:marker.title]
#define CURRENTUSER_SELECTED [[CodeSnip sharedInstance] getUserSelectedIconForTitle:marker.title]

#define INCIDENT  [[CodeSnip sharedInstance] image:[UIImage imageNamed:@"redot.png"] scaledToSize:CGSizeMake(30.0f, 30.0f)];
#define INCIDENT_SELECTED [[CodeSnip sharedInstance] image:[UIImage imageNamed:@"redot.png"] scaledToSize:CGSizeMake(30.0f, 30.0f)];

#define MEMBER [[CodeSnip sharedInstance] getMemberIconForTitle:userName]
#define MEMBER_SELECTED [[CodeSnip sharedInstance] getMemberSelectedIconForTitle:userName]

#define UNREACH_MEMBER [[CodeSnip sharedInstance] getUnreachMemberIconForTitle:userName]
#define UNREACH_MEMBER_SELECTED [[CodeSnip sharedInstance] getUnreachMemberSelectedIconForTitle:userName]


#define GROUP_MEMBER [[CodeSnip sharedInstance] getGroupMemberIconForTitle:userName WithCount:(int)userIDs.count]
#define GROUP_MEMBER_SELECTED [[CodeSnip sharedInstance] getGroupMemberSelectedIconForTitle:userName WithCount:(int)names.count]

#pragma mark - Map Settings
#define MAPZOOM 15


