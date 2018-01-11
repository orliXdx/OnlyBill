//
//  StatisticsViewController.h
//  OnlyBill
//
//  Created by Orientationsys on 15/1/11.
//  Copyright (c) 2015年 Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieChartView.h"

#define PAGE_CONTROL_WIDTH (120.f)
#define HEADER_HEIGHT (40.f)
#define CLOSE_BUTTON_SIZE (30.f)

typedef enum{
    year=0,
    month,
    day,
    week
}State;

@interface StatisticsViewController : UIViewController<UIScrollViewDelegate, PieChartDelegate>

@end
