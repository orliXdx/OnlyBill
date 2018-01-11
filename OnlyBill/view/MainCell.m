//
//  MainHeaderCell.m
//  OnlyBill
//
//  Created by Orientationsys on 14-10-28.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import "MainCell.h"
#import "RecordObject.h"
#import "PublicFunctions.h"
#import "AvatarImageBrowser.h"
#import "FontAwesome.h"

@implementation MainCell{
    DCPathButton *iconButton;
    RecordObject *currentRecord;
}

@synthesize editBtnClickBlock, deleteBtnClickBlock;
@synthesize picture, remarksLabel, costLabel, categoryLabel;

- (void)initWithRecord:(RecordObject *)record
{
    currentRecord = record;
    /* set category name */
    if ([PublicFunctions getCategory:record.category]) {
        [categoryLabel setText:[PublicFunctions getCategory:record.category]];
    }
    
    /* set cost */
    [costLabel setText:record.cost];
    if ([record.category isEqualToString:@"0"]) {
        [costLabel setTextColor:[PublicFunctions getIncomeColor]];   // if category is income, set green
    }
    else{
        [costLabel setTextColor:[UIColor blackColor]];
    }
    
    [remarksLabel setText:record.remarks];
    [picture setImage:[UIImage imageWithData:[PublicFunctions getPictureByName:record.picture]]];
    if (iconButton) {
        [iconButton.centerButton setImage:[UIImage imageNamed:[PublicFunctions getCategory:record.category]] forState:UIControlStateNormal];
    }
}

- (void)awakeFromNib
{
    /* set style none */
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    /* add addGestureRecognizer to image */
    [self.picture setUserInteractionEnabled:YES];
    [self.picture addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAvatar:)]];
    
    /* add center button */
    iconButton = [[DCPathButton alloc] initDCPathButtonWithSubButtons:2
                                               totalRadius:60.f
                                               centerRadius:10.f
                                               subRadius:20.f
                                               centerImage:@"plus.png"
                                               centerBackground:nil
                                               subImages:^(DCPathButton *dc){
                                                   [dc subButtonImage:[FontAwesome imageWithIcon:fa_minus_circle iconColor:[UIColor redColor] iconSize:20.f] withTag:0];
                                                   [dc subButtonImage:[FontAwesome imageWithIcon:fa_pencil iconColor:[UIColor darkGrayColor] iconSize:20.f] withTag:1];
                                               }
                                            subImageBackground:@"scenery_1"
                                               inLocationX:60.f locationY:40.f toParentView:self];
    iconButton.delegate = self;
    
    /* add notification for shrink sub buttons */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSubBtns:) name:@"removeSubBtns" object:nil];
}

- (void)removeSubBtns:(id)sender
{
    /* if has expanded, shrink it. */
    if (iconButton.expanded == YES) {
        [iconButton centerButtonPress];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

/* show Avatar imageView */
- (void)showAvatar:(UITapGestureRecognizer*)sender {
    [AvatarImageBrowser showImage:(UIImageView *)sender.view];
}

#pragma mark - DCPathButton delegate
- (void)button_0_action{
    if (deleteBtnClickBlock) {
        self.deleteBtnClickBlock(currentRecord);
    }
}

- (void)button_1_action{
    if (editBtnClickBlock) {
        self.editBtnClickBlock(currentRecord);
    }
}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"removeSubBtns"];
}

@end
