//
//  TicketGrabScene.m
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 2/5/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "TicketGrabScene.h"
#import "JLogging.h"

@interface TicketGrabScene(){
    int secondsCount;
    int previousScore;
}
@property (nonatomic) NSTimer* gameTimer;
@property (nonatomic) UILabel *clock;
@property (nonatomic) NSArray* ticketStubs;

@property (nonatomic)GameTextBox* textBox;
@end

@implementation TicketGrabScene

-(id)initWithScore:(int)score{
    self=[super init];
    if(self){
        previousScore=score;
    }
    return self;
}


-(void)startLevel{
    self.textBox = [[GameTextBox alloc] init];
    [self.view addSubview:self.textBox];
    [self.textBox showWithMessage:@"Grab as many ticket stubs as you can!!" andTitle:@"" dismisssAfterCompletion:3.0];
}


-(void)createStubs{
    NSMutableArray *stubs = [[NSMutableArray alloc] init];
    for(int i=0; i<previousScore; i++){
        SKSpriteNode *stub = [[SKSpriteNode alloc] initWithImageNamed:@"textbox.png"];
        //stub.size=CGSizeMake(<#CGFloat width#>, <#CGFloat height#>);
        //stub.position=CGPointMake(<#CGFloat x#>, );
        
        [stubs addObject:stub];
    }
    self.ticketStubs = (NSArray*)stubs;
}


#pragma mark ---- Update -----
-(void)update:(NSTimeInterval)currentTime{
    
}


#pragma mark --- Touch Events ---
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    DLog(@"tocuhes began");
    
}

#pragma mark ---- Game Display Clock -----
-(void)createClock{
    self.clock = [[UILabel alloc] initWithFrame: CGRectMake(CGRectGetMidX(self.view.frame)-(160/2), 25, 160, 62)];
    self.clock.font = [UIFont fontWithName:@"BitBoy" size:60];
    self.clock.text=[NSString stringWithFormat:@"%i:00",kStartWithTime];
    //self.clock.textColor=[UIColor colorWithRed:37/255.0 green:152/255.0 blue:211/255.0 alpha:1.0];
    self.clock.textColor=[UIColor whiteColor];
    [self.clock setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.clock];
    
    secondsCount=kMaxClockTime;
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
}

-(void)updateTimer{
    if(secondsCount<=0){//Game Over
        [self.gameTimer invalidate];
        self.gameTimer=nil;
    }
    else if(secondsCount<=30){
        if(self.gameTimer.timeInterval>0.5){//is interval is over 1/2 sec then make a new timer with shorter time
            [self.gameTimer invalidate];
            self.gameTimer=nil;
            self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES]; //when under 30 sec start counting in ms
            self.clock.textColor= [UIColor colorWithRed:0.773 green:0.000 blue:0.147 alpha:1.000];//set color to red
        }
        int seconds = secondsCount;
        int miliseconds = (secondsCount - floor(secondsCount)) *10;//will only store first num of milisec, accurate time
        secondsCount-=self.gameTimer.timeInterval;
        self.clock.text=[NSString stringWithFormat:@"%i:%02i",seconds,miliseconds*10];
    }
    else{
        int minutes = secondsCount/60;
        int seconds = secondsCount -(minutes*60);
        
        self.clock.text=[NSString stringWithFormat:@"%i:%02i", minutes, seconds];
        secondsCount--; //remove one second
    }
}

@end
