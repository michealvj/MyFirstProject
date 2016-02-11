//
//  ParseJSON.m
//  Newstracker
//
//  Created by Micheal on 02/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "WebServiceHandler.h"
#import "utils.h"
#import "CodeSnip.h"

@implementation WebServiceHandler
{
    BOOL isRefreshingMap;
    void (^gsuccess)(Settings *settings);
    void (^gfailure)(NSString *error);
}
@synthesize delegate, currentElementName, progressStatus;

+ (WebServiceHandler *)sharedInstance
{
    static WebServiceHandler *webServiceHandler = nil;
    static dispatch_once_t dispatchOnce;
    
    dispatch_once(&dispatchOnce, ^{
        webServiceHandler = [[WebServiceHandler alloc]init];
    });
    return webServiceHandler;
}

#pragma mark - Get Methods Webservice

- (void)getGeocodeForURL:(NSString *)URL
{
    [SVProgressHUD showWithStatus:@"Getting Location"];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self parseGeocodeData:responseObject];
         [SVProgressHUD dismiss];
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if ([self.delegate respondsToSelector:@selector(requestFailedWithError:)]) {
             [self.delegate requestFailedWithError:error];
         }
         [SVProgressHUD dismiss];
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
     }];
    
}

- (void)getTimeDistanceForURL:(NSString *)URL
{
    [SVProgressHUD showWithStatus:@"Getting Travel Time"];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self parseTimeDistanceData:responseObject];
         [SVProgressHUD dismiss];
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if ([self.delegate respondsToSelector:@selector(requestFailedWithError:)]) {
             [self.delegate requestFailedWithError:error];
         }
         [SVProgressHUD dismiss];
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
     }];
    
}

- (void)bgTimeDistanceForURL:(NSString *)URL
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *routeArray = responseObject[@"routes"];
         if (routeArray.count>0)
         {
             NSString *distance = responseObject[@"routes"][0][@"legs"][0][@"distance"][@"text"];
             NSString *duration = responseObject[@"routes"][0][@"legs"][0][@"duration"][@"text"];
             
             NSLog(@"Distance: %@", distance);
             NSLog(@"Time: %@", duration);
         }
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error: %@", [error localizedDescription]);
     }];
    
}


#pragma mark - My Webservices

- (void)postBackgroundSoapMessage:(NSString *)soapMessage WithContentType:(NSString *)contentType
{
    NSURL *url = [NSURL URLWithString:@"http://46.137.247.207/newscrewtrackerservice/NewsCrewTracker.asmx"];
    
    NSData *soapData = [soapMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    [theRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:soapData];
    
     AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:theRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:responseObject];
         xmlParser.delegate = self;
         BOOL isParsed = [xmlParser parse];
         if (isParsed)
         {
             
         }
      }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error in Background update: %@", [error localizedDescription]);
     }];
    [operation setQueuePriority:NSOperationQueuePriorityLow];
    [operation setQualityOfService:NSOperationQualityOfServiceBackground];
    [[NSOperationQueue new] addOperation:operation];
    
}


- (void)postSoapMessage:(NSString *)soapMessage WithContentType:(NSString *)contentType
{
    NSURL *url = [NSURL URLWithString:@"http://46.137.247.207/newscrewtrackerservice/NewsCrewTracker.asmx"];
    
    NSData *soapData = [soapMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    [theRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:soapData];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:theRequest];
    [SVProgressHUD showWithStatus:self.progressStatus];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:responseObject];
         xmlParser.delegate = self;
         BOOL isParsed = [xmlParser parse];
         if (isParsed)
         {
         }
         [SVProgressHUD dismiss];
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if ([self.delegate respondsToSelector:@selector(requestFailedWithError:)]) {
             [self.delegate requestFailedWithError:error];
         }
         if (gfailure!=nil) {
             gfailure([error localizedDescription]);
         }
         [SVProgressHUD dismiss];
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
     }];
    [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [operation setQualityOfService:NSOperationQualityOfServiceUserInteractive];
    [[NSOperationQueue mainQueue] addOperation:operation];
    
}

- (void)getSettingsWithSuccess:(void (^)(Settings *settings))success WithError:(void (^)(NSString * failure))failure
{
    NSString *userID = [UserDefaults getUserID];
    self.progressStatus = @"Loading Settings";
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<GetSettings xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"</GetSettings>"]];
    [soapMessage appendString:soapEndTag];
    
    gsuccess = success;
    gfailure = failure;
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];

}

- (void)saveSettings:(Settings *)settings
{
    NSString *userID = [UserDefaults getUserID];
    
    
    self.progressStatus = @"Saving";
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<AddSettings xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Latitude>%f</Latitude>\n", settings.mapCoordinate.latitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Longitude>%f</Longitude>\n", settings.mapCoordinate.longitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Location>%@</Location>\n", settings.mapLocation]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserView>%i</UserView>\n", settings.isVisibleToOtherUsers]];
    [soapMessage appendString:[NSString stringWithFormat:@"<IncidentDeleteStatus>%i</IncidentDeleteStatus>\n", settings.isAutomaticDeletionEnabled]];
    [soapMessage appendString:[NSString stringWithFormat:@"<DeletionTime>%@</DeletionTime>\n", settings.incidentDeletionTime]];
    [soapMessage appendString:[NSString stringWithFormat:@"<LogoutTime>%@</LogoutTime>\n", settings.logoutTime]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"</AddSettings>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)sendGroupMessage:(NSString *)message
{
    NSString *userID = [UserDefaults getUserID];
    
    
    self.progressStatus = @"Sending Message...";
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<SendGroupMessage xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Msg>%@</Msg>\n", message]];
    [soapMessage appendString:[NSString stringWithFormat:@"</SendGroupMessage>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)getCurrentUserDetailsForEmailID:(NSString *)emailID AndPassword:(NSString *)password
{
    self.progressStatus = @"Verifying";
    CLLocationCoordinate2D currentCoordinate = [[LocationTracker sharedInstance] getCurrentLocation].location.coordinate;
    
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *osType = [[UIDevice currentDevice] systemName];
    NSString *deviceName = [[UIDevice currentDevice] model];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *latitude = [NSString stringWithFormat:@"%f", currentCoordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", currentCoordinate.longitude];
    NSString *deviceToken = [UserDefaults getDeviceToken];
    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserLogin xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Email>%@</Email>\n", emailID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Password>%@</Password>\n", password]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Latitude>%@</Latitude>\n", latitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Longitude>%@</Longitude>\n", longitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<OSType>%@</OSType>\n", osType]];
    [soapMessage appendString:[NSString stringWithFormat:@"<OSVersion>%@</OSVersion>\n", osVersion]];
    [soapMessage appendString:[NSString stringWithFormat:@"<DeviceName>%@</DeviceName>\n", deviceName]];
    [soapMessage appendString:[NSString stringWithFormat:@"<AppVersionNo>%@</AppVersionNo>\n", version]];
    [soapMessage appendString:[NSString stringWithFormat:@"<GCMDeviceToken>%@</GCMDeviceToken>\n", deviceToken]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UUID>%@</UUID>\n", uniqueIdentifier]];
    [soapMessage appendString:[NSString stringWithFormat:@"</UserLogin>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)getPasswordForEmailID:(NSString *)emailID
{
    self.progressStatus = @"Sending";
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<ForGotPassword xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<email>%@</email>\n", emailID]];
    [soapMessage appendString:[NSString stringWithFormat:@"</ForGotPassword>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)logOffUser
{
    self.progressStatus = @"Logging Off";
    NSString *groupID = [UserDefaults getGroupID];
    NSString *userID = [UserDefaults getUserID];
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<LogOffUsers xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<GroupId>%@</GroupId>\n", groupID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"</LogOffUsers>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)refreshMap
{
    isRefreshingMap = YES;
    CLLocationCoordinate2D currentCoordinate = [[[LocationTracker alloc] init]getCurrentLocation].location.coordinate;
    
    NSString *userID = [UserDefaults getUserID];
    NSString *latitude = [NSString stringWithFormat:@"%f", currentCoordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", currentCoordinate.longitude];
    
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<GetMap xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Latitude>%@</Latitude>\n", latitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Longitude>%@</Longitude>\n", longitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"</GetMap>"]];
    [soapMessage appendString:soapEndTag];
    
    NSURL *url = [NSURL URLWithString:@"http://46.137.247.207/newscrewtrackerservice/NewsCrewTracker.asmx"];
    
    NSData *soapData = [soapMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    [theRequest addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:soapData];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:theRequest];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:responseObject];
         xmlParser.delegate = self;
         BOOL isParsed = [xmlParser parse];
         if (isParsed)
         {
         }
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if ([self.delegate respondsToSelector:@selector(requestFailedWithError:)]) {
             [self.delegate requestFailedWithError:error];
         }
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }];
    [operation setQueuePriority:NSOperationQueuePriorityLow];
    [operation setQualityOfService:NSOperationQualityOfServiceBackground];
    [[NSOperationQueue new] addOperation:operation];
}

- (void)getMemberAndIncidentDetails
{
    isRefreshingMap = NO;
    self.progressStatus = @"Loading map";
    
    CLLocationCoordinate2D currentCoordinate = [[[LocationTracker alloc] init]getCurrentLocation].location.coordinate;
    
    NSString *userID = [UserDefaults getUserID];
    NSString *latitude = [NSString stringWithFormat:@"%f", currentCoordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", currentCoordinate.longitude];
    
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<GetMap xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Latitude>%@</Latitude>\n", latitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Longitude>%@</Longitude>\n", longitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"</GetMap>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)createIncidentWithParams:(NSDictionary *)createInfo
{
    self.progressStatus = @"Creating Incident";
    NSString *userID = [UserDefaults getUserID];
    NSString *incidentName = createInfo[@"IncidentName"];
    NSString *description = createInfo[@"Description"];
    NSString *latitude = createInfo[@"Latitude"];
    NSString *longitude = createInfo[@"Longitude"];
    NSString *addressLine1 = createInfo[@"AddressLine1"];
    NSString *addressLine2 = createInfo[@"AddressLine2"];
    NSString *city = createInfo[@"City"];
    NSString *state = createInfo[@"State"];
    NSString *country = createInfo[@"Country"];
    NSString *zipCode = createInfo[@"ZipCode"];
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<NewIncident xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<IncidentName>%@</IncidentName>\n", incidentName]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Description>%@</Description>\n", description]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Latitude>%@</Latitude>\n", latitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Longitude>%@</Longitude>\n", longitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<AddressLine1>%@</AddressLine1>\n", addressLine1]];
    [soapMessage appendString:[NSString stringWithFormat:@"<AddressLine2>%@</AddressLine2>\n", addressLine2]];
    [soapMessage appendString:[NSString stringWithFormat:@"<City>%@</City>\n", city]];
    [soapMessage appendString:[NSString stringWithFormat:@"<State>%@</State>\n", state]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Country>%@</Country>\n", country]];
    [soapMessage appendString:[NSString stringWithFormat:@"<ZipCode>%@</ZipCode>\n", zipCode]];
    [soapMessage appendString:[NSString stringWithFormat:@"</NewIncident>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)updateIncidentWithParams:(NSDictionary *)createInfo
{
    self.progressStatus = @"Updating Incident";
    NSString *groupID = [UserDefaults getGroupID];
    NSString *userID = [UserDefaults getUserID];
    NSString *incidentID = createInfo[@"IncidentId"];
    NSString *incidentName = createInfo[@"IncidentName"];
    NSString *description = createInfo[@"Description"];
    NSString *latitude = createInfo[@"Latitude"];
    NSString *longitude = createInfo[@"Longitude"];
    NSString *addressLine1 = createInfo[@"AddressLine1"];
    NSString *addressLine2 = createInfo[@"AddressLine2"];
    NSString *city = createInfo[@"City"];
    NSString *state = createInfo[@"State"];
    NSString *country = createInfo[@"Country"];
    NSString *zipCode = createInfo[@"ZipCode"];
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<UpdateIncident xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<GroupId>%@</GroupId>\n", groupID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<IncidentId>%@</IncidentId>\n", incidentID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<IncidentName>%@</IncidentName>\n", incidentName]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Description>%@</Description>\n", description]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Latitude>%@</Latitude>\n", latitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Longitude>%@</Longitude>\n", longitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<AddressLine1>%@</AddressLine1>\n", addressLine1]];
    [soapMessage appendString:[NSString stringWithFormat:@"<AddressLine2>%@</AddressLine2>\n", addressLine2]];
    [soapMessage appendString:[NSString stringWithFormat:@"<City>%@</City>\n", city]];
    [soapMessage appendString:[NSString stringWithFormat:@"<State>%@</State>\n", state]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Country>%@</Country>\n", country]];
    [soapMessage appendString:[NSString stringWithFormat:@"<ZipCode>%@</ZipCode>\n", zipCode]];
    [soapMessage appendString:[NSString stringWithFormat:@"</UpdateIncident>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)deleteIncidentWithID:(NSString *)incidentID
{
    self.progressStatus = @"Deleting Incident";
    NSString *userID = [UserDefaults getUserID];
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<DeleteIncident xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<IncidentId>%@</IncidentId>\n", incidentID]];
       [soapMessage appendString:[NSString stringWithFormat:@"</DeleteIncident>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)getAllIncidents
{
    self.progressStatus = @"Loading Incidents";
    CLLocationCoordinate2D currentCoordinate = [[[LocationTracker alloc] init]getCurrentLocation].location.coordinate;
    NSString *userID = [UserDefaults getUserID];
    NSString *latitude = [NSString stringWithFormat:@"%f", currentCoordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", currentCoordinate.longitude];

    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<GetIncidents xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Latitude>%@</Latitude>\n", latitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Longitude>%@</Longitude>\n", longitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"</GetIncidents>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)getAllMessages
{
    self.progressStatus = @"Loading Messages";
    NSString *userID = [UserDefaults getUserID];
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<GetGroupMessages xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"</GetGroupMessages>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}


- (void)getIncidentNearUser:(NSString *)incidentID
{
    self.progressStatus = @"Loading Users";
    NSString *userID = [UserDefaults getUserID];
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<GetIncidentNearUser xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<IncidentId>%@</IncidentId>\n", incidentID]];
    [soapMessage appendString:[NSString stringWithFormat:@"</GetIncidentNearUser>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)assignIncident:(NSString *)incidentID forUserID:(NSString *)userID
{
    self.progressStatus = @"Assigning Incident";
    NSString *groupID = [UserDefaults getGroupID];
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<AssignIncident xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<GroupId>%@</GroupId>\n", groupID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<IncidentId>%@</IncidentId>\n", incidentID]];
    [soapMessage appendString:[NSString stringWithFormat:@"</AssignIncident>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)unassignIncident:(NSString *)incidentID forUserID:(NSString *)userID
{
    self.progressStatus = @"Unassigning Incident";
    NSString *groupID = [UserDefaults getGroupID];
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<UnAssignIncident xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<GroupId>%@</GroupId>\n", groupID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<IncidentId>%@</IncidentId>\n", incidentID]];
    [soapMessage appendString:[NSString stringWithFormat:@"</UnAssignIncident>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)getUsersIncidentForUserID:(NSString *)userID
{
    self.progressStatus = @"Getting Incidents";
    NSString *groupID = [UserDefaults getGroupID];
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<GetUsersIncident xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<GroupId>%@</GroupId>\n", groupID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"</GetUsersIncident>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)checkIfAssigedForUserID:(NSString *)userID AndIncidentID:(NSString *)incidentID
{
    self.progressStatus = @"Loading";
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<ChkUsers xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<IncidentId>%@</IncidentId>\n", incidentID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"</ChkUsers>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)getAllUsers
{
    self.progressStatus = @"Loading Users";
    NSString *groupID = [UserDefaults getGroupID];
    
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<GetAllUsers xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<GroupId>%@</GroupId>\n", groupID]];
    [soapMessage appendString:[NSString stringWithFormat:@"</GetAllUsers>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

- (void)updateCurrentLocation:(CLLocationCoordinate2D)currentCoordinate WithGPSStatus:(NSString *)gpsStatus
{
    NSString *userID = [UserDefaults getUserID];
    NSLog(@"Updating current Location...");
    NSString *soapBeginTag = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n<soap12:Body>\n"];
    NSString *soapEndTag = [NSString stringWithFormat:@"\n</soap12:Body>\n</soap12:Envelope>"];
    
    NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:soapBeginTag];
    [soapMessage appendString:[NSString stringWithFormat:@"<UpdateCurrentLocation xmlns=\"http://tempuri.org/\">\n"]];
    [soapMessage appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>\n", userID]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Latitude>%f</Latitude>\n", currentCoordinate.latitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<Longitude>%f</Longitude>\n", currentCoordinate.longitude]];
    [soapMessage appendString:[NSString stringWithFormat:@"<GPS>%@</GPS>\n", gpsStatus]];
    [soapMessage appendString:[NSString stringWithFormat:@"</UpdateCurrentLocation>"]];
    [soapMessage appendString:soapEndTag];
    
    [self postBackgroundSoapMessage:soapMessage WithContentType:@"application/soap+xml; charset=utf-8"];
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
{
    currentElementName = elementName;
//    NSLog(@"currentElementName: %@", elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSError *jsonError;
    NSData *objectData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
//    NSLog(@"Parsed Json: %@", json);
    
    if ([currentElementName isEqualToString:@"UserLoginResult"])
    {
        if ([self.delegate respondsToSelector:@selector(didReceiveUserData:)])
        {
            [self.delegate didReceiveUserData:json];
        }
        else {
            NSLog(@"Error in delegate...");
        }
    }
    
    else if ([currentElementName isEqualToString:@"GetMapResult"])
    {
        //Run UI Updates
        if (isRefreshingMap)
        {
            [self parseMemberAndIncidentDetailsData:json];
        }
        else
        {
            [self parseMemberAndIncidentDetailsData:json];
        }
    }
    
    else if ([currentElementName isEqualToString:@"NewIncidentResult"])
    {
        [self parseNewIncidentDetails:json];
    }
    else if ([currentElementName isEqualToString:@"DeleteIncidentResult"])
    {
        [self parseDeleteIncidentDetails:json];
    }
    else if ([currentElementName isEqualToString:@"UpdateIncidentResult"])
    {
        [self parseUpdateIncidentDetails:json];
    }
    else if ([currentElementName isEqualToString:@"GetIncidentsResult"])
    {
        [self parseAllIncidentDetails:json];
    }
    else if ([currentElementName isEqualToString:@"GetIncidentNearUserResult"])
    {
        [self parseIncidentNearUser:json];
    }
    else if ([currentElementName isEqualToString:@"AssignIncidentResult"])
    {
        [self parseAssignIncident:json];
    }
    else if ([currentElementName isEqualToString:@"UnAssignIncidentResult"])
    {
        [self parseUnassignIncident:json];
    }
    else if ([currentElementName isEqualToString:@"GetUsersIncidentResult"])
    {
        [self parseUserIncidents:json];
    }
    else if ([currentElementName isEqualToString:@"ForGotPasswordResult"])
    {
        [self parseForgotPassword:json];
    }
    else if ([currentElementName isEqualToString:@"ChkUsersResult"])
    {
        [self parseCheckIfAssigned:json];
    }
    else if ([currentElementName isEqualToString:@"GetAllUsersResult"])
    {
        [self parseAllUsersDetails:json];
    }
    else if ([currentElementName isEqualToString:@"LogOffUsersResult"])
    {
        [self parseLogoffResults:json];
    }
    else if ([currentElementName isEqualToString:@"AddSettingsResult"])
    {
        [self parseSetSettings:json];
    }
    else if ([currentElementName isEqualToString:@"UpdateCurrentLocationResult"])
    {
        if ([json[@"Status"] isEqualToString:@"Success"])
        {
            [[LocationTracker sharedLocationManager] stopUpdatingLocation];
            NSLog(@"Current Location Updated");
        }
    }
    else if ([currentElementName isEqualToString:@"GetSettingsResult"])
    {
        [self parseGetSettings:json];
    }
    else if ([currentElementName isEqualToString:@"SendGroupMessageResult"])
    {
        [self parseGroupMessage:json];
    }
    else if ([currentElementName isEqualToString:@"GetGroupMessagesResult"])
    {
        [self parseAllMessages:json];
    }
}

#pragma mark - Parse Received Data

- (void)parseSetSettings:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"Not saved"];
        });
    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(didSaveSettings)]) {
                [self.delegate didSaveSettings];
            }
            [SVProgressHUD showSuccessWithStatus:@"Saved"];
        });
    }
}

- (void)parseGroupMessage:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:data[@"Message"]];
        });
    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(didSentGroupMessages)]) {
                [self.delegate didSentGroupMessages];
            }
            [SVProgressHUD showSuccessWithStatus:@"Message sent"];
        });
        
    }
}

- (void)parseAllMessages:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }
    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        NSMutableArray *messagesList = [[NSMutableArray alloc] init];
        NSArray *allMessages = data[@"Message"];
        for (NSDictionary *message in allMessages)
        {
            Message *newMessage = [Message new];
            newMessage.senderID = message[@"UserId"];
            newMessage.senderName = message[@"SenderName"];
            newMessage.sentMessage = message[@"Message"];
            newMessage.sentTime = message[@"Time"];
            [messagesList addObject:newMessage];
        }
        if ([self.delegate respondsToSelector:@selector(didReceiveGroupMessages:)]) {
            [self.delegate didReceiveGroupMessages:messagesList];
        }
    }
}

- (void)parseGetSettings:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        gfailure(data[@"Message"]);
    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        NSDictionary *settingsDict = data[@"Message"];
        NSString *min = [[UserDefaults getGPSTime] intValue]==1 ? @"min":@"mins";
        NSString *gpsTime = [NSString stringWithFormat:@"%@ %@", [UserDefaults getGPSTime], min];
        NSString *lat = settingsDict[@"Latitude"];
        NSString *lng = settingsDict[@"Longitude"];
        NSString *logoutTime = settingsDict[@"LogoutTime"];
        NSString *incidentDeletionTime = settingsDict[@"IncDeletionTime"];
        NSString *incDeletionStatus = [NSString stringWithFormat:@"%@", settingsDict[@"IncDeletionStatus"]];
        NSString *userView = [NSString stringWithFormat:@"%@", settingsDict[@"UserView"]];
        NSString *location = [NSString stringWithFormat:@"%@", settingsDict[@"Location"]];
        
        
        Settings *settings = [Settings new];
        settings.gpsTime = gpsTime;
        settings.logoutTime = logoutTime;
        settings.incidentDeletionTime = incidentDeletionTime;
        settings.isAutomaticDeletionEnabled = [incDeletionStatus isEqualToString:@"0"] ? NO:YES;
        settings.isVisibleToOtherUsers = [userView isEqualToString:@"0"] ? NO:YES;
        settings.mapLocation = location;
        settings.mapCoordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
        gsuccess(settings);
        
        [UserDefaults setMapCoordinateWithValue:settings.mapCoordinate];
        [UserDefaults setMapAddressWithValue:settings.mapLocation];
    }
}

- (void)parseAllUsersDetails:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
           [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }
    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        
        NSMutableArray *memberList = [[NSMutableArray alloc] init];
        NSDictionary *jsonMemberList = data[@"Message"];
        
        for (NSDictionary *member in jsonMemberList)
        {
            NSString *status = [NSString stringWithFormat:@"%@", member[@"OnlineStatus"]];
            
            User *newUser = [User new];
            newUser.userID = member[@"UserId"];
            newUser.userName = member[@"Name"];
            newUser.status = [status isEqualToString:@"1"] ? @"Online" : @"Offline";
            [memberList addObject:newUser];
        }
        if ([self.delegate respondsToSelector:@selector(didReceiveUsersDetails:)])
        {
            [self.delegate didReceiveUsersDetails:memberList];
        }

        
    }
}


- (void)parseUserIncidents:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }

    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        
        NSMutableArray *incidentList = [[NSMutableArray alloc] init];
        NSDictionary *jsonIncidentList = data[@"Message"][@"lstIncidents"];
        
        for (NSDictionary *incident in jsonIncidentList) {
            NSString *lat = incident[@"Latitude"];
            NSString *lng = incident[@"Longitude"];
            
            Incident *detail = [Incident new];
            detail.incidentID = incident[@"IncidentId"];
            detail.incidentAddress = incident[@"AddressLine1"];
            detail.incidentName = incident[@"IncidentName"];
            detail.incidentDescription = incident[@"Description"];
            detail.coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
            
            [incidentList addObject:detail];
        }
        if ([self.delegate respondsToSelector:@selector(didReceiveUserIncidents:)]) {
            [self.delegate didReceiveUserIncidents:incidentList];
        }
    }
}


- (void)parseIncidentNearUser:(id)data
{
    
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(didNotGetIncidentNearUser:)]) {
            [self.delegate didNotGetIncidentNearUser:data[@"Message"]];
        }
    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        
        NSMutableArray *userList = [[NSMutableArray alloc] init];
        NSDictionary *jsonUserList = data[@"Message"];
        
        for (NSDictionary *user in jsonUserList) {
            
            NSString *userID = user[@"UserId"];
            NSString *userName = user[@"Name"];
            NSString *lat = user[@"UserLatitute"];
            NSString *lng = user[@"UserLongitude"];

            User *newUser = [User new];
            newUser.userID = userID;
            newUser.userName = userName;
            newUser.coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
            newUser.isAssigned = [user[@"IncidentStatus"] isEqualToString:@"Assign"]?NO:YES;
            [userList addObject:newUser];

        }
        if ([self.delegate respondsToSelector:@selector(didGetIncidentNearUser:)]) {
             [self.delegate didGetIncidentNearUser:userList];
        }
    }
}

- (void)parseAllIncidentDetails:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }

    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        
        NSMutableArray *incidentList = [[NSMutableArray alloc] init];
        NSDictionary *jsonIncidentList = data[@"Message"];
        
        for (NSDictionary *incident in jsonIncidentList) {
            NSString *lat = incident[@"Latitude"];
            NSString *lng = incident[@"Longitude"];
            
            Incident *detail = [Incident new];
            detail.incidentID = incident[@"IncidentId"];
            detail.incidentAddress = incident[@"AddressLine1"];
            detail.incidentName = incident[@"IncidentName"];
            detail.incidentDescription = incident[@"Description"];
            detail.coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
            
            [incidentList addObject:detail];
        }
        if ([self.delegate respondsToSelector:@selector(didReceiveIncidentDetails:)]) {
            [self.delegate didReceiveIncidentDetails:incidentList];
        }
    }
}

- (void)parseDeleteIncidentDetails:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }

    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        if ([self.delegate respondsToSelector:@selector(didDeleteIncident)]) {
            [self.delegate didDeleteIncident];
        }
     }
}

- (void)parseLogoffResults:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }

    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        if ([self.delegate respondsToSelector:@selector(didLogOffUser:)]) {
            [self.delegate didLogOffUser:data[@"Message"]];
        }
    }
}

- (void)parseAssignIncident:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }

    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        if ([self.delegate respondsToSelector:@selector(didAssignIncident)]) {
            [self.delegate didAssignIncident];
        }
    }
}

- (void)parseUnassignIncident:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }

    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        if ([self.delegate respondsToSelector:@selector(didUnassignIncident)]) {
            [self.delegate didUnassignIncident];
        }
    }
}

- (void)parseUpdateIncidentDetails:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }

    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        if ([self.delegate respondsToSelector:@selector(didUpdateIncident)]) {
            [self.delegate didUpdateIncident];
        }
    }
}

- (void)parseCheckIfAssigned:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }

    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        NSMutableArray *isAssignedArray = [[NSMutableArray alloc] init];
        NSArray *usersList = data[@"Message"];
        for (NSDictionary *user in usersList)
        {
            [isAssignedArray addObject:user[@"Result"]];
        }
        if ([self.delegate respondsToSelector:@selector(isUserAssignedToIncident:)]) {
            [self.delegate isUserAssignedToIncident:isAssignedArray];
       }
     }
}

- (void)parseForgotPassword:(id)data
{
    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }

    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        if ([self.delegate respondsToSelector:@selector(didReceiveUserData:)]) {
            [self.delegate didReceiveUserData:data];
        }
    }
}

- (void)parseNewIncidentDetails:(id)data
{
    NSString *errorStatus = data[@"Status"];
   
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }

    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        NSDictionary *incident = data[@"Message"];
        Incident *cincident = [Incident new];
        cincident.incidentID = incident[@"IncidentId"];
        cincident.incidentAddress = incident[@"AddressLine1"];
        cincident.incidentName = incident[@"IncidentName"];
        cincident.incidentDescription = incident[@"Description"];
        
        if ([self.delegate respondsToSelector:@selector(didCreateNewIncident:)]) {
            [self.delegate didCreateNewIncident:cincident];
        }
    }
}

- (void)parseMemberAndIncidentDetailsData:(id)data
{

    NSString *errorStatus = data[@"Status"];
    
    if ([errorStatus isEqualToString:@"Failed"])
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"News Crew Tracker" WithMessage:data[@"Message"]];
        }

    }
    else if ([errorStatus isEqualToString:@"Success"])
    {
        //Parsing Member Details
        NSMutableArray *memberList = [[NSMutableArray alloc] init];
        NSArray *jsonMemberList = data[@"Message"][@"lstUsers"];
        
        
        int range = 500;
        //grouping
        NSMutableArray *usersAdded = [[NSMutableArray alloc] init];
        for (int i=0; i<jsonMemberList.count; i++)
        {
            //Storing Single member datas
            NSDictionary *member1 = jsonMemberList[i];
            NSMutableArray *userNames = [[NSMutableArray alloc] init];
            NSMutableArray *userIDs = [[NSMutableArray alloc] init];
            NSString *lat = member1[@"UserLatitute"];
            NSString *lng = member1[@"UserLongitude"];
            CLLocationCoordinate2D firstCoordinate;
            NSString *GPSStatus;
            
            //Checking if user is already added to group
            if (![usersAdded containsObject:member1[@"UserId"]])
            {
                [userIDs addObject:member1[@"UserId"]];
                [userNames addObject:member1[@"Name"]];
                firstCoordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
                GPSStatus = [member1[@"GPS"] isEqualToString:@"True"] ? @"YES":@"NO";
            }
            
            [usersAdded addObject:member1[@"UserId"]];
            
            //Adding other users to existing user
            for (int j=i+1; j<jsonMemberList.count; j++)
            {
                NSDictionary *member2 = jsonMemberList[j];
                
                CLLocation *locA = [[CLLocation alloc] initWithLatitude:[member1[@"UserLatitute"] doubleValue] longitude:[member1[@"UserLongitude"]doubleValue]];
                
                CLLocation *locB = [[CLLocation alloc] initWithLatitude:[member2[@"UserLatitute"] doubleValue] longitude:[member2[@"UserLongitude"]doubleValue]];
                CLLocationDistance distance = [locA distanceFromLocation:locB];
                if (distance<range)
                {
                    if (![usersAdded containsObject:member2[@"UserId"]] && ![[UserDefaults getUserID] isEqualToString:member2[@"UserId"]])
                    {
                        [userIDs addObject:member2[@"UserId"]];
                        [userNames addObject:member2[@"Name"]];
                        [usersAdded addObject:member2[@"UserId"]];
                    }
                   
                }
            }
            if (userNames.count>0)
            {
                GroupMember *detail = [GroupMember new];
                detail.userNames = userNames;
                detail.userID = userIDs;
                detail.coordinate = firstCoordinate;
                detail.reachablity = userIDs.count==1 ? GPSStatus : @"YES";
                [memberList addObject:detail];
                
            }
        }
        
//        NSLog(@"Not Grouping");
        
//        for (NSDictionary *member in jsonMemberList)
//        {
//            NSString *username = member[@"Name"];
//            NSString *userID = member[@"UserId"];
//            NSString *lat = member[@"UserLatitute"];
//            NSString *lng = member[@"UserLongitude"];
//            
//            
//            GroupMember *detail = [GroupMember new];
//            detail.userNames =@[username];
//            detail.userID = @[userID];
//            detail.coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
//            detail.reachablity = @"YES";
//            
//            NSLog(@"%@",detail.userNames);
//            [memberList addObject:detail];
//        }
        
        if ([self.delegate respondsToSelector:@selector(didReceiveMemberDetails:)]) {
             NSLog(@"members loaded");
             [self.delegate didReceiveMemberDetails:memberList];
        }
    
        
        
        //Parsing Incident Details
        NSMutableArray *incidentList = [[NSMutableArray alloc] init];
        NSArray *jsonIncidentList = data[@"Message"][@"lstIncidents"];
        
        for (NSDictionary *incident in jsonIncidentList) {
            NSString *lat = incident[@"Latitude"];
            NSString *lng = incident[@"Longitude"];
            
            Incident *detail = [Incident new];
            detail.incidentID = incident[@"IncidentId"];
            detail.incidentAddress = incident[@"AddressLine1"];
            detail.incidentName = incident[@"IncidentName"];
            detail.incidentDescription = incident[@"Description"];
            detail.coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
            
            
            [incidentList addObject:detail];
        }
        if ([self.delegate respondsToSelector:@selector(didReceiveIncidentDetails:)]) {
            NSLog(@"incidents loaded");
            [self.delegate didReceiveIncidentDetails:incidentList];
        }
        
    }
}

- (void)parseGeocodeData:(id)data
{
    NSString *geocodeStatus = data[@"status"];
    
    if ([geocodeStatus isEqualToString:@"OK"]) {
        NSString *latitude = data[@"result"][@"geometry"][@"location"][@"lat"];
        NSString *longitude = data[@"result"][@"geometry"][@"location"][@"lng"];
        NSString *formattedAddress = data[@"result"][@"formatted_address"];
        NSString *placeName = data[@"result"][@"name"];
        
        Geocode *model = [Geocode sharedInstance];
        model.coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
        if ([formattedAddress containsString:placeName]) {
            model.address = [NSString stringWithFormat:@"%@", formattedAddress];
        } else {
             model.address = [NSString stringWithFormat:@"%@, %@", placeName, formattedAddress];
        }
        
        if ([self.delegate respondsToSelector:@selector(requestLoadedWithGeocodeData:)]) {
            [self.delegate requestLoadedWithGeocodeData:model];
        }
    }
}

- (void)parseTimeDistanceData:(id)data
{
    NSArray *routeArray = data[@"routes"];
    if (routeArray.count>0)
    {
        NSString *distance = data[@"routes"][0][@"legs"][0][@"distance"][@"text"];
        NSString *duration = data[@"routes"][0][@"legs"][0][@"duration"][@"text"];
        NSString *polyline = data[@"routes"][0][@"overview_polyline"][@"points"];
        
        NSLog(@"Distance: %@", distance);
        NSLog(@"Time: %@", duration);
        
        
        TimeDistance *model = [TimeDistance sharedInstance];
        model.distance = distance;
        model.duration = duration;
        model.polyLine = polyline;
        
        if ([self.delegate respondsToSelector:@selector(requestLoadedWithTimeDistanceData:)]) {
            [self.delegate requestLoadedWithTimeDistanceData:model];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(showErrorAlertWithTitle:WithMessage:)]) {
            [self.delegate showErrorAlertWithTitle:@"Error" WithMessage:@"Cannot find duration"];
        }
    }
}

@end
