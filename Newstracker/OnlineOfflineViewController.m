//
//  OnlineOfflineViewController.m
//  Newstracker
//
//  Created by Micheal on 15/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "OnlineOfflineViewController.h"

@interface OnlineOfflineViewController ()
{
    NSArray *userDetails, *dataArray, *userID;
}
@end

@implementation OnlineOfflineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarSetup];
    
    [WebServiceHandler sharedInstance].delegate = self;
    [[WebServiceHandler sharedInstance] getAllUsers];
    
    self.tableView.hidden = YES;
}

- (void)navigationBarSetup
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Online Users";
    [[SideBar sharedInstance] setUpImage:@"menu.png" WithTarget:self];
}

- (NSArray *)getUserWithStatus:(NSString *)status
{
    NSMutableArray *usersList = [[NSMutableArray alloc] init];
    
    for (User *user in userDetails) {
        if ([user.status isEqualToString:status]) {
            [usersList addObject:user];
        }
    }
    return usersList;
}

- (IBAction)segmentClicked:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex==0) {
        dataArray = [self getUserWithStatus:@"Online"];
        self.navigationItem.title = @"Online Users";
        [self.tableView reloadData];
    }
    else {
        dataArray = [self getUserWithStatus:@"Offline"];
        self.navigationItem.title = @"Offline Users";
        [self.tableView reloadData];
    }
    
}

#pragma mark - Webservice Handler

- (void)didReceiveUsersDetails:(id)data
{
    userDetails = data;
    
    dataArray = [[NSMutableArray alloc] init];
    dataArray = [self getUserWithStatus:@"Online"];
    
    self.tableView.hidden = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView reloadData];
}

- (void)showErrorAlertWithTitle:(NSString *)title WithMessage:(NSString *)message
{
    [[CodeSnip sharedInstance] showAlert:title withMessage:message withTarget:self];
}

- (void)requestFailedWithError:(NSError *)error
{
    [[CodeSnip sharedInstance] showAlert:@"Network Error" withMessage:[error localizedDescription] withTarget:self];
}


#pragma mark - Tableview delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *MyIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
    
    User *currentUser = [dataArray objectAtIndex:indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:3];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    
    titleLabel.text = currentUser.userName;
    
    if ([currentUser.status isEqualToString:@"Online"]) {
        imageView.image = [UIImage imageNamed:@"greecircle.png"];
        titleLabel.textColor = [UIColor blackColor];
    }
    else {
        imageView.image = [UIImage imageNamed:@"greycircle.png"];
        titleLabel.textColor = GREYTEXTCOLOR;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MapViewController *map = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    map.selectedUser = [dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:map animated:YES];
}

@end
