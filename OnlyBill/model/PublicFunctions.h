//
//  PublicFunctions.h
//  OnlyBill
//
//  Created by Orientationsys on 14-12-1.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define STATUS_BAR_HEIGHT (20.f)
@class BillObject;

typedef enum {
    IPHONE4_4S = 0,
    IPHONE5_5S,
    IPHONE6,
    IPHONE6_PLUS,
}OSDevice;

@interface PublicFunctions : NSObject

+ (NSInteger)OSVersion;

+ (NSInteger)OSDevice;

/* the animation for view appear or disappear */
+ (void)animationForViewAppearOrDisappear:(UIView *)view Transition:(NSString *)transition Type:(NSString *)type;

/* shaking */
+ (void)shakeAnimationForView:(UIView *)view;

/* get current date (ms) */
+ (NSString *)getCurrentDateByMS;

/* get color by Hex RGB */
+ (UIColor *) colorFromHexRGB:(NSString *) inColorString;

/* get floatValue of string */
+ (float) getFloatValueOfString:(NSString *)floatString;

/* show alertView */
+ (void)showAlertView:(NSString *)title Message:(NSString *)message;

/* color of income */
+ (UIColor *)getIncomeColor;

@end

/* frame of screen */
@interface PublicFunctions (frameOfScreen)
/* get screen */
+ (CGRect)getMainScreen;

+ (float)getXOfMainScreen;

+ (float)getYOfMainScreen;

+ (float)getWidthOfMainScreen;

+ (float)getHeightOfMainScreen;

@end


/* bill manager */
@interface PublicFunctions (billManager)

/* save and get bill list */
+ (BOOL)saveBillList:(NSArray *)billList;
+ (NSArray *)getBillList;

/* save and get selected bill */
+ (BOOL)saveBill:(BillObject *)bill;
+ (BillObject *)getBill;

@end


/* category manager (icon) */
@interface PublicFunctions (categoryManager)

/* save all the categories */
+ (BOOL)saveAllCategoies;

/* get category */
+ (NSString *)getCategory:(NSString *)categoryNumber;

@end


/* picture manager */
@interface PublicFunctions (pictureManager)

+ (void)savePictureWithName:(UIImage *)picture Name:(NSString *)name;
+ (NSData *)getPictureByName:(NSString *)name;

@end
