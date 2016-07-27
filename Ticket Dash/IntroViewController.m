//
//  IntroViewController.m
//  Ticket Dash
//
//  Created by John Cardasis on 1/31/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "IntroViewController.h"
#import "JLogging.h"
#import "MainMenuViewController.h"

@interface IntroViewController(){
    MainMenuViewController *mainMenu;
}
@property (strong, nonatomic) UIImageView* titleImageView;
@property (strong, nonatomic) UIImageView* ticketImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ticketWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopSpaceConstraint;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.185 green:0.304 blue:0.521 alpha:1.000];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    mainMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"Main Menu"];
    
    float origTitleWidth = self.titleWidthConstraint.constant;
    float origTicketWidth = self.ticketWidthConstraint.constant;
    float origTopSpace = self.titleTopSpaceConstraint.constant;
    
    self.titleWidthConstraint.constant *= 2.5;
    self.ticketWidthConstraint.constant *=7;
    self.titleTopSpaceConstraint.constant=200;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:2.0
                          delay:0.0
                          usingSpringWithDamping:0.6
                          initialSpringVelocity:0.3
                          options:UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                              self.titleWidthConstraint.constant=origTitleWidth;
                              self.ticketWidthConstraint.constant=origTicketWidth;
                              [self.view layoutIfNeeded];
                          }
                          completion:^(BOOL finished){//Move up
                              [self.view layoutIfNeeded];
                              [UIView animateWithDuration:0.75 animations:^{
                                  self.titleTopSpaceConstraint.constant=origTopSpace;
                                  [self.view layoutIfNeeded];
                              } completion:^(BOOL finished){ //once all animation have completed
                                  [self presentMainMenu];
                              }];
                          }];
}

-(BOOL)prefersStatusBarHidden{
    return true; //Hides statusbar on this vc
}

-(void)presentMainMenu{
    DLog(@"Presenting Main Menu...");
    [self dismissViewControllerAnimated:NO completion:nil];
    mainMenu.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:mainMenu animated:YES completion:nil];
}
@end
