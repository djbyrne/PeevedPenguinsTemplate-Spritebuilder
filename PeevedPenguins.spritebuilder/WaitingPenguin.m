//
//  WaitingPenguin.m
//  PeevedPenguins
//
//  Created by djb on 10/07/2014.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "WaitingPenguin.h"

@implementation WaitingPenguin

-(void)didLoadFromCCB
{
    //generate a random number between 0 and 2
    float delay = (arc4random()%2000)/1000.f;
    //call method to start animation
    [self performSelector:@selector(startBlinkAndJump)withObject:nil afterDelay:delay];
}

-(void)startBlinkAndJump
{
    //the animation manager of each node is stored in the animation manager
    CCAnimationManager* animationManager = self.animationManager;
    //timelines can be referenced and run by name
    [animationManager runAnimationsForSequenceNamed:@"BlinkAndJump"];
}

@end
