//
//  Player.h
//  Ticket Dash
//
//  Created by John Cardasis on 12/20/14.
//  Copyright (c) 2014 John Cardasis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kStartHealth 100 //health for character



@class Student;

@interface Player : NSObject


@property (nonatomic) Student* student;
@property (nonatomic) Class studentClass; //defines what type of class the player is


/* Movements for DPad --Unimplimented--
@property (nonatomic) BOOL moveUp;
@property (nonatomic) BOOL moveLeft;
@property (nonatomic) BOOL moveRight;
@property (nonatomic) BOOL moveDown;*/


//data that the player holds
@property (nonatomic) uint8_t livesLeft;
@property (nonatomic) uint32_t score;



//ios touch events
@property (nonatomic) UITouch *movementTouch; //track if touch is fired
@property (nonatomic) CGPoint targetLocation; //new touch location
@property (nonatomic) BOOL moveRequested; //request a movement for the player

@end
