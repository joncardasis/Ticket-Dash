//
//  TicketGrabScene.h
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 2/5/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameTextBox.h"

#define kStartWithTime 1 //play time in minutes
#define kMaxClockTime kStartWithTime*60

@interface TicketGrabScene : SKScene


-(void)startLevel;

@end
