//
//  CreditsViewController.m
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 2/4/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "CreditsViewController.h"
#import "JLogging.h"

@interface CreditsViewController ()
@property (weak, nonatomic) IBOutlet UIView *creditsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *creditsViewTopConstraint;

@end

@implementation CreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = YES;
    self.creditsView.layer.cornerRadius = 12.5;
    self.creditsView.layer.masksToBounds=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    CGFloat origSpace = self.creditsViewTopConstraint.constant;
    self.creditsViewTopConstraint.constant = 800.0f;
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.7
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.creditsViewTopConstraint.constant = origSpace;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (IBAction)animateDismissView:(id)sender {
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.creditsViewTopConstraint.constant -= 80;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3 animations:^{
                             self.creditsViewTopConstraint.constant = 800;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL completedAnimation){//Remove from parent vc after animation has completed
                             [self willMoveToParentViewController:nil];
                             [self.view removeFromSuperview];
                             [self removeFromParentViewController];
                         }];
                     }];
}

@end
