//
//  UserAssignTableButton.m
//  Newstracker
//
//  Created by Micheal on 18/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "UserAssignTableButton.h"

@implementation UserAssignTableButton
@synthesize strokeColor,roundedness;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.cornerRadius = roundedness;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = strokeColor.CGColor;
}

- (void) setHighlighted: (BOOL) highlighted {
    [super setHighlighted: highlighted];
    // Only as an example. Caution: looks like a disabled control
    self.alpha = highlighted ? 0.5f : 1.0f;
}

@end
