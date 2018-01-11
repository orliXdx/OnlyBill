//
//  MainHeaderCell.h
//  OnlyBill
//
//  Created by Orientationsys on 14-10-28.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCPathButton.h"

@class RecordObject;

@interface MainCell : UITableViewCell<DCPathButtonDelegate>

typedef void (^EditBtnClickBlock)(RecordObject *);
typedef void (^DeleteBtnClickBlock)(RecordObject *);

@property (nonatomic, copy) EditBtnClickBlock editBtnClickBlock;
@property (nonatomic, copy) DeleteBtnClickBlock deleteBtnClickBlock;

@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *costLabel;
@property (nonatomic, weak) IBOutlet UILabel *remarksLabel;
@property (nonatomic, weak) IBOutlet UIImageView *picture;


- (void)initWithRecord:(RecordObject *)record;

@end
