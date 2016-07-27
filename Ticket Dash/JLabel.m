//
//  JLabel.m
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 2/2/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "JLabel.h"

@implementation JLabel

/* Draws a white border around text */
- (void)drawTextInRect:(CGRect)rect {
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 6.5);
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = [UIColor whiteColor];
    
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    
    [super drawTextInRect:rect];
    self.shadowOffset = shadowOffset;
}

@end
