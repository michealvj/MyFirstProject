//
//  SearchTableViewController.m
//  Newstracker
//
//  Created by Micheal on 22/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "SearchTableViewController.h"
#import "utils.h"
#import <AFNetworking.h>

@interface SearchTableViewController ()
{
    NSMutableArray *searchLocation, *searchAddress, *searchFullAddress, *searchPlaceIDs;
    NSDate *currentDate;
}
@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.searchAddressBar becomeFirstResponder];
}


#pragma mark - Searchbar Delegate Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    currentDate = [NSDate date];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSDate *bDate = [NSDate date];
            NSTimeInterval timeDiff = [bDate timeIntervalSinceDate:currentDate];
            NSLog(@"%f", timeDiff);
            if (timeDiff>0.5) {
                [self loadSearchResults:searchText];
            }
        });
}

- (void)loadSearchResults:(NSString *)searchText
{
    searchText = [searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *browserKey = GOOGLE_SERVER_KEY1;
    NSString *urlString = [NSString stringWithFormat:
                           @"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=%@",searchText,browserKey];
    [SVProgressHUD show];
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
         [SVProgressHUD dismiss];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[CodeSnip sharedInstance] showAlert:@"Error" withMessage:[error localizedDescription] withTarget:self];
         [SVProgressHUD dismiss];
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<searchPlaceIDs.count) {
        if ([_delegate respondsToSelector:@selector(didSelectAddress:)]) {
            [_delegate didSelectAddress:[searchPlaceIDs objectAtIndex:indexPath.row]];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
