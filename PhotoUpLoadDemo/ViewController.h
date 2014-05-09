//
//  ViewController.h
//  PhotoUpLoadDemo
//
//  Created by FengXingTianXia on 14-2-17.
//  Copyright (c) 2014年 Clover. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *imageScroll;
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;

@end
