//
//  TutorialViewController.h
//  Newstracker
//
//  Created by Micheal on 15/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYBlurIntroductionView.h"
#import "Tutorials.h"

typedef void (^CompletionBlock) (void);
@interface TutorialScreen : NSObject <MYIntroductionDelegate>
-(void)buildIntroOnView:(UIView *)parentView WithCompletionHandler:(void(^)(void))sentBlock;
@end
