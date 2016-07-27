//
//  CloudConnection.h
//  Ticket Dash
//
//  Created by John Cardasis on 1/24/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^onCompletion)(void);

@interface CloudConnection : NSObject

-(BOOL)uploadToCloudWithValues: (NSDictionary*) values WithCompletionHandler:(onCompletion) block;

-(NSArray*)getSchoolScores;
-(NSArray*)getWorldScores;

@end
