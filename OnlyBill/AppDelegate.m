//
//  AppDelegate.m
//  OnlyBill
//
//  Created by APPLE on 14-7-16.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "BillDB.h"
#import "PublicFunctions.h"

@implementation AppDelegate
{
    BillDB *billDB;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /* create database */
    billDB = [[BillDB alloc] init];
    [billDB createDataBase];
    
    /* if no bill, create one */
    [self initBill];
    
    /* save all categories */
    [PublicFunctions saveAllCategoies];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[MainViewController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

/* create default bill(if no bill) */
- (void)initBill
{
    if (![PublicFunctions getBill]) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM"];
        NSString *bill_name = [format stringFromDate:[NSDate date]];
        BillObject *bill = [[BillObject alloc] initWithIdAndName:@"1" BillName:bill_name InputCost:@"0" OutputCost:@"0" AddedTime:[PublicFunctions getCurrentDateByMS]];
        if ([billDB createBill:bill]) {
            [PublicFunctions saveBill:bill];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}



@end
