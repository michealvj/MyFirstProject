//
//  Tutorials.h
//  Newstracker
//
//  Created by Micheal on 15/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tutorials : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *imageName;
- (NSArray *)getTutorials;
@end
