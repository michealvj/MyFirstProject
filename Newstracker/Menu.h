//
//  Menu.h
//  Newstracker
//
//  Created by Micheal on 08/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Menu : NSObject

@property (nonatomic,assign) NSString *menuTitle;
@property (nonatomic,assign) NSString *menuImage;


+ (Menu *)sharedInstance;
- (NSArray *)getMenuList;
@end
