//
//  MemberIcon.h
//  Newstracker
//
//  Created by Micheal on 09/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MemberIcon : UIView
@property (weak, nonatomic) IBOutlet UILabel *memberNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pinImage;

@end
