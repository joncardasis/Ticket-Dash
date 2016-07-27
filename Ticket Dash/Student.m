//
//  Student.m
//  Ticket Dash
//
//  Created by John Cardasis on 12/22/14.
//  Copyright (c) 2014 John Cardasis. All rights reserved.
//

#import "JLogging.h"
#import "Student.h"
#import "GameScene.h"
#import "Teacher.h"

@implementation Student

-(id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position withPlayer: (Player*)player{
    self = [super initWithTexture:texture atPosition:position];
    if(self){
        _player = player;
        self.name =@"Student"; //gives name to the node
        self.completedQuests=[[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark --Physics and Collision Handling---
-(void)configurePhysicsBody{
    //Sets the hitbox of the character
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size.width/2.5, self.size.height/2) center:CGPointMake(0, 0-self.size.height/4)];
    /*Hitbox set to be about the lower half of character and not including the arms*/
    
    self.physicsBody.allowsRotation=NO;//Prevents rotation of player around objects
    self.physicsBody.affectedByGravity=NO;
    
    self.physicsBody.categoryBitMask=ColliderTypeStudentPlayer; //Sets the type of bitmask
    
    /*Objects that our player will collide with*/
    self.physicsBody.collisionBitMask= ColliderTypeWall | ColliderTypeDoor | ColliderTypeTeacher | ColliderTypeDoorLabel | ColliderTypeLadder | ColliderTypeItem;
    
    self.physicsBody.contactTestBitMask= ColliderTypeTeacher | ColliderTypeWall | ColliderTypeDoor | ColliderTypeDoorLabel | ColliderTypeItem | ColliderTypeTicket; //Gives notifications for colliding with these objects
}

-(void)collidedWith:(SKPhysicsBody *)other{
    NSString *nodeName = other.node.name;
    GameScene *scene = (GameScene*)self.scene;
    self.collided=YES;
    CGPoint position = self.position;
    
    if(other.categoryBitMask == ColliderTypeWall){//If player ran into a wall
        //DLog(@"WALL!!!");
        self.player.movementTouch=nil;
        self.player.moveRequested=NO;
        self.walking=FALSE;
        self.position=position;
    }
    else if (other.categoryBitMask == ColliderTypeDoor){
        /* Set the destination location */
        if ([nodeName isEqualToString:@"School"])
            scene.gameLevelToLoad=GameLevelSchool; //will get updated on next frame update
        else if ([nodeName isEqualToString:@"Classroom"])
            scene.gameLevelToLoad=GameLevelClassroom;
        else if([nodeName isEqualToString:@"Stuart"])
            scene.gameLevelToLoad=GameLevelStuart;
        else if([nodeName isEqualToString:@"Gizmondi"])
            scene.gameLevelToLoad=GameLevelGizmondi;
        else if([nodeName isEqualToString:@"Levens"])
            scene.gameLevelToLoad=GameLevelLevens;
        else if ([nodeName isEqualToString:@"Track"])
            scene.gameLevelToLoad=GameLevelTrack;
        
        [scene runAction:[SKAction playSoundFileNamed:@"door open.wav" waitForCompletion:NO]];
        //DLog(@"DOOR!!!!");
    }
    else if (other.categoryBitMask == ColliderTypeDoorLabel){
        [scene doorLabelWithNameTouched:nodeName];
    }
    else if(other.categoryBitMask == ColliderTypeTeacher){//ran into teacher
        [scene collidedWithTeacher:(Teacher*)other.node];
        self.currentTeachersQuest=nodeName;
    }
    else if(other.categoryBitMask ==ColliderTypeItem){
        DLog(@"Grabbed Lasso");
        [scene.textBox showWithMessage:@"You found a lasso!" andTitle:@"" dismisssAfterCompletion:1.0];
        self.item=GameItemLasso;
    }
    else if(other.categoryBitMask == ColliderTypeTicket){
        [scene runAction:[SKAction playSoundFileNamed:@"collect ticket.wav" waitForCompletion:NO]];//Play sound
        if([nodeName isEqualToString: @"blueTicket"])
            [scene addToScore:10];//blue ticket worth
        else if ([nodeName isEqualToString:@"redTicket"])
            [scene addToScore:50];
        else if ([nodeName isEqualToString:@"goldTicket"])
            [scene addToScore:100];
        
        //play collection sound
        [scene removeNode:other.node atWorldLayer:WorldLayerGround]; //remove the ticket
    }
}


@end
