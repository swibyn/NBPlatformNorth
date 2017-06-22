//
//  NSDictionary+FileExtend.m
//  CaSimDemo
//
//  Created by s on 16/4/12.
//  Copyright © 2016年 Sunward. All rights reserved.
//

#import "NSDictionary+FileExtend.h"

@implementation NSDictionary (FileExtend)

-(NSString *)fileDetail
{
    double filesizeM = [self fileSize] * 1.0/(1024*1024);
    
//    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return  [NSString stringWithFormat:@"%fMB, %@",filesizeM,[dateformatter stringFromDate:[self fileModificationDate]]];
}

-(NSString *)filePath
{
    return self[@"filePath"];
}

@end

@implementation NSMutableDictionary (FileExtend)

-(void)setFilePath:(NSString *)filePath
{
    self[@"filePath"] = filePath;
}

@end