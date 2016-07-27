//
//  GameTextBox.h
//  Ticket Dash
//
//  Created by John Cardasis on 1/31/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameTextBox : UIView
@property (nonatomic) UIImageView *imgView;
@property (nonatomic) NSTimer *writingTimer;
@property (nonatomic) CGRect messageFrame;
@property (strong, nonatomic) UILabel* title;
@property (strong, nonatomic) UILabel* message;
@property (nonatomic, getter=isShowing)BOOL showing;

-(void)showWithMessage:(NSString*)message andTitle:(NSString*)title;
-(void)showWithMessage:(NSString*)message andTitle:(NSString*)title dismisssAfterCompletion:(NSTimeInterval)time;
-(void)dismiss;
-(void)dismissWithoutAnimation;
@end
