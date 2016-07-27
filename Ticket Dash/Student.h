//
//  Student.h
//  Ticket Dash
//
//  Created by John Cardasis on 12/22/14.
//  Copyright (c) 2014 John Cardasis. All rights reserved.
//


@class Player;
#import "DriveCharacter.h"

/* Game items for a student */
typedef enum : uint8_t {
    GameItemNone =0,
    GameItemLasso,
} GameItem;

typedef enum : uint8_t {
    CompletedQuestStuart,
    CompletedQuestMagni,
    CompletedQuestGizmondi,
} CompletedQuest;

@interface Student : DriveCharacter

@property (nonatomic, weak) Player *player; //will allow for the spritenode to be controlled
@property (nonatomic, getter=isCollidedWithObject) BOOL collided;
@property (nonatomic)NSString* currentTeachersQuest;
@property (nonatomic)NSMutableArray* completedQuests;

/* Item properties, currently a player can only hold 1 item */
@property (nonatomic)GameItem item;

-(id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position withPlayer:(Player*)player;


@end
