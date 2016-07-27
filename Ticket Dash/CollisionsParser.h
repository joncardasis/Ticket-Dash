//
//  CollisionsParser.h
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 1/14/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameScene.h"

@interface CollisionsParser : NSObject

-(NSDictionary*)getCollisionsFor: (GameLevel)map;
@end
