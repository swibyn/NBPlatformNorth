//
//  NSDictionary+FileExtend.h
//  CaSimDemo
//
//  Created by s on 16/4/12.
//  Copyright © 2016年 Sunward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FileExtend)

-(NSString *)fileDetail;
@property (nonatomic, readonly) NSString *filePath;

@end

@interface NSMutableDictionary (FileExtend)

@property (nonatomic, readwrite) NSString *filePath;

@end
