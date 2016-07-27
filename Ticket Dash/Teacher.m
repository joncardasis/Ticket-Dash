//
//  Teacher.m
//  Ticket Dash
//
//  Created by John Cardasis on 1/8/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "JLogging.h"
#import "Teacher.h"

@implementation Teacher

-(id)initWithTeacher:(NSString*)name atPosition:(CGPoint)position{
    SKTextureAtlas *atlas;
    SKTexture *texture;
    if([name isEqualToString:@"Stuart"]){
        atlas = [SKTextureAtlas atlasNamed:@"Stuart"];
        texture = [atlas textureNamed:@"Stuart_001.png"];
    }
    else if ([name isEqualToString:@"Gizmondi"]){
        atlas = [SKTextureAtlas atlasNamed:@"Gismondi_Standing"];
        texture = [atlas textureNamed:@"Gismondi_00.png"];
    }
    else{ //default teacher is Staurt
        atlas = [SKTextureAtlas atlasNamed:@"Stuart"];
        texture = [atlas textureNamed:@"Stuart_001.png"];
    }
    
    self=[super initWithTexture:texture atPosition:position];
    
    if(self){
        self.name=name;
        self.dialog=[[NSMutableArray alloc] init];
        self.currentDialog=0;
        texture.filteringMode = SKTextureFilteringNearest;
        [self assignDialogForTeacherNamed:name];
    }
    return self;
}

-(id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position{
    self = [super initWithTexture:texture atPosition:position];
    if(self){
        self.name =@"Teacher"; //gives name to the node
    }
    
    return self;
}

-(void)assignDialogForTeacherNamed:(NSString*)teacher{
    /* standard dialog is assigned into an array which is read as follows:
        -When the student talks for the first time
        -quest not completed but talked to again
        -quest completed
        -quest completed and talked to again */
    if([teacher isEqualToString:@"Stuart"]){
        [self.dialog addObject: @"Hello. My name is Mrs. Stuart. I seem to have misplaced my lasso. I may have left it in Mrs.Levens room when I was on  the computer. If you can bring it back to me I'll buy 5 drive books off of you."]; //dialog 0
        
        [self.dialog addObject:@"Did you happen to find my lasso yet?"];
        [self.dialog addObject:@"Oh my! My lasso! Thank you so much for finding it. As agreed I'll buy 5 drive books from you."];
        [self.dialog addObject:@"Shouldn't you be in class right now?"]; //dialog 3
    }
    
    else if ([teacher isEqualToString:@"Gizmondi"]){
        [self.dialog addObject:@"I bet you can’t beat me in a trivia battle. If you can get a passing grade, I will buy quota from you. If you lose, however, you have to stand with your nose to the board for a week."];
        
        [self.dialog addObject:@"Well I suppose you won. So as agreed I will buy quota from you."];//just won
        
        [self.dialog addObject:@"Haha! Next time make sure you have the testicular fortitude to challange me!"]; //just lost
        
        [self.dialog addObject:@"Get out of here before I bring out the old war axe."]; //done with quest
        
        
    }
}


#pragma mark --Physics and Collision Handling---
-(void)configurePhysicsBody{
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.texture.size];
    
    self.physicsBody.allowsRotation=NO;//Prevents rotation of player around objects
    self.physicsBody.affectedByGravity=NO;
    self.physicsBody.categoryBitMask=ColliderTypeTeacher;
    self.physicsBody.dynamic=NO;
    
    /*Objects that the teacher will collide with*/
    self.physicsBody.collisionBitMask= ColliderTypeWall | ColliderTypeTeacher | ColliderTypeStudentPlayer;
    
    self.physicsBody.contactTestBitMask= ColliderTypeTeacher | ColliderTypeWall | ColliderTypeStudentPlayer; //Gives notifications for colliding with these objects
}

-(void)collidedWith:(SKPhysicsBody *)other{
    
}

@end
