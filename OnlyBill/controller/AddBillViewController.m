//
//  AddBillViewController.m
//  OnlyBill
//
//  Created by Orientationsys on 14-11-26.
//  Copyright (c) 2014年 Xu. All rights reserved.
//

#import "AddBillViewController.h"
#import "PublicFunctions.h"
#import "DatePickerButton.h"
#import "BillDB.h"
#import "WaterDropButton.h"

#define ORIGINAL_MAX_WIDTH  (640.f)
#define TYPE_BUTTON_HEIGHT  (35.f)
#define PATH_ANIMATION_DURATION (0.4f)

@interface AddBillViewController ()

@end

@implementation AddBillViewController
{
    UIPageControl *pageControl;
    UIScrollView *myScrollView;
    NumberKeyboardView *keyBoardView;
    DatePickerButton *datePickerButton;
    
    /* icons and names */
    NSArray *firstRowImages;
    NSArray *firstRowNames;
    NSArray *secondRowImages;
    NSArray *secondRowNames;
    
    /* all the data */
    NSString *recordId;
    NSString *date;
    NSString *remarks;
    NSString *cost;
    NSString *pictureName;
    UIImage  *picture;
    NSString *billId;
    NSString *category;
    NSString *oldCategory;  // for edit.
    
    BillDB *billDB;
    RecordObject *record;
    BOOL isEdit;
    BOOL isPictureNewSet;
    
    CALayer *pathLayer;
}

- (id)initWithRecord:(RecordObject *)editRecord
{
    self = [super init];
    if (self) {
        isEdit = YES;
        record = editRecord;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* init database */
    billDB   = [[BillDB alloc] init];
    
    /* init info of record */
    [self initInfo];
    
    /* init images. */
    [self initTypeButtonImages];
    
    /* date header */
    [self addHeader];
    
    /* scroll view */
    [self addScrollView];
    
    /* number keyboard */
    [self addNumberKeyboard];
}

- (void)initInfo
{
    /* get billId */
    BillObject *bill = [PublicFunctions getBill];
    billId = bill.billId;
    
    /* if edit record */
    if (record) {
        remarks = record.remarks;
        category = record.category;
        oldCategory = category;
        cost = record.cost;
        date = record.date;
        /* get picture */
        pictureName = record.picture;
        picture = [UIImage imageWithData:[PublicFunctions getPictureByName:pictureName]];
        if (picture) {
            isPictureNewSet = NO;
        }
    }
    /* if add record */
    else{
        isEdit = NO;
        
        remarks = @"";
        category = @"1";    // tag of common icon
        cost = @"$0.00";
        pictureName = @"";
        picture = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated;
{
    
}

/* init type button images */
- (void)initTypeButtonImages
{
    if (!firstRowImages && !secondRowImages) {
        firstRowImages = [[NSArray alloc] initWithObjects:
                          [UIImage imageNamed:@"income.png"],
                          [UIImage imageNamed:@"common.png"],
                          [UIImage imageNamed:@"eating.png"],
                          [UIImage imageNamed:@"fruits.png"],
                          [UIImage imageNamed:@"snacks.png"],
                          [UIImage imageNamed:@"live.png"],
                          [UIImage imageNamed:@"pets.png"],
                          [UIImage imageNamed:@"films.png"],
                          [UIImage imageNamed:@"games.png"],
                          [UIImage imageNamed:@"gamble.png"], nil];
        firstRowNames = [[NSArray alloc] initWithObjects:@"income",
                         @"common", @"eating", @"fruits",
                         @"snacks", @"live", @"pets", @"films",
                         @"games", @"gamble", nil];
        
        secondRowImages = [[NSArray alloc] initWithObjects:
                        [UIImage imageNamed:@"shopping.png"],
                        [UIImage imageNamed:@"cards.png"],
                        [UIImage imageNamed:@"cloth.png"],
                        [UIImage imageNamed:@"shoes.png"],
                        [UIImage imageNamed:@"transport.png"],
                        [UIImage imageNamed:@"digital.png"],
                        [UIImage imageNamed:@"phone.png"],
                        [UIImage imageNamed:@"doctor.png"],
                        [UIImage imageNamed:@"smoking.png"],
                        [UIImage imageNamed:@"drinking.png"], nil];
        secondRowNames = [[NSArray alloc] initWithObjects:@"shopping",
                         @"cards", @"cloth", @"shoes",
                         @"transport", @"digital", @"phone", @"doctor",
                         @"smoking", @"drinking", nil];
    }
}

/* add header, remarks button, date pickerView and close button */
- (void)addHeader
{
    CGRect screen = [PublicFunctions getMainScreen];
    /* add remarks button */
    UIButton *remarks_button = [[UIButton alloc] initWithFrame:CGRectMake(10.f, screen.origin.y+STATUS_BAR_HEIGHT+10.f, BUTTON_SIZE, BUTTON_SIZE)];
    [remarks_button setImage:[FontAwesome imageWithIcon:fa_bookmark_o iconColor:[UIColor darkGrayColor] iconSize:BUTTON_SIZE] forState:UIControlStateNormal];
    [remarks_button addTarget:self action:@selector(addRemarks) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:remarks_button];
    
    /* add date picker */
    datePickerButton = [[DatePickerButton alloc] initWithFrame:CGRectMake(([PublicFunctions getWidthOfMainScreen]-DATE_BUTTON_WIDTH)/2, screen.origin.y+STATUS_BAR_HEIGHT+10.f, DATE_BUTTON_WIDTH, BUTTON_SIZE)];
    [datePickerButton setFatherView:self.view];
    /* if edit record, set date of record */
    if (record && date) {        
        [datePickerButton setTitle:date forState:UIControlStateNormal];
    }
    [self.view addSubview:datePickerButton];
    
    /* add close button */
    WaterDropButton *close_button = [[WaterDropButton alloc] initWithFrame:CGRectMake([PublicFunctions getWidthOfMainScreen]-STATUS_BAR_HEIGHT*2, screen.origin.y+STATUS_BAR_HEIGHT+10.f, BUTTON_SIZE, BUTTON_SIZE)];
    [close_button setBorderSize:1.f];
    [close_button setImage:[UIImage imageNamed:@"cancel-50.png"] forState:UIControlStateNormal];
    [close_button addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:close_button];
}

/* add remarks */
- (void)addRemarks
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Remarks" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    // set remarks, if has.
    if (remarks) {
        UITextField *text_field = [alert textFieldAtIndex:0];
        [text_field setText:remarks];
    }
    
    [alert show];
}

/* UIAlertDelegate */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *text_field = [alertView textFieldAtIndex:0];
    // ok
    if (buttonIndex == 1) {
        remarks = [text_field text];
    }
}

/* close view */
- (void)closeView
{
    if (self) {
        /* set transition style */
        CATransition *animation = [CATransition animation];
        [animation setDuration:1.f];
        [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
        [animation setType:@"rippleEffect"];
        [animation setSubtype:kCATransitionFromBottom];
        [self.view.window.layer addAnimation:animation forKey:nil];
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

/* add scroll view */
- (void)addScrollView
{
    CGRect screen = [PublicFunctions getMainScreen];
    float height = screen.size.height - screen.origin.y - (STATUS_BAR_HEIGHT+10.f)*2 - KEY_BOARD_HEIGHT;
    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, screen.origin.y + (STATUS_BAR_HEIGHT+10.f)*2, [PublicFunctions getWidthOfMainScreen], height)];
    [myScrollView setContentSize:CGSizeMake([PublicFunctions getWidthOfMainScreen]*2, height)];
    [myScrollView setPagingEnabled:YES];
    [myScrollView setShowsHorizontalScrollIndicator:NO];
    [myScrollView setShowsVerticalScrollIndicator:NO];
    [myScrollView setScrollsToTop:NO];
    [myScrollView setDelegate:self];
    [myScrollView setBackgroundColor:[UIColor clearColor]];
    /* set center */
    [myScrollView setCenter:CGPointMake(screen.size.width/2, (screen.size.height-KEY_BOARD_HEIGHT+screen.origin.y+(STATUS_BAR_HEIGHT+10.f)*2)/2)];
    for (int i=0; i<10; i++) {
        float interval = i * ([PublicFunctions getWidthOfMainScreen]-20.f)/5 + 20.f;
        if (interval >= [PublicFunctions getWidthOfMainScreen]) {
            interval += 20.f;
        }
        /* first row */
        UIButton *up_button = [self createTypeButton:interval ScaleY:height/5 Image:[firstRowImages objectAtIndex:i] Tag:i];
        [myScrollView addSubview:up_button];

        UILabel *up_label = [self createNameLabelOfTypeButton:interval ScaleY:height/5+TYPE_BUTTON_HEIGHT Name:[firstRowNames objectAtIndex:i]];
        
        /* income icon */
        if (i == 0) {
            [up_label setTextColor:[PublicFunctions getIncomeColor]];
        }
        [myScrollView addSubview:up_label];
        
        /* second row */
        UIButton *down_btn = [self createTypeButton:interval ScaleY:height/5*3 Image:[secondRowImages objectAtIndex:i] Tag:i+10];
        [myScrollView addSubview:down_btn];
        
        UILabel *down_label = [self createNameLabelOfTypeButton:interval ScaleY:height/5*3+TYPE_BUTTON_HEIGHT Name:[secondRowNames objectAtIndex:i]];
        [myScrollView addSubview:down_label];
    }
    
    [self.view addSubview:myScrollView];
    
    /* add pageControl */
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(([PublicFunctions getWidthOfMainScreen]-PAGE_CONTROL_WIDTH)/2, screen.size.height-KEY_BOARD_HEIGHT-STATUS_BAR_HEIGHT*2, PAGE_CONTROL_WIDTH, 20.f)];
    [pageControl setCenter:CGPointMake(screen.size.width/2, (2*(screen.size.height-KEY_BOARD_HEIGHT)-30.f)/2)];
    [pageControl setNumberOfPages:2];
    // set page indicator
    [pageControl setCurrentPageIndicatorTintColor:[UIColor blackColor]];
    [pageControl setPageIndicatorTintColor:[UIColor grayColor]];
    [self.view addSubview:pageControl];
}

/* create type button */
- (UIButton *)createTypeButton:(float)scaleX ScaleY:(float)scaleY Image:(UIImage *)image Tag:(int)tag
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(scaleX, scaleY, TYPE_BUTTON_HEIGHT, TYPE_BUTTON_HEIGHT)];
    [button setImage:image forState:UIControlStateNormal];
    [button setTag:tag];    // sign the tag of icon
    [button addTarget:self action:@selector(chooseType:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

/* type button click */
- (void)chooseType:(id)sender
{
    UIButton *button = (UIButton *)sender;
    category = [NSString stringWithFormat:@"%ld", (long)button.tag];
    UIImage *image = button.imageView.image;

    if (keyBoardView && image) {
        /* path Animation */
        [self pathAnimation:button.imageView StartParentView:button EndView:keyBoardView.typeButton EndParentView:keyBoardView];
        
        /* delay 0.5 second(when path animation is okay) */
        [self performSelector:@selector(setTypeButtonImage:) withObject:image afterDelay:PATH_ANIMATION_DURATION];
    }
}

/* set selected type icon */
- (void)setTypeButtonImage:(id)image
{
    [keyBoardView.typeButton setImage:image forState:UIControlStateNormal];
    [keyBoardView.typeLabel setText:[PublicFunctions getCategory:category]];
    if ([category isEqualToString:@"0"]) {
        [keyBoardView.typeLabel setTextColor:[PublicFunctions getIncomeColor]];
    }
    else{
        [keyBoardView.typeLabel setTextColor:[UIColor blackColor]];
    }
}

/* create name label of type button */
- (UILabel *)createNameLabelOfTypeButton:(float)scaleX ScaleY:(float)scaleY Name:(NSString *)name
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(scaleX, scaleY, 40.f, 20.f)];
    [label setText:name];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:8.f]];
    
    return label;
}

/* path animation (Test)*/
- (void)pathAnimation:(UIView *)startView StartParentView:(UIView *)startParentView EndView:(UIView *)endView EndParentView:(UIView *)endParentView
{
    if (pathLayer) {
        [pathLayer removeAnimationForKey:@"pathAnimation"];
        [pathLayer removeFromSuperlayer];
    }
    pathLayer = [[CALayer alloc] init];
    pathLayer.contents = startView.layer.contents;
    pathLayer.frame    = startView.frame;
    pathLayer.opacity  = 1;
    [self.view.layer addSublayer:pathLayer];
    
    /* Bezier */
    UIBezierPath *path=[UIBezierPath bezierPath];
    
    /* start point */
    CGPoint start_point = [self.view convertPoint:startView.center fromView:startParentView];
    /* end point */
    CGPoint end_point = [self.view convertPoint:endView.center fromView:endParentView];
    NSLog(@"start(%f, %f) ----- end(%f, %f)", start_point.x, start_point.y, end_point.x, end_point.y);
    
    [path moveToPoint:start_point];
    
    /* center point of bezier */
    float center_x = start_point.x + (end_point.x - start_point.x) / 2;
    float center_y;
    if (start_point.x < 150.f) {
        center_y = start_point.y + (end_point.y - start_point.y) * 0.5 - 200 + start_point.x;
    }
    else if (start_point.x < 200.f){
        center_y = start_point.y + (end_point.y - start_point.y) * 0.5 - 300 + start_point.x;
    }
    else{
        center_y = start_point.y + (end_point.y - start_point.y) * 0.5 - 400 + start_point.x;
    }
    
    
    
    CGPoint center_point = CGPointMake(center_x, center_y);
    [path addQuadCurveToPoint:end_point controlPoint:center_point];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path.CGPath;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = PATH_ANIMATION_DURATION;
    animation.repeatCount = 1;
    animation.delegate = self;
    animation.autoreverses = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [pathLayer addAnimation:animation forKey:@"pathAnimation"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    id animation = [anim valueForKey:@"pathAnimation"];
    NSLog(@"%@", animation);
    
    if (pathLayer) {
        [pathLayer removeAnimationForKey:@"pathAnimation"];
        [pathLayer removeFromSuperlayer];
    }
}

/* add date pickerView */
- (void)addNumberKeyboard
{
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"NumberKeyboardView" owner:self options:nil];
    keyBoardView = (NumberKeyboardView *)[nibs objectAtIndex:0];
    CGRect screen = [PublicFunctions getMainScreen];
    CGRect frame = CGRectMake(0, screen.size.height - 245.f, [PublicFunctions getWidthOfMainScreen], 245.f);
    keyBoardView.frame = frame;
    [keyBoardView setBackgroundColor:[UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1.f]];
    
    /* set default icon and label */
    [keyBoardView.typeButton setImage:[UIImage imageNamed:[PublicFunctions getCategory:category]] forState:UIControlStateNormal];
    [keyBoardView.typeLabel setText:[PublicFunctions getCategory:category]];
    if ([category isEqualToString:@"0"]) {
        [keyBoardView.typeLabel setTextColor:[PublicFunctions getIncomeColor]];
    }
    /* set default cost */
    [keyBoardView.costLabel setText:cost];
    [keyBoardView setCostString:[NSMutableString stringWithString:cost]];
    
    /* set default picture(if has) */
    if (picture) {
        [keyBoardView.photoButton setImage:picture forState:UIControlStateNormal];
    }
    
    /* ok button click */
    __block AddBillViewController *block_self = self;
    keyBoardView.okClickBlock = ^(NSString *costString, UIImage *image){
        NSLog(@"cost:%@", costString);
        
        if ([block_self isValidCost:costString] == NO) {
            /* if cost=0, shaking */
            [PublicFunctions shakeAnimationForView:block_self->keyBoardView.costLabel];
            return;
        }
        
        /* create record object */
        if (block_self->record == nil) {
            block_self->record = [[RecordObject alloc] init];
        }
        block_self->record.cost = costString;
        block_self->record.date = block_self->datePickerButton.titleLabel.text;
        block_self->record.remarks  = block_self->remarks;
        block_self->record.category = block_self->category;
        block_self->record.billId   = block_self->billId;
        if (block_self->isEdit == NO) {
            block_self->record.picture  = block_self->pictureName;
        }
        
        BillObject *update_bill = [PublicFunctions getBill];
        BOOL is_created_or_edit = NO;
        /* edit record */
        if (block_self->isEdit) {
            is_created_or_edit = [block_self->billDB updateRecord:block_self->record];
            if (block_self->isPictureNewSet) {
                /* update picture to userdefaults */
                [PublicFunctions savePictureWithName:block_self->picture Name:block_self->record.picture];
            }
            
            /* update bill input or output */
            float quntity = [PublicFunctions getFloatValueOfString:block_self->record.cost];
            float dif_value = 0.f;
            
            //  input
            if ([block_self->category isEqualToString:@"0"]) {
                // income -> income
                if ([block_self->oldCategory isEqualToString:@"0"]) {
                    dif_value = quntity - [PublicFunctions getFloatValueOfString:block_self->cost];
                    update_bill.input = [NSString stringWithFormat:@"%.2f", dif_value + [update_bill.input floatValue]];
                }
                // cost -> income
                else{
                    update_bill.output = [NSString stringWithFormat:@"%.2f", [update_bill.output floatValue] - [PublicFunctions getFloatValueOfString:block_self->cost]];
                    update_bill.input = [NSString stringWithFormat:@"%.2f", quntity + [update_bill.input floatValue]];
                }
            }
            //  output
            else{
                // income -> cost
                if ([block_self->oldCategory isEqualToString:@"0"]) {
                    update_bill.input = [NSString stringWithFormat:@"%.2f", [update_bill.input floatValue] - [PublicFunctions getFloatValueOfString:block_self->cost]];
                    update_bill.output = [NSString stringWithFormat:@"%.2f", quntity + [update_bill.output floatValue]];
                }
                // cost -> cost
                else{
                    dif_value = quntity - [PublicFunctions getFloatValueOfString:block_self->cost];
                    update_bill.output = [NSString stringWithFormat:@"%.2f", dif_value + [update_bill.output floatValue]];
                }
            }
        }
        /* create record */
        else{
            is_created_or_edit = [block_self->billDB createRecordToBill:block_self->record];
            /* save picture to userdefaults */
            [PublicFunctions savePictureWithName:block_self->picture Name:block_self->pictureName];
            
            /* update bill input or output */
            float quntity = [PublicFunctions getFloatValueOfString:block_self->record.cost];
            
            //  input
            if ([block_self->category isEqualToString:@"0"]) {
                update_bill.input = [NSString stringWithFormat:@"%.2f", quntity + [update_bill.input floatValue]];
            }
            //  output
            else{
                update_bill.output = [NSString stringWithFormat:@"%.2f", quntity + [update_bill.output floatValue]];
            }
        }
        
        /* if created or edit record */
        if (is_created_or_edit) {
            BOOL is_updated = [block_self->billDB updateBill:update_bill];
            if (is_updated) {
                [PublicFunctions saveBill:update_bill];
                
                [block_self closeView];
                
                /* post notification to MainViewController */
                [[NSNotificationCenter defaultCenter] postNotificationName:@"recordAddedOrEdit" object:nil];
            }
        }
    };
    
    /* pick photo */
    keyBoardView.photoPickerBlock = ^(){
        [block_self pickPhoto];
    };
    
    [self.view addSubview:keyBoardView];
}

/* is valid cost */
- (BOOL)isValidCost:(NSString *)costString
{
    if ([PublicFunctions getFloatValueOfString:costString] > 0) {
        return YES;
    }
    
    return NO;
}


#pragma Scroll View
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    pageControl.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}


#pragma mark - UIActionSheetDelegate
/* pick photo in AddBillController */
- (void)pickPhoto
{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a photo", @"Pick a photo", nil];
    
    [choiceSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    /* copy to image */
    picture = editedImage.copy;
    pictureName = [PublicFunctions getCurrentDateByMS];
    isPictureNewSet = YES;
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        if (picture) {
            /* set photo image */
            [keyBoardView.photoButton setImage:picture forState:UIControlStateNormal];
        }
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    __block AddBillViewController *block_self = self;
    if (buttonIndex == 0) {
        // take a photo
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            //            if ([self isFrontCameraAvailable]) {
            //                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            //            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // Pick a photo
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
