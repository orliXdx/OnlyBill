//
//  DatePickerButton.m
//  OnlyBill
//
//  Created by Orientationsys on 14-12-10.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import "DatePickerButton.h"

@implementation DatePickerButton
{
    UIDatePicker *datePicker;
    UIToolbar *toolBar;
}

@synthesize fatherView;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        [self setTitle:[format stringFromDate:[NSDate date]] forState:UIControlStateNormal];
        
        [self addTarget:self action:@selector(showDatePicker:) forControlEvents:UIControlEventTouchUpInside];
        
        /* set circle cornor */
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:8.f];
        
        /* set border color */
        [self.layer setBorderWidth:1.f];
        [self.layer setBorderColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(), (CGFloat[]){240/255, 244/255, 240/255, 1})];
        
        /* set title color */
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        /* set background */
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

/* show datepPicker */
- (void)showDatePicker:(id)sender
{
    if (fatherView && !toolBar && !datePicker) {
        NSLog(@"father_x:%f, toolbar_y:%f, toolbar_width:%f, toolbar_height:%f", fatherView.frame.origin.x, fatherView.frame.origin.y, fatherView.frame.size.width, fatherView.frame.size.height);
        /* add toolbar */
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, [PublicFunctions getHeightOfMainScreen]-210.f-40.f, [PublicFunctions getWidthOfMainScreen], 40.f)];
        toolBar.barStyle = UIBarStyleBlackTranslucent;
        toolBar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [toolBar sizeToFit];
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneRemove:)];
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [toolBar setItems:array];
        
        NSLog(@"toolbar_y:%f", toolBar.frame.origin.y);
        [fatherView addSubview:toolBar];
        [self showViewWithAnimation:toolBar YPostion:([PublicFunctions getHeightOfMainScreen] - 210.f - 40.f)];
        
        /* add datePicker */
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, [PublicFunctions getHeightOfMainScreen]-210.f, [PublicFunctions getWidthOfMainScreen], 210.f)];
        [datePicker setBackgroundColor:[UIColor whiteColor]];
        datePicker.datePickerMode = UIDatePickerModeDate;
        
        /* default selectd item */
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        [datePicker setDate:[format dateFromString:self.titleLabel.text]];
        
        [self setTitle:[format stringFromDate:datePicker.date] forState:UIControlStateNormal];
        
        NSLog(@"datePicker_y:%f", datePicker.frame.origin.y);
        [fatherView addSubview:datePicker];
        [self showViewWithAnimation:datePicker YPostion:([PublicFunctions getHeightOfMainScreen] - 210.f)];
    }
    // if created
    else{
        [toolBar setHidden:NO];
        CGRect rect_tool_bar = toolBar.frame;
        rect_tool_bar.origin.y = [PublicFunctions getHeightOfMainScreen] - 210.f - 40.f;
        [toolBar setFrame:rect_tool_bar];
        [self showViewWithAnimation:toolBar YPostion:toolBar.frame.origin.y];
        
        [datePicker setHidden:NO];
        CGRect rect_date_picker = datePicker.frame;
        rect_date_picker.origin.y = [PublicFunctions getHeightOfMainScreen] - 210.f;
        [datePicker setFrame:rect_date_picker];
        [self showViewWithAnimation:datePicker YPostion:datePicker.frame.origin.y];
    }
    
}

/* remove the datePicker */
- (void)doneRemove:(id)sender {
    if (fatherView && toolBar && datePicker) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        [self setTitle:[format stringFromDate:datePicker.date] forState:UIControlStateNormal];
        
        [self hideViewWithAnimation:toolBar];

        [self hideViewWithAnimation:datePicker];
    }
}

/* show view with animation */
- (void)showViewWithAnimation:(UIView *)view YPostion:(float)yPosition
{
    CGRect rect_origin = view.frame;
    rect_origin.origin.y = [PublicFunctions getHeightOfMainScreen];
    view.frame = rect_origin;
//    view.alpha = 0.5f;
    
    [UIView animateWithDuration:0.5f animations:^{
        CGRect rect_current = view.frame;
        rect_current.origin.y = yPosition;
        view.frame = rect_current;
//        view.alpha = 1.0f;
    } completion:^(BOOL finished){

    }];
}

/* hide view with animation */
- (void)hideViewWithAnimation:(UIView *)view
{
    [UIView animateWithDuration:0.5f animations:^{
        CGRect rect_current = view.frame;
        rect_current.origin.y = ([PublicFunctions getHeightOfMainScreen]);
        view.frame = rect_current;
    } completion:^(BOOL finished){
        [view setHidden:YES];
    }];
}

- (void)drawRect:(CGRect)rect {
    // draw code
}
         
- (void)dealloc
{
    toolBar = nil;
    datePicker = nil;
}


@end
