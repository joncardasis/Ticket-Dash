//
//  QuestionsParser.m
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 2/15/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "JLogging.h"
#import "QuestionsParser.h"

@implementation QuestionsParser

-(NSDictionary*)getQuestionsAndAnswers{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *jsonsStr = [mainBundle pathForResource:@"GizmondiQuestions" ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonsStr];
    
    NSError *error =nil;
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error]; //Parse
    
    return JSONDictionary;
}



@end
