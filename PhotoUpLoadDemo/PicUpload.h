//
//  PicUpload.h
//  haircut
//
//  Created by FengXingTianXia on 14-2-14.
//  Copyright (c) 2014年 Clover. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicUpload : NSObject
+ (NSString *)postRequestWithURL: (NSString *)url  // IN
                      postParems: (NSMutableDictionary *)postParems // IN
                     picFilePath: (NSMutableArray *)picFilePath  // IN
                     picFileName: (NSMutableArray *)picFileName ;

//+ (UIImage *) imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize) newSize;
//+ (NSString *)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName;
//+ (NSString *)generateUuidString;
@end
