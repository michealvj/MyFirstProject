//
//  MessageViewController.m
//  Newstracker
//
//  Created by Micheal on 08/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import "MessageViewController.h"

@interface MessageViewController ()
{
    NSArray *dataArray;
}
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarSetup];
    [WebServiceHandler sharedInstance].delegate = self;
    [[WebServiceHandler sharedInstance] getAllMessages];
}

- (void)navigationBarSetup
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Messages";
    [[SideBar sharedInstance] setUpImage:@"menu.png" WithTarget:self];
    UIBarButtonItem *compose = [[navBar sharedInstance] setComposeMessageWithScale:0.7 WithPadding:10 isLeftSide:NO WithAction:^{
        GroupMessageViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupMessageViewController"];
        [self.navigationController pushViewController:nav animated:YES];
    }];
    self.navigationItem.rightBarButtonItem = compose;
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

- (void)didReceiveGroupMessages:(id)data
{
    dataArray = data;
    
    self.messageTableView.estimatedRowHeight = 100.0f;
    self.messageTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self.messageTableView reloadData];
}

#pragma mark - Tableview delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *MyIdentifier;
    UITableViewCell *cell;
    
    Message *message = [dataArray objectAtIndex:indexPath.row];
    
    if ([message.senderID isEqualToString:[UserDefaults getUserID]]) {
        MyIdentifier = @"MyMessage";
        message.senderName = @"Me";
    }
    else {
        MyIdentifier = @"OtherMessage";
    }

    cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];

    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *messageLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:3];
    
    titleLabel.text = message.senderName;
    messageLabel.text = message.sentMessage;
    timeLabel.text = message.sentTime;

    return cell;
}



@end
