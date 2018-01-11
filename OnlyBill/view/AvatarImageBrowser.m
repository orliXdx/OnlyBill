//
//  AvatarImageBrowser.m
//  OnlyBill
//
//  Created by Orientationsys on 15/1/25.
//  Copyright (c) 2015年 Xu. All rights reserved.
//

#import "AvatarImageBrowser.h"
#import "PublicFunctions.h"

static CGRect oldframe;
@implementation AvatarImageBrowser

/* show imageView */
+ (void)showImage:(UIImageView *)avatarImageView{
    UIImage *image = avatarImageView.image;
    /* if has image */
    if (image) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [PublicFunctions getWidthOfMainScreen], [PublicFunctions getHeightOfMainScreen])];
        oldframe = [avatarImageView convertRect:avatarImageView.bounds toView:window];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:oldframe];
        imageView.image=image;
        imageView.tag=1;
        [backgroundView addSubview:imageView];
        [window addSubview:backgroundView];
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
        [backgroundView addGestureRecognizer: tap];
        
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
            backgroundView.alpha=1;
        } completion:^(BOOL finished) {
            
        }];
    }
}


/* remove backgroundView */
+ (void)hideImage:(UITapGestureRecognizer *)tap{
    UIView *backgroundView = tap.view;
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = oldframe;
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}

@end
