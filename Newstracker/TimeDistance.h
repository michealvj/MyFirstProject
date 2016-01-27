//
//  TimeDistance.h
//  Newstracker
//
//  Created by Micheal on 09/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeDistance : NSObject

@property (nonatomic,assign) NSString *distance;
@property (nonatomic,assign) NSString *duration;
@property (nonatomic,assign) NSString *polyLine;

+ (TimeDistance *)sharedInstance;
@end
