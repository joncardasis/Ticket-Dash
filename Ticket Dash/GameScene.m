//
//  GameScene.m
//  Ticket Dash
//
//  Created by John Cardasis on 12/20/14.
//  Copyright (c) 2014 John Cardasis. All rights reserved.
//

#import "JLogging.h"
#import "GameScene.h"
#import "Student.h"
#import "Freshman.h"
#import "Sophomore.h"
#import "Junior.h"
#import "Senior.h"
#import "CollisionsParser.h"
#import "Teacher.h"
#import "JLabel.h"
#import "GizmondiQuizTextBox.h"

@interface GameScene(){
    BOOL tapheld;
    float secondsCount; //updated from the gametimer
    UIView *fadeView;
}

@property (nonatomic) NSMutableArray *layers;
@property (nonatomic) UILongPressGestureRecognizer *holdTap;
@property (nonatomic) NSTimer *gameTimer;
@property (nonatomic) UILabel *clock;
@property (nonatomic) JLabel* scoreLabel;

@end



@implementation GameScene

#pragma mark------- Initializaiton -------
-(instancetype)initWithSize:(CGSize)size{
    self=[super initWithSize:size];
    if(self){
        DLog(@"Building World...");
        _defaultPlayer = [[Player alloc] init];
        _world = [[SKNode alloc] init];
        
        _layers = [NSMutableArray arrayWithCapacity:kWorldLayerCount];
        for (int i=0; i<kWorldLayerCount; i++){
            SKNode *layer = [[SKNode alloc] init];
            layer.zPosition = i-kWorldLayerCount;
            [_world addChild:layer];
            [(NSMutableArray*)_layers addObject:layer];
        }
        
        
        [self buildWorld];
        [self addChild:_world];
        
        [self addAssetsToMap];
    }
    return self;
}


-(void)buildWorld{
    [_world setName:@"world"];
    self.backgroundColor=[UIColor blackColor];
    
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f); // no gravity
    self.physicsWorld.contactDelegate = self;
    
    [self addCollisionsForLevel:self.gameLevelToLoad];
}

-(void)addAssetsToMap{
        for (SKNode *currentTile in [self backgroundTiles]){
            [self addNode:currentTile atWorldLayer:WorldLayerGround];
        }
}

-(void)updateSpawnLocationForLevel:(GameLevel)level{
    if(level == GameLevelSchool){
        DLog(@"current level: %i        level to load: %i", self.currentGameLevel, self.gameLevelToLoad);
        if(self.gameLevelToLoad == GameLevelStuart){
            DLog(@"stuart");
            self.defaultPlayer.student.position=CGPointMake(-860, -220);
        }
        else if(self.gameLevelToLoad == GameLevelClassroom){
            self.defaultPlayer.student.position=CGPointMake(-860, -220);
        }
        else{
            self.defaultPlayer.student.position= CGPointMake(50, -225);//spawns player below elevator
            //self.defaultPlayer.student.position=CGPointMake(0, 225); //debug
        }
    }
            
    if(level == GameLevelClassroom || level == GameLevelStuart || level == GameLevelGizmondi){
        self.defaultPlayer.student.position=CGPointMake(-70,-64);
        self.defaultPlayer.student.xScale=1.0; //forces player to face right on spawn
    }
    else if(level == GameLevelLevens){
        self.defaultPlayer.student.position=CGPointMake(-120, 120);
        self.defaultPlayer.student.xScale=1.0;
    }
    else if(level == GameLevelTrack){
        self.defaultPlayer.student.position=CGPointMake(50, -125);
        self.defaultPlayer.student.xScale=1.0;
    }
    [self centerWorldOnCharacter:self.defaultPlayer.student];
}


-(void)startLevel{
    //set up additional info here for world
    Student *student = [self addStudentForPlayer:self.defaultPlayer];
    [self centerWorldOnCharacter:student];
    [self updateSpawnLocationForLevel:self.currentGameLevel];
    [self spawnTicketsInLevel:self.currentGameLevel]; //spawns tickets in first loaded room
    
    [self createClock];
    [self buildHUD];
    [self playBackgroundMusic];
}

#pragma mark ---Building World Assets---
+(void)loadWorldLevel:(GameLevel)level{
    NSLog(@"Loading World Tiles..."); //static methods must use nslog
    NSDate *startTime = [NSDate date];
    SKTextureAtlas *worldTileAtlas;
    
    //load defaults
    float yAxisTiles=0;
    float xAxisTiles=0;
    int capacity=0;
    CGSize size = CGSizeMake(0, 0);
    float nodeSize =0.0;
    
    //specify based on level to be loaded
    if(level ==GameLevelSchool || level == GameLevelTrack){
        yAxisTiles=10;
        xAxisTiles=28;
        if(level==GameLevelTrack)
            worldTileAtlas = [SKTextureAtlas atlasNamed:@"Track_Tiles"];
        else
            worldTileAtlas = [SKTextureAtlas atlasNamed:@"School_Tiles"];
        capacity=280;//how many images in worldtitleatals
        size=CGSizeMake(1792, 640); //size of level (in pixels)
        nodeSize=64; //how big each square node should be. ie.64x64
        sMapDimensions=size;
    }
            
    else if((level== GameLevelClassroom) || (level ==GameLevelStuart) || (level== GameLevelGizmondi)){
        yAxisTiles=3;
        xAxisTiles=3;
        worldTileAtlas = [SKTextureAtlas atlasNamed:@"Classroom_Tiles"];
        capacity=9;
        size=CGSizeMake(192, 192);
        nodeSize=64;
        sMapDimensions=size;
    }
    
    else if(level ==GameLevelLevens){
        yAxisTiles=5;
        xAxisTiles=4;
        worldTileAtlas = [SKTextureAtlas atlasNamed:@"Levens_Tiles"];
        capacity=20;
        size=CGSizeMake(256, 320);
        nodeSize=64;
        sMapDimensions=size;
    }
    else{
    
    }
    
    sBackgroundTiles=nil;
    sBackgroundTiles = [[NSMutableArray alloc] initWithCapacity:capacity];//# of tiles used
    for(int y=0; y<yAxisTiles; y++){ //y axis (across) of map to load tiles
        for (int x=0; x< xAxisTiles; x++){
            int currentTile = (y*xAxisTiles)+x; //used to associate a location with a tile name
            SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithTexture:[worldTileAtlas textureNamed:[NSString stringWithFormat:@"tile-%d.png", currentTile]]];
            tileNode.anchorPoint = CGPointMake(0, 1); //sets the starting target to upper left
            //VLog(@"Tile being loaded: tile-%d.png",currentTile);
            
            CGPoint currentPosition = CGPointMake((x *nodeSize)-(size.width/2), size.height-(y*nodeSize)-(size.height/2));
            //VLog(@"Tile CurrentPosition: %f. %f", currentPosition.x, currentPosition.y);
            
            tileNode.texture.filteringMode = SKTextureFilteringNearest;
            tileNode.position=currentPosition;
            tileNode.zPosition=-1.0f;//assures the tiles will be placed behind all other objects added in
            tileNode.xScale=1.001; //increasing each node slightly will prevent double-planing
            tileNode.yScale=1.001;
            tileNode.blendMode=SKBlendModeAlpha;
            [(NSMutableArray*)sBackgroundTiles addObject:tileNode];
        }
    }
    
    
    NSLog(@"All World Tiles Loaded in %f Seconds for level type:%hhu", [[NSDate date] timeIntervalSinceDate:startTime], level);
}

-(void)insertTeachersIntoLevel:(GameLevel)level{
    DLog(@"Adding teachers...");
    if(level ==GameLevelStuart){//classroom as been loaded and can now add the teacher
        Teacher *stuart = [[Teacher alloc] initWithTeacher:@"Stuart" atPosition:CGPointMake(65, 0)];
        stuart.xScale=-1.0;
        [self addNode:stuart atWorldLayer:WorldLayerGround]; //this layer gets unloaded when player leaves room
        
    }
    else if(level == GameLevelGizmondi){
        Teacher *gizmondi = [[Teacher alloc] initWithTeacher:@"Gizmondi" atPosition:CGPointMake(65, 0)];
        gizmondi.xScale=-1.0;
        [self addNode:gizmondi atWorldLayer:WorldLayerGround];
    }
    
}


-(void)unloadCurrentWorldLevel{
    [self removeWorlLayer:WorldLayerGround];
    sBackgroundTiles=nil;//releases memory stored in array
}


static CGSize sMapDimensions;
-(CGSize)mapDimensions{
    return sMapDimensions;
}

static NSArray *sBackgroundTiles = nil;
- (NSArray *)backgroundTiles {
    return sBackgroundTiles;
}


-(void)gameDidEnd{
    DLog(@"GAME OVER");
    [self.textBox dismiss];
    fadeView= [[UIView alloc] initWithFrame:self.view.frame];
    fadeView.backgroundColor=[UIColor blackColor];
    fadeView.alpha=0;
    [self.view insertSubview:fadeView aboveSubview:self.view];
    
    [UIView animateWithDuration:0.5 //fade to black
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         fadeView.alpha=0.4;
                     } completion:^(BOOL finished){
                    
                     }];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:self.defaultPlayer.score] forKey:@"finalScore"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gameFinished" object:nil userInfo:dict];
    
    
    self.defaultPlayer.student.dying=true; //"kills" player
    
}


-(Student *)addStudentForPlayer:(Player*)player{
    DLog(@"Adding student for Player 1");
    NSAssert(![player isKindOfClass:[NSNull class]], @"Player is a null class. Quitting Application..."); //if this test is not passed the app crashes 'gracefully'
    
    if(player.student && !player.student.dying){ //if the player has a student object and is not dying
        [player.student removeFromParent];
    }
    
    CGPoint spawnPoint = self.defaultSpawnPoint;
    
    Student *student = [[player.studentClass alloc] initAtPositiion:spawnPoint withPlayer:player];
    if(student){
        //if wanted spawning animation can be added here
        //ex. [student fadeIn:1.0f]; //1 second to fade in
        
        [student addToScene:self];
    }
    
    player.student=student;
    return student;
}

-(void)sceneDidFinishLoading{//called once new level has been fully loaded in
    
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
}

#pragma mark --Loop Updates--
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    /* if framerate drops below 60fps objects should still move same distance */
    CFTimeInterval timeSinceLast = currentTime = self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if(timeSinceLast>1){ //if more than a second has passed from last update
        timeSinceLast = kMinTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
        self.worldMovedForUpdate=YES;
    }
    
    if(self.gameLevelToLoad != self.currentGameLevel){//If needs to load new level
        /* Stop player movements */
        self.defaultPlayer.targetLocation=CGPointZero;
        tapheld=false;//stops all taps that are still on screen
        self.defaultPlayer.student.canBeginMovement=false;
        
        self.currentGameLevel = self.gameLevelToLoad; //must be called before the animation
        
        /* *Do Custom Animation here before loading new level if desired* */
        [self.textBox dismissWithoutAnimation];
        fadeView= [[UIView alloc] initWithFrame:self.view.frame]; // view for fading in and out
        fadeView.backgroundColor=[UIColor blackColor];
        fadeView.alpha=0;
        [self.view addSubview:fadeView];
        [UIView animateWithDuration:0.4 //fade to black
                        delay:0.1
                        options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             fadeView.alpha=1;
                         }
                         completion:^(BOOL finished){
                             DLog(@"Finished animation");
                             [self unloadCurrentWorldLevel];//unloads old level
                             [GameScene loadWorldLevel:self.gameLevelToLoad];//loads nodes for new level
                             DLog(@"end of load");
                             [self addAssetsToMap];//adds the nodes that were loaded to the world
                             [self loadQuestForRoom:self.gameLevelToLoad];//loads quest if there is one
                             [self updateSpawnLocationForLevel:self.gameLevelToLoad];//sets new spawn point in level and centers world on the player
                             [self spawnTicketsInLevel:self.gameLevelToLoad];
                             
                             [self insertTeachersIntoLevel:self.gameLevelToLoad];
                             [self addCollisionsForLevel:self.gameLevelToLoad];//add doors, walls, etc
                             
                             self.defaultPlayer.student.canBeginMovement=true;
                             
                             [UIView animateWithDuration:0.2 animations:^{fadeView.alpha=0;} completion:^(BOOL completed){
                                 [self sceneDidFinishLoading];
                             }];
                         }];
        
        
        
    }
    
    
    if(self.defaultPlayer.student.isWalking){
        [self centerWorldOnCharacter:self.defaultPlayer.student];
    }
    else{
        //Prevents an error where the player continues to walk even when he reaches the destination
        self.defaultPlayer.student.requestedAnimation=AnimationStateIdle;
    }
    
    [self updateWithTimeSinceLastUpdate: timeSinceLast];
    
    
    
    if(![self.defaultPlayer.student isDying] && self.defaultPlayer.student.canBeginMovement){
        if (!CGPointEqualToPoint(self.defaultPlayer.targetLocation, CGPointZero)){
            DriveCharacter* student = self.defaultPlayer.student;
            if(self.defaultPlayer.moveRequested){
                if (!CGPointEqualToPoint(self.defaultPlayer.targetLocation, student.position)) { //if not occupied by current player
                    CGFloat time= timeSinceLast;
                    if(time<0.04)//Provides a .04s delay between movement updates
                        time=0.04;
                    [student moveTowards:self.defaultPlayer.targetLocation withTimeInterval:time];
                }
                else{
                    self.defaultPlayer.movementTouch = nil;
                    self.defaultPlayer.moveRequested=NO;
                }
            }
        }
    }
}

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast{
    //update player
    [self.defaultPlayer.student updateWithTimeSinceLastUpdate:timeSinceLast];
}

-(void)didSimulatePhysics{//Updated with each frame as well

}

-(void)addNode:(SKNode*)node atWorldLayer:(WorldLayer)layer{
    SKNode *layernode = self.layers[layer];
    [layernode addChild:node];
}

-(void)removeNode:(SKNode*)node atWorldLayer:(WorldLayer)layer{
    SKNode *layernode = self.layers[layer];
    [layernode removeChildrenInArray:[NSArray arrayWithObject:node]];
}

-(void)removeWorlLayer:(WorldLayer)layer{
    SKNode *layernode = self.layers[layer];
    [layernode removeAllChildren];
}

#pragma mark -----World Positioning------
-(void)centerWorldOnPosition:(CGPoint)position{
    //DLog(@"Current position of world: %f %f", self.world.position.x, self.world.position.y);
    [self.world setPosition:CGPointMake(CGRectGetMidX(self.frame)-position.x, CGRectGetMidY(self.frame)-position.y)];
    //DLog(@"Updated position of world: %f %f", self.world.position.x, self.world.position.y);
    self.worldMovedForUpdate=YES;
}

- (void)centerWorldOnCharacter:(DriveCharacter*)character{
    [self centerWorldOnPosition:character.position];
}

- (void)clearWorldMoved {
    self.worldMovedForUpdate = NO;
}

-(void)addToScore:(uint32_t)amount{
    self.defaultPlayer.score+=amount;
    self.scoreLabel.text=[NSString stringWithFormat:@"%i", self.defaultPlayer.score];
}

-(void)buildHUD{
    CGSize scoreLabelSize = CGSizeMake(200, 65);
    self.scoreLabel=[[JLabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-scoreLabelSize.width-20, 20, scoreLabelSize.width, scoreLabelSize.height)];
    self.scoreLabel.font = [UIFont fontWithName:@"BitBoy" size:45];
    self.scoreLabel.textColor=[UIColor colorWithRed:0.160 green:0.367 blue:0.713 alpha:1.000];
    self.scoreLabel.textAlignment=NSTextAlignmentRight;
    self.textBox = [[GameTextBox alloc] init];
    
    [self.view addSubview:self.textBox];
    [self.view addSubview:self.scoreLabel];
}


#pragma mark -------Touch Event Handling-------
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //VLog(@"Touches began");
    UITouch *touch = [touches anyObject];
    Player *defaultPlayer = self.defaultPlayer;
    if(defaultPlayer.movementTouch){ //prevents spam touching
        return;
    }
    
    //[self debugWithTouch:[touch locationInNode:self] withColor:[UIColor colorWithRed:0.678 green:0.257 blue:0.728 alpha:0.5]];
    
    defaultPlayer.targetLocation=[touch locationInNode:_world];
    defaultPlayer.moveRequested=YES; //Will be updated on next frame updated
    defaultPlayer.movementTouch = touch;
    
    //Handle hold
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:touch forKey:@"touch"];
    
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(handleHoldWithTouch:)
                                   userInfo:userInfo
                                    repeats:YES];
    tapheld=true;
    
}

-(void)handleHoldWithTouch: (NSTimer*) timer{
    //VLog(@"Handling Hold Touch");
    NSDictionary *dict = [timer userInfo];
    UITouch *touch = [dict objectForKey:@"touch"];
    
    if(ABS([touch locationInNode:self].x-CGRectGetMidX(_world.frame) - self.defaultPlayer.student.position.x)<2.5 && ABS([touch locationInNode:self].y-CGRectGetMidY(_world.frame) - self.defaultPlayer.student.position.y)<2.5){ /*2.5 is the buffer for how far tap must be from character. Prevents bug where the character could be dragged aroundand out of the map */
        [timer invalidate];
        touch=nil;
        return;
    }
    
    if(!self.defaultPlayer.student.canBeginMovement){//used to stop player movement updates
        [timer invalidate];
        touch=nil;
        self.defaultPlayer.targetLocation=self.defaultPlayer.student.position;
        self.defaultPlayer.moveRequested=NO;
    }
    
    if(tapheld){
        self.defaultPlayer.targetLocation=[touch locationInNode:_world];
        self.defaultPlayer.moveRequested=YES;
        self.defaultPlayer.movementTouch = touch;
    }
    else{
        [timer invalidate];
        touch=nil;
    }
}

-(void)debugWithTouch: (CGPoint)position withColor:(UIColor*)color{
    CGPoint location = position;

    SKSpriteNode *dot = [[SKSpriteNode alloc] initWithColor:color size:CGSizeMake(20, 20)];
    dot.position=CGPointMake(location.x-CGRectGetMidX(_world.frame), location.y-CGRectGetMidY(_world.frame));
    [_world addChild:dot];
}

/* Handled by handleHoldWithTouch:
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    VLog(@"Touches Moved");
    Player *defaultPlayer = self.defaultPlayer;
    UITouch *touch = defaultPlayer.movementTouch;
    if([touches containsObject:touch]){
        defaultPlayer.targetLocation = [touch locationInNode:defaultPlayer.student.parent];
    }
}*/

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    tapheld=false;
    Player *defaultPlayer = self.defaultPlayer;
    UITouch *touch = defaultPlayer.movementTouch;
    
    if(!defaultPlayer.student.isCollidedWithObject){
        //DLog(@"Not Collided");
        //[self debugWithTouch:[touch locationInNode:self] withColor:[UIColor colorWithRed:0.614 green:0.091 blue:0.105 alpha:0.500]];
        
        defaultPlayer.targetLocation = [touch locationInNode:defaultPlayer.student.parent];
    }
    else{//prevents small error where player keeps running into a wall
        //When collided with object
        defaultPlayer.moveRequested=NO;
        self.defaultPlayer.student.collided=NO;
    }
    
    if([touches containsObject:touch]){
        defaultPlayer.movementTouch=nil; //stop movement
    }
}


#pragma mark ---Node Touched Events----
-(void)doorLabelWithNameTouched:(NSString*)name{
    if([name isEqualToString: @"Gizmondi"]){
        [self.textBox showWithMessage:@"Enter if you dare." andTitle:[NSString stringWithFormat:@"%@'s Domain", name] dismisssAfterCompletion:1.0];
    }
    else
        [self.textBox showWithMessage:@"" andTitle:[NSString stringWithFormat:@"%@'s Room", name] dismisssAfterCompletion:2.0];
}


#pragma mark - Load Shared Assets
+ (void)loadSceneAssets {
    // Load assets for all the sprites within this scene.
    [self loadWorldLevel:GameLevelSchool]; //default
    
    [Senior loadSharedAssets];
    
}


+ (void)loadSceneAssetsWithCompletionHandler:(AssetLoadCompletionHandler)handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Load the shared assets in the background.
        [self loadSceneAssets];
        
        if (!handler) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Call the completion handler back on the main queue.
            handler();
        });
    });
}








- (void)setDefaultStudentType:(StudentType)type{
    switch (type) {
        case StudentTypeFreshman:
            DLog(@"Player Type Selected: Freshman");
            self.defaultPlayer.studentClass = [Freshman class];
            break;
            
        case StudentTypeSophomore:
            DLog(@"Player Type Selected: Sophomore");
            self.defaultPlayer.studentClass = [Sophomore class];
            break;
            
        case StudentTypeJunior:
            DLog(@"Player Type Selected: Junior");
            self.defaultPlayer.studentClass = [Junior class];
            break;
            
        case StudentTypeSenior:
            DLog(@"Player Type Selected: Senior");
            self.defaultPlayer.studentClass = [Senior class];
            break;
            
        default:
            DLog(@"[ERROR ESABLISHING SCENE]: StudentType invalid");
            break;
    }
}



#pragma mark ---Add Collision Objects----
-(void)addCollisionsForLevel: (GameLevel)level{
    if(level== GameLevelClassroom || level==GameLevelStuart || level==GameLevelGizmondi)
        level=GameLevelClassroom;//Loads same classroom collisions for these rooms
    
    /*for logging purposes*/
    NSDate *startDate = [NSDate date];
    int numVolumes = 0;
    
    /* Get data from JSON file */
    CollisionsParser *parser = [[CollisionsParser alloc] init];
    NSDictionary *dict = [[parser getCollisionsFor:level] objectForKey:@"Collision Objects"];
    
    NSDictionary *walls = [dict objectForKey:@"Walls"];
    NSDictionary *doors = [dict objectForKey:@"Doors"];
    NSDictionary *doorLabels = [dict objectForKey:@"Door Labels"];
    
    /* Add Walls */
    for (int i=1; i<[walls count]+1; i++){ //For each wall to be created from JSON file
        NSDictionary *currentWall = [walls objectForKey:[NSString stringWithFormat: @"Wall%i",i]];
        
        NSArray *JSONWallSize = [currentWall objectForKey:@"size"]; //returns a size array with width and height
        NSArray *JSONWallPosition = [currentWall objectForKey:@"position"];//returns array with x and y
        
        CGPoint wallPosition = CGPointMake([[JSONWallPosition objectAtIndex:0] floatValue], [[JSONWallPosition objectAtIndex:1] floatValue]);
        CGSize wallSize = CGSizeMake([[JSONWallSize objectAtIndex:0] floatValue], [[JSONWallSize objectAtIndex:1]floatValue]);
        
        [self addCollisionAtWorldPosition:wallPosition withType:ColliderTypeWall withSize:wallSize withName:nil];
        numVolumes++;
    }
    
    /* Add Doors*/
    for (int i=1; i<[doors count]+1; i++){
        NSDictionary *currentDoor = [doors objectForKey:[NSString stringWithFormat: @"Door%i",i]];
        
        NSArray *JSONDoorSize = [currentDoor objectForKey:@"size"]; //returns a size array with width and height
        NSArray *JSONDoorPosition = [currentDoor objectForKey:@"position"];//returns array with x and y
        
        CGPoint doorPosition = CGPointMake([[JSONDoorPosition objectAtIndex:0] floatValue], [[JSONDoorPosition objectAtIndex:1] floatValue]);
        CGSize doorSize = CGSizeMake([[JSONDoorSize objectAtIndex:0] floatValue], [[JSONDoorSize objectAtIndex:1]floatValue]);
        NSString* name = [currentDoor objectForKey:@"name"];
        
        
        [self addCollisionAtWorldPosition:doorPosition withType:ColliderTypeDoor withSize:doorSize withName:name];
        numVolumes++;
    }
    
    /* Add Door Labels */
    for (int i=1; i<[doorLabels count]+1; i++){
        NSDictionary *currentDoorLabel = [doorLabels objectForKey:[NSString stringWithFormat: @"Door Label%i",i]];
        NSArray *JSONLabelSize = [currentDoorLabel objectForKey:@"size"];
        NSArray *JSONLabelPosition = [currentDoorLabel objectForKey:@"position"];
        CGPoint labelPosition = CGPointMake([[JSONLabelPosition objectAtIndex:0] floatValue], [[JSONLabelPosition objectAtIndex:1] floatValue]);
        CGSize labelSize = CGSizeMake([[JSONLabelSize objectAtIndex:0] floatValue], [[JSONLabelSize objectAtIndex:1]floatValue]);
        NSString* name = [currentDoorLabel objectForKey:@"name"];
        
        [self addCollisionAtWorldPosition:labelPosition withType:ColliderTypeDoorLabel withSize:labelSize withName:name];
        numVolumes++;
    }
    
    DLog(@"Created %i collision volumes in %.3f seconds", numVolumes, [[NSDate date] timeIntervalSinceDate:startDate]);
}



-(void)addCollisionAtWorldPosition: (CGPoint)worldPosition withType:(ColliderType)collider withSize:(CGSize)size withName:(NSString*)name{
    CGSize collisionSize = size;//make reference size for shape
    
    SKNode *collisionNode = [SKNode node];
    
    collisionNode.position= CGPointMake(worldPosition.x-(sMapDimensions.width/2)+(collisionSize.width/2), (sMapDimensions.height/2)- worldPosition.y-(collisionSize.height/2));//sets position equal to the upper left of image. (Prevents having to use a spirtenode for anchorpoints)
    //VLog(@"WallNode Location: x:%f y:%f", wallNode.position.x, wallNode.position.y);
    collisionNode.physicsBody= [SKPhysicsBody bodyWithRectangleOfSize:collisionSize];//makes collision body size of the wall being made
    collisionNode.physicsBody.dynamic=NO; //physics body will not be simulated and moved
    collisionNode.physicsBody.collisionBitMask=0; //sets what THIS NODE will collide with (nothing). NOT what will collide with it
    
    
    //DEBUG---
    //SKSpriteNode *testnode = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:collisionSize];
    //[collisionNode addChild:testnode];
    //--
    
    if(name != nil){
        if(collider==ColliderTypeDoor){
            collisionNode.physicsBody.categoryBitMask=ColliderTypeDoor;
            collisionNode.name=name;
            //testnode.color=[UIColor purpleColor];
            
        }
        else if (collider==ColliderTypeDoorLabel){
            collisionNode.physicsBody.categoryBitMask=ColliderTypeDoorLabel;
            collisionNode.name=name;
            //testnode.color=[UIColor orangeColor];
        }
    }
    else{
        //testnode.color=[UIColor blueColor];
        collisionNode.physicsBody.categoryBitMask=ColliderTypeWall; //sets type of collision for object
    }
    
    
    [self addNode:collisionNode atWorldLayer:WorldLayerGround]; //add collision wall to scene
    

}

#pragma mark - Physics Delegate
- (void)didBeginContact:(SKPhysicsContact *)contact {
    //DLog(@"Contact has been made!");
    SKNode *node = contact.bodyA.node; //gets the first object that collides
    if([node isKindOfClass:[DriveCharacter class]]){ //if the node is a character
        [(DriveCharacter *)node collidedWith:contact.bodyB];
    }
    
    //also check body B for type
    node=contact.bodyB.node;
    if([node isKindOfClass:[DriveCharacter class]]){
        [(DriveCharacter *)node collidedWith:contact.bodyA];
    }
    // ^This way if two characters interact both of their collidedWith methods will be called
    
}



#pragma mark ---- Game Display Clock -----
-(void)createClock{
    self.clock = [[UILabel alloc] initWithFrame: CGRectMake(CGRectGetMidX(self.view.frame)-(160/2), 25, 160, 62)];
    self.clock.font = [UIFont fontWithName:@"BitBoy" size:60];
    self.clock.text=[NSString stringWithFormat:@"2:30"]; //sets display time for temp clock
    //self.clock.textColor=[UIColor colorWithRed:37/255.0 green:152/255.0 blue:211/255.0 alpha:1.0];
    self.clock.textColor=[UIColor whiteColor];
    [self.clock setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.clock];
    
    secondsCount=kMaxClockTime;
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    self.defaultPlayer.student.canBeginMovement=false;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(makePlayerMoveable) userInfo:nil repeats:NO];
}

-(void)makePlayerMoveable{
    self.defaultPlayer.student.canBeginMovement=true;
}

-(void)updateTimer{
    if(secondsCount<=0){//Game Over
        [self.gameTimer invalidate];
        self.gameTimer=nil;
        [self gameDidEnd];
    }
    else if(secondsCount<=30){
        if(self.gameTimer.timeInterval>0.5){//is interval is over 1/2 sec then make a new timer with shorter time
            [self.gameTimer invalidate];
            self.gameTimer=nil;
            self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES]; //when under 30 sec start counting in ms
            self.clock.textColor= [UIColor colorWithRed:0.773 green:0.000 blue:0.147 alpha:1.000];//set color to red
        }
        int seconds = secondsCount;
        int miliseconds = (secondsCount - floor(secondsCount)) *10;//will only store first num of milisec, accurate time
        secondsCount-=self.gameTimer.timeInterval;
        self.clock.text=[NSString stringWithFormat:@"%i:%02i",seconds,miliseconds*10];
    }
    else{
        int minutes = secondsCount/60;
        int seconds = secondsCount -(minutes*60);
        
        self.clock.text=[NSString stringWithFormat:@"%i:%02i", minutes, seconds];
        secondsCount--; //remove one second
    }
}

#pragma mark ----Quests and Dialog -----
-(void)collidedWithTeacher:(Teacher *)teacher{
    self.defaultPlayer.student.walking=false;
    self.defaultPlayer.targetLocation=self.defaultPlayer.student.position;
    self.defaultPlayer.moveRequested=NO;
    [self showDialogForTeacher:teacher];
}

-(void)showDialogForTeacher:(Teacher*)teacher{
    if([teacher.name isEqualToString: @"Stuart"] && ![self.defaultPlayer.student.completedQuests containsObject:[NSNumber numberWithInt: CompletedQuestStuart]]){
        //Right now the dialog is 0 for the first encounter, and then will auto accept the quest
        if(self.defaultPlayer.student.item == GameItemLasso){//Did Quest
            [self addToScore:500]; //5 books rewarded
            [self.defaultPlayer.student.completedQuests addObject:[NSNumber numberWithInt:CompletedQuestStuart]];
            self.defaultPlayer.student.currentTeachersQuest=@""; //disband current quest
            self.defaultPlayer.student.item=GameItemNone;
            teacher.currentDialog=2;
        }
        
        [self.textBox showWithMessage:[teacher.dialog objectAtIndex:teacher.currentDialog] andTitle:teacher.name dismisssAfterCompletion:5.0];
        if(teacher.currentDialog!=1 && teacher.currentDialog<[teacher.dialog count]-1)
            teacher.currentDialog++;
    }
    else if([teacher.name isEqualToString: @"Gizmondi"] && ![self.defaultPlayer.student.completedQuests containsObject:[NSNumber numberWithInt: CompletedQuestGizmondi]]){
        //dialog 0
        
        if(teacher.currentDialog==1){ //start quest
            GizmondiQuizTextBox *gQuest = [[GizmondiQuizTextBox alloc] init];
            [self.view addSubview:gQuest];
            [gQuest startQuizWithTeacher:teacher andPlayer:self.defaultPlayer scene:self];
            self.defaultPlayer.student.canBeginMovement=false;
        }
        /* rest of dialog is determined by the quiztextbox if the player wins */
        
        [self.textBox showWithMessage:[teacher.dialog objectAtIndex:teacher.currentDialog] andTitle:teacher.name dismisssAfterCompletion:5.0];
        if(teacher.currentDialog<[teacher.dialog count]-1)
            teacher.currentDialog++;
    }
}


#pragma mark --Setup Quests----

-(void)loadQuestForRoom:(GameLevel)level{
    if(level==GameLevelLevens){
        if([self.defaultPlayer.student.currentTeachersQuest isEqualToString:@"Stuart"]){ //lasso quest
            /* Place the lasso in the room at a random computer */
            SKSpriteNode *lasso = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(31, 31)];
            CGPoint position;
            /* Generate random pos for item on a computer in room */
            float ranX = arc4random()%4; //select random x pos
            if(ranX==0 || ranX==1)
                position.x=63+ (ranX*lasso.size.width);
            else
                position.x=161+ ((ranX-2)*lasso.size.width);
            
            float ranY = arc4random()%6;//select random y pos
            position.y=82 + (ranY*lasso.size.height);
            
            lasso.position=CGPointMake(position.x-(sMapDimensions.width/2)+lasso.size.width/2,(sMapDimensions.height/2)- position.y-(lasso.size.height/2));
            
            lasso.physicsBody= [SKPhysicsBody bodyWithRectangleOfSize:lasso.size];
            lasso.physicsBody.dynamic=NO;
            lasso.physicsBody.collisionBitMask=0;
            lasso.physicsBody.categoryBitMask=ColliderTypeItem;
            [self addNode:lasso atWorldLayer:WorldLayerGround];
        }
    }
    else if(level==GameLevelGizmondi){
        
    }
}


#pragma mark --- Spawn Collectible Tickets ---
-(void)spawnTicketsInLevel:(GameLevel)level{
    NSBundle *mainBundle = [NSBundle mainBundle]; //Get resource directory
    NSString *jsonsStr;
    if(level ==GameLevelTrack){
        jsonsStr= [mainBundle pathForResource:@"Track_ticketSpawns" ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonsStr];
        NSError *error=[[NSError alloc] init];
        NSDictionary *ticketsDict = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error] objectForKey:@"Ticket Stubs"]; //Parse
        
        BOOL goldTicketsSpawned = false;
        BOOL redTicketsSpawned = false;
        for (int i=1; i<[ticketsDict count]+1; i++){ //For each wall to be created from JSON file
            NSDictionary *currentTicket = [ticketsDict objectForKey:[NSString stringWithFormat: @"Ticket Stub%i",i]];
            NSArray *JSONTicketPositions = [currentTicket objectForKey:@"position"];
            
            CGPoint ticketPosition = CGPointMake([[JSONTicketPositions objectAtIndex:0] floatValue], [[JSONTicketPositions objectAtIndex:1] floatValue]);
            
            int colorIndex = arc4random()%3;
            if(colorIndex==2 && !goldTicketsSpawned)
                goldTicketsSpawned=true;
            else if (colorIndex==1 && !redTicketsSpawned)
                redTicketsSpawned=true;
            else
                colorIndex=0;
            
            [self addTicketCollisions:ColliderTypeTicket atWorldPosition:ticketPosition withColor:colorIndex];
        }
    }
    
    if(level == GameLevelSchool){
        jsonsStr= [mainBundle pathForResource:@"School_ticketSpawns" ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonsStr];
        NSError *error=[[NSError alloc] init];
        NSDictionary *ticketsDict = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error] objectForKey:@"Ticket Stubs"]; //Parse
        
        for (int i=1; i<[ticketsDict count]+1; i++){ //For each wall to be created from JSON file
            NSDictionary *currentTicket = [ticketsDict objectForKey:[NSString stringWithFormat: @"Ticket Stub%i",i]];
            NSArray *JSONTicketPositions = [currentTicket objectForKey:@"position"];
            CGPoint ticketPosition = CGPointMake([[JSONTicketPositions objectAtIndex:0] floatValue], [[JSONTicketPositions objectAtIndex:1] floatValue]);
            
            [self addTicketCollisions:ColliderTypeTicket atWorldPosition:ticketPosition withColor:0];
        }
    }
    
    if(level == GameLevelClassroom || level==GameLevelGizmondi){
        jsonsStr= [mainBundle pathForResource:@"Classroom_ticketSpawns" ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonsStr];
        NSError *error=[[NSError alloc] init];
        NSDictionary *ticketsDict = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error] objectForKey:@"Ticket Stubs"]; //Parse
        
        for (int i=1; i<[ticketsDict count]+1; i++){ //For each wall to be created from JSON file
            NSDictionary *currentTicket = [ticketsDict objectForKey:[NSString stringWithFormat: @"Ticket Stub%i",i]];
            NSArray *JSONTicketPositions = [currentTicket objectForKey:@"position"];
            CGPoint ticketPosition = CGPointMake([[JSONTicketPositions objectAtIndex:0] floatValue], [[JSONTicketPositions objectAtIndex:1] floatValue]);
            
            [self addTicketCollisions:ColliderTypeTicket atWorldPosition:ticketPosition withColor:0];
        }
    }
}

-(void)addTicketCollisions:(ColliderType)collider atWorldPosition:(CGPoint)position withColor:(int)colorIndex{
    /* colorIndex: 0 -> blue, 1 -> red, 2 -> gold */
    CGSize size = CGSizeMake(16, 16);
    SKSpriteNode *ticket;
    ticket.texture.filteringMode = SKTextureFilteringNearest;
    
    if(colorIndex==1){//spawn red ticket
        //DLog(@"placing red ticket");
        ticket = [[SKSpriteNode alloc] initWithImageNamed:@"Red Ticket.png"];
        ticket.name=@"redTicket";
    }
    else if(colorIndex==2){
        //DLog(@"placng gold ticket");
        ticket = [[SKSpriteNode alloc] initWithImageNamed:@"Gold Ticket.png"];
        ticket.name=@"goldTicket";
    }
    else{ //standard blue ticket
        //DLog(@"placing blue ticket");
        ticket = [[SKSpriteNode alloc] initWithImageNamed:@"Blue Ticket.png"];
        ticket.name=@"blueTicket";
    }
    
    ticket.position= CGPointMake(position.x-(sMapDimensions.width/2)+(size.width/2), (sMapDimensions.height/2)- position.y-(size.height/2));
    ticket.physicsBody= [SKPhysicsBody bodyWithRectangleOfSize:size];
    ticket.physicsBody.dynamic=NO;
    ticket.physicsBody.collisionBitMask=0;
    ticket.physicsBody.categoryBitMask=ColliderTypeTicket;
    [self addNode:ticket atWorldLayer:WorldLayerGround];
}

-(void)showTicketsForLevel:(GameLevel)level{
    SKNode *layerNode = self.layers[WorldLayerGround];
    if(level == GameLevelTrack){
        for(SKSpriteNode* node in [layerNode children]){
            if([node.name isEqualToString:@"blueTicket"] || [node.name isEqualToString:@"redTicket"] || [node.name isEqualToString:@"goldTicket"]){
                node.hidden=false;
            }
        }
    }
}

-(void)hideTicketsForLevel:(GameLevel)level{
    
}

#pragma mark --- Music and Sound effects ---
-(void)playBackgroundMusic{
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error];//Prevent Mute switch from stopping audio
    NSURL * backgroundMusicURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bg music" ofType:@"wav"]];;
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.backgroundMusicPlayer.numberOfLoops = -1;//infinite loop
    [self.backgroundMusicPlayer prepareToPlay];
    self.backgroundMusicPlayer.volume=0;
    [self.backgroundMusicPlayer play];
    [self fadeVolumeIn];
}

-(void)fadeVolumeIn
{
    if (self.backgroundMusicPlayer.volume < 0.65) {//sets max value
        self.backgroundMusicPlayer.volume += 0.05;
        [self performSelector:@selector(fadeVolumeIn) withObject:nil afterDelay:0.1];
    }
}
@end
