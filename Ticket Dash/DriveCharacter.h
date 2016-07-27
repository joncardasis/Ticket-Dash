//
//  DriveCharacter.h
//  Ticket Dash
//
//  Created by John Cardasis on 12/20/14.
//  Copyright (c) 2014 John Cardasis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

/* D-Pad Character movement positions **CURRENTLY UNIMPLEMENTED** */
typedef enum : uint8_t {
    MoveDirectionUp = 0,
    MoveDirectionLeft,
    MoveDirectionRight,
    MoveDirectionDown,
} MoveDirection;

/* Different Animation states for the Drive Character */
typedef enum : uint8_t {
    AnimationStateIdle = 0,
    AnimationStateWalk/*,
    AnimationStateAttack,
    AnimationStateGetHit,
    AnimationStateDeath,
    kAnimationStateCount*/
} AnimationState;


/* Bitmask colliders for the different entity nodes with physic bodies*/
typedef enum : uint8_t {
    ColliderTypeStudentPlayer= 1,
    ColliderTypeTeacher,
    ColliderTypeDoor,
    ColliderTypeWall,
    ColliderTypeLadder,
    ColliderTypeDoorLabel,
    ColliderTypeItem,
    ColliderTypeTicket,
} ColliderType;



@class GameScene;

@interface DriveCharacter : SKSpriteNode

@property (nonatomic, getter=isDying) BOOL dying;
@property (nonatomic, getter=isWalking) BOOL walking;
@property (nonatomic) BOOL didReachLocation;
@property (nonatomic, getter=isAnimated) BOOL animated;
@property (nonatomic) BOOL canBeginMovement; //Used to stall player entering rooms
@property (nonatomic) CGFloat animationSpeed;
@property (nonatomic) CGFloat health;
@property (nonatomic) CGFloat movementSpeed;

@property (nonatomic) NSString *activeAnimationKey;
@property (nonatomic) AnimationState requestedAnimation;


/* Preload shared animation frames, emitters, etc. */
+ (void)loadSharedAssets;

/* Initialize sprite. */
- (id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position;



/* Overwitten Methods */
- (void)collidedWith:(SKPhysicsBody *)other;
- (void)performDeath;
- (void)configurePhysicsBody;


/* Applying Damage */
//- (BOOL)applyDamage:(CGFloat)damage;
//- (BOOL)applyDamage:(CGFloat)damage fromNode:(SKNode *)node;


/* Loop Update - called once per frame. */
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval;


/* Orientation, Movement, and Interact. */
//- (void)move:(MoveDirection)direction withTimeInterval:(NSTimeInterval)timeInterval;
//- (CGFloat)faceTo:(CGPoint)position;
- (void)moveTowards:(CGPoint)position withTimeInterval:(NSTimeInterval)timeInterval;
- (void)moveInDirection:(CGPoint)direction withTimeInterval:(NSTimeInterval)timeInterval;
- (void)interact;



/* Scenes. */
-(void)addToScene:(GameScene*)scene;
//-(GameScene *)characterScene; //returns the scene the character is in

/* Physics and Collisions */
-(CGRect)collisionBoundingBox;

@end
