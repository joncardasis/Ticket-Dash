//
//  Senior.m
//  Ticket Dash
//
//  Created by John Cardasis on 12/22/14.
//  Copyright (c) 2014 John Cardasis. All rights reserved.
//

#import "JLogging.h"
#import "Senior.h"
#import "GameScene.h"

#define kSeniorWalkFrames 4 //num of frames for walking cycle
@implementation Senior

-(id)initAtPositiion:(CGPoint)position withPlayer:(Player *)player{
    DLog(@"Player created at: %f %f", position.x, position.y);
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Senior_Walking"]; //the atlas to be used by the senior
    SKTexture *texture = [atlas textureNamed:@"senior_walking_001.png"]; //the starting texture to be cycled though
    texture.filteringMode = SKTextureFilteringNearest;
    return [super initWithTexture:texture atPosition:position withPlayer:player];
}



static NSArray *sSharedWalkAnimationFrames = nil;
- (NSArray *)walkAnimationFrames {
    return sSharedWalkAnimationFrames;
}

static NSArray *sSharedIdleAnimationFrames = nil;
- (NSArray *)idleAnimationFrames {
    return sSharedIdleAnimationFrames;
}

#pragma mark - Shared Assets
+ (void)loadSharedAssets {
    [super loadSharedAssets];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Senior_Walking"];
        SKTexture *idle = [atlas textureNamed:@"senior_walking_002.png"];
        sSharedIdleAnimationFrames= [NSArray arrayWithObject:idle];
        
        //sSharedIdleAnimationFrames
        sSharedWalkAnimationFrames = loadFramesFromAtlas(@"Senior_Walking", @"senior_walking_", kSeniorWalkFrames);
        /*sSharedDamageAction = [SKAction sequence:@[[SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:10.0 duration:0.0],
                                                   [SKAction waitForDuration:0.75],
                                                   [SKAction colorizeWithColorBlendFactor:0.0 duration:0.25]
                                                   ]];*/
    });
}






#pragma mark - Loading from a Texture Atlas
NSArray *loadFramesFromAtlas(NSString *atlasName, NSString *baseFileName, int numberOfFrames) {
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numberOfFrames];
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:atlasName];
    for (int i = 1; i <= numberOfFrames; i++) { //don't count first frame as it is already set
        NSString *fileName = [NSString stringWithFormat:@"%@%03d.png", baseFileName, i];
        SKTexture *texture = [atlas textureNamed:fileName];
        [frames addObject:texture];
    }
    
    return frames;
}


@end
