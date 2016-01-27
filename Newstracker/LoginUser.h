//
//  LoginUser.h
//  Newstracker
//
//  Created by Micheal on 04/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginUser : NSObject

@property (nonatomic,assign) NSString *emailID;
@property (nonatomic,assign) NSString *password;

+ (LoginUser *)sharedInstance;

@end
