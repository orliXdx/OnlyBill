//
//  RecordObject.m
//  OnlyBill
//
//  Created by Orientationsys on 14-12-14.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import "RecordObject.h"

@implementation RecordObject

@synthesize recordId, cost, remarks, date, category, picture, billId;

- (id)initWithInfo
{
    self = [super init];
    
    return  self;
}

@end
