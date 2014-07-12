//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by djb on 26/06/2014.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "Seal.h"
#import "Penguin.h"

@implementation Gameplay
{
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCSprite *_penguin1;
    CCSprite *_penguin2;
    CCNode *_penguin3;
    CCPhysicsJoint *_mouseJoint;
    Penguin *_currentPenguin;
    CCPhysicsJoint *_penguinCatapltJoint;
    CCAction *_followPenguin;
    
}

static const float MIN_SPEED =5.f;

int _penguinCount = 3;

- (void)update:(CCTime)delta
{
    if(_currentPenguin.launched)
    {
        // if speed is below minimum speed, assume this attempt is over
        if (ccpLength(_currentPenguin.physicsBody.velocity) < MIN_SPEED){
            [self nextAttempt];
            return;
        }
    
        int xMin = _currentPenguin.boundingBox.origin.x;
    
        if (xMin < self.boundingBox.origin.x) {
            [self nextAttempt];
            return;
        }
    
        int xMax = xMin + _currentPenguin.boundingBox.size.width;
        
        if (xMax > (self.boundingBox.origin.x + self.boundingBox.size.width)) {
            [self nextAttempt];
            return;
        }
    }
}



//this is called when the CCB file is loaded
-(void)didLoadFromCCB
{
    
    //tells the scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    CCScene *level=[CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    //visualize physics bodies & joints
    //_physicsNode.debugDraw = TRUE;
    
    //nothing shall collide with our invisible nodes
    _pullbackNode.physicsBody.collisionMask = @[];
    
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    _physicsNode.collisionDelegate = self;
}

//this is called eveytime we touch the screen
-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    // start catapult dragging when a touch inside of the catapult arm occurs
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation))
    {
        // move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        
        // setup a spring joint between the mouseJointNode and the catapultArm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
    }
    
    //create a penguin if one is available
    if(_penguinCount>0 &&_penguinCount<4)
    {
        _currentPenguin = (Penguin*)[CCBReader load:@"Penguin"];
    
    
    //initially position it on the scoop
    CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34,138)];
    
    //transform the world space
    _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
    
    //add physics to the world
    [_physicsNode addChild:_currentPenguin];
    
    //we dont want the penguin to rotate in the catapult bowl
    _currentPenguin.physicsBody.allowsRotation = FALSE;
    
    //create a joint to keep the penguin in place
    _penguinCatapltJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // whenever touches move, update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
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
    
    // ensure followed object is in visible are when starting
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
    
}

- (void)releaseCatapult {
    if (_mouseJoint != nil)
    {
        
        
        // releases the joint and lets the catapult snap back
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        
        //release joint of penguin
        [_penguinCatapltJoint invalidate];
        _penguinCatapltJoint = nil;
        
        //allow rotation
        _currentPenguin.physicsBody.allowsRotation = true;
        
        // follow the flying penguin
        _followPenguin = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction:_followPenguin];
    }
    
    _currentPenguin.launched = TRUE;
}


- (void)nextAttempt {
    _currentPenguin = nil;
    [_contentNode stopAction:_followPenguin];
    _penguinCount-=1;
    [_penguin2 removeFromParent];
    
    
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:1.f position:ccp(0, 0)];
    [_contentNode runAction:actionMoveTo];
}



-(void)retry {
    //reload level
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
    NSLog(@"retry");
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    // when touches end, meaning the user releases their finger, release the catapult
    [self releaseCatapult];
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    // when touches are cancelled, meaning the user drags their finger off the screen or onto something else, release the catapult
    [self releaseCatapult];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    float energy = [pair totalKineticEnergy];
    
    // if energy is large enough, remove the seal
    if (energy > 5000.f) {
        [[_physicsNode space] addPostStepBlock:^{
            [self sealRemoved:nodeA];
        } key:nodeA];
    }
    
}

- (void)sealRemoved:(CCNode *)seal {
    
    //load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    
    //make the particle effect clean itself up,once its complete
    explosion.autoRemoveOnFinish = TRUE;
    
    //place the particle effect on the seals position
    explosion.position = seal.position;
    
    //add the particle effect to the same node the seal is on
    [seal.parent addChild:explosion];
    
    //finally,remove the destriyed seal
    [seal removeFromParent];
   
}


- (void)penguinRemoved:(CCNode *)animation{
    
   
    
    [animation removeFromParent];
    
}




@end
