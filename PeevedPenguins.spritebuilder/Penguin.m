//
//  Penguin.m
//  PeevedPenguins
//
//  Created by djb on 24/06/2014.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Penguin.h"

@implementation Penguin

- (void)didLoadFromCCB {
    //CCLOG(@"COLLISION");
    self.physicsBody.collisionGroup = @"penguin";
}


@end
