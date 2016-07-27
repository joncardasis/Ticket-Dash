//
//  Teacher.h
//  Ticket Dash
//
//  Created by John Cardasis on 1/8/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "DriveCharacter.h"



@interface Teacher : DriveCharacter

@property (nonatomic)NSMutableArray* dialog;
@property (nonatomic)int currentDialog;//an int from 0-infinity of sets of dialog

-(id)initWithTeacher:(NSString*)name atPosition:(CGPoint)position;
-(id)initWithTexture:(SKTexture *)texture atPosition:(CGPoint)position;

@end
