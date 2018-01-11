//
//  AboutViewController.m
//  OnlyBill
//
//  Created by Orientationsys on 15/2/6.
//  Copyright (c) 2015年 Xu. All rights reserved.
//

#import "AboutViewController.h"
#import "PublicFunctions.h"
#import "FontAwesome.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"About";
    UIBarButtonItem *back_btn = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_angle_left iconColor:nil iconSize:30.f] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = back_btn;
    
    
    /* add app icon */
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150.f, 150.f)];
    [icon setCenter:CGPointMake([PublicFunctions getWidthOfMainScreen]/2, [PublicFunctions getHeightOfMainScreen]/2)];
    [icon setImage:[UIImage imageNamed:@"icon_180.png"]];
    [self.view addSubview:icon];
    
    
    /* add title label */
    UILabel *title_label = [self createLabel:CGRectMake(0, 0, 100.f, 50.f) Title:@"Only Bill" FontSize:16.f];
    [title_label setCenter:CGPointMake([PublicFunctions getWidthOfMainScreen]/2, icon.frame.origin.y - 80.f)];
    [self.view addSubview:title_label];
    
    /* add version label */
    UILabel *version_label = [self createLabel:CGRectMake(0, 0, 100.f, 30.f) Title:@"Version 1.0" FontSize:12.f];
    [version_label setCenter:CGPointMake([PublicFunctions getWidthOfMainScreen]/2, icon.frame.origin.y + icon.frame.size.height + 50.f)];
    [self.view addSubview:version_label];
    
    /* add copyright label */
    UILabel *copyright_label = [self createLabel:CGRectMake(0, 0, 300.f, 30.f) Title:@"Created By Xu (orliXdx@gmail.com)" FontSize:13.f];
    [copyright_label setCenter:CGPointMake([PublicFunctions getWidthOfMainScreen]/2, version_label.frame.origin.y+80.f)];
    [self.view addSubview:copyright_label];
}

/* close current view */
- (void)goBack:(id)sender
{
    [PublicFunctions animationForViewAppearOrDisappear:self.view Transition:kCATransitionFromLeft Type:kCATransitionPush];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UILabel *) createLabel:(CGRect)frame Title:(NSString *)title FontSize:(float)fontSize
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setText:title];
    [label setFont:[UIFont systemFontOfSize:fontSize]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    return label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
