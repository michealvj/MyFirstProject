//
//  OnOffUsers.h
//  Newstracker
//
//  Created by Micheal on 15/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnOffUsers : NSObject

@property (nonatomic,retain) NSString *userName;
@property (nonatomic,retain) NSString *status;

+ (OnOffUsers *)sharedInstance;
- (NSArray *)getOnlineUser;
- (NSArray *)getOfflineUser;
@end
