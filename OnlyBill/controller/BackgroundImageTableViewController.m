//
//  BackgroundImageTableViewController.m
//  OnlyBill
//
//  Created by Orientationsys on 15/2/3.
//  Copyright (c) 2015年 Xu. All rights reserved.
//

#import "BackgroundImageTableViewController.h"
#import "PublicFunctions.h"
#import "FontAwesome.h"
#import "PictureCell.h"

@interface BackgroundImageTableViewController ()

@end

@implementation BackgroundImageTableViewController{
    NSArray *imageArray;
    
    BOOL isFirstLoad;
    NSInteger currentSelect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* first load, set default selected image */
    isFirstLoad = YES;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    self.title = @"Background";
    UIBarButtonItem *back_btn = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_angle_left iconColor:nil iconSize:30.f] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = back_btn;
    
    imageArray = @[@"scenery_1.jpg", @"scenery_2.jpg", @"scenery_3.jpg", @"scenery_4.jpg", @"scenery_5.jpg", @"scenery_6.jpg", @"scenery_7.jpg", @"scenery_8.jpg", @"scenery_9.jpg", @"scenery_10.jpg", @"scenery_11.jpg", @"scenery_12.jpg"];
}

/* close current view */
- (void)goBack:(id)sender
{
    [PublicFunctions animationForViewAppearOrDisappear:self.view Transition:kCATransitionFromLeft Type:kCATransitionPush];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [imageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"pictureCell";
    PictureCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"PictureCell" owner:nil options:nil];
        cell = [nibs lastObject];
    }
    
    [cell.okayBtn setHidden:YES];
    cell.parallaxImage.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]];
    
    if (isFirstLoad) {
        /* is current image */
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *image_name = [defaults objectForKey:@"background"];
        if (image_name && image_name.length > 0) {
            if ([image_name isEqualToString:[imageArray objectAtIndex:indexPath.row]]) {
                [cell.okayBtn setHidden:NO];
            }
        }
        else{
            if ([[imageArray objectAtIndex:indexPath.row] isEqualToString:@"scenery_1.jpg"]) {
                [cell.okayBtn setHidden:NO];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isFirstLoad = NO;
    
    [self.tableView reloadData];
    
    PictureCell *cell = (PictureCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        /* show selected button */
        [cell.okayBtn setHidden:NO];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[imageArray objectAtIndex:indexPath.row] forKey:@"background"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newBackground" object:[imageArray objectAtIndex:indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.f;
}


@end
