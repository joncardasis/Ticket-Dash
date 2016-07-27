//
//  GameTextBox.m
//  Ticket Dash
//
//  Created by John Cardasis on 1/31/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "GameTextBox.h"
#import "JLogging.h"

#define kPixelsPastScreen 300
#define kWritingSpeed 0.03 //time between each char being printed

@interface GameTextBox()

@end

@implementation GameTextBox

-(id)init{
    self = [super init];
    if(self){
        self.showing=false;
        self.writingTimer=[[NSTimer alloc] init];
        self.messageFrame=CGRectMake(34, 75, 957, 171);
        self.imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textBox.png"]];
        self.imgView.userInteractionEnabled=YES;
        self.message = [[UILabel alloc] initWithFrame:self.messageFrame];
        self.message.textColor=[UIColor whiteColor];
        self.message.font=[UIFont fontWithName:@"Silom" size:24];
        self.message.lineBreakMode=NSLineBreakByTruncatingTail;
        self.message.numberOfLines=5;
        [self.message sizeToFit];//Trims excess area
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(34, 25, 957, 40)];
        self.title.font=[UIFont fontWithName:@"Silom" size:35];
        self.title.textColor=[UIColor whiteColor];
        
        self.message.text=@"";
        self.title.text=@"";
        
        self.frame=CGRectMake(0, [[UIScreen mainScreen] bounds].size.height + kPixelsPastScreen, [[UIScreen mainScreen] bounds].size.width, [UIImage imageNamed:@"textBox.png"].size.height/2);
        self.imgView.frame=CGRectMake(0, 0, [UIImage imageNamed:@"textBox.png"].size.width/2, [UIImage imageNamed:@"textBox.png"].size.height/2);
        
        [self addSubview:self.imgView];
        [self addSubview:self.message];
        [self addSubview:self.title];
    }
    return self;
}

-(void)showWithMessage:(NSString*)message andTitle:(NSString*)title dismisssAfterCompletion:(NSTimeInterval)time{
    [self displayLabelWithMessage:message andTitle:title dismissOnceCompletedWithTime:time];
}

-(void)showWithMessage:(NSString*)message andTitle:(NSString*)title{
    [self displayLabelWithMessage:message andTitle:title dismissOnceCompletedWithTime:-1];//time of -1 means dont dismiss
}

-(void)displayLabelWithMessage:(NSString*)message andTitle:(NSString*)title dismissOnceCompletedWithTime:(NSTimeInterval)time{
    if(self.showing) //if textbox already presented
        return;
    
    self.title.text=title;
    
    self.showing=true;
    [UIView animateWithDuration:0.6
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                        self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y-[UIImage imageNamed:@"textBox.png"].size.height/2 - kPixelsPastScreen, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         if([message length]==0 || message==nil)
                             [NSTimer scheduledTimerWithTimeInterval:(time) target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
                         else{
                         for(int i=0; i<[message length]; i++){
                             float delay = kWritingSpeed*(i+1);
                             NSDictionary *dir = [[NSDictionary alloc]initWithObjectsAndKeys:message, @"message", [NSNumber numberWithInt:i],@"index", nil];
                             [NSTimer scheduledTimerWithTimeInterval:(delay) target:self selector:@selector(writeMessage:) userInfo:dir repeats:NO];
                             
                             if(i==[message length]-1 && time != -1){
                                 [NSTimer scheduledTimerWithTimeInterval:(time + delay) target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
                             }
                             
                         }
                         }
                     }];
}
-(void)writeMessage:(NSTimer*)timer{
    self.writingTimer=timer;
    int index = [[[timer userInfo] objectForKey:@"index"] intValue];
    NSString *message = [[timer userInfo] objectForKey:@"message"];
    self.message.text = [NSString stringWithFormat:@"%@%c", self.message.text, [message characterAtIndex:index]];
    
    /* Vertically align the text */
    self.message.frame = self.messageFrame;
    [self.message sizeToFit];

}

-(void)dismiss{
    [UIView animateWithDuration:0.3
                     animations:^{
                        self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y-kPixelsPastScreen/50, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL completed){
                         [UIView animateWithDuration:0.6
                                          animations:^{
                                              self.frame=CGRectMake(self.frame.origin.x, [[UIScreen mainScreen] bounds].size.height + kPixelsPastScreen, self.frame.size.width, self.frame.size.height);
                                          }
                                          completion:^(BOOL completed){
                                              [self resetTextBox];
                                          }];
                     }];
}

-(void)dismissWithoutAnimation{
     self.frame=CGRectMake(self.frame.origin.x, [[UIScreen mainScreen] bounds].size.height + kPixelsPastScreen, self.frame.size.width, self.frame.size.height);
    [self resetTextBox];
}

-(void)resetTextBox{
    self.showing=false;
    [self.writingTimer invalidate];
    self.writingTimer=nil;
    self.title.text=@"";
    self.message.text=@"";
}
@end
