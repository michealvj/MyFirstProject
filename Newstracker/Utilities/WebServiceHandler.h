//
//  ParseJSON.h
//  Newstracker
//
//  Created by Micheal on 02/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "Incident.h"
#import "ModalObjects.h"

@protocol WebServiceHandlerDelegate <NSObject>

@optional
- (void)didUpdateCurrentLocation:(NSDictionary *)data;
- (void)didReceiveUserData:(NSDictionary *)data;
- (void)requestLoadedWithGeocodeData:(id)data;
- (void)requestLoadedWithTimeDistanceData:(id)data;
- (void)didReceiveIncidentDetails:(id)data;
- (void)didReceiveMemberDetails:(id)data;
- (void)didReceiveUsersDetails:(id)data;
- (void)didLogOffUser:(NSString *)message;
- (void)didReceiveAllUsers:(NSDictionary *)data;
- (void)didCreateNewIncident:(Incident *)incident;
- (void)didDeleteIncident;
- (void)didUpdateIncident;
- (void)didAssignIncident;
- (void)didUnassignIncident;
- (void)didGetIncidentNearUser:(id)data;
- (void)didReceiveUserIncidents:(id)data;
- (void)isUserAssignedToIncident:(NSArray *)isAssignedArray;

@required
- (void)requestFailedWithError:(NSError*)error;
- (void)showErrorAlertWithTitle:(NSString*)title WithMessage:(NSString*)message;
@end

@interface WebServiceHandler : NSObject <NSXMLParserDelegate>

@property (nonatomic,retain) AFHTTPRequestOperationManager *manager;
@property (nonatomic,retain) NSString *currentElementName;
@property (nonatomic,retain) NSString *progressStatus;
@property (nonatomic,retain) id<WebServiceHandlerDelegate> delegate;

+(WebServiceHandler *)sharedInstance;
- (void)updateCurrentLocation:(CLLocationCoordinate2D)currentCoordinate WithGPSStatus:(NSString *)gpsStatus;

- (void)getGeocodeForURL:(NSString *)URL;
- (void)getTimeDistanceForURL:(NSString *)URL;

- (void)getCurrentUserDetailsForEmailID:(NSString *)emailID AndPassword:(NSString *)password;
- (void)getPasswordForEmailID:(NSString *)emailID;
- (void)logOffUser;

- (void)getAllUsers;
- (void)getMemberAndIncidentDetails;
- (void)refreshMap;

- (void)createIncidentWithParams:(NSDictionary *)createInfo;
- (void)updateIncidentWithParams:(NSDictionary *)createInfo;
- (void)deleteIncidentWithID:(NSString *)incidentID;
- (void)getAllIncidents;
- (void)getIncidentNearUser:(NSString *)incidentID;
- (void)getUsersIncidentForUserID:(NSString *)userID;

- (void)assignIncident:(NSString *)incidentID forUserID:(NSString *)userID;
- (void)unassignIncident:(NSString *)incidentID forUserID:(NSString *)userID;
- (void)checkIfAssigedForUserID:(NSString *)userID AndIncidentID:(NSString *)incidentID;

- (void)saveSettings:(Settings *)settings;
- (void)getSettingsWithSuccess:(void (^)(Settings *settings))success WithError:(void (^)(NSString *error))failure;

- (void)sendGroupMessage:(NSString *)message;
@end
