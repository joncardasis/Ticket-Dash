//
//  DriveCharacter.m
//  Ticket Dash
//
//  Created by John Cardasis on 12/20/14.
//  Copyright (c) 2014 John Cardasis. All rights reserved.
//

#import "JLogging.h"
#import "DriveCharacter.h"

@implementation DriveCharacter

-(id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position{
    self = [super initWithTexture:texture];
    if(self){
        [self sharedInitAtPosition:position];
    }
    
    return self;
}

#pragma mark --Reset character--
-(void) reset{
    self.health=kStartHealth;
    self.dying=NO;
    self.animated=YES;
    self.requestedAnimation= AnimationStateIdle;
}

- (void)sharedInitAtPosition:(CGPoint)position {    
    self.position=position;
    _health= kStartHealth;
    self.movementSpeed=20;
    _animated = YES;
    _animationSpeed = 1.0f/20.0f; //fps for animation speed of character
    
    [self configurePhysicsBody];
}




#pragma mark - Loop Update
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    if (self.isAnimated) {
        //DLog(@"Updating character animation...");
        [self resolveRequestedAnimation];
    }
}




- (void)addToScene:(GameScene *)scene {
    [scene addNode:self atWorldLayer:WorldLayerCharacter];
}

-(void)interact{
    DLog(@"DriveCharacter is interacting");
}

#pragma mark -----Movements------
- (void)moveTowards:(CGPoint)position withTimeInterval:(NSTimeInterval)timeInterval {
    self.walking=TRUE;
    CGPoint curPosition = self.position;
    CGFloat dx = position.x - curPosition.x;
    CGFloat dy = position.y - curPosition.y;
    CGFloat dt = self.movementSpeed *0.1;
    
    //DLog(@"%f %f %f", dx, dy, timeInterval);
    
    CGFloat ang = [self distanceBetweenPoints:position withPoint:curPosition] + (M_PI*0.5f); //angle between 2 nodes, for rotation of node if needed
    
    
    float facingDirection = (self.position.x>=position.x) ? -1.0 : 1; //flips sprite
    self.xScale=facingDirection;
    
    
    CGFloat distRemaining = hypotf(dx, dy);
    if (distRemaining < dt) {//If close enough to final position just finish so the position will be exact
        self.position = position;
        self.walking=FALSE;
    } else {
        self.position = CGPointMake(curPosition.x - sinf(ang)*dt,
                                    curPosition.y + cosf(ang)*dt);
        //DLog(@"Player Position: %f %f", self.position.x, self.position.y);
    }
    
    self.requestedAnimation = AnimationStateWalk;
}


- (CGFloat)distanceBetweenPoints:(CGPoint) first withPoint:(CGPoint)second {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return atan2f(deltaY, deltaX);
}


//UNIMPLEMENTED **FOR D-PAD**
- (void)moveInDirection:(CGPoint)direction withTimeInterval:(NSTimeInterval)timeInterval {
    self.walking=TRUE;
    CGPoint curPosition = self.position;
    CGFloat movementSpeed = self.movementSpeed;
    CGFloat distanceX = movementSpeed * direction.x;
    CGFloat distanceY = movementSpeed * direction.y;
    CGFloat distanceT = movementSpeed * timeInterval;
    
    CGPoint targetPosition = CGPointMake(curPosition.x + distanceX, curPosition.y + distanceY);

    CGFloat ang = [self distanceBetweenPoints:targetPosition withPoint:curPosition] + (M_PI*0.5f);
    self.zRotation = ang;
    
    CGFloat distRemaining = hypotf(distanceX, distanceY);
    if (distRemaining < distanceT) {
        self.position = targetPosition;
    } else {
        self.position = CGPointMake(curPosition.x - sinf(ang)*distanceT,
                                    curPosition.y + cosf(ang)*distanceT);
    }
    
    // Don't change to a walk animation if we planning an attack.
    /*
    if (!self.attacking) {
        self.requestedAnimation = APAAnimationStateWalk;
    }
     */
}


#pragma mark - Load Shared Assets
+ (void)loadSharedAssets {
    //overridden by sublasses
}

- (NSArray *)idleAnimationFrames {
    return nil;
}

- (NSArray *)walkAnimationFrames {
    return nil;
}

#pragma mark --Setup Physics--
-(void)configurePhysicsBody{
    //overridden by subclasses
}

- (void)collidedWith:(SKPhysicsBody *)other {
    // Handle a collision with another character, wall, etc (usually overidden).
}


#pragma mark - Animation
- (void)resolveRequestedAnimation {
    // Determine the animation we want to play.
    NSString *animationKey = nil;
    NSArray *animationFrames = nil;
    AnimationState animationState = self.requestedAnimation;
    
    switch (animationState) {
            
        default:
        case AnimationStateIdle:
            animationKey = @"anim_idle";
            animationFrames = [self idleAnimationFrames];
            break;
            
        case AnimationStateWalk:
            animationKey = @"anim_walk";
            animationFrames = [self walkAnimationFrames];
            break;
            
        /*case APAAnimationStateAttack:
            animationKey = @"anim_attack";
            animationFrames = [self attackAnimationFrames];
            break;
            
        case APAAnimationStateGetHit:
            animationKey = @"anim_gethit";
            animationFrames = [self getHitAnimationFrames];
            break;
            
        case APAAnimationStateDeath:
            animationKey = @"anim_death";
            animationFrames = [self deathAnimationFrames];
            break;*/
    }
    
    if (animationKey) {
        [self preformAnimationForState:animationState usingTextures:animationFrames withKey:animationKey];
    }
    
    self.requestedAnimation = self.dying ? AnimationStateIdle : AnimationStateIdle; // FIX! would replace first state with AnimationStateDeath
}

-(void) performDeath{
    DLog(@"PLAYER HAS DIED!");
}


-(void) preformAnimationForState:(AnimationState)animationState usingTextures:
(NSArray *)frames withKey:(NSString *)key {
    SKAction *animationAction = [self actionForKey:key];
    
    if(animationAction || [frames count]<1)
        return;// we already have a running animation or there aren't any frames to animate
    
    self.activeAnimationKey = key;
    [self runAction:[SKAction sequence:@[
                                         [SKAction animateWithTextures:frames timePerFrame:self.animationSpeed resize:YES restore:NO],
                                         [SKAction runBlock:^{
        [self animationHasCompleted:animationState];
    }]]] withKey:key];
}

- (void)animationHasCompleted:(AnimationState)animationState {
    if(self.dying){
        self.animated=NO;
    }
    
    [self animationDidComplete:animationState];
    self.activeAnimationKey = nil;
    
}

- (void)animationDidComplete:(AnimationState)animation {
    //called when animation is finished. Overridden by subclass
}

#pragma mark --Physics---
-(CGRect)collisionBoundingBox {
    return CGRectInset(self.frame, 2, 0);
}


@end
