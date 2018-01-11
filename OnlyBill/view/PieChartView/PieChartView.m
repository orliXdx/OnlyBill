//
//  PieChartView.m
//  Statements
//
//  Created by Moncter8 on 13-5-30.
//  Copyright (c) 2013年 Moncter8. All rights reserved.
//

#import "PieChartView.h"

@interface PieChartView()
@property (nonatomic,strong)RotatedView *rotatedView;
@property (nonatomic,strong) UIButton *centerView;
@property (nonatomic,strong) UILabel *amountLabel;
@property (nonatomic, strong) UILabel *title;
@end

@implementation PieChartView

- (void)dealloc
{
    self.rotatedView.delegate = nil;
    self.rotatedView = nil;
    self.centerView = nil;
    self.amountLabel = nil;
}

- (id)initWithFrame:(CGRect)frame withKey:(NSMutableArray *)keyArr valueArr:(NSMutableArray *)valueArr withColor:(NSMutableArray *)colorArr
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sortValueArr:keyArr valueArr:valueArr colorArr:colorArr];
        
        /* if no empty data */
        if (valueArr && colorArr) {
            self.rotatedView = [[RotatedView alloc]initWithFrame:self.bounds];
            self.rotatedView.mValueArray = valueArr;
            self.rotatedView.mColorArray = colorArr;
            self.rotatedView.delegate = self;
            [self addSubview:self.rotatedView];
        }
        
        /* centerView */
        self.centerView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.centerView removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        [self.centerView addTarget:self action:@selector(changeInOut:) forControlEvents:UIControlEventTouchUpInside];
        
        self.centerView.frame = CGRectMake((frame.size.width - 100)/2, (frame.size.height - 100)/2, 100, 100);
        self.centerView.layer.cornerRadius = self.centerView.frame.size.height/2;
        self.centerView.layer.masksToBounds = YES;
        self.centerView.contentMode = UIViewContentModeScaleAspectFill;
        self.centerView.clipsToBounds = YES;
        self.centerView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.centerView.layer.shadowOffset = CGSizeMake(4, 4);
        self.centerView.layer.shadowOpacity = 0.5;
        self.centerView.layer.shadowRadius = 2.0;
        self.centerView.layer.borderColor = [[UIColor blackColor] CGColor];
        self.centerView.layer.borderWidth = 2.0f;
        self.centerView.userInteractionEnabled = YES;
        self.centerView.backgroundColor = [UIColor whiteColor];
        
        int titleWidth = 65;
        self.title = [[UILabel alloc]initWithFrame:CGRectMake((100 - titleWidth)/2,35 , titleWidth, 17)];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.font = [UIFont systemFontOfSize:14.f];
        self.title.textColor = [self colorFromHexRGB:@"000000"];
        self.title.text = @"";
        [self.centerView addSubview:self.title];
        
        int amountWidth = 75;
        self.amountLabel = [[UILabel alloc]initWithFrame:CGRectMake((100 - amountWidth)/2, 53, amountWidth, 22)];
        self.amountLabel.backgroundColor = [UIColor clearColor];
        self.amountLabel.textAlignment = NSTextAlignmentCenter;
        self.amountLabel.font = [UIFont boldSystemFontOfSize:21];
        self.amountLabel.textColor = [self colorFromHexRGB:@"000000"];
        [self.amountLabel setAdjustsFontSizeToFitWidth:YES];
        [self.centerView addSubview:self.amountLabel];
        
        [self addSubview:self.centerView];
        
        
        /* if empty data */
        if (valueArr == nil || colorArr == nil) {
//            self.title.text = @"Nothing";
            self.amountLabel.text = @"$0";
        }
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)initCenterView
{
    if (self.centerView) {
        
    }
}

- (void)sortValueArr:(NSMutableArray *)keyArr valueArr:(NSMutableArray *)valueArr colorArr:(NSMutableArray *)colorArr
{
    float sum = 0.0;
    int maxIndex = 0;
    int maxValue = 0;
    for (int i = 0; i < [valueArr count]; i++) {
        float curValue = [[valueArr objectAtIndex:i] floatValue];
        if (curValue > maxValue) {
            maxValue = curValue;
            maxIndex = i;
        }
        sum += curValue;
    }
    float frac = 2.0 * M_PI / sum;
    int changeIndex = 0;
    sum = 0.0;
    for (int i = 0; i < [valueArr count]; i++) {
        float curValue = [[valueArr objectAtIndex:i] floatValue];
        sum += curValue;
        if(sum*frac > M_PI/2){
            changeIndex = i;
            break;
        }
    }
    if (maxIndex != changeIndex) {
        [keyArr exchangeObjectAtIndex:maxIndex withObjectAtIndex:changeIndex];
        [valueArr exchangeObjectAtIndex:maxIndex withObjectAtIndex:changeIndex];
        [colorArr exchangeObjectAtIndex:maxIndex withObjectAtIndex:changeIndex];
    }
}

- (void)changeInOut:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onCenterClick:)]) {
        [self.delegate onCenterClick:self];
    }
}

- (void)setTitleText:(NSString *)text
{
    [self.title setText:text];
}
- (void)setAmountText:(NSString *)text
{
    [self.amountLabel setText:text];
}

- (UIColor *) colorFromHexRGB:(NSString *) inColorString
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

- (void)reloadChart
{
    [self.rotatedView reloadPie];
}

- (void)selectedFinish:(RotatedView *)rotatedView index:(NSInteger)index percent:(float)per
{
    [self.delegate selectedFinish:self index:index percent:per];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
