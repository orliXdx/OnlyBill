//
//  NumberKeyboardView.m
//  OnlyBill
//
//  Created by Orientationsys on 14-11-26.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import "NumberKeyboardView.h"
#import "PublicFunctions.h"

@implementation NumberKeyboardView
{
    BOOL isClickDot;                    /* is click the dot */
    BOOL isClickPlus;                   /* is click the plus */
    
    NSInteger decimalLocation;          /* location of input decimal */
    double sumCost;                     /* temp sum of cost */
}

@synthesize okClickBlock, photoPickerBlock;
@synthesize costLabel, typeButton, typeLabel;
@synthesize dotButton, okButton, photoButton;
@synthesize costString;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        decimalLocation = 0;
        sumCost = 0.00;
        costString = [[NSMutableString alloc] initWithString:@"$0.00"];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [costLabel setTextColor:[UIColor darkGrayColor]];
}

/* number click (0-9) */
- (IBAction)numberClick:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSString *title = [btn.titleLabel text];
//    NSLog(@"title: %@", title);
    [self changeValue:title];
}

/* dot click (.) */
- (IBAction)dotClick:(id)sender
{
    isClickDot = YES;
}

/* plus click (+) */
- (IBAction)plusClick:(id)sender
{
    [self.okButton setTitle:@"=" forState:UIControlStateNormal];
    [self.okButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    
    /* set new text of label */
    sumCost += [costString substringFromIndex:1].doubleValue;
    costString = [[NSMutableString alloc] initWithString:@"$0.00"];
    [costLabel setText:costString];
    
    isClickPlus = YES;
    isClickDot  = NO;
    decimalLocation = 0;
}

/* delete click (<) */
- (IBAction)deleteClick:(id)sender
{
    [self deleteNumber];
}

/* delete the char */
- (void)deleteNumber
{
    NSRange range = [costString rangeOfString:@"."];
    if (isClickDot) {
        // second decimal.
        range.location += 2;
        if ([[costString substringWithRange:range] isEqualToString:@"0"]) {
            // first decimal
            range.location--;
            decimalLocation = 1;
            if ([[costString substringWithRange:range] isEqualToString:@"0"]) {
                decimalLocation = 0;
                isClickDot = NO;
                [self deleteNumber];    // delete digital part
            }
            else{
                isClickDot = NO;
                decimalLocation = 0;
            }
        }
        else{
            decimalLocation = 1;
        }
        
        [costString replaceCharactersInRange:range withString:@"0"];
        [self.costLabel setText:costString];

        return;
    }
    else{
        // last digital(before dot)
        range.location--;
        if (range.location > 1) {
            [costString deleteCharactersInRange:range];
        }
        else{
            // if only one digital(before dot).
            if (![[costString substringWithRange:range] isEqualToString:@"0"]) {
                [costString replaceCharactersInRange:range withString:@"0"];
            }
            else{
                [PublicFunctions shakeAnimationForView:self.costLabel];
                
                return;
            }
        }
        [self.costLabel setText:costString];
        
        return;
    }
}

- (IBAction)okClick:(id)sender
{
    if (isClickPlus) {
        [self.okButton setTitle:@"OK" forState:UIControlStateNormal];
        [self.okButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        sumCost += [costString substringFromIndex:1 ].doubleValue;
        [costLabel setText:[NSString stringWithFormat:@"$%.2f", sumCost]];
        costString = [[NSMutableString alloc] initWithString:costLabel.text];
        sumCost = 0.00f;
        
        isClickDot = YES;
        isClickPlus = NO;
    }
    /* ok, create the record */
    else{
        NSLog(@"OK, %@", costString);
        if (self.okClickBlock) {
            self.okClickBlock(costString, self.typeButton.imageView.image);
        }
    }
}

/* change cost value */
- (void)changeValue:(NSString *)character
{
    // no more than 2 decimal, like $**.99
    if (isClickDot) {
        if (decimalLocation > 1) {
            [PublicFunctions shakeAnimationForView:self.costLabel];
            return;
        }
        
        NSRange decimal_range = [costString rangeOfString:@"."];
        decimal_range.location++;   // first decimal
        if ([[costString substringWithRange:decimal_range] isEqualToString:@"0"] && decimalLocation == 0) {
            [costString replaceCharactersInRange:decimal_range withString:character];
            [self.costLabel setText:costString];
            
            decimalLocation = 1;  // jump to second decimal
            return;
        }
        
        decimal_range.location++;   //second decimal
        if ([[costString substringWithRange:decimal_range] isEqualToString:@"0"] && decimalLocation == 1) {
            [costString replaceCharactersInRange:decimal_range withString:character];
            [self.costLabel setText:costString];
            
            decimalLocation = 2;  // jump to third decimal (can't input more)
            return;
        }
    }
    else{
        NSRange range = [costString rangeOfString:@"."];
        // not more than 6 digits. like $999999.00
        if (range.location > 6) {
            [PublicFunctions shakeAnimationForView:self.costLabel];
            return;
        }
        
        // front char of '.'
        range.location--;
        if ([[costString substringWithRange:range] isEqualToString:@"0"] && (range.location == 1)) {
            [costString replaceCharactersInRange:range withString:character];
        }
        else{
            [costString insertString:character atIndex:range.location+1];
        }
        
        [self.costLabel setText:costString];
    }
}

/* pick photo */
- (IBAction)pickPhotoClick:(id)sender
{
    if (self.photoPickerBlock) {
        self.photoPickerBlock();
    }
}




@end
