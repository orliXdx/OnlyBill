//
//  DatePickerTextField.m
//  yuyueba
//
//  Created by APPLE on 14-8-21.
//  Copyright (c) 2014年 Michael Cheng. All rights reserved.
//

#import "DatePickerTextField.h"

@implementation DatePickerTextField{
    UIToolbar *inputAccessoryView;
}

@synthesize datePicker;
@synthesize currentDate;

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
    [self setUserInteractionEnabled:NO];
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 200, 320, 120)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    self.inputView = datePicker;
    
    /* default selectd item */
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    if (currentDate) {
        [self.datePicker setDate:currentDate];
    }
    else{
        [self setText:[format stringFromDate:[NSDate date]]];
    }
}

#pragma mark - inputAccessoryView with toolbar
- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)done:(id)sender {
    [self resignFirstResponder];
	[super resignFirstResponder];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    [self setText:[format stringFromDate:datePicker.date]];
}

- (UIView *)inputAccessoryView {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return nil;
	} else {
		if (!inputAccessoryView) {
			inputAccessoryView = [[UIToolbar alloc] init];
			inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
			inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			[inputAccessoryView sizeToFit];
			CGRect frame = inputAccessoryView.frame;
			frame.size.height = 30.0f;
			inputAccessoryView.frame = frame;
            
			UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
			UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            
			NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
			[inputAccessoryView setItems:array];
		}
		return inputAccessoryView;
	}
}


@end
