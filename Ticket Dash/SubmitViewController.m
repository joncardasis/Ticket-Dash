//
//  SubmitViewController.m
//  Ticket Dash
//
//  Created by John Cardasis on 1/25/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "SubmitViewController.h"
#import "JLogging.h"
#import "CloudConnection.h"
#import "MainMenuViewController.h"
#import "JInfoView.h"

@interface SubmitViewController(){
    int finalScore;
    float orignameVerticalSpaceConstraint;
    float origScoreVerticalSpaceConstraint;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scoreVerticalSpaceConstraint;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) UIView *fadeView;

@end


@implementation SubmitViewController

-(id)init{
    self = [super init];
    if(self){
    }
    return self;
}


-(void)viewDidLoad{
    [super viewDidLoad];
    orignameVerticalSpaceConstraint=self.nameVerticalSpaceConstraint.constant;
    origScoreVerticalSpaceConstraint=self.scoreVerticalSpaceConstraint.constant;
    
    /* Keyboard Observers for animations */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    
    self.fadeView=[[UIView alloc] initWithFrame:self.view.frame];
    self.fadeView.alpha=0;
    [UIView animateWithDuration:0.5 animations:^{
        self.fadeView.alpha=0.6;
    }];
    
    
    /* Make background transparent */
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = YES;
    
    self.submitView.layer.cornerRadius = 12.5; //rounds corners of uiview
    self.submitView.layer.masksToBounds=YES;
    
    if ([self.nameField respondsToSelector:@selector(setAttributedPlaceholder:)]){ //ios 6+ can change placeholder properties
        UIColor *color = [UIColor colorWithRed:200 green:206 blue:217 alpha:0.2];
        self.nameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.nameField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
        self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    }
    
    [self.submitButton addTarget:self action:@selector(submitScore) forControlEvents:UIControlEventTouchUpInside];
    self.submitButton.layer.cornerRadius=4.0;
    self.submitButton.layer.masksToBounds=YES;
    [self.submitButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.268 green:0.777 blue:0.911 alpha:1.000]] forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    CGFloat temp = self.submitViewTopConstraint.constant;
    self.submitViewTopConstraint.constant = 800.0f;
    [self.view layoutIfNeeded];

    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.submitViewTopConstraint.constant = temp;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeSubviewsFromView:self.view];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [UIView animateWithDuration:0.5 animations:^{
        self.fadeView.alpha=1.0;
    } completion:^(BOOL completed){
        [self dismissViewControllerAnimated:NO completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"submitVCdisbanded" object:nil userInfo:nil];
        
    }];
}



-(void)removeSubviewsFromView:(UIView*)view{
    for(UIView* v in [view subviews])
        [v removeFromSuperview];
}

- (IBAction)animateDismissView:(id)sender {
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ //Animate bob up
                         self.submitViewTopConstraint.constant -= 80;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5 animations:^{ //Animate bob down
                             self.submitViewTopConstraint.constant = 800;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL completedAnimation){//Remove from parent vc after animation has completed
                             [self willMoveToParentViewController:nil];
                             [self.view removeFromSuperview];
                             [self removeFromParentViewController];
                         }];
                     }];
}

-(void)setScore:(int)score{
    finalScore = score;
    [self updateScoreLabel];
}

-(void)updateScoreLabel{
    self.scoreLabel.text = [NSString stringWithFormat:@"%@: %i", @"Score", finalScore];
}

- (UIImage *)imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


-(void)submitScore{
    if([self.nameField.text isEqualToString:@""])
        return; //if name is left blank
    DLog(@"Submitting score to server...");
    
    CloudConnection *connection = [[CloudConnection alloc] init];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *values = @{
                             @"Name" : self.nameField.text,
                             @"Score" : [NSNumber numberWithInt:finalScore],
                             @"TimeUploaded" : [NSDate date],
                             @"Email" : self.emailField.text,
                             @"AppVersion" : appVersion,
                             };
    
    BOOL success = [connection uploadToCloudWithValues:values WithCompletionHandler:^{
        DLog(@"Successfully Uploaded Score to Cloudkit!");
    }];
    if(!success){//error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Uploading"
                                                        message:@"Could not upload scores to server. Please check your internet connection and try again."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else{//upload successfull
        self.view.userInteractionEnabled=false; //disables interaction with UI elements
        JInfoView *confirmationAlert = [[JInfoView alloc] initWithType:viewTypeSuccess andMessage:@"Successfully uploaded score to server"];
        [confirmationAlert show];
        [self.view addSubview:confirmationAlert];
        [confirmationAlert dismissAfterDelay:2.0 completion:^{
            [self animateDismissView:self];
        }];
    }
}


#pragma mark ---Keyboard Handling---

-(void)keyboardWillShow{
    //VLog(@"KEYBAORD WILL SHOW!!!");
    DLog(@"%f %f", self.submitViewTopConstraint.constant, self.submitViewHeightConstraint.constant);
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.54
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.submitViewTopConstraint.constant=11;
                         self.submitViewHeightConstraint.constant=365;
                         self.nameVerticalSpaceConstraint.constant=20;
                         self.scoreVerticalSpaceConstraint.constant=25;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}


-(void)keyboardWillHide{
    //DLog(@"KEYBAORD WILL HIDE");
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.54
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.submitViewTopConstraint.constant=109;
                         self.submitViewHeightConstraint.constant=550;
                         self.nameVerticalSpaceConstraint.constant=orignameVerticalSpaceConstraint;
                         self.scoreVerticalSpaceConstraint.constant=origScoreVerticalSpaceConstraint;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}
@end
