//
//  MainViewController.h
//  OnlyBill
//
//  Created by Orientationsys on 14-12-8.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainHeaderView.h"

@class RESideMenu;

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface MainViewController : UIViewController<MainHeaderViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, readonly, nonatomic) RESideMenu *sideMenu;

@end
