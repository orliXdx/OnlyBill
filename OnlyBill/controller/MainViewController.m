//
//  MainViewController.m
//  OnlyBill
//
//  Created by Orientationsys on 14-12-8.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import "MainViewController.h"
#import "FontAwesome.h"
#import "MainCell.h"
#import "AddBillViewController.h"
#import "PublicFunctions.h"
#import "BillDB.h"
#import "RESideMenu.h"
#import "StatisticsViewController.h"
#import "SettingTableViewController.h"
#import "SettingNavigationController.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    BillDB *billDB;
    
    MainHeaderView *headerView;
    UITableView *myTableView;
    
    NSArray *recordList;        // record list of selected bill
    NSMutableDictionary *recordDictionary;   // record list seperated by date, and date list.
    NSMutableDictionary *costByDateDictionary;  // cost list seperated by date.
    
    BOOL isAlertDelete;    // YES: delete record alert, NO:add bill alert
    RecordObject *currentRecord;    // current record of cell.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* new record added or edit */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRecordList) name:@"recordAddedOrEdit" object:nil];
    
    /* bill name changed */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBillName:) name:@"BillNameChanged" object:nil];
    
    /* init database */
    billDB   = [[BillDB alloc] init];
    
    /* add headerView */
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"MainHeaderView" owner:self options:nil];
    headerView = (MainHeaderView *)[nibs objectAtIndex:0];
    [headerView setDelegate:self];
    [self.view addSubview:headerView];
    
    /* add tableView */
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 220.f, [PublicFunctions getWidthOfMainScreen], [PublicFunctions getHeightOfMainScreen]-220.f) style:UITableViewStylePlain];
    [myTableView setDataSource:self];
    [myTableView setDelegate:self];
    [self.view addSubview:myTableView];
    
    /* refresh record list and reload data */
    [self refreshRecordList];
    
    [myTableView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSubBtns:)]];
}

/* refresh billName */
- (void)refreshBillName:(NSNotification *)notification
{
    BillObject *bill = notification.object;
    if (bill && headerView) {
        [headerView.billNameLabel setText:bill.name];
    }
}

/* remove the alert buttons (cell center click) */
- (void)removeSubBtns:(id)sender
{
    NSLog(@"Remove sub buttons expanded");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeSubBtns" object:sender];
}

/* refresh record list, when new record added, change other bill */
- (void)refreshRecordList
{
    BillObject *bill = [PublicFunctions getBill];
    [self updateBillInfoOfHeaderView:bill]; // update bill info of headerView
    recordList = [billDB getRecordListByBillId:bill.billId];
    [self initRecordDictionary];    // init record list by date
    
    [myTableView reloadData];
}

/* update bill info of headerView */
- (void)updateBillInfoOfHeaderView:(BillObject *)bill
{
    if (headerView) {
        /* set info of bill */
        [headerView.billNameLabel setText:bill.name];
        [headerView.inputLabel setText:[NSString stringWithFormat:@"$%@", bill.input]];
        [headerView.outputLabel setText:[NSString stringWithFormat:@"$%@", bill.output]];
    }
}

/* record list seperated by date, and date list */
- (void)initRecordDictionary
{
    recordDictionary = [[NSMutableDictionary alloc] init];
    costByDateDictionary = [[NSMutableDictionary alloc] init];
    if (recordList && recordList.count > 0) {
        NSMutableArray *record_list_by_date = [[NSMutableArray alloc] init];
        NSString *date = [(RecordObject *)[recordList objectAtIndex:0] date];
        for (RecordObject *record in recordList) {
            if (![date isEqualToString:record.date]) {
                [recordDictionary setObject:record_list_by_date forKey:date];   // set record list by date
                [costByDateDictionary setObject:[self getTotalCostByDate:record_list_by_date] forKey:date]; // set cost list by date
                date = record.date; // new date
                
                record_list_by_date = [[NSMutableArray alloc] init]; // init
            }
            
            [record_list_by_date addObject:record];
        }
        
        [recordDictionary setObject:record_list_by_date forKey:date];
        [costByDateDictionary setObject:[self getTotalCostByDate:record_list_by_date] forKey:date];
        
        /* save all keys(dates) */
        NSArray *keys = [[recordDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj2 compare:obj1];
        }];
        [recordDictionary setObject:keys forKey:@"keys"];
    }
}

- (NSString *)getTotalCostByDate:(NSMutableArray *)records
{
    if (records) {
        float total_cost = 0;
        for (RecordObject *record in records) {
            float cost_each = 0;
            if ([record.category isEqualToString:@"0"]) {
                cost_each = [[record.cost substringFromIndex:1] floatValue];
            }
            else{
                cost_each = - [[record.cost substringFromIndex:1] floatValue];
            }
            
            total_cost += cost_each;
        }
        
        if (total_cost > 0) {
            return [NSString stringWithFormat:@"$+%.2f", total_cost];
        }
        else{
            return [NSString stringWithFormat:@"$%.2f", total_cost];
        }
    }
    
    return @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[recordDictionary objectForKey:@"keys"] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [recordDictionary objectForKey:@"keys"];
    NSArray *key = [keys objectAtIndex:section];
    
    return [[recordDictionary objectForKey:key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *date = [[recordDictionary objectForKey:@"keys"] objectAtIndex:section];
    NSString *cost = [costByDateDictionary objectForKey:date];

    return [NSString stringWithFormat:@"%@ (%@)", date, cost];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"mainCell";
    MainCell *cell = (MainCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"MainCell" owner:nil options:nil];
        cell = [nibs lastObject];
    }
    
    RecordObject *record = [[recordDictionary objectForKey:[[recordDictionary objectForKey:@"keys"] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    [cell initWithRecord:record];
    
    /* block listener, delete and edit record */
    cell.editBtnClickBlock = ^(RecordObject *record){
        NSLog(@"cell edit click");
        
        AddBillViewController *add_bill_vc = [[AddBillViewController alloc] initWithRecord:record];
        
        /* animation */
        [PublicFunctions animationForViewAppearOrDisappear:self.view Transition:kCATransitionFromBottom Type:kCATransitionPush];
        
        [self presentViewController:add_bill_vc animated:NO completion:nil];
    };
    cell.deleteBtnClickBlock = ^(RecordObject *record){
        NSLog(@"cell delete click");
        
        isAlertDelete = YES;    // alert delete record
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete ?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        currentRecord = record;
        [alert show];
    };
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /* if scroll, remove the sub buttons expanded */
    [self removeSubBtns:self];
}

#pragma mark - MainHeaderView delegate

- (void)leftMenuClick
{
    NSLog(@"menu click");
    
    /* invoke menu */
    [self showMenu];
}

- (void)addBill
{
    NSLog(@"add record");
    AddBillViewController *add_bill_vc = [[AddBillViewController alloc] init];
    
    /* set transition style */
    //    [add_bill_contrller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:.5f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromBottom];
    [self.view.window.layer addAnimation:animation forKey:nil];
    
    [self presentViewController:add_bill_vc animated:NO completion:nil];
}

- (void)viewStatistics
{
    NSLog(@"view stastics");
    StatisticsViewController *statitics_contrller = [[StatisticsViewController alloc] init];
    
    /* animation */
    [PublicFunctions animationForViewAppearOrDisappear:self.view Transition:kCATransitionFromRight Type:kCATransitionPush];
    
    [self presentViewController:statitics_contrller animated:NO completion:nil];
}


#pragma mark - Button actions
- (void)showMenu
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:10];
    
    /* add bill item */
    RESideMenuItem *addBillItem = [[RESideMenuItem alloc] initWithTitle:@"Add Bill" action:^(RESideMenu *menu, RESideMenuItem *item) {
        
        isAlertDelete = NO; // alert add bill
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add Bill" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alertView show];
    }];
    [items addObject:addBillItem];
    
    /* bill items */
    NSArray *bill_list = [billDB getBillList];
    /* save to local */
    [PublicFunctions saveBillList:bill_list];
    for (BillObject *bill in bill_list) {
        RESideMenuItem *item = [[RESideMenuItem alloc] initWithTitle:bill.name action:^(RESideMenu *menu, RESideMenuItem *item) {
            
            /* save selected bill */
            [PublicFunctions saveBill:bill];
            /* reload data */
            [self refreshRecordList];
            
            [menu hide];
        }];
        
        [items addObject:item];
    }
    
    /* setting item */
    RESideMenuItem *settingItem = [[RESideMenuItem alloc] initWithTitle:@"Setting" action:^(RESideMenu *menu, RESideMenuItem *item) {
        
        [menu hide];
        NSLog(@"Setting");
        
        /* present setting view */
        SettingTableViewController *setting_view = [[SettingTableViewController alloc] init];
        SettingNavigationController *setting_nav_view = [[SettingNavigationController alloc] initWithRootViewController:setting_view];
        [PublicFunctions animationForViewAppearOrDisappear:self.view Transition:kCATransitionFromTop Type:kCATransitionPush];
        [self presentViewController:setting_nav_view animated:NO completion:nil];
    }];
    [items addObject:settingItem];
    
    _sideMenu = [[RESideMenu alloc] initWithItems:items];
    _sideMenu.verticalOffset = IS_WIDESCREEN ? 110 : 76;
    _sideMenu.hideStatusBarArea = [PublicFunctions OSVersion] < 7;

    [_sideMenu show];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /* delete record */
    if (isAlertDelete) {
        if (buttonIndex == 1) {
            if (currentRecord) {
                BOOL is_updated = NO;
                BOOL is_deleted = NO;
                BillObject *update_bill = [PublicFunctions getBill];
                /* if income, minus value of minus */
                if ([currentRecord.category isEqualToString:@"0"]) {
                    update_bill.input = [NSString stringWithFormat:@"%.2f", (update_bill.input.floatValue - [PublicFunctions getFloatValueOfString:currentRecord.cost])];
                }
                /* if cost, minus value of cost */
                else{
                    update_bill.output = [NSString stringWithFormat:@"%.2f", (update_bill.output.floatValue - [PublicFunctions getFloatValueOfString:currentRecord.cost])];
                }
                /* update bill */
                is_updated = [billDB updateBill:update_bill];
                if (is_updated) {
                    /* delete record */
                    is_deleted = [billDB deleteRecord:currentRecord.recordId];
                    if (is_deleted) {
                        /* remove subBtns of cell */
                        [self removeSubBtns:self];
                        
                        /* save current bill */
                        [PublicFunctions saveBill:update_bill];
                        
                        /* refresh */
                        [self refreshRecordList];
                    }
                }
                currentRecord = nil;
            }
        }
        else{
            [self removeSubBtns:self];
        }
    }
    else{
        /* add new bill */
        UITextField *text_field = [alertView textFieldAtIndex:0];
        /* ok */
        if (buttonIndex == 1) {
            NSLog(@"text: %@", text_field.text);
            if (text_field.text) {
                NSString *current_time = [PublicFunctions getCurrentDateByMS];
                NSLog(@"seconds:%@", current_time);
                BillObject *bill = [[BillObject alloc] initWithIdAndName:nil BillName:text_field.text InputCost:@"0.00" OutputCost:@"0.00" AddedTime:current_time];
                
                if ([billDB createBill:bill]) {
                    /* get bill added just now by time */
                    bill = [billDB getBillByTime:current_time];
                    [PublicFunctions saveBill:bill];    // save bill
                    /* reload data */
                    [self refreshRecordList];
                    
                    /* hide menu */
                    [_sideMenu hide];
                }
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self removeSubBtns:self];
}

#pragma mark - Receive memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _sideMenu = nil;
    billDB = nil;
    headerView = nil;
    myTableView = nil;
    recordList = nil;
    
    /* remove observer */
    [[NSNotificationCenter defaultCenter] removeObserver:nil forKeyPath:@"recordAddedOrEdit"];
    [[NSNotificationCenter defaultCenter] removeObserver:nil forKeyPath:@"BillNameChanged"];
}


@end
