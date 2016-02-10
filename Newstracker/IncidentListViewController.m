//
//  IncidentListViewController.m
//  Newstracker
//
//  Created by Micheal on 15/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "IncidentListViewController.h"
#import "utils.h"

@interface IncidentListViewController ()
{
    NSArray *dataArray;
}
@end

@implementation IncidentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarSetup];
    [WebServiceHandler sharedInstance].delegate = self;
    [[WebServiceHandler sharedInstance] getAllIncidents];
    self.tableView.alwaysBounceVertical = NO;
  
}

- (void)navigationBarSetup
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"List of Incidents";
    [[SideBar sharedInstance] setUpImage:@"menu.png" WithTarget:self];
}

#pragma mark - Webservice Handler delegate

- (void)didReceiveIncidentDetails:(id)data
{
    dataArray = data;
    [self.tableView reloadData];
}

- (void)requestFailedWithError:(NSError *)error
{
    dataArray = [UserDefaults getIncidentData];
    [self.tableView reloadData];
    [[CodeSnip sharedInstance] showAlert:@"Network Error" withMessage:[error localizedDescription] withTarget:self];
}

- (void)showErrorAlertWithTitle:(NSString *)title WithMessage:(NSString *)message
{
    [[CodeSnip sharedInstance] showAlert:title withMessage:message withTarget:self];
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
    
    Incident *incident = [dataArray objectAtIndex:indexPath.row];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    titleLabel.text = incident.incidentName;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MapViewController *map = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    map.selectedIncident = [dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:map animated:YES];
}


@end
