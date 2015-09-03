//
//  JInfoView.m
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 2/7/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "JInfoView.h"
#import "JLogging.h"

@implementation JInfoView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        //[self setupWithType:viewTypeBasic];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        //[self setupWithType:viewTypeBasic];
    }
    return self;
}

-(id)init{
    self=[super init];
    if(self){
        //[self setupWithType:viewTypeBasic];
    }
    return self;
}

-(id)initWithType:(viewType)type andMessage:(NSString*)message{
    self=[super init];
    if(self){
        [self setupWithType:type andMessage:message];
    }
    return self;
}

-(void)setupWithType:(viewType)type andMessage:(NSString*)message{
    self.layer.cornerRadius = 12.5;
    self.layer.masksToBounds=YES;
    self.backgroundColor=[UIColor whiteColor];
    self.opaque = YES;
    
    self.type=type;
    CGSize frameSize = CGSizeMake(350, 350);
    self.frame=CGRectMake(CGRectGetMidX([[UIScreen mainScreen]bounds])-frameSize.width/2, CGRectGetMidY([[UIScreen mainScreen] bounds])-frameSize.height/2, frameSize.width, frameSize.height); //override frame
    
    /* Setup UILabels */
    self.message=[[UILabel alloc] init];
    self.message.textAlignment=NSTextAlignmentCenter;
    self.message.numberOfLines=3;
    self.message.text=message;
    self.message.textColor=[UIColor colorWithWhite:0.504 alpha:1.000];
    self.message.font=[UIFont fontWithName:@"AvenirNext-DemiBold" size:24];
    self.message.alpha=0;
    CGSize messageSize = CGSizeMake(self.frame.size.width/1.25, self.frame.size.height/3);
    self.message.frame=CGRectMake(self.frame.size.width/2 - messageSize.width/2, self.frame.size.height- messageSize.height - 20 ,messageSize.width, messageSize.height);
    
    
    CGSize size = CGSizeMake(25, 25);
    CGRect displayFrame= CGRectMake(self.frame.size.width/2 - size.width/2, self.frame.size.height/3.5 - size.height/2, size.width, size.height);
    self.displayImage=[[UIImageView alloc] initWithFrame:displayFrame];
    self.displayImage.alpha=0;
    
    switch (type) {
        case viewTypeSuccess:
            self.displayImage.image=[UIImage imageNamed:@"success.png"];
            break;
            
        default:
            DLog(@"No implementation for viewType: %i yet", type);
            break;
    }
    [self addSubview:self.displayImage];
    [self addSubview:self.message];
}

-(void)show{
    CGSize newSize = CGSizeMake(125, 125);
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.message.alpha=1.0;
                         self.displayImage.alpha=1.0;
                     }];
    
    [UIView animateWithDuration:1.0 //This animation will happen while above is also occuring
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.displayImage.frame= CGRectMake(self.frame.size.width/2 - newSize.width/2, self.frame.size.height/3.5 - newSize.height/2, newSize.width, newSize.height);
                     }
                     completion:^(BOOL completed){
                         
                     }];
}


-(void)dismissWithCompletion: (onCompletion) block{
    CGSize newSize = CGSizeMake(25, 25); //original size
    [UIView animateWithDuration:0.75
                     animations:^{
                         self.displayImage.alpha=0.0;
                     }];
    
    CGSize bloatSize = CGSizeMake(self.displayImage.frame.size.width*1.2, self.displayImage.frame.size.height*1.2);
    /* Animate bob out effect for imageView */
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.displayImage.frame= CGRectMake(self.frame.size.width/2 - bloatSize.width/2, self.frame.size.height/3.5 - bloatSize.height/2, bloatSize.width, bloatSize.height);
                     }completion:^(BOOL completed){
                         [UIView animateWithDuration:0.8
                                          animations:^{
                                              self.displayImage.frame= CGRectMake(self.frame.size.width/2 - newSize.width/2, self.frame.size.height/3.5 - newSize.height/2, newSize.width, newSize.height);
                                              self.message.alpha=0;
                                          }
                                          completion:^(BOOL completed){
                                              [self dismissViewWithAnimation];
                                              block();
                                          }];
                     }];
}

-(void)dismissViewWithAnimation{
    CGSize bloatSize = CGSizeMake(self.frame.size.width*1.2, self.frame.size.height*1.2);
    CGSize minSize = CGSizeMake(100, 100);
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.frame=CGRectMake(CGRectGetMidX([[UIScreen mainScreen]bounds])-bloatSize.width/2, CGRectGetMidY([[UIScreen mainScreen] bounds])-bloatSize.height/2, bloatSize.width, bloatSize.height);
                     }completion:^(BOOL completed){
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              self.alpha=0;
                                              self.frame=CGRectMake(CGRectGetMidX([[UIScreen mainScreen]bounds])-minSize.width/2, CGRectGetMidY([[UIScreen mainScreen] bounds])-minSize.height/2, minSize.width, minSize.height);
                                          }completion:^(BOOL completed){
                                              [self removeFromSuperview];
                                          }];
                     }];

}

-(void)dismissAfterDelay:(CFTimeInterval)time completion:(onCompletion) block{
    if(block == nil)
        [self performSelector:@selector(dismissWithCompletion:) withObject:^{} afterDelay:time];
    else
        [self performSelector:@selector(dismissWithCompletion:) withObject:block afterDelay:time];
}
-(void)dismiss{
    [self dismissWithCompletion:nil];
}

- (void)drawRect:(CGRect)rect {/*
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    if(self.type==viewTypeSuccess){
        CGContextSetFillColorWithColor(contextRef, [UIColor colorWithRed:1.000 green:0.423 blue:0.830 alpha:1.000].CGColor);
        CGContextFillEllipseInRect(contextRef, self.displayImage.frame);
        
        self.displayImage.image= UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }*/
}
@end
