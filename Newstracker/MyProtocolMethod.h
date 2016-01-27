//
//  MyProtocolMethod.h
//  Newstracker
//
//  Created by Micheal on 04/01/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Incident.h"

@protocol MyProtocolDelegate <NSObject>
@optional
- (void)didSelectIncident:(Incident *)incident;
@end
