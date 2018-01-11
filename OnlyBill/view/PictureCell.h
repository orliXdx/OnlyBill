//
//  PictureCell.h
//  OnlyBill
//
//  Created by Orientationsys on 15/2/4.
//  Copyright (c) 2015年 Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *parallaxImage;
@property (nonatomic, weak) IBOutlet UIButton *okayBtn;

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view;

@end
