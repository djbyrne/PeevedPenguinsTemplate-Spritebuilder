//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by djb on 26/06/2014.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay
{
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
}


//this is called when the CCB file is loaded
-(void)didLoadFromCCB
{
    //tells the scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    CCScene *level=[CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
}

//this is called eveytime we touch the screen
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self launchPenguin];
    
}

-(void)launchPenguin
{
    //loads the Penguin.ccb file
    CCNode* penguin = [CCBReader load:@"Penguin"];
    //positions penguin at bowl of catapult
    penguin.position = ccpAdd(_catapultArm.position, ccp(16, 50));
    
    //add the penguin to the physics node
    [_physicsNode addChild:penguin];
    
    //manualy create and apply force to launch penguin
    CGPoint launchDirection = ccp(1,0);
    CGPoint force = ccpMult(launchDirection,8000);
    [penguin.physicsBody applyForce:force];
    
    //ensure followed object is in visible are when starting
    //this follows the penguin
    self.position = ccp(0,0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    [self runAction:follow];
    
}



@end
