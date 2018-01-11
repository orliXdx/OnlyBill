//
//  SDBManager.m
//  SDatabase
//
//  Created by Orientationsys on 12-10-20.
//  Copyright (c) 2014年 xu. All rights reserved.
//

#import "SDBManager.h"
#import "FMDatabase.h"

#define kDefaultDBName @"sas.sqlite"

@interface SDBManager ()

@end

@implementation SDBManager

static SDBManager * _sharedDBManager;

+ (SDBManager *) defaultDBManager {
	if (!_sharedDBManager) {
		_sharedDBManager = [[SDBManager alloc] init];
	}
    
	return _sharedDBManager;
}

- (void) dealloc {
    [self close];
}

- (id) init {
    self = [super init];
    if (self) {
        int state = [self initializeDBWithName:kDefaultDBName];
        if (state == -1) {
            NSLog(@"DB Init false");
        } else {
            NSLog(@"DB Init success");
        }
    }
    
    return self;
}

/**
 * @brief 初始化数据库操作
 * @param name 数据库名称
 * @return 返回数据库初始化状态， 0 为 已经存在，1 为创建成功，-1 为创建失败
 */
- (int) initializeDBWithName : (NSString *) name {
    if (!name) {
        // 返回数据库创建失败
		return -1;
	}
    
    // 沙盒Docu目录
    NSString * docp = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
	_name = [docp stringByAppendingString:[NSString stringWithFormat:@"/%@",name]];
	NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:_name];
    NSLog(@"Database Address: %@", _name);
    [self connect];
    if (!exist) {
        return 0;
    } else {
        // 返回 数据库已经存在
        return 1;
	}
}

/* 连接数据库 */
- (void) connect {
	if (!_dataBase) {
		_dataBase = [[FMDatabase alloc] initWithPath:_name];
	}
	if (![_dataBase open]) {
		NSLog(@"Cant open the databasse");
	}
}

/* 关闭连接 */
- (void) close {
	[_dataBase close];
    _sharedDBManager = nil;
}

@end
