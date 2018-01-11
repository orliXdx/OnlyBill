//
//  DatePickerTextField.h
//  yuyueba
//
//  Created by APPLE on 14-8-21.
//  Copyright (c) 2014年 Michael Cheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerTextField : UITextField<UITextFieldDelegate>

@property UIDatePicker *datePicker;

@property (nonatomic, strong) NSDate *currentDate;

@end
