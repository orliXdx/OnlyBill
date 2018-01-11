//
//  BillDB.h
//  OnlyBill
//
//  Created by Orientationsys on 14-12-15.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDBManager.h"
#import "RecordObject.h"
#import "BillObject.h"


@interface BillDB : NSObject {
    FMDatabase * _db;
}

/**
 * @brief 创建数据库
 */
- (void) createDataBase;

/* bill */
- (BOOL) createBill:(BillObject *)bill;

- (NSArray *)getBillList;

- (BillObject *)getBillByTime:(NSString *)time;

- (BOOL) updateBill:(BillObject *)bill;

- (BOOL) deleteBill:(NSString *)billId;

- (BOOL) deleteRecordListByBillId:(NSString *)billId;

/* record */
- (BOOL) createRecordToBill:(RecordObject *)record;

- (NSArray *)getRecordListByBillId:(NSString *)billId;

- (BOOL) updateRecord:(RecordObject *)record;

- (BOOL) deleteRecord:(NSString *)recordId;


@end
