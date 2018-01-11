//
//  PublicFunctions.m
//  OnlyBill
//
//  Created by Orientationsys on 14-12-1.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import "PublicFunctions.h"
#import "BillObject.h"

@implementation PublicFunctions

+ (NSInteger)OSVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

+ (NSInteger)OSDevice
{
    CGSize size = [[UIScreen mainScreen] currentMode].size;
    if (CGSizeEqualToSize(CGSizeMake(640, 1136), size)) {
        return IPHONE5_5S;
    }
    else if (CGSizeEqualToSize(CGSizeMake(640, 1136), size)){
        return IPHONE6;
    }
    else if (CGSizeEqualToSize(CGSizeMake(1080, 1920), size)){
        return IPHONE6_PLUS;
    }
    
    return IPHONE4_4S;
}

/* the animation for view appear or disappear */
+ (void)animationForViewAppearOrDisappear:(UIView *)view Transition:(NSString *)transition Type:(NSString *)type
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:.5f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setType:type];
    [animation setSubtype:transition];
    [view.window.layer addAnimation:animation forKey:nil];
}

/* shaking */
+ (void)shakeAnimationForView:(UIView *)view
{
    CALayer *label = [view layer];
    CGPoint pos_label = [label position];
    CGPoint scale_y = CGPointMake(pos_label.x-8, pos_label.y);
    CGPoint scale_x = CGPointMake(pos_label.x+8, pos_label.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:scale_x]];
    [animation setToValue:[NSValue valueWithCGPoint:scale_y]];
    [animation setDuration:.08f];
    [animation setRepeatCount:2];
    [animation setAutoreverses:YES];
    [label addAnimation:animation forKey:nil];
}

/* get current date(MS) */
+ (NSString *)getCurrentDateByMS
{
    NSDateFormatter *date_fmt = [[NSDateFormatter alloc] init];
    [date_fmt setDateFormat:@"YYYY.MM.dd hh:mm:ss:SSS"];
    NSString *current_seconds = [date_fmt stringFromDate:[NSDate date]];
    
    return current_seconds;
}

/* get Hex RGB */
+ (UIColor *) colorFromHexRGB:(NSString *) inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    
    return result;
}

/* get floatValue of string */
+ (float) getFloatValueOfString:(NSString *)floatString
{
    if (floatString && floatString.length > 0) {
        // '$1.23' -> 1.23f
        if ([[floatString substringToIndex:1] isEqualToString:@"$"]) {
            return [[floatString substringFromIndex:1] floatValue];
        }
        // '1.23' -> 1.23f
        else{
            [floatString floatValue];
        }
    }
    
    return 0.f;
}

/* show alertView */
+ (void)showAlertView:(NSString *)title Message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"", nil];
    
    [alert show];
}

/* color of income */
+ (UIColor *)getIncomeColor
{
    return [UIColor colorWithRed:0 green:120/255.f blue:0 alpha:1.f];
}


@end


/* category frame of screen */
@implementation PublicFunctions (frameOfScreen)

+ (CGRect)getMainScreen
{
    return [[UIScreen mainScreen] bounds];
}

+ (float)getXOfMainScreen
{
    return [UIScreen mainScreen].bounds.origin.x;
}

+ (float)getYOfMainScreen
{
    return [UIScreen mainScreen].bounds.origin.y;
}

+ (float)getWidthOfMainScreen
{
    return [UIScreen mainScreen].bounds.size.width;
}

+ (float)getHeightOfMainScreen
{
    return [UIScreen mainScreen].bounds.size.height;
}

@end


/* bill manager */
@implementation PublicFunctions (billManager)

/* save bill list */
+ (BOOL)saveBillList:(NSArray *)billList
{
    if (billList && billList.count > 0) {
        /* turn to NSData */
        NSMutableArray *bill_data_list = [[NSMutableArray alloc] initWithCapacity:billList.count];
        for (BillObject *bill in billList) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bill];
            [bill_data_list addObject:data];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[NSArray arrayWithArray:bill_data_list] forKey:@"billList"];
        
        return YES;
    }
    
    return NO;
}

+ (NSArray *)getBillList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"billList"]) {
        /* turn to BillObjectList */
        NSMutableArray *bill_list = [[NSMutableArray alloc] initWithCapacity:10];
        NSArray *bill_data_list = [defaults objectForKey:@"billList"];
        for (NSData *data in bill_data_list) {
            [bill_list addObject:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
        }
        
        return bill_list;
    }
    
    return nil;
}


/* save selected bill */
+ (BOOL)saveBill:(BillObject *)bill
{
    if (bill) {
        /* turn to NSData */
        NSData *bill_data = [NSKeyedArchiver archivedDataWithRootObject:bill];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:bill_data forKey:@"bill"];
        
        return YES;
    }
    
    return NO;
}

/* get selected bill */
+ (BillObject *)getBill
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"bill"]) {
        NSData *bill_data = [defaults objectForKey:@"bill"];
        return [NSKeyedUnarchiver unarchiveObjectWithData:bill_data];
    }
    
    return nil;
}

@end


/* category manageer(icons) */
@implementation PublicFunctions (categoryManager)

/* save all the categories */
+ (BOOL)saveAllCategoies
{
    /* categories */
    NSArray *categories = @[@"income", @"common", @"eating", @"fruits", @"snacks", @"live", @"pets", @"films", @"games", @"gamble", @"shopping", @"cards", @"cloth", @"shoes", @"transport", @"digital", @"phone", @"doctor", @"smoking", @"drinking"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (int i=0; i<categories.count; i++) {
        if (![defaults objectForKey:[NSString stringWithFormat:@"%d", i]]){
            [defaults setValue:categories[i] forKey:[NSString stringWithFormat:@"%d", i]];
        }
    }
    
    return YES;
}

/* get category */
+ (NSString *)getCategory:(NSString *)categoryNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:categoryNumber]) {
        return [defaults objectForKey:categoryNumber];
    }
    
    return @"";
}

@end


/* category pictureManager */
@implementation PublicFunctions (pictureManager)

+ (void)savePictureWithName:(UIImage *)picture Name:(NSString *)name
{
    if (picture && name && name.length > 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:UIImageJPEGRepresentation(picture, 0.00001) forKey:name];
    }
}

+ (NSData *)getPictureByName:(NSString *)name
{
    if (name && name.length > 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:name]) {
            return [defaults objectForKey:name];
        }
    }
    
    return nil;
}

@end


