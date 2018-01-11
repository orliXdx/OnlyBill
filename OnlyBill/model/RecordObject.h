//
//  RecordObject.h
//  OnlyBill
//
//  Created by Orientationsys on 14-12-14.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordObject : NSObject

@property (nonatomic, strong) NSString *recordId;
@property (nonatomic, strong) NSString *cost;
@property (nonatomic, strong) NSString *remarks;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *billId;

@end
