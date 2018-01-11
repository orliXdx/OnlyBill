//
//  AddBillViewController.h
//  OnlyBill
//
//  Created by Orientationsys on 14-11-26.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberKeyboardView.h"
#import "FontAwesome.h"
#import "RecordObject.h"
#import "BillObject.h"
#import "VPImageCropperViewController.h"
#import "ImageCropper.h"

#define BUTTON_SIZE (30.f)
#define KEY_BOARD_HEIGHT (245.f)
#define DATE_BUTTON_WIDTH (110.f)
#define PAGE_CONTROL_WIDTH (120.f)

@interface AddBillViewController : UIViewController<UIScrollViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, VPImageCropperDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>


- (id)initWithRecord:(RecordObject *)editRecord;

@end
