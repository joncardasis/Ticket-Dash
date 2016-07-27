//
//  GameViewController.m
//  Ticket Dash
//
//  Created by John Cardasis on 12/20/14.
//  Copyright (c) 2014 John Cardasis. All rights reserved.
//

#import "JLogging.h"
#import "GameViewController.h"
#import "SubmitViewController.h"
#import "MainMenuViewController.h"

#define SHOW_DEBUG_INFO 1

@interface GameViewController()

@property (nonatomic, strong)SKView * skView;

@end



@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameFinished:) name:@"gameFinished" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitVCdisbanded:) name:@"submitVCdisbanded" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.scene.currentGameLevel=GameLevelSchool;//sets begining level for the game
    
    [GameScene loadSceneAssetsWithCompletionHandler:^{
        self.skView = (SKView *)self.view; //cast the default view into a spritekit view
        //skView.showsFPS = YES;//debug
        //skView.showsNodeCount = YES;//debug
        //skView.ignoresSiblingOrder = YES; //speeds up render times by ignoring hyarcy
        
        CGSize viewSize = self.view.bounds.size;
        
        /* Set up scene object */
        //self.scene.scaleMode=SKSceneScaleModeResizeFill;
        self.scene.scaleMode=SKSceneScaleModeAspectFill;
        self.scene = [[GameScene alloc] initWithSize:CGSizeMake(viewSize.width*0.35, viewSize.height*0.35)]; //sets zoom level
        
        //Present the Scene
        [self.skView presentScene:self.scene];
        
        
        [self startGameWithCharacter:StudentTypeSenior];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)gameFinished:(NSNotification*)notification
{
    DLog(@"Game Finished Notification recieved");
    NSNumber *recievedScore = [[notification userInfo] valueForKey:@"finalScore"];
    uint32_t score = recievedScore.intValue;
    
    SubmitViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"submit"];
    [vc didMoveToParentViewController:self];
    
    
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc setScore:score];
}


-(void)submitVCdisbanded:(NSNotification*)notification{
    /* Remove SKScene from view */
    [self.scene removeAllChildren];
    [self.scene removeFromParent];
    [self.scene.backgroundMusicPlayer stop]; //stop playing music
    self.scene.backgroundMusicPlayer= nil;
    
    MainMenuViewController *mainMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"Main Menu"];
    mainMenu.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:mainMenu animated:YES completion:nil];
}

-(void)startGameWithCharacter: (StudentType)type{
    [self.scene setDefaultStudentType:type];
    [self.scene startLevel];
}

@end
