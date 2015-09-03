//
//  GizmondiQuizTextBox.h
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 2/11/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "GameTextBox.h"
#import "Teacher.h"
#import "Player.h"
#import "Student.h"
#import "GameScene.h"

@interface GizmondiQuizTextBox : GameTextBox{
    int currentQuestion;
}

@property (nonatomic) UILabel *answersCount; //displays the correct answers
@property (nonatomic) NSDictionary *questions;
@property (nonatomic) NSMutableArray *answerButtons;
@property (nonatomic) Teacher *currentTeacher;
@property (nonatomic) Player *currentPlayer;
@property (nonatomic) GameScene *scene;

-(void)startQuizWithTeacher:(Teacher*)teacher andPlayer:(Player*)player scene:(GameScene*)scene;

@end
