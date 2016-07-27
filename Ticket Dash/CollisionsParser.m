//
//  CollisionsParser.m
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 1/14/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "JLogging.h"
#import "CollisionsParser.h"

@implementation CollisionsParser

-(NSDictionary*)getCollisionsFor: (GameLevel)map{
    NSBundle *mainBundle = [NSBundle mainBundle]; //Get resource directory
    NSString *jsonsStr;
    
    
    if(map==GameLevelSchool)
        jsonsStr= [mainBundle pathForResource:@"SchoolCollisions" ofType:@"json"];
    
    else if(map==GameLevelClassroom || map==GameLevelGizmondi || map==GameLevelStuart)
        jsonsStr= [mainBundle pathForResource:@"ClassroomCollisions" ofType:@"json"];
    
    else if(map==GameLevelLevens)
        jsonsStr= [mainBundle pathForResource:@"LevensCollisions" ofType:@"json"];
    
    else if(map==GameLevelTrack)
        jsonsStr = [mainBundle pathForResource:@"TrackCollisions" ofType:@"json"];
    
    else
        DLog(@"[COLLISION ERROR] Error in assigning level to collisons");
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonsStr];
    NSError *error =nil;
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error]; //Parse
    
    return JSONDictionary;
}

@end
