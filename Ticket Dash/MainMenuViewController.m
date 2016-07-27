//
//  MainMenuViewController.m
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 1/21/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "JLogging.h"
#import "MainMenuViewController.h"
#import "TwinkleStarView.h"
#import "HighScoresViewController.h"
#import "CreditsViewController.h"
#import  <AVFoundation/AVFoundation.h>

#import "GizmondiQuizTextBox.h"
#import "JInfoView.h"

@interface MainMenuViewController ()
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (strong, nonatomic) TwinkleStarView *stars1;
@property (strong, nonatomic) TwinkleStarView *stars2;
@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.153 green:0.236 blue:0.430 alpha:1.000] CGColor], (id)[[UIColor colorWithRed:0.240 green:0.385 blue:0.593 alpha:1.000] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    
    /* Easter Egg */
    self.stars1 = [[TwinkleStarView alloc] initWithFrame:CGRectMake(355, 33, 0, 0)];
    self.stars2 = [[TwinkleStarView alloc] initWithFrame:CGRectMake(534, 33, 0, 0)];
    self.stars1.alpha=0;
    self.stars2.alpha=0;
    [self.view insertSubview:self.self.stars1 belowSubview:self.ticketImageView];
    [self.view insertSubview:self.stars2 belowSubview:self.ticketImageView];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(show33EasterEgg) userInfo:nil repeats:NO];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.302 green:0.466 blue:0.659 alpha:1.000];

}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self playBackgroundMusic];
    
}

-(void)show33EasterEgg{
    [UIView animateWithDuration:3.0
                     animations:^{
                         self.titleImageView.alpha=0;
                         self.ticketImageView.alpha=0;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:2.0 animations:^{
                             self.stars1.alpha=1;
                             self.stars2.alpha=1;
                             [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(showDefaultTitle) userInfo:nil repeats:NO];
                         }];
                     }];
}

-(void)showDefaultTitle{
    [UIView animateWithDuration:3.0
                     animations:^{
                         self.self.stars1.alpha=0;
                         self.stars2.alpha=0;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:2.0 animations:^{
                             self.titleImageView.alpha=1;
                             self.ticketImageView.alpha=1;
                             [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(show33EasterEgg) userInfo:nil repeats:NO];
                         }];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)prefersStatusBarHidden{
    return true; //Hides statusbar on this vc
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([self.backgroundMusicPlayer isPlaying])
        [self.backgroundMusicPlayer stop];
}

-(void)playBackgroundMusic{
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error];//Prevent Mute switch from stopping audio
    NSURL * backgroundMusicURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Adventure" ofType:@"mp3"]];;
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.backgroundMusicPlayer.numberOfLoops = -1;//infinite loop
    [self.backgroundMusicPlayer prepareToPlay];
    self.backgroundMusicPlayer.volume=0;
    [self.backgroundMusicPlayer play];
    [self fadeVolumeIn];
}

-(void)fadeVolumeIn
{
    if (self.backgroundMusicPlayer.volume < 0.6) { //maxes out the volume at 60%
        self.backgroundMusicPlayer.volume += 0.01;
        [self performSelector:@selector(fadeVolumeIn) withObject:nil afterDelay:0.1];
    }
}

- (IBAction)play:(id)sender {//start playing game
    self.gameViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Game"];
    UIView *transition = [[UIView alloc] initWithFrame:self.view.frame];
    transition.backgroundColor=[UIColor blackColor];
    transition.alpha=0;
    [self.view addSubview:transition];
    
    [UIView animateWithDuration:0.5
                     animations:^{ //do transition animation here
                         transition.alpha=1;
                     }
                     completion:^(BOOL finished){
                         UIView *fade = [[UIView alloc] initWithFrame:self.view.frame]; //Can't make copy of transition since it will unload
                         fade.backgroundColor=[UIColor blackColor];
                         fade.alpha=1;
                         
                         self.gameViewController.scene.backgroundColor = [UIColor blackColor];
                         [self.gameViewController.view addSubview:fade];
                         [self presentViewController:self.gameViewController animated:YES completion:^(void){ //default modal push up animation
                             [UIView animateWithDuration:1.0
                                              animations:^{
                                                  fade.alpha=0;
                                              }
                                              completion:^(BOOL done){
                                                  [fade removeFromSuperview];
                                              }];
                         }];
                     }];
    
}

- (IBAction)showHighScores:(id)sender {
    HighScoresViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"highScores"];
    [vc didMoveToParentViewController:self];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}

- (IBAction)showCredits:(id)sender {
    CreditsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"credits"];
    [vc didMoveToParentViewController:self];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}

@end
