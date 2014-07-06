//
//  Seal.m
//  PeevedPenguins
//
//  Created by djb on 24/06/2014.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

- (void)didLoadFromCCB {
    self.physicsBody.collisionGroup = @"seal";
}

@end
