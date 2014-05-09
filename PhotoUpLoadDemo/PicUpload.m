//
//  PicUpload.m
//  haircut
//
//  Created by FengXingTianXia on 14-2-14.
//  Copyright (c) 2014年 Clover. All rights reserved.
//

#import "PicUpload.h"
#import "SVProgressHUD.h"
#import "SBJson.h"
#import "Singleton.h"
@implementation PicUpload
static NSString * const FORM_FLE_INPUT = @"file1";

+ (NSString *)postRequestWithURL: (NSString *)url
                      postParems: (NSMutableDictionary *)postParems
                     picFilePath: (NSMutableArray *)picFilePath
                     picFileName: (NSMutableArray *)picFileName
{
    
    
     NSString *hyphens = @"--";
     NSString *boundary = @"*****";
     NSString *end = @"\r\n";
    
    NSMutableData *myRequestData1=[NSMutableData data];
    //遍历数组，添加多张图片
    for (int i = 0; i < picFilePath.count; i ++) {
        NSData* data;
        UIImage *image=[UIImage imageWithContentsOfFile:[picFilePath objectAtIndex:i]];
        //判断图片是不是png格式的文件
        if (UIImagePNGRepresentation(image)) {
            //返回为png图像。
            data = UIImagePNGRepresentation(image);
        }else {
            //返回为JPEG图像。
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        
        
        [myRequestData1 appendData:[hyphens dataUsingEncoding:NSUTF8StringEncoding]];
        [myRequestData1 appendData:[boundary dataUsingEncoding:NSUTF8StringEncoding]];
        [myRequestData1 appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableString *fileTitle=[[NSMutableString alloc]init];
        
        [fileTitle appendFormat:@"Content-Disposition:form-data;name=\"%@\";filename=\"%@\"",[NSString stringWithFormat:@"file%d",i+1],[NSString stringWithFormat:@"image%d.png",i+1]];
        
        [fileTitle appendString:end];
        
        [fileTitle appendString:[NSString stringWithFormat:@"Content-Type:application/octet-stream%@",end]];
         [fileTitle appendString:end];
        
        [myRequestData1 appendData:[fileTitle dataUsingEncoding:NSUTF8StringEncoding]];
        
        [myRequestData1 appendData:data];
        
        [myRequestData1 appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];

        }
    
    
    [myRequestData1 appendData:[hyphens dataUsingEncoding:NSUTF8StringEncoding]];
    [myRequestData1 appendData:[boundary dataUsingEncoding:NSUTF8StringEncoding]];
    [myRequestData1 appendData:[hyphens dataUsingEncoding:NSUTF8StringEncoding]];
    [myRequestData1 appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];

    
    //参数的集合的所有key的集合
    NSArray *keys= [postParems allKeys];
    
    //遍历keys，添加其他参数
    for(int i=0;i<[keys count];i++)
    {
        
        NSMutableString *body=[[NSMutableString alloc]init];
         [body appendString:hyphens];
         [body appendString:boundary];
         [body appendString:end];
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        //添加字段名称
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"",key];
        
        [body appendString:end];
        
        [body appendString:end];
        //添加字段的值
        [body appendFormat:@"%@",[postParems objectForKey:key]];
        
        [body appendString:end];
        
         [myRequestData1 appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"添加字段的值==%@",[postParems objectForKey:key]);
    }

    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];
    
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",boundary];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", [myRequestData1 length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData1];
    //http method
    [request setHTTPMethod:@"POST"];
    
    
    
    NSHTTPURLResponse *urlResponese = nil;
    NSError *error = [[NSError alloc]init];
    
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponese error:&error];
    NSString* result= [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    
    if([urlResponese statusCode] >=200&&[urlResponese statusCode]<300){
        NSLog(@"返回结果=====%@",result);
        SBJsonParser *parser = [[SBJsonParser alloc ] init];
        NSDictionary *jsonobj = [parser objectWithString:result];
        
        if (jsonobj == nil || (id)jsonobj == [NSNull null] || [[jsonobj objectForKey:@"flag"] intValue] == 0)
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"dissmissSVP" object:nil];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"上传失败." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"dissmissSVP" object:nil];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"上传成功." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            });
        }
        
        return result;
    }
    else if (error) {
        NSLog(@"%@",error);
            [[NSNotificationCenter defaultCenter]postNotificationName:@"dissmissSVP" object:nil];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"上传失败." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return nil;
        
    }
    else
        return nil;
    
}


//+ (UIImage *) imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize) newSize{
//    newSize.height=image.size.height*(newSize.width/image.size.width);
//    UIGraphicsBeginImageContext(newSize);
//    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return  newImage;
//    
//}
//
//
//+ (NSString *)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName{
//    NSData* imageData;
//    
//    //判断图片是不是png格式的文件
//    if (UIImagePNGRepresentation(tempImage)) {
//        //返回为png图像。
//        imageData = UIImagePNGRepresentation(tempImage);
//    }else {
//        //返回为JPEG图像。
//        imageData = UIImageJPEGRepresentation(tempImage, 1.0);
//    }
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    
//    NSString* documentsDirectory = [paths objectAtIndex:0];
//    
//    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
//    
//    NSArray *nameAry=[fullPathToFile componentsSeparatedByString:@"/"];
//    NSLog(@"===fullPathToFile===%@",fullPathToFile);
//    NSLog(@"===FileName===%@",[nameAry objectAtIndex:[nameAry count]-1]);
//    
//    [imageData writeToFile:fullPathToFile atomically:NO];
//    return fullPathToFile;
//}
//
//
//+ (NSString *)generateUuidString{
//    // create a new UUID which you own
//    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
//    
//    // create a new CFStringRef (toll-free bridged to NSString)
//    // that you own
//    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
//    
//    // transfer ownership of the string
//    // to the autorelease pool
//    
//    // release the UUID
//    
//    
//    return uuidString;
//}


@end
