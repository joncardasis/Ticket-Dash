//
//  GizmondiQuizTextBox.m
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 2/11/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#define kNumOfQuestions 10

#import "GizmondiQuizTextBox.h"
#import "JLogging.h"
#import "QuestionsParser.h"

@interface GizmondiQuizTextBox(){
    NSString *titleName;
    int correctAnswers;
}
@property UILabel *scoreLabel;

@end

@implementation GizmondiQuizTextBox

-(id)init{
    self = [super init];
    if(self){
        self.answerButtons = [[NSMutableArray alloc] init];
        self.questions = [[NSDictionary alloc] init];
        self.scoreLabel=[[UILabel alloc] initWithFrame:CGRectMake(922, 31, 68, 36)];
        self.messageFrame = CGRectMake(34, 75, 957, 171);
        self.message.frame = self.messageFrame;
        self.message.numberOfLines=2;//max of 2 lines for the question
        self.currentTeacher=[[Teacher alloc] init];
        titleName=@"Gizmondi";
    }
    return self;
}

-(void)startQuizWithTeacher:(Teacher*)teacher andPlayer:(Player*)player scene:(GameScene*)scene{
    self.currentTeacher=teacher;
    self.currentPlayer=player;
    self.scene=scene;
    [self setup];
    [self addButtonsToView];
    [self setQuestionForProblemNumber:1]; //start with question 1
}


-(void)addButtonsToView{
    for(int i=0; i<4; i++){ //create 4 buttons
        UIButton *answerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        answerButton.titleLabel.font=[UIFont fontWithName:@"Silom" size:29];
        [answerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        answerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        answerButton.titleLabel.numberOfLines=1;
        answerButton.titleLabel.adjustsFontSizeToFitWidth=YES;
        
        if(i<2) //for left answers
            answerButton.frame= CGRectMake(44, 140+(50*i), 445, 40);
        else
            answerButton.frame= CGRectMake(557, 140+(50*(i-2)), 445, 40);
        [answerButton addTarget:self action:@selector(tappedAnswer:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self.answerButtons addObject:answerButton];
        [self.imgView addSubview:answerButton];
    }
}

-(void)setup{
    QuestionsParser *parser = [[QuestionsParser alloc] init];
    self.questions = [[parser getQuestionsAndAnswers] objectForKey:@"Questions"];
    self.scoreLabel.textAlignment=NSTextAlignmentRight;
    correctAnswers=0;
    self.scoreLabel.font=[UIFont fontWithName:@"Silom" size:24];
    self.scoreLabel.text=[NSString stringWithFormat:@"%i/10", correctAnswers];
    self.scoreLabel.textColor=[UIColor colorWithRed:0.639 green:1.000 blue:0.690 alpha:1.000];
    [self.imgView addSubview:self.scoreLabel];
    [self showWithMessage:@" " andTitle:titleName]; //display question
}

-(void)setQuestionForProblemNumber:(NSInteger)number{
    for(UIButton* button in self.answerButtons){ //resets the correct answer
        button.tag=0;
    }
    
    NSDictionary *currentQ = [self.questions objectForKey:[NSString stringWithFormat: @"Question%i", number]];
    
    self.message.text=[currentQ objectForKey:@"Question"];
    
    [(UIButton*)[self.answerButtons objectAtIndex:0] setTitle:[currentQ objectForKey:@"AnswerA"] forState:UIControlStateNormal]; //Answer A
    [(UIButton*)[self.answerButtons objectAtIndex:1] setTitle:[currentQ objectForKey:@"AnswerB"] forState:UIControlStateNormal];
    [(UIButton*)[self.answerButtons objectAtIndex:2] setTitle:[currentQ objectForKey:@"AnswerC"] forState:UIControlStateNormal];
    [(UIButton*)[self.answerButtons objectAtIndex:3] setTitle:[currentQ objectForKey:@"AnswerD"] forState:UIControlStateNormal];
    
    [(UIButton*)[self.answerButtons objectAtIndex:[[currentQ objectForKey:@"CorrectAnswer"] integerValue]] setTag:1]; //1 is a correct answer
    currentQuestion=number;
}


-(void)tappedAnswer: (id)sender{
    currentQuestion++;
    if(currentQuestion>=kNumOfQuestions){ //mini game finished
        for(UIButton* button in self.answerButtons)
            [button removeFromSuperview];
        [self.scoreLabel removeFromSuperview];
        if(correctAnswers>=6){
            self.message.text=[NSString stringWithFormat:@"Hmmm. It seems you scored a %i/10. I'm going to need to make my next test harder.", correctAnswers];
            self.currentTeacher.currentDialog=1;
            [self.scene addToScore:(80*correctAnswers)];
        }
        else{
            self.message.text = [NSString stringWithFormat:@"Wow, that was very pitiful. Although I don't expect much more than a %i/10 from you.", correctAnswers];
            self.currentTeacher.currentDialog=2;
        }
        
        [self.currentPlayer.student.completedQuests addObject:[NSNumber numberWithInt:CompletedQuestGizmondi]];
        self.currentPlayer.student.canBeginMovement=YES; //player can move again
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:4.75];
        return;
    }
    
    if([(UIButton*)sender tag] == 1){
        correctAnswers++;
        self.scoreLabel.text=[NSString stringWithFormat:@"%i/10", correctAnswers];
        DLog(@"correct answer");
    }
    [self setQuestionForProblemNumber:currentQuestion];
    
    
}

@end
