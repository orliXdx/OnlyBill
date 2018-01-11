//
//  BillObject.m
//  OnlyBill
//
//  Created by Orientationsys on 14/12/17.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import "BillObject.h"

@implementation BillObject
@synthesize billId, name, input, output, addedTime;

- (id) initWithIdAndName:(NSString *)bid BillName:(NSString *)billName InputCost:(NSString *)inputCost OutputCost:(NSString *)outputCost AddedTime:(NSString *)time
{
    self = [super init];
    
    if (bid) {
        self.billId = bid;
    }
    if (billName) {
        self.name = billName;
    }
    if (inputCost) {
        self.input = inputCost;
    }
    if (outputCost) {
        self.output = outputCost;
    }
    if (time) {
        self.addedTime = time;
    }
    
    
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.billId forKey:@"billId"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.input forKey:@"input"];
    [aCoder encodeObject:self.output forKey:@"output"];
    [aCoder encodeObject:self.addedTime forKey:@"addedTime"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.billId = [aDecoder decodeObjectForKey:@"billId"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.input = [aDecoder decodeObjectForKey:@"input"];
        self.output = [aDecoder decodeObjectForKey:@"output"];
        self.addedTime = [aDecoder decodeObjectForKey:@"addedTime"];
    }
    
    return self;
}


@end
