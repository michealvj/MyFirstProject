//
//  MapAreaViewController.m
//  Newstracker
//
//  Created by Micheal on 28/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "MapAreaViewController.h"

@interface MapAreaViewController ()
{
    GMSMapView *gmapView;
    GMSMarker *gmarker;
    NSDate *currentDate;
    NSMutableArray *searchLocation, *searchAddress, *searchFullAddress, *searchPlaceIDs;
;
}
@end

@implementation MapAreaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarSetup];
    [self initialiseMapView];
    self.searchTableView.hidden = YES;
    self.searchTextField.delegate = self;
    [WebServiceHandler sharedInstance].delegate = self;
}

- (void)navigationBarSetup
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Settings";
    [[navBar sharedInstance] setUpImageWithTarget:self withImage:@"ltarrow.png" leftSide:YES];
    [[navBar sharedInstance] setUpImageWithTarget:self withImage:@"home.png" leftSide:NO];
}

- (void)initialiseMapView
{
    //Get current Location
    CLLocationCoordinate2D setLocation = [UserDefaults getMapLocation];
    
    //Setting Mapview
    CGRect mapViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+65);
    
    gmapView = [[MapViewHelper sharedInstance] createMapWithCoordinate:setLocation WithFrame:mapViewFrame onTarget:self];
    
    gmarker = [[MapViewHelper sharedInstance] addSimpleMarkerWithTitle:@"My Location" WithSnippet:nil WithCoordinate:setLocation onMap:gmapView];
    [gmapView setSelectedMarker:gmarker];
    [self animateMarkerToBottom:gmarker];
    [self.mapParentView bringSubviewToFront:self.searchView];
    [self.mapParentView bringSubviewToFront:self.searchTableView];
    
    self.searchTextField.text = [UserDefaults getMapAddress];
}

- (IBAction)searchButton:(id)sender
{
    [self loadNearBySearchResults:self.searchTextField.text];
//    self.searchTextField.text = @"";
//    self.searchTableView.hidden=YES;
//    [self.searchTextField becomeFirstResponder];
}

#pragma mark - textField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.searchTableView.hidden = YES;
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.searchTextField.text = [UserDefaults getMapAddress];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    currentDate = [NSDate date];
    NSString *searchText = [NSString stringWithFormat:@"%@%@", textField.text, string];
    
    if (searchText.length==1&&[string isEqualToString:@""])
    {
        self.searchTableView.hidden = YES;
    }
    else
    {
        self.searchTableView.hidden = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSDate *bDate = [NSDate date];
            NSTimeInterval timeDiff = [bDate timeIntervalSinceDate:currentDate];
            NSLog(@"%f", timeDiff);
            if (timeDiff>0.5) {
                [self loadSearchResults:searchText];
            }
        });
    }
    return YES;
}

#pragma mark - Search Delegate

- (void)loadSearchResults:(NSString *)searchText
{
    searchText = [searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *browserKey = GOOGLE_SERVER_KEY1;
    NSString *urlString = [NSString stringWithFormat:
                           @"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=%@",searchText,browserKey];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonData = responseObject;
         NSLog(@"%@", jsonData);
         NSArray *predictions = jsonData[@"predictions"];
         
         searchLocation = [[NSMutableArray alloc] init];
         searchAddress = [[NSMutableArray alloc] init];
         searchFullAddress = [[NSMutableArray alloc] init];
         searchPlaceIDs = [[NSMutableArray alloc] init];
         
         if (predictions.count==0) {
             [searchLocation addObject:@"No results found"];
             [searchAddress addObject:@""];
             [searchFullAddress addObject:@""];
             [self.searchTableView reloadData];
         }
         
         else {
             for (NSDictionary *predict in predictions) {
                 [searchFullAddress addObject:predict[@"description"]];
                 [searchPlaceIDs addObject:predict[@"place_id"]];
                 
                 NSArray *terms = predict[@"terms"];
                 for (NSDictionary *term in terms) {
                     NSMutableString *addressString = [[NSMutableString alloc] init];
                     if ([term[@"offset"] intValue] == 0) {
                         [searchLocation addObject:term[@"value"]];
                     }
                     else {
                         [addressString appendString:[NSString stringWithFormat:@"%@, ", term[@"value"]]];
                     }
                     [searchAddress addObject:addressString];
                 }
             }
             [self.searchTableView reloadData];
         }
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[CodeSnip sharedInstance] showAlert:@"Error" withMessage:[error localizedDescription] withTarget:self];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }];
    
}

- (void)loadNearBySearchResults:(NSString *)searchText
{
    searchText = [searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    CLLocationCoordinate2D currentCoordinate = [[LocationTracker sharedInstance] getCurrentLocation].location.coordinate;
    NSString *browserKey = GOOGLE_SERVER_KEY1;
    int radius = 2500;
    
    NSString *urlString = [NSString stringWithFormat:
                           @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%i&name=%@&key=%@", currentCoordinate.latitude, currentCoordinate.longitude, radius, searchText,browserKey];
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonData = responseObject;
         NSLog(@"%@", jsonData);
         NSArray *predictions = jsonData[@"results"];
         
         searchLocation = [[NSMutableArray alloc] initWithCapacity:5];
         searchAddress = [[NSMutableArray alloc] initWithCapacity:5];
         searchFullAddress = [[NSMutableArray alloc] initWithCapacity:5];
         searchPlaceIDs = [[NSMutableArray alloc] initWithCapacity:5];
         
         if (predictions.count==0) {
             [searchLocation addObject:@"No results found"];
             [searchAddress addObject:@""];
             [searchFullAddress addObject:@""];
             [self.searchTableView reloadData];
         }
         
         else {
             for (NSDictionary *predict in predictions) {
                 [searchFullAddress addObject:predict[@"vicinity"]];
                 [searchPlaceIDs addObject:predict[@"place_id"]];
                 [searchLocation addObject:predict[@"name"]];
                 [searchAddress addObject:predict[@"vicinity"]];
             }
             [self.searchTableView reloadData];
         }
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[CodeSnip sharedInstance] showAlert:@"Error" withMessage:[error localizedDescription] withTarget:self];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }];
    
}

#pragma mark - Tableview delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return searchLocation.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *MyIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
    
    UILabel *location = (UILabel *)[cell viewWithTag:1];
    UILabel *address = (UILabel *)[cell viewWithTag:2];
    
    location.text = [searchLocation objectAtIndex:indexPath.row];
    address.text = [searchFullAddress objectAtIndex:indexPath.row];
    
    if ([[searchLocation objectAtIndex:indexPath.row] isEqualToString:@"No results found"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.scrollEnabled = NO;
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        tableView.scrollEnabled = YES;
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![[searchLocation objectAtIndex:indexPath.row] isEqualToString:@"No results found"]) {
        
        self.searchTableView.hidden = YES;
        [self.searchTextField resignFirstResponder];
        
        NSString *placeID = [searchPlaceIDs objectAtIndex:indexPath.row];
        
        NSString *geocodeURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@", placeID, GOOGLE_SERVER_KEY1];
        
        [[WebServiceHandler sharedInstance] getGeocodeForURL:geocodeURL];

        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - WebserviceHandler delegate and datasource

- (void)requestFailedWithError:(NSError *)error
{
    [[CodeSnip sharedInstance] showAlert:@"Network Error" withMessage:[error localizedDescription] withTarget:self];
}

- (void)showErrorAlertWithTitle:(NSString *)title WithMessage:(NSString *)message
{
    [[CodeSnip sharedInstance] showAlert:title withMessage:message withTarget:self];
}

- (void)requestLoadedWithGeocodeData:(id)data
{
    //Geocode data
    Geocode *model = data;
    gmarker.map = nil;
    gmarker = [[MapViewHelper sharedInstance] addSimpleMarkerWithTitle:@"My Location" WithSnippet:nil WithCoordinate:model.coordinate onMap:gmapView];
    [gmapView setSelectedMarker:gmarker];
    [self animateMarkerToBottom:gmarker];

    
    [UserDefaults setMapCoordinateWithValue:model.coordinate];
    [UserDefaults setMapAddressWithValue:model.address];
    self.searchTextField.text = model.address;
    
    self.settings.mapCoordinate = model.coordinate;
    self.settings.mapLocation = model.address;
    [[WebServiceHandler sharedInstance] saveSettings:self.settings];
}

- (void)animateMarkerToBottom:(GMSMarker *)marker
{
    [gmapView animateToLocation:marker.position];
    CGPoint mapPoint = [gmapView.projection pointForCoordinate:marker.position];
    CGPoint newPoint = CGPointMake(mapPoint.x, mapPoint.y-(self.view.frame.size.height/3)+75);
    CLLocationCoordinate2D coordinate = [gmapView.projection coordinateForPoint:newPoint];
    [gmapView animateToLocation:coordinate];
}


@end
