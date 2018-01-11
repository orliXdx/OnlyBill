//
//  SettingTableViewController.m
//  OnlyBill
//
//  Created by Orientationsys on 15/2/2.
//  Copyright (c) 2015年 Xu. All rights reserved.
//

#import "SettingTableViewController.h"
#import "FontAwesome.h"
#import "PublicFunctions.h"
#import "BillListTableViewController.h"
#import "SettingNavigationController.h"
#import "BackgroundImageTableViewController.h"
#import "AboutViewController.h"

@interface SettingTableViewController ()

@end

@implementation SettingTableViewController
{
    NSArray *cellIconArray;
    NSArray *cellTextArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* set navigation title */
    self.title = @"Setting";
    
    /* add close buttonItem */
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onCloseView:)];
    
    [self.tableView setScrollEnabled:NO];
    
    /* cell icons and text */
    cellIconArray = [[NSArray alloc] initWithObjects:fa_align_justify, fa_leaf, fa_info_circle, nil];
    cellTextArray = [[NSArray alloc] initWithObjects:@"Bill Manager", @"Background", @"About", nil];
}

/* close view */
- (void)onCloseView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cellIconArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"setting";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"setting"];
    }
    
    [cell.imageView setImage:[FontAwesome imageWithIcon:[cellIconArray objectAtIndex:indexPath.row] iconColor:nil iconSize:20.f]];
    [cell.textLabel setText:[cellTextArray objectAtIndex:indexPath.row]];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:18.f]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:{
            BillListTableViewController *bill_view = [[BillListTableViewController alloc] init];
            SettingNavigationController *nav_view = [[SettingNavigationController alloc] initWithRootViewController:bill_view];
            
            [PublicFunctions animationForViewAppearOrDisappear:self.view Transition:kCATransitionFromRight Type:kCATransitionPush];
            
            [self presentViewController:nav_view animated:NO completion:nil];
            break;
        }
        case 1:{
            BackgroundImageTableViewController *image_view = [[BackgroundImageTableViewController alloc] init];
            SettingNavigationController *nav_view = [[SettingNavigationController alloc] initWithRootViewController:image_view];
            
            [PublicFunctions animationForViewAppearOrDisappear:self.view Transition:kCATransitionFromRight Type:kCATransitionPush];
            
            [self presentViewController:nav_view animated:NO completion:nil];
            
            break;
        }
        case 2:{
            AboutViewController *about_view = [[AboutViewController alloc] init];
            SettingNavigationController *nav_view = [[SettingNavigationController alloc] initWithRootViewController:about_view];
            
            [PublicFunctions animationForViewAppearOrDisappear:self.view Transition:kCATransitionFromRight Type:kCATransitionPush];
            [self presentViewController:nav_view animated:NO completion:nil];
            
            break;
        }
   
        default:
            break;
    }
}

#pragma mark - UITableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}


@end
