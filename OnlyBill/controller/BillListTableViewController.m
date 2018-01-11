//
//  BillListTableViewController.m
//  OnlyBill
//
//  Created by Orientationsys on 15/2/3.
//  Copyright (c) 2015年 Xu. All rights reserved.
//

#import "BillListTableViewController.h"
#import "PublicFunctions.h"
#import "FontAwesome.h"
#import "BillObject.h"
#import "BillDB.h"

@interface BillListTableViewController ()

@end

@implementation BillListTableViewController{
    NSMutableArray *billList;
    BillObject *currentBill;
    BillObject *selectedBill;
    
    BOOL isDeleteBill;
    
    BillDB *billDB;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    billDB = [[BillDB alloc] init];
    
    self.title = @"Bill Manager";
    UIBarButtonItem *back_btn = [[UIBarButtonItem alloc] initWithImage:[FontAwesome imageWithIcon:fa_angle_left iconColor:nil iconSize:30.f] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = back_btn;
    
    /* background */
//    UIImageView *image_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scenery_8.jpg"]];
//    [self.tableView setBackgroundView:image_view];
    
    
    billList = [NSMutableArray arrayWithArray:[PublicFunctions getBillList]];
    currentBill = [PublicFunctions getBill];
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
    return [billList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"bill";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bill"];
    }
    
    BillObject *bill = [billList objectAtIndex:indexPath.row];
    if ([bill.billId isEqualToString:currentBill.billId]) {
        [cell.textLabel setText:[NSString stringWithFormat:@"* %@", bill.name]];
    }
    else{
        [cell.textLabel setText:bill.name];
    }
    
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:18.f]];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BillObject *bill = [billList objectAtIndex:indexPath.row];
    if (bill && currentBill && [bill.billId isEqualToString:currentBill.billId]) {
        return NO;
    }
    
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setEditing:NO animated:YES];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Delete");
        
        isDeleteBill = YES;
        
        selectedBill = [billList objectAtIndex:indexPath.row];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete ?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        
        [alert show];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedBill = [billList objectAtIndex:indexPath.row];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bill name" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    if (selectedBill) {
        UITextField *text_field = [alert textFieldAtIndex:0];
        [text_field setText:selectedBill.name];
    }
    
    [alert show];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (isDeleteBill == YES) {
        // remove
        if (buttonIndex == 1) {
            if (selectedBill && currentBill) {
                if (![selectedBill.billId isEqualToString:currentBill.billId]) {
                    BOOL is_removed = [billDB deleteBill:selectedBill.billId];
                    if (is_removed) {
                        BOOL is_removed_records = [billDB deleteRecordListByBillId:selectedBill.billId];
                        if (is_removed_records) {
                            /* remove bill from billList */
                            [billList removeObject:selectedBill];
                            
                            [self.tableView reloadData];
                        }
                        else{
                            [PublicFunctions showAlertView:@"Remove failed" Message:nil];
                        }
                    }
                }
            }
        }
    }
    else{
        /* add new bill */
        UITextField *text_field = [alertView textFieldAtIndex:0];
        /* ok */
        if (buttonIndex == 1) {
            NSLog(@"text: %@", text_field.text);
            if (selectedBill) {
                if (![selectedBill.name isEqualToString:text_field.text]) {
                    selectedBill.name = text_field.text;
                    BOOL is_update = [billDB updateBill:selectedBill];
                    if (is_update) {
                        if ([selectedBill.billId isEqualToString:currentBill.billId]) {
                            /* if update current bill, update userdefault */
                            [PublicFunctions saveBill:selectedBill];
                            
                            /* post notification to mainView */
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"BillNameChanged" object:selectedBill];
                        }
                        
                        /* refresh */
                        [self.tableView reloadData];
                    }
                    else{
                        [PublicFunctions showAlertView:@"Updated failed" Message:nil];
                    }
                }
            }
        }
    }
}


@end
