//
//  MainHeaderView.h
//  OnlyBill
//
//  Created by Orientationsys on 14-10-29.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontAwesome.h"

@class MainHeaderView;
@protocol MainHeaderViewDelegate <NSObject>

- (void)leftMenuClick;
- (void)addBill;
- (void)viewStatistics;

@end

@interface MainHeaderView : UIView

@property (nonatomic, assign) id<MainHeaderViewDelegate>delegate;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel  *billNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, weak) IBOutlet UIButton *statisticsButton;
@property (nonatomic, weak) IBOutlet UILabel  *inputLabel;
@property (nonatomic, weak) IBOutlet UILabel  *outputLabel;

- (IBAction)menuClick:(id)sender;
- (IBAction)stasticsClick:(id)sender;

@end
