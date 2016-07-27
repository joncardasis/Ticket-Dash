//
//  GameScene.h
//  Ticket Dash
//

//  Copyright (c) 2014 John Cardasis. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import  <AVFoundation/AVFoundation.h>
#import "Player.h"
#import "GameTextBox.h"

@class DriveCharacter, Player, Student, Teacher;


#define kMinTimeInterval (1.0f / 60.0f)
#define kStartWithTime 2.5 //play time in minutes
#define kMaxClockTime kStartWithTime*60


typedef enum : uint8_t { //playable character types definitions
    StudentTypeFreshman,
    StudentTypeSophomore,
    StudentTypeJunior,
    StudentTypeSenior
} StudentType;


//layers in the scene
typedef enum : uint8_t {
    WorldLayerGround = 0,
    WorldLayerBelowCharacter,
    WorldLayerCharacter,
    WorldLayerAboveCharacter,
    WorldLayerTop,
    kWorldLayerCount
} WorldLayer;

//game levels (0 starts it in the school)
typedef enum : uint8_t {
    GameLevelSchool = 0,
    GameLevelTrack,
    GameLevelClassroom,
    GameLevelGizmondi,
    GameLevelStuart,
    GameLevelLevens
} GameLevel;

/* Completion handler for callback after loading assets asynchronously. */
typedef void (^AssetLoadCompletionHandler)(void);

@interface GameScene : SKScene<SKPhysicsContactDelegate>

@property (nonatomic, readonly) SKNode *world;       // root node to which all game renderables are attached
@property (nonatomic, readonly) Player *defaultPlayer;  //player 1
@property (nonatomic) CGPoint defaultSpawnPoint;
@property (nonatomic) BOOL worldMovedForUpdate;  // indicates the world moved before or during the current update
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval; // the previous update: loop time interval
@property (nonatomic) GameLevel currentGameLevel;
@property (nonatomic) GameLevel gameLevelToLoad;
@property (strong, nonatomic) GameTextBox* textBox;
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

/* methods for tracking cords */
- (void)centerWorldOnCharacter:(DriveCharacter *)character;
- (void)centerWorldOnPosition:(CGPoint)position;

-(void)addNode:(SKNode*)node atWorldLayer:(WorldLayer)layer;
-(void)removeNode:(SKNode*)node atWorldLayer:(WorldLayer)layer;
    
- (void)addToScore:(uint32_t)amount;
- (void)startLevel;
- (void)setDefaultStudentType:(StudentType)type;

- (void)doorLabelWithNameTouched:(NSString*)name;
- (void)collidedWithTeacher:(Teacher*)teacher;

/* Start loading all the shared assets for the scene in the background. This method calls +loadSceneAssets
 on a background queue, then calls the callback handler on the main thread. */
+ (void)loadSceneAssetsWithCompletionHandler:(AssetLoadCompletionHandler)callback;

/* Overridden by subclasses to load scene-specific assets. */
+ (void)loadSceneAssets;


@end
