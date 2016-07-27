//
//  Player.m
//  Ticket Dash
//
//  Created by John Cardasis on 12/20/14.
//  Copyright (c) 2014 John Cardasis. All rights reserved.
//

#import "Player.h"
#import "JLogging.h"

@implementation Player

-(id)init{
    self=[super init];
    if(self){
        _livesLeft = kStartHealth;
        
        _studentClass = NSClassFromString(@"Senior"); //defaults a player to a senior
    }
    
    return self;
}

@end
