//
//  BillObject.h
//  OnlyBill
//
//  Created by Orientationsys on 14/12/17.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BillObject : NSObject<NSCoding>

@property (nonatomic, strong) NSString *billId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *input;
@property (nonatomic, strong) NSString *output;
@property (nonatomic, strong) NSString *addedTime;

- (id) initWithIdAndName:(NSString *)bid BillName:(NSString *)billName InputCost:(NSString *)inputCost OutputCost:(NSString *)outputCost AddedTime:(NSString *)time;

@end
