//
//  Message.h
//  Newstracker
//
//  Created by Micheal on 08/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

+ (Message *)sharedInstance;
@property (nonatomic,retain) NSString *senderID;
@property (nonatomic,retain) NSString *senderName;
@property (nonatomic,retain) NSString *sentMessage;
@property (nonatomic,retain) NSString *sentTime;

@end
