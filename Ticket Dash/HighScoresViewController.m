//
//  HighScoresViewController.m
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 1/29/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "JLogging.h"
#import "HighScoresViewController.h"
#import "CloudConnection.h"

#define WorldScoreTable 1
#define SchoolScoreTable 2

@interface HighScoresViewController (){
    BOOL visible;
}
@property (nonatomic) NSArray* worldScores;
@property (nonatomic) NSArray* schoolScores;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scoreViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *selectionMenu;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectionViewSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIView *selectionView;

@property (nonatomic)UIImageView *easterEgg;
@end

@implementation HighScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = YES;
    self.scoreView.layer.cornerRadius = 12.5;
    self.scoreView.layer.masksToBounds=YES;
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor= [UIColor colorWithRed:0.116 green:0.183 blue:0.394 alpha:1.000];
    
    self.selectionView.layer.cornerRadius=7.5;
    self.selectionView.layer.masksToBounds=YES;
    
    self.tableView.tag=WorldScoreTable;//Set default table to show
    
    /* Easter Egg */
    self.easterEgg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OneTrueGaffy.png"]];
    CGSize easterEggSize = CGSizeMake(65, 65);
    self.easterEgg.frame=CGRectMake(self.tableView.frame.size.width/2 - easterEggSize.width/2, -165, easterEggSize.width, easterEggSize.height);
    self.easterEgg.layer.magnificationFilter = kCAFilterNearest;
    self.easterEgg.hidden=YES;
    [self.tableView addSubview:self.easterEgg];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    CGFloat temp = self.scoreViewTopConstraint.constant;
    self.scoreViewTopConstraint.constant = 800.0f;
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.7
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.scoreViewTopConstraint.constant = temp;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getScores];
    visible=true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    visible=false;
    self.worldScores = nil;
    self.schoolScores = nil;
    self.easterEgg.image=nil;
    self.easterEgg=nil;
}
#pragma mark -----TableView DataSource----

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView.tag==WorldScoreTable)
        return [self.worldScores count];
    
    else if(tableView.tag==SchoolScoreTable){
        return [self.schoolScores count];
    }
    
    else //Future impliment a message stating the scores could not be gotten
        return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ScoreCell";
    NSArray *scores;
    if(tableView.tag==WorldScoreTable)
        scores=self.worldScores;
    else{
        scores=self.schoolScores;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

    
    
    // Configure Cell Labels
    UILabel *entryLabel = (UILabel *)[cell.contentView viewWithTag:20];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:21];
    UILabel *scoreLabel = (UILabel *)[cell.contentView viewWithTag:22];
    [entryLabel setText:[NSString stringWithFormat:@"%i", (int)indexPath.row+1]];
    [nameLabel setText:[[scores objectAtIndex:indexPath.row] objectForKey:@"Name"]];
    [scoreLabel setText:[NSString stringWithFormat:@"%@", [[scores objectAtIndex:indexPath.row] objectForKey:@"Score"]]];
    
    if(indexPath.row%2==0)//change attributes of every other row
        cell.contentView.backgroundColor= [UIColor colorWithRed:0.154 green:0.252 blue:0.472 alpha:1.000];
    else
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.013 green:0.159 blue:0.292 alpha:1.000];
    
    return cell;
}

- (IBAction)animateDismissView:(id)sender {
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ //Pull Up
                         self.scoreViewTopConstraint.constant -= 40;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.35 animations:^{ //Push Down
                             self.scoreViewTopConstraint.constant = 800;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL completedAnimation){
                             [self willMoveToParentViewController:nil];
                             [self.view removeFromSuperview];
                             [self removeFromParentViewController];
                         }];
                     }];
}

#pragma mark -- Handle Scores ---
- (IBAction)showWorldScores:(id)sender {
    if(self.selectionView.frame.origin.x >= self.scoreView.frame.size.width/2){
        self.easterEgg.hidden=YES;
        self.tableView.tag=WorldScoreTable;
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.8
                          delay:0.0
                          usingSpringWithDamping:0.5
                          initialSpringVelocity:0.3
                          options:UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                              self.selectionViewSpaceConstraint.constant+=self.selectionView.frame.size.width;
                              [self.view layoutIfNeeded];
                          }
                          completion:nil];
        [self.tableView reloadData];
    }
}

- (IBAction)showSchoolScores:(id)sender {
    if(self.selectionView.frame.origin.x < self.scoreView.frame.size.width/2){
        self.easterEgg.hidden=NO;
        self.tableView.tag=SchoolScoreTable;
        [UIView animateWithDuration:0.8
                          delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.3
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.selectionViewSpaceConstraint.constant-=self.selectionView.frame.size.width;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
        [self.tableView reloadData];
    }
}

-(void)getScores{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CloudConnection *connection = [[CloudConnection alloc] init];
        
        self.schoolScores = [connection getSchoolScores];
        self.worldScores  = [connection getWorldScores];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.schoolScores ==nil || self.worldScores == nil) { //failed to get the scores
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"There was an error in recieving some of the scores. Please check Settings to insure Wifi is enabled."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            [self.tableView reloadData];
        });
    });

}
@end
