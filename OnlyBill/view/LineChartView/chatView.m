//
//  chatView.m
//  test
//
//  Created by Z on 14-5-26.
//  Copyright (c) 2014年 carlsworld. All rights reserved.
//

#import "chatView.h"

@implementation chatView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.lines = [[NSMutableArray alloc] init];
//        self.afColor = [UIColor colorWithRed:123.0/255.0 green:207.0/255.0 blue:35.0/255.0 alpha:1.0];
        self.afColor = [UIColor darkGrayColor];
        self.bfColor = [UIColor colorWithRed:123.0/255.0 green:207.0/255.0 blue:35.0/255.0 alpha:1.0];
        self.points = [[NSMutableArray alloc] init];
    }
    
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    /* color of line */
//    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    
    for(int i=0; i<self.lines.count; i++){
        Line* line = [self.lines objectAtIndex:i];
        if(i!=0 ||i!=6 || i!=7){
            CGContextSetLineWidth(context, 1);
        }else{
            CGContextSetLineWidth(context, 1);
        }
        CGContextMoveToPoint(context, line.firstPoint.x, line.firstPoint.y);
        CGContextAddLineToPoint(context, line.secondPoint.x, line.secondPoint.y);
    }
    CGContextDrawPath(context, kCGPathStroke);

    if([self.points count]){
        UIBezierPath* path1 = [UIBezierPath bezierPath];
        [path1 setLineWidth:3];
        for(int i=0; i<[[self.points lastObject] count]-1; i++){
            CGPoint firstPoint = [[[self.points lastObject] objectAtIndex:i] CGPointValue];
            CGPoint secondPoint = [[[self.points lastObject] objectAtIndex:i+1] CGPointValue];
            [path1 moveToPoint:firstPoint];
            [UIView animateWithDuration:.1 animations:^(){
                [path1 addCurveToPoint:secondPoint controlPoint1:CGPointMake((secondPoint.x-firstPoint.x)/2+firstPoint.x, firstPoint.y) controlPoint2:CGPointMake((secondPoint.x-firstPoint.x)/2+firstPoint.x, secondPoint.y)];
            }];
            [self.bfColor set];
            
        }
        path1.lineCapStyle = kCGLineCapRound;
        [path1 strokeWithBlendMode:kCGBlendModeNormal alpha:1];
        
        //画点
        if(!self.isDrawPoint){
            for(int i=0; i<[[self.points lastObject] count]; i++){
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGPoint point = [[[self.points lastObject] objectAtIndex:i] CGPointValue];
                CGContextFillEllipseInRect(ctx, CGRectMake(point.x-4, point.y-4, 8, 8));
                CGContextSetFillColorWithColor(ctx, self.bfColor.CGColor);
                CGContextFillPath(ctx);
            }
        }
        
        //画线
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path setLineWidth:2];
        for(int i=0; i<[[self.points objectAtIndex:0] count]-1; i++){
            CGPoint firstPoint = [[[self.points objectAtIndex:0] objectAtIndex:i] CGPointValue];
            CGPoint secondPoint = [[[self.points objectAtIndex:0] objectAtIndex:i+1] CGPointValue];
            [path moveToPoint:firstPoint];
            [path addCurveToPoint:secondPoint controlPoint1:CGPointMake((secondPoint.x-firstPoint.x)/2+firstPoint.x, firstPoint.y) controlPoint2:CGPointMake((secondPoint.x-firstPoint.x)/2+firstPoint.x, secondPoint.y)];
            [self.afColor set];
        }
        path.lineCapStyle = kCGLineCapRound;
        [path strokeWithBlendMode:kCGBlendModeNormal alpha:1];
        
        if(!self.isDrawPoint){
            for(int i=0; i<[[self.points objectAtIndex:0] count]; i++){
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGPoint point = [[[self.points objectAtIndex:0] objectAtIndex:i] CGPointValue];
                CGContextFillEllipseInRect(ctx, CGRectMake(point.x-4, point.y-4, 8, 8));
                CGContextSetFillColorWithColor(ctx, self.afColor.CGColor);
                CGContextFillPath(ctx);
            }
        }
    }
}

@end

@implementation Line

- (id)init
{
    if(self=[super init]){
        
    }
    return self;
}

@end