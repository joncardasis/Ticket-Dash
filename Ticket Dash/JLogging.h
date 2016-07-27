//
//  JLogging.h
//  Ticket Dash
//
//  Created by John Cardasis on 1/23/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#ifndef Ticket_Dash_JLogging_h
#define Ticket_Dash_JLogging_h

/* If the app is not being compiled for debug then do not compile the DLog and VLog Statements */
# define ALog(format, ...) NSLog(__VA_ARGS__); //Always log this func no matter compiler settings

#ifdef DEBUG
    #define DLog(...) NSLog(__VA_ARGS__)
    #define VLog(...)NSLog(@"%s [Line:%d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__]) // Detailed logging
#else
    #define DLog(...) 
    #define VLog(...)
#endif

#endif
