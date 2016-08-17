//
//  ViewController.m
//  PushImgaes
//
//  Created by  Asura on 16/8/17.
//  Copyright © 2016年 wangfeng. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>

@interface ViewController ()

//图片数据源

@property(nonatomic,strong)NSMutableArray *images;

//标示的下标

@property(nonatomic,assign)NSUInteger index;

//第一种失败回调所需存储失败数据

@property(nonatomic,strong)NSMutableArray *faileIndexs;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self test];
}

- (void)test{
    
    _images = [@[[UIImage imageNamed:@"scenery1.jpg"], [UIImage imageNamed:@"scenery2.jpg"], [UIImage imageNamed:@"scenery3.jpg"], [UIImage imageNamed:@"scenery4.jpg"]]mutableCopy];
    
    _faileIndexs = [NSMutableArray array];
    
    //上传图片
    
    [self updateImage:_images[0]completion:^(NSUInteger index,BOOL isSuccess) {
        
        //1.失败回调1的情况处理
        
        if(isSuccess) {
            
            if(index ==_images.count) {
                
                NSLog(@"上传完毕,失败的张数为:%@",_faileIndexs);
                
            }
            NSLog(@"上传过程第%lu张成功",index);
            
        }else{
            
            if(index ==_images.count) {
                
                NSLog(@"上传完毕,失败的张数为:%@",_faileIndexs);
                
            }
            [_faileIndexs addObject:@(index)];
            
            NSLog(@"上传过程第%lu张失败",index);
            
        }
        
        //2.失败回调2的情况处理
        
        /*
         
         if (isSuccess) {
         
         if (index == _images.count) {
         
         //上传所有图片的成功
         
         NSLog(@"上传所有的成功");
         
         }
         
         NSLog(@"上传过程第%lu张成功",index);
         
         }else{
         
         //上传图片失败
         
         NSLog(@"上传图片失败,止于第%lu张",index);
         
         }
         
         */
        
    }];
  
}

//3.上传图片的递归算法函数

- (void)updateImage:(UIImage*)image completion:(void(^)(NSUInteger index,BOOL isSuccess))completion{
    
    //压缩图片,看自己的要求压缩比例设置compressionQuality参数,此参数最好在2-7之间.太小泽压缩容易失真,太大占用内存太大
    
    NSData *dataImage = UIImageJPEGRepresentation(image,0.3);
    
    //转换的参数有四个枚举,分别为:
    
    // NSDataBase64Encoding64CharacterLineLength = 1UL << 0,将最大行长度设置为64个字符,插入你所指定的那一行
    
    // NSDataBase64Encoding76CharacterLineLength = 1UL << 1,将最大行长度设置为76个字符,插入你所指定的那一行
    
    //以下可以控制结束行数的:
    
    // NSDataBase64EncodingEndLineWithCarriageReturn = 1UL << 4,设置最大行长度64个字符,并可以指定在哪行结束
    
    // NSDataBase64EncodingEndLineWithLineFeed = 1UL << 5,指定最大行长度76个字符，并指定在哪行结束
    
    //这个转换可以自行google base64加密
    
    NSString *imageStr = [dataImage base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    [self GET:@"url"parameter:@{@"youparmater": imageStr,@"id": [NSString stringWithFormat:@"%u",arc4random() %2]}success:^(id respondObject) {
        
        //如果上传成功
        
        _index++;
        
        //回调
        completion(_index,YES);
        
        if(_index==_images.count) {
            
            //全部上传成功
            
            //清空标示
            
            _index=0;
            
            return;
        }
        //继续下一行张
        
        [self updateImage:_images[_index]completion:completion];
        
    }failure:^(NSError*error) {
        
        //先判断是否是最后一张,如果是,则返回
        
        if(_index==_images.count-1) {
            
            completion(_index+1,NO);
            
            //清空标示
            
            _index=0;
            
            return;
            
        }
        //失败,分两种情况:
        
        //1.跳过失败的那张,返回失败信息,继续下张上传
        
        _index++;
        
        completion(_index,NO);
        
        [self updateImage:_images[_index]completion:completion];
        
        //2.直接返回,不在进行接下来的上传工作
        
        /*
         
         completion(_index + 1, NO);
         
         //清空标示
         
         _index = 0;
         
         return ;
         
         */
        
    }];
}

#pragma mark -模拟网络请求-

- (void)GET:(NSString*)url

  parameter:(NSDictionary*)parmeter

    success:(void(^)(id respondObject))success

    failure:(void(^)(NSError*error))failure{
    
    NSError*error;
    
    if([parmeter[@"id"]isEqualToString:@"0"]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
            
            failure(error);
            
        });
        
    }else{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
            
            success(@"");
            
        });
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
