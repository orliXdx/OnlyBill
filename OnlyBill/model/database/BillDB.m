//
//  BillDB.m
//  OnlyBill
//
//  Created by Orientationsys on 14-12-15.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import "BillDB.h"

#define recordTableName @"SRecord"
#define billTableName @"SBill"

@implementation BillDB

- (id) init {
    self = [super init];
    if (self) {
        /* ---首先查看有没有建立message的数据库，如果未建立，则建立数据库--- */
        _db = [SDBManager defaultDBManager].dataBase;    
    }
    
    return self;
}

/**
 * @brief 创建数据库
 */
- (void) createDataBase {
    /* bill table */
    FMResultSet * cartSet = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",billTableName]];
    [cartSet next];
    NSInteger cartCount = [cartSet intForColumnIndex:0];
    
    BOOL existBillTable = !!cartCount;
    if (!existBillTable) {
        NSString * sql = @"CREATE TABLE SBill (bid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(100) NOT NULL, input VARCHAR(20), output VARCHAR(20), addedTime VARCHAR(50))";
        [_db executeUpdate:sql];
    }
    
    /* record table */
    FMResultSet * record_set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",recordTableName]];
    [record_set next];
    NSInteger count = [record_set intForColumnIndex:0];
    
    BOOL existRecordTable = !!count;
    if (!existRecordTable) {
        NSString * sql = @"CREATE TABLE SRecord (rid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, bid INTEGER NOT NULL, cost VARCHAR(50), remarks VARCHAR(100), date VARCHAR(50), category VARCHAR(10), picture VARCHAR(50))";
        [_db executeUpdate:sql];
    }
}


/* create bill */
- (BOOL)createBill:(BillObject *)bill
{
    NSString *query = [NSString stringWithFormat:@"INSERT INTO SBill (name, input, output, addedTime) VALUES ('%@', '%@', '%@', '%@')", bill.name, bill.input, bill.output, bill.addedTime];

    return [_db executeUpdate:query];
}

/* get bill list */
- (NSArray *)getBillList
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM SBill"];
    FMResultSet *rs = [_db executeQuery:query];
    NSMutableArray * bill_list = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    
    /* bill list */
    while ([rs next]) {
        BillObject *bill = [[BillObject alloc] initWithIdAndName:[rs stringForColumn:@"bid"] BillName:[rs stringForColumn:@"name"] InputCost:[rs stringForColumn:@"input"] OutputCost:[rs stringForColumn:@"output"] AddedTime:[rs stringForColumn:@"addedTime"]];

        [bill_list addObject:bill];
    }
    
    return bill_list;
}

/* get bill by added time */
- (BillObject *)getBillByTime:(NSString *)time
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT bid, name, input, output, addedTime FROM SBill WHERE addedTime='%@'", time];
    FMResultSet *rs = [_db executeQuery:query];
    while ([rs next]) {
        BillObject *bill = [[BillObject alloc] initWithIdAndName:[rs stringForColumn:@"bid"] BillName:[rs stringForColumn:@"name"] InputCost:[rs stringForColumn:@"input"] OutputCost:[rs stringForColumn:@"output"] AddedTime:[rs stringForColumn:@"addedTime"]];
                            
        return bill;
    }
    
    return nil;
}

/* update bill */
- (BOOL)updateBill:(BillObject *)bill
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT bid, name, input, output FROM SBill WHERE bid='%@'", bill.billId];
    FMResultSet *rs = [_db executeQuery:query];
    
    if ([rs next]) {
        NSString *query = @"UPDATE SBill SET";
        NSMutableString *temp = [NSMutableString stringWithCapacity:30];
        
        [temp appendFormat:@" name = '%@', input = '%@', output = '%@'", bill.name, bill.input, bill.output];
        
        query = [query stringByAppendingFormat:@"%@ WHERE bid = '%@'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""], bill.billId];
        NSLog(@"%@", query);
        
        return [_db executeUpdate:query];
    }
    
    return NO;
}

/* delete bill */
- (BOOL)deleteBill:(NSString *)billId
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"DELETE FROM SBill WHERE bid='%@'", billId];
    
    return [_db executeUpdate:query];
}

/* delete record list by bill id */
- (BOOL) deleteRecordListByBillId:(NSString *)billId
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"DELETE FROM SRecord WHERE bid='%@'", billId];
    
    return [_db executeUpdate:query];
}

/* create record */
- (BOOL)createRecordToBill:(RecordObject *)record
{
    return [_db executeUpdate:@"INSERT INTO SRecord (bid, cost, remarks, date, category, picture) VALUES (?, ?, ?, ?, ?, ?)", [NSNumber numberWithInteger:record.billId.integerValue], record.cost, record.remarks, record.date, record.category, record.picture];
}

/* get record list */
- (NSArray *)getRecordListByBillId:(NSString *)billId
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM SRecord WHERE bid='%@' ORDER BY date DESC", billId];
    FMResultSet *rs = [_db executeQuery:query];
    NSMutableArray * record_list = [NSMutableArray arrayWithCapacity:[rs columnCount]];
    
    /* bill list */
    while ([rs next]) {
        RecordObject *record = [[RecordObject alloc] init];
        record.recordId = [rs stringForColumn:@"rid"];
        record.billId = [rs stringForColumn:@"bid"];
        record.cost = [rs stringForColumn:@"cost"];
        record.remarks = [rs stringForColumn:@"remarks"];
        record.date = [rs stringForColumn:@"date"];
        record.category = [rs stringForColumn:@"category"];
        record.picture = [rs stringForColumn:@"picture"];
        
        [record_list addObject:record];
    }
    
    return record_list;
}

/* update record */
- (BOOL)updateRecord:(RecordObject *)record
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT rid, cost, remarks, date, category, picture FROM SRecord WHERE rid='%@'", record.recordId];
    FMResultSet *rs = [_db executeQuery:query];
    
    if ([rs next]) {
        NSString *query = @"UPDATE SRecord SET";
        NSMutableString *temp = [NSMutableString stringWithCapacity:30];
        
        [temp appendFormat:@" cost = '%@', remarks = '%@', date = '%@', category = '%@', picture='%@'", record.cost, record.remarks, record.date, record.category, record.picture];
        
        query = [query stringByAppendingFormat:@"%@ WHERE rid = '%@'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""], record.recordId];
        NSLog(@"%@", query);
        
        return [_db executeUpdate:query];
    }
    
    return NO;
}

/* delete record */
- (BOOL)deleteRecord:(NSString *)recordId
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"DELETE FROM SRecord WHERE rid='%@'", recordId];
    
    return [_db executeUpdate:query];
}




@end
