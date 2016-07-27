//
//  HighScoresViewController.h
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 1/29/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighScoresViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *highScoreView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *scoreView;


- (IBAction)animateDismissView:(id)sender;
- (IBAction)showWorldScores:(id)sender;
- (IBAction)showSchoolScores:(id)sender;

@end
