//
//  SearchTableViewController.h
//  Newstracker
//
//  Created by Micheal on 22/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchAddressDelegate <NSObject>
@optional
- (void)didSelectAddress:(NSString *)placeID;
@end

@interface SearchTableViewController : UIViewController <UISearchBarDelegate,UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) id<SearchAddressDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchAddressBar;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;

@end
