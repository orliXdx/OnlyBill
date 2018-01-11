//
//  MainHeaderView.m
//  OnlyBill
//
//  Created by Orientationsys on 14-10-29.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import "MainHeaderView.h"
#import "WaterDropButton.h"

@implementation MainHeaderView

@synthesize delegate;
@synthesize imageView, billNameLabel, menuButton, statisticsButton;
@synthesize inputLabel, outputLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newBackground:) name:@"newBackground" object:nil];
    
    /* set imageView */
    [self setBackgroundImage];
    
    /* init add button */
    [self initAddButtonCircle];
}

/* observe new background */
- (void) newBackground:(NSNotification *)notification
{
    NSString *string = notification.object;
    if (string && self.imageView) {
        [self.imageView setImage:[UIImage imageNamed:string]];
    }
}

/* set background image */
- (void)setBackgroundImage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *image_name = [defaults objectForKey:@"background"];
    if (self.imageView) {
        if (image_name && image_name.length > 0) {
            [self.imageView setImage:[UIImage imageNamed:image_name]];
        }
        else{
            /* set default image */
            [self.imageView setImage:[UIImage imageNamed:@"scenery_1.jpg"]];
        }
    }
}

/* set addButton circle */
- (void)initAddButtonCircle {
    WaterDropButton *add_button = [[WaterDropButton alloc] initWithFrame:CGRectMake(100.f, 100.f, 120.f, 120.f)];
    [add_button setImage:[FontAwesome imageWithIcon:fa_plus iconColor:[UIColor blackColor] iconSize:45.f] forState:UIControlStateNormal];
    add_button.layer.cornerRadius = add_button.frame.size.height/2;
    add_button.layer.masksToBounds = YES;
    add_button.contentMode = UIViewContentModeScaleAspectFill;
    add_button.clipsToBounds = YES;
    add_button.layer.shadowColor = [UIColor blackColor].CGColor;
    add_button.layer.shadowOffset = CGSizeMake(4, 4);
    add_button.layer.shadowOpacity = 0.5;
    add_button.layer.shadowRadius = 2.0;
    add_button.userInteractionEnabled = YES;
    add_button.backgroundColor = [UIColor whiteColor];
    // add target
    [add_button addTarget:self action:@selector(addBillClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:add_button];
}

/* add bill */
- (void)addBillClick:(id)sender
{
    if (delegate) {
        [delegate addBill];
    }
}

/* left menu button click */
- (IBAction)menuClick:(id)sender
{
    /* invoke delegate */
    if (delegate) {
        [delegate leftMenuClick];
    }
}

/* view the stastics */
- (IBAction)stasticsClick:(id)sender
{
    if (delegate) {
        [delegate viewStatistics];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newBackground" object:nil];
}

@end
