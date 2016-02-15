//
//  TutorialViewController.m
//  Newstracker
//
//  Created by Micheal on 15/02/16.
//  Copyright © 2016 Micheal. All rights reserved.
//

#import "TutorialScreen.h"

@interface TutorialScreen ()
{
    CompletionBlock completeBlock;
}
@end

@implementation TutorialScreen

-(void)buildIntroOnView:(UIView *)parentView WithCompletionHandler:(void(^)(void))sentBlock
{
    completeBlock = sentBlock;
    NSArray *allTutorials = [[[Tutorials alloc] init] getTutorials];
    NSMutableArray *allPanels = [[NSMutableArray alloc] init];
    for (Tutorials *tutorial in allTutorials)
    {
        MYIntroductionPanel *panel = [[MYIntroductionPanel alloc] initWithFrame:parentView.frame
                                                                          title:tutorial.title
                                                                    description:tutorial.desc
                                                                          image:[UIImage imageNamed:tutorial.imageName]];
        [allPanels addObject:panel];
    }

    //Create the introduction view and set its delegate
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:parentView.frame];
    introductionView.delegate = self;
    [introductionView setBackgroundColor:[UIColor whiteColor]];
    //introductionView.LanguageDirection = M0128YLanguageDirectionRightToLeft;
    
    //Build the introduction with desired panels
    [introductionView buildIntroductionWithPanels:allPanels];
    
    //Add the introduction to your view
    [parentView addSubview:introductionView];
}

#pragma mark - MYIntroduction Delegate

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    NSLog(@"Introduction did change to panel %ld", (long)panelIndex);
    
    //You can edit introduction view properties right from the delegate method!
    //If it is the first panel, change the color to green!
    
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    NSLog(@"Introduction did finish %u", finishType);
    completeBlock();
}

@end
