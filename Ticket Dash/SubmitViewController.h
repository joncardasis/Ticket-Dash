//
//  SubmitViewController.h
//  Ticket Dash
//
//  Created by John Cardasis on 1/25/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubmitViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *submitView;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;


-(void)setScore:(int)score;

@end
