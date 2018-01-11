//
//  StatisticsViewController.m
//  OnlyBill
//
//  Created by Orientationsys on 15/1/11.
//  Copyright (c) 2015年 Xu. All rights reserved.
//

#import "StatisticsViewController.h"
#import "PublicFunctions.h"
#import "BillObject.h"
#import "BillDB.h"
#import "chatView.h"
#import "InfoView.h"
#import "FontAwesome.h"
#import "WaterDropButton.h"

#define PIE_HEIGHT 280

#define LINE_COUNT  8
#define POINT_COUNT 8
#define WIDHT_OF_CHART  250
#define HEIGHT_OF_CHART 250
#define Y_OF_DATEVIEW 20
#define HEIGHT_OF_DATEVIEW 30.f

@interface StatisticsViewController ()

@property (nonatomic, strong) PieChartView *pieChartView;
@property (nonatomic, strong) UIView *pieContainer;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UIImageView *categoryImageView;

@end

@implementation StatisticsViewController{
    UIPageControl *pageControl;
    UIScrollView  *sScrollView;   //  scroll view
    
    /* line chart */
    chatView* lineChartView;
    UIView* dayView;
    UIView* dateView;
    UILabel* dateLabel;
    UIView *YView;
    InfoView *infoView;
    int weekPlus;
    
    NSMutableArray *costPointsArray;    // all cost   points
    NSMutableArray *incomePointsArray;  // all income points
    float maxY;                         // the max value of Y
    float gapY;                         // gap of Y (maxY / HEIGHT_OF_CHART)
    
    BillDB *billDB;                         //  BillDB
    BillObject *currentBill;                //  current bill
    NSArray *recordList;                    //  current record list
    NSMutableDictionary *costByCategory;    //  cost by category dictionary
    NSMutableArray *categoryKeys;           //  keys of category
    NSMutableArray *categoryValues;         //  values of category
    NSMutableArray *categoryColors;         //  colors of category
    
    NSMutableDictionary *costByDateDictionary;   // total cost by date.
    NSMutableDictionary *incomeByDateDictionary; // total income by date.
    NSMutableArray *currentWeekDays;        //  current 7 days of this week.
    
    /* offset of different devices */
    float deviceOffset;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* different devices */
    deviceOffset = 0.f;
    if ([PublicFunctions OSDevice] == IPHONE5_5S) {
        deviceOffset = 30.f;
    }
    else if ([PublicFunctions OSDevice] == IPHONE6){
        deviceOffset = 40.f;
    }
    else if ([PublicFunctions OSDevice] == IPHONE6_PLUS){
        deviceOffset = 50.f;
    }
    
    billDB = [[BillDB alloc] init];
    /* get current bill */
    currentBill = [PublicFunctions getBill];
    /* get record list */
    recordList = [billDB getRecordListByBillId:currentBill.billId];
    
    /* add page control and close button */
    [self addPageControl];
    [self addCloseButton];
    
    /* add scrollView */
    [self addScrollView];
    
    /* add pieChartView */
    [self addPieView];
    
    
    /* -------------------- Line Chart View --------------------- */
    
    /* get costByDateDictionary and incomeByDateDictionary */
    [self initCostByDateDicAndIncomByDateDic];
    
    /* first init line chart view */
    [self addLineChartView];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.pieChartView) {
        [self.pieChartView reloadChart];
    }
}

/* add page control */
- (void)addPageControl
{
    /* add pageControl */
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(([PublicFunctions getWidthOfMainScreen]-PAGE_CONTROL_WIDTH), [PublicFunctions getYOfMainScreen]+STATUS_BAR_HEIGHT+STATUS_BAR_HEIGHT/2, PAGE_CONTROL_WIDTH, HEADER_HEIGHT)];
    [pageControl setCenter:CGPointMake([PublicFunctions getWidthOfMainScreen]/2, [PublicFunctions getYOfMainScreen]+HEADER_HEIGHT)];
    [pageControl setNumberOfPages:2];
    // set page indicator
    [pageControl setCurrentPageIndicatorTintColor:[UIColor blackColor]];
    [pageControl setPageIndicatorTintColor:[UIColor grayColor]];
    [self.view addSubview:pageControl];
}

/* add close button */
- (void)addCloseButton
{
    /* add close button */
    WaterDropButton *close_button = [[WaterDropButton alloc] initWithFrame:CGRectMake([PublicFunctions getWidthOfMainScreen]-CLOSE_BUTTON_SIZE-10.f, [PublicFunctions getYOfMainScreen]+STATUS_BAR_HEIGHT, CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)];
    [close_button setBorderSize:1.f];
    [close_button setImage:[UIImage imageNamed:@"cancel-50.png"] forState:UIControlStateNormal];
    [close_button addTarget:self action:@selector(closeStatisticsView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:close_button];
}

/* close view */
- (void)closeStatisticsView
{
    if (self) {
        /* set transition style */
        CATransition *animation = [CATransition animation];
        [animation setDuration:1.f];
        [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
        [animation setType:@"rippleEffect"];
        [animation setSubtype:kCATransitionFromBottom];
        [self.view.window.layer addAnimation:animation forKey:nil];
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

/* add scrollView */
- (void)addScrollView
{
    sScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, [PublicFunctions getYOfMainScreen]+STATUS_BAR_HEIGHT+HEADER_HEIGHT, [PublicFunctions getWidthOfMainScreen], [PublicFunctions getHeightOfMainScreen]-STATUS_BAR_HEIGHT-HEADER_HEIGHT)];
    sScrollView.contentSize = CGSizeMake([PublicFunctions getWidthOfMainScreen]*2, [PublicFunctions getHeightOfMainScreen]-STATUS_BAR_HEIGHT-HEADER_HEIGHT);
    [sScrollView setDelegate:self];
    [sScrollView setShowsHorizontalScrollIndicator:NO];
    [sScrollView setShowsVerticalScrollIndicator:NO];
    [sScrollView setScrollsToTop:NO];
    [sScrollView setPagingEnabled:YES];
    [sScrollView setScrollEnabled:YES];
    [sScrollView setBackgroundColor:[UIColor whiteColor]];

    [self.view addSubview:sScrollView];
}

/* add pie chart view */
- (void)addPieView
{
    /* add income label and value label */
    [self createLabelWithTitle:@"Income" withX:30.f withY:STATUS_BAR_HEIGHT withHeight:20.f withWidth:50.f];
    [self createLabelWithTitle:[NSString stringWithFormat:@"$%@", currentBill.input] withX:10.f withY:STATUS_BAR_HEIGHT+21.f withHeight:21.f withWidth:90.f];
    
    /* add cost label and value label */
    [self createLabelWithTitle:@"Cost" withX:[PublicFunctions getWidthOfMainScreen]-30.f-50.f withY:STATUS_BAR_HEIGHT withHeight:20.f withWidth:50.f];
    [self createLabelWithTitle:[NSString stringWithFormat:@"$%@", currentBill.output] withX:[PublicFunctions getWidthOfMainScreen]-10.f-90.f withY:STATUS_BAR_HEIGHT+21.f withHeight:21.f withWidth:90.f];
    
    /* get cost by category dictionary */
    costByCategory = [self getCategoriesWithDic];
    if (costByCategory && costByCategory.count > 0) {
        categoryKeys   = [NSMutableArray arrayWithArray:[costByCategory allKeys]];
        categoryValues = [NSMutableArray arrayWithArray:[costByCategory allValues]];
        
        categoryColors = [[NSMutableArray alloc] initWithCapacity:20];
        for (int i=0; i<[categoryKeys count]; i++) {
            [categoryColors addObject:[UIColor colorWithHue:(arc4random()%256/256.f) saturation:(arc4random()%128/256.f)+0.5 brightness:(arc4random()%128/256.f)+0.5 alpha:1.f]];
        }
    }
    
    //add shadow img
    CGRect pie_frame = CGRectMake(([PublicFunctions getWidthOfMainScreen] - PIE_HEIGHT) / 2, STATUS_BAR_HEIGHT+HEADER_HEIGHT, PIE_HEIGHT, PIE_HEIGHT);
    
    self.pieContainer = [[UIView alloc] initWithFrame:pie_frame];
    self.pieChartView = [[PieChartView alloc]initWithFrame:self.pieContainer.bounds withKey:categoryKeys valueArr:categoryValues withColor:categoryColors];
    [self.pieChartView setDelegate:self];
    
    [self.pieContainer addSubview:self.pieChartView];
    [sScrollView addSubview:self.pieContainer];
    
    /* add category icon */
    self.categoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 30.f)/2, self.pieContainer.frame.origin.y + self.pieContainer.frame.size.height+10.f+deviceOffset, 30.f, 30.f)];
    
    [sScrollView addSubview:self.categoryImageView];
    
    self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(([PublicFunctions getWidthOfMainScreen]-100.f)/2, self.categoryImageView.frame.origin.y+30.f+10.f, 100.f, 21)];
    self.categoryLabel.backgroundColor = [UIColor clearColor];
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryLabel.font = [UIFont systemFontOfSize:17];
    self.categoryLabel.textColor = [UIColor blackColor];
    [sScrollView addSubview:self.categoryLabel];
    
    
    self.view.backgroundColor = [PublicFunctions colorFromHexRGB:@"f8f8ff"];
}

/* create income, cost label and add to lineScrollView */
- (void)createLabelWithTitle:(NSString *)title withX:(float)x withY:(float)y withHeight:(float)height withWidth:(float)width
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [label setText:title];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:13.f]];
    if (sScrollView) {
        [sScrollView addSubview:label];
    }
}

/* seperated with categories */
- (NSMutableDictionary *)getCategoriesWithDic
{
    if (recordList && recordList.count > 0) {
        NSMutableDictionary *category_dic = [[NSMutableDictionary alloc] initWithCapacity:20];
        for (RecordObject *record in recordList) {
            if ([record.category isEqualToString:@"0"]) {
                continue;
            }
            else{
                category_dic = [self saveToCategoryDictionary:category_dic withCategory:record.category withCost:record.cost];
            }
        }
        
        return category_dic;
    }
    
    return nil;
}

/* save to categroy dictionary */
- (NSMutableDictionary *)saveToCategoryDictionary:(NSMutableDictionary *)dic withCategory:(NSString *)category withCost:(NSString *)cost
{
    NSString *old_cost;
    NSString *new_cost;
    if ([dic objectForKey:category]) {
        old_cost = [dic objectForKey:category];
        new_cost = [NSString stringWithFormat:@"%.2f", ([old_cost floatValue] + [[cost substringFromIndex:1] floatValue])];
        [dic setValue:new_cost forKey:category];
    }
    else{
        [dic setValue:[NSString stringWithFormat:@"%@", [cost substringFromIndex:1]] forKey:category];
    }
    
    return dic;
}


#pragma mark Scroll View
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    pageControl.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}


#pragma mark - PieChartViewDelegate
- (void)selectedFinish:(PieChartView *)pieChartView index:(NSInteger)index percent:(float)per
{
    if (categoryKeys && categoryKeys.count > 0) {
        NSString *category_name = [PublicFunctions getCategory:[categoryKeys objectAtIndex:index]];
        /* set category image and label */
        [self.categoryImageView setImage:[UIImage imageNamed:category_name]];
        [self.categoryLabel setText:[NSString stringWithFormat:@"%2.2f%@",per*100,@"%"]];
        
        /* set label of pieChartView */
        [self.pieChartView setTitleText:category_name];
        [self.pieChartView setAmountText:[NSString stringWithFormat:@"$%@", [categoryValues objectAtIndex:index]]];
    }
}

/* center click (no use for now.) */
- (void)onCenterClick:(PieChartView *)pieChartView
{
    NSLog(@"Center Click");
}



/*********************** Add Line Chart View  ***********************/

/* init costByDateDic and incomeByDateDic */
- (void)initCostByDateDicAndIncomByDateDic
{
    if (recordList && recordList.count > 0) {
        costByDateDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
        incomeByDateDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        NSMutableArray *record_list_by_date = [[NSMutableArray alloc] init];
        NSString *date = [(RecordObject *)[recordList objectAtIndex:0] date];
        for (RecordObject *record in recordList) {
            if (![date isEqualToString:record.date]) {
                [costByDateDictionary setObject:[self getTotalCostOrIncomeByDate:record_list_by_date Type:@"cost"] forKey:date];   // set cost list by date
                [incomeByDateDictionary setObject:[self getTotalCostOrIncomeByDate:record_list_by_date Type:@"income"] forKey:date]; // set income list by date
                
                date = record.date; // new date
                
                record_list_by_date = [[NSMutableArray alloc] init]; // init
            }
            
            [record_list_by_date addObject:record];
        }
        
        [costByDateDictionary setObject:[self getTotalCostOrIncomeByDate:record_list_by_date Type:@"cost"] forKey:date];
        [incomeByDateDictionary setObject:[self getTotalCostOrIncomeByDate:record_list_by_date Type:@"income"] forKey:date];
    }
}

/* get total cost or income by date */
- (NSString *)getTotalCostOrIncomeByDate:(NSMutableArray *)records Type:(NSString *)type
{
    if (records) {
        float total_cost = 0.00;
        for (RecordObject *record in records) {
            float cost_each = 0.00;
            // income
            if ([type isEqualToString:@"income"]) {
                if ([record.category isEqualToString:@"0"]) {
                    cost_each = [[record.cost substringFromIndex:1] floatValue];
                }
                
                total_cost += cost_each;
            }
            // cost
            else{
                if ([record.category isEqualToString:@"0"]) {
                    continue;
                }
                else{
                    cost_each = [[record.cost substringFromIndex:1] floatValue];
                }
                
                total_cost += cost_each;
            }
        }
        
        return [NSString stringWithFormat:@"%.2f", total_cost];
    }
    
    return @"0.00";
}

/* add lineChartView */
- (void)addLineChartView
{
    if (sScrollView) {
        [self readyDrawLineChartView];
    }
}

/* add dateView (dateLabel, forward and back button) */
- (void)initDateView
{
    if(!dateView){
        dateView = [[UIView alloc]initWithFrame:CGRectMake([PublicFunctions getWidthOfMainScreen]+10, Y_OF_DATEVIEW+deviceOffset, 300, HEIGHT_OF_DATEVIEW)];
        dateView.opaque = NO;
        [sScrollView addSubview:dateView];
        
        dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 5, dateView.frame.size.width-100, 25)];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [dateLabel setTextColor:[UIColor blackColor]];
        [dateLabel setFont:[UIFont fontWithName:@"Arial" size:15]];
        [dateLabel setTextAlignment:NSTextAlignmentCenter];
        /* set default date */
        [dateLabel setText:[self returnCurrentWeekDays:[self getCurrentTimeWith:week] WeekPlus:0]];
        [dateView addSubview:dateLabel];
        
        for(int i=0; i<2; i++){
            UIImage* image;
            if (i == 0) {
                image = [FontAwesome imageWithIcon:fa_arrow_left iconColor:[UIColor darkGrayColor] iconSize:30.f];
            }
            else{
                image = [FontAwesome imageWithIcon:fa_arrow_right iconColor:[UIColor darkGrayColor] iconSize:30.f];
            }
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(270*i, 0, HEIGHT_OF_DATEVIEW, HEIGHT_OF_DATEVIEW)];
            btn.tag = i;
            [btn setBackgroundImage:image forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(forwardOrBack:) forControlEvents:UIControlEventTouchUpInside];
            [dateView addSubview:btn];
        }
    }
}

/* forward or back click */
- (void)forwardOrBack:(UIButton* )btn
{
    /* remove info view */
    for(id obj in lineChartView.subviews){
        if([obj isKindOfClass:[InfoView class]]){
            [obj removeFromSuperview];
        }
    }
    
    /* remove lines */
    if(lineChartView.lines){
        [lineChartView.lines removeAllObjects];
        [lineChartView.points removeAllObjects];
        [dayView removeFromSuperview];
        dayView = nil;
        [lineChartView setNeedsDisplay];
    }
    
    /* remove Y-axis */
    if (YView) {
        [YView removeFromSuperview];
        YView = nil;
    }
    
    /* froward */
    if(btn.tag==1){
        weekPlus++;
        [dateLabel setText:[self returnCurrentWeekDays:[self getCurrentTimeWith:week] WeekPlus:weekPlus]];  // must refresh before draw lineChartView.
        [self readyDrawLineChartView];
    }
    /* back */
    else{
        weekPlus--;
        [dateLabel setText:[self returnCurrentWeekDays:[self getCurrentTimeWith:week] WeekPlus:weekPlus]];  // must refresh before draw lineChartView.
        [self readyDrawLineChartView];
    }
}

/* get curren month, day, week */
- (int)getCurrentTimeWith:(State)state
{
    NSDate* date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit) fromDate:date];
    switch (state) {
        case year:{
            return (int)[comps year];
        }
            break;
        case month:{
            return (int)[comps month];
            break;
        }
        case day:{
            return (int)[comps day];
            break;
        }
        case week:{
            return (int)[comps weekday]>0?(int)[comps weekday]:6;   // 0=sunday
            break;
        }
        default:
            break;
    }
}

/* return the range of current week */
- (NSString* )returnCurrentWeekDays:(int)dayOfWeek WeekPlus:(int)week
{
    NSDate* date1 = [NSDate dateWithTimeIntervalSinceNow:60*60*24*(week*7-dayOfWeek+1)];
    NSDate* date2 = [NSDate dateWithTimeIntervalSinceNow:60*60*24*(week*7-dayOfWeek+7)];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    /* add current 7 days */
    currentWeekDays = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i=0; i<7; i++) {
        NSDate *tem_date = [date1 dateByAddingTimeInterval:60*60*24*i];
        [currentWeekDays addObject:[formatter stringFromDate:tem_date]];
    }
    
    NSString* str1 = [formatter stringFromDate:date1];
    NSString* str2 = [formatter stringFromDate:date2];
    
    return [NSString stringWithFormat:@"%@  To  %@", str1, str2];
}

/* create value of XY for points */
- (NSArray* )returnPointXandYWithTip
{
    if (costPointsArray && costPointsArray.count > 0) {
        NSMutableArray* cost_points   = [[NSMutableArray alloc] init];
        NSMutableArray* income_points = [[NSMutableArray alloc] init];
        
        int gap = lineChartView.frame.size.width/(POINT_COUNT-2);
        for(int i=0; i<[costPointsArray count]; i++){
            /* pointes of cost line */
            float cost = [[costPointsArray objectAtIndex:i] floatValue];
            CGPoint point_cost =CGPointMake(1+gap*i, HEIGHT_OF_CHART - cost/gapY);
            [cost_points addObject:[NSValue valueWithCGPoint:point_cost]];
            
            /* pointes of income line */
            float income = [[incomePointsArray objectAtIndex:i] floatValue];
            CGPoint point_income =CGPointMake(1+gap*i, HEIGHT_OF_CHART - income/gapY);
            [income_points addObject:[NSValue valueWithCGPoint:point_income]];
        }
        
        return [NSArray arrayWithObjects:cost_points, income_points, nil];
    }
    
    return nil;
}

/* draw line */
- (void)readyDrawLineChartView
{
    /* refresh dateView */
    [self initDateView];
    
    /* refresh maxY, gapY, currentWeekDays, incomePointsArray, costPointsArray */
    if (incomeByDateDictionary && [incomeByDateDictionary count] > 0) {
        maxY = [self getMaxFromIncomeOrCostDic];
        gapY = maxY / HEIGHT_OF_CHART;
        
        incomePointsArray = [self getIncomeOrCostOfCurrent7Days:@"income"];
        costPointsArray   = [self getIncomeOrCostOfCurrent7Days:@"cost"];
    }
    
    /* add Y-axis */
    if (!YView) {
        YView = [[UIView alloc] initWithFrame:CGRectMake([PublicFunctions getWidthOfMainScreen]+0, Y_OF_DATEVIEW+HEIGHT_OF_DATEVIEW+60+deviceOffset, 45, HEIGHT_OF_CHART+50)];
        
        /* value of Y */
        for(int i=0; i<6; i++){
            UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(5, i*(HEIGHT_OF_CHART/5.f), 40, 20)];
            if (i == 5) {
                [label setText:@"0.00"];    // point(0, 0)
            }
            else{
                [label setText:[NSString stringWithFormat:@"%.2f", maxY-i*gapY*(HEIGHT_OF_CHART/5.f)]];
            }
            
            [label setTextColor:[UIColor blackColor]];
            [label setFont:[UIFont systemFontOfSize:9.f]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setBackgroundColor:[UIColor clearColor]];
            [YView addSubview:label];
        }
        
        [sScrollView addSubview:YView];
    }
    
    /* add chart */
    if(!lineChartView){
        lineChartView = [[chatView alloc]initWithFrame:CGRectMake([PublicFunctions getWidthOfMainScreen]+50, Y_OF_DATEVIEW+HEIGHT_OF_DATEVIEW+70+deviceOffset, WIDHT_OF_CHART, HEIGHT_OF_CHART)];
        lineChartView.opaque= NO;
        [sScrollView addSubview:lineChartView];
    }
    
    /* add dayView */
    if(!dayView){
        dayView = [[UIView alloc]initWithFrame:CGRectMake([PublicFunctions getWidthOfMainScreen], lineChartView.frame.origin.y+HEIGHT_OF_CHART+10, [[UIScreen mainScreen] bounds].size.width, 10)];
        dayView.opaque = NO;
        [sScrollView addSubview:dayView];
    }
    
    /* add lines */
    if(!lineChartView.lines.count){
        int gap = lineChartView.frame.size.width / (LINE_COUNT-2);
        for(int i=0; i<LINE_COUNT; i++){
            Line* line = [[Line alloc] init];
            if(i != LINE_COUNT - 1){
                /* line of column */
                line.firstPoint = CGPointMake(1+gap*i, 0);
                line.secondPoint = CGPointMake(1+gap*i, HEIGHT_OF_CHART);
                
                /* week name label */
                UILabel* week_label = [[UILabel alloc]initWithFrame:CGRectMake(40+gap*i, 0, 20.f, 10)];
                [week_label setText:[self reWeeksWithDay:i]];
                [week_label setBackgroundColor:[UIColor clearColor]];
                [week_label setTextColor:[UIColor blackColor]];
                [week_label setTextAlignment:NSTextAlignmentCenter];
                [week_label setFont:[UIFont systemFontOfSize:8.f]];
                [dayView addSubview:week_label];
            }else{
                /* line of row */
                line.firstPoint = CGPointMake(0, HEIGHT_OF_CHART);
                line.secondPoint = CGPointMake(WIDHT_OF_CHART-3, HEIGHT_OF_CHART);
            }
            
            [lineChartView.lines addObject:line];
        }
        
        /* points */
        lineChartView.points = [[self returnPointXandYWithTip] mutableCopy];
        
        /* line for cost */
        if(lineChartView.points && lineChartView.points.count > 0 && [[lineChartView.points objectAtIndex:0] count] < POINT_COUNT){
            for(int i =0; i<[[lineChartView.points objectAtIndex:0] count]; i++){
                infoView = [[InfoView alloc] init];
                [lineChartView addSubview:infoView];
                infoView.tapPoint = [[[lineChartView.points objectAtIndex:0]objectAtIndex:i] CGPointValue];
                if ([[costPointsArray objectAtIndex:i] floatValue] > 0) {
                    [infoView.infoLabel setText:[costPointsArray objectAtIndex:i]];
                }
                [infoView sizeToFit];
            }
        }else{
            lineChartView.isDrawPoint = YES;
        }
        
        /* line for income */
        if(lineChartView.points && lineChartView.points.count > 0 && [[lineChartView.points lastObject] count] < POINT_COUNT){
            for(int i =0; i<[[lineChartView.points lastObject] count]; i++){
                infoView = [[InfoView alloc]init];
                [lineChartView addSubview:infoView];
                infoView.tapPoint = [[[lineChartView.points lastObject]objectAtIndex:i] CGPointValue];
                
                float income_value = [[incomePointsArray objectAtIndex:i] floatValue];
                if (income_value > 0) {
                    [infoView.infoLabel setText:[NSString stringWithFormat:@"%.2f", income_value]];
                }
                [infoView sizeToFit];
            }
        }else{
            lineChartView.isDrawPoint = YES;
        }
        
        if (recordList && recordList.count > 0) {
            [infoView setNeedsDisplay];
            [lineChartView setNeedsDisplay];
        }
    }
}

/* get max from income/cost dictionary */
- (float)getMaxFromIncomeOrCostDic
{
    float max_number;
    if (incomeByDateDictionary && costByDateDictionary && [incomeByDateDictionary count] > 0) {
        // cost
        NSArray *values = [[costByDateDictionary allValues]  sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return ([obj1 floatValue] < [obj2 floatValue]);
        }];
        max_number = [[values objectAtIndex:0] floatValue];
        
        // income
        values = [[incomeByDateDictionary allValues]  sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return ([obj1 floatValue] < [obj2 floatValue]);
        }];
        
        if(max_number < [[values objectAtIndex:0] floatValue]){
            max_number = [[values objectAtIndex:0] floatValue];
        }
        
        return max_number;
    }
    
    return 1000.00;  // default maxY
}

/* get income or cost of current 7 days */
- (NSMutableArray *)getIncomeOrCostOfCurrent7Days:(NSString *)type
{
    NSMutableArray *pointes = [[NSMutableArray alloc] initWithCapacity:10];
    NSArray *keys = [costByDateDictionary allKeys];
    if (currentWeekDays && currentWeekDays.count > 0) {
        for (NSString *date_week in currentWeekDays) {
            NSString *value_each_day = @"0.00";
            for (NSString *date_key in keys) {
                if ([date_week isEqualToString:date_key]) {
                    // income
                    if ([type isEqualToString:@"income"]) {
                        value_each_day = [incomeByDateDictionary objectForKey:date_key];
                    }
                    // cost
                    else{
                        value_each_day = [costByDateDictionary objectForKey:date_key];
                    }
                }
            }
            
            [pointes addObject:value_each_day];
        }
        
        return  pointes;
    }
    
    return nil;
}


- (NSString* )reWeeksWithDay:(int)day
{
    switch (day) {
        case 0:{
            return @"Sun";
        }
            break;
        case 1:{
            return @"Mon";
            break;
        }
        case 2:{
            return @"Tue";
            break;
        }
        case 3:{
            return @"Wed";
            break;
        }
        case 4:{
            return @"Thu";
            break;
        }
        case 5:{
            return @"Fri";
            break;
        }
        case 6:{
            return @"Sat";
            break;
        }
        default:
            return @"Non";
            break;
    }
}



#pragma mark - receive memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.pieContainer      = nil;
    self.pieChartView      = nil;
    self.categoryImageView = nil;
    self.categoryLabel     = nil;
    categoryKeys           = nil;
    categoryValues         = nil;
    categoryColors         = nil;
    currentWeekDays        = nil;
    
    /* scroll view */
    pageControl = nil;
    sScrollView = nil;
    
    /* line chart view */
    lineChartView = nil;
    dayView       = nil;
    dateView      = nil;
    dateLabel     = nil;
    YView         = nil;
    infoView      = nil;
    costPointsArray   = nil;
    incomePointsArray = nil;
}

@end
