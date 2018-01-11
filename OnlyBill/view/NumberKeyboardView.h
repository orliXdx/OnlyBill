//
//  NumberKeyboardView.h
//  OnlyBill
//
//  Created by Orientationsys on 14-11-26.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumberKeyboardView : UIView

typedef void (^OkClickBlock)(NSString *cost, UIImage *image);
typedef void (^PhotoPikerBlock)(void);

@property (nonatomic, copy) OkClickBlock okClickBlock;  /* ok click block */
@property (nonatomic, copy) PhotoPikerBlock photoPickerBlock;   /* pick photo block */

@property (nonatomic, weak) IBOutlet UILabel  *costLabel;
@property (nonatomic, weak) IBOutlet UIButton *typeButton;
@property (nonatomic, weak) IBOutlet UILabel  *typeLabel;

@property (nonatomic, weak) IBOutlet UIButton *dotButton;
@property (nonatomic, weak) IBOutlet UIButton *okButton;
@property (nonatomic, weak) IBOutlet UIButton *photoButton;

@property (nonatomic, strong) NSMutableString *costString;        /* current cost */

@end
