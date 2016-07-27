//
//  TwinkleStarView.m
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 1/21/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "JLogging.h"
#import "TwinkleStarView.h"
@interface TwinkleStarView()

@end

@implementation TwinkleStarView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self addStarImages];
    }
    return self;
}

-(id)init{
    self=[super init];
    if(self){
        [self addStarImages];
    }
    return self;
}

-(void)addStarImages{
    NSBundle *mainBundle = [NSBundle mainBundle]; //Get resource directory
    NSString *jsonsStr= [mainBundle pathForResource:@"Starpoints" ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonsStr];
    NSError *error =nil;
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error]; //Parse
    
    NSDictionary *dict = [JSONDictionary objectForKey:@"33"];
    for (int i=1; i<=[dict count]; i++){
        UIImageView *star = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star.png"]];
            
        NSDictionary *currentStar = [dict objectForKey:[NSString stringWithFormat: @"Star%i",i]];
        NSArray *JSONSize = [currentStar objectForKey:@"size"];
        NSArray *JSONPosition = [currentStar objectForKey:@"position"];
            
        CGPoint position = CGPointMake([[JSONPosition objectAtIndex:0] floatValue], [[JSONPosition objectAtIndex:1] floatValue]);
        CGSize size = CGSizeMake([[JSONSize objectAtIndex:0] floatValue], [[JSONSize objectAtIndex:1]floatValue]);
            
        [star setFrame:CGRectMake(position.x, position.y, size.width, size.height)];

        
        float randomTime = 0.1*(arc4random()% 20 +30); //value between 4.0 and 5.0
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:star, @"star", [NSNumber numberWithFloat:randomTime], @"time", nil];
        
        [NSTimer scheduledTimerWithTimeInterval:randomTime target:self selector:@selector(animateStar:) userInfo:info repeats:YES]; //randomly starts between 4.0 and 5.0 seconds
        
        [self addSubview:star];
    
    }
    
}

-(void)animateStar:(NSTimer*) timer{
    UIImageView *star =[[timer userInfo] objectForKey:@"star"];
    float time = [[[timer userInfo] objectForKey:@"time"] floatValue];
    float shrinkAmount = 0.75;
    CGRect originalFrame = star.frame;
    [UIView animateWithDuration:time/2
                     animations:^{
                         star.frame = CGRectMake(star.frame.origin.x +(originalFrame.size.width-(star.frame.size.width*shrinkAmount))/2, star.frame.origin.y+(originalFrame.size.width-(star.frame.size.height*shrinkAmount))/2, star.frame.size.width*shrinkAmount, star.frame.size.height*shrinkAmount); //Centers the star from last position
                         star.alpha=0.9;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:time/2 animations:^{star.frame=originalFrame; star.alpha=1;}]; //Reset the values
    }];
}

-(NSArray*)getStarsInView{
    return [self subviews];
}



@end
