//
//  MainMenuViewController.h
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 1/21/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//
#import "GameViewController.h"
#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController

@property (strong, nonatomic) GameViewController *gameViewController;

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ticketImageView;
- (IBAction)play:(id)sender;
- (IBAction)showHighScores:(id)sender;
- (IBAction)showCredits:(id)sender;

@end
