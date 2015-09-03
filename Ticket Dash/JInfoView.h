//
//  JInfoView.h
//  Ticket Dash
//
//  Created by Jonathan Cardasis on 2/7/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : uint8_t {
    viewTypeBasic,
    viewTypeSuccess,
    viewTypeFailed,
    viewTypeWarning,
} viewType;

typedef void(^onCompletion)(void);

@interface JInfoView : UIView
@property (nonatomic) viewType type;
@property (nonatomic) UILabel *message;
//@property (nonatomic) UILabel *title;
@property (nonatomic, strong) UIImageView *displayImage;

-(id)initWithType:(viewType)type andMessage:(NSString*)message;
-(void)dismiss;
-(void)dismissAfterDelay:(CFTimeInterval)time completion:(onCompletion) block;
-(void)show;
@end
