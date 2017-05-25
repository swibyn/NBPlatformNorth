//
//  NSData_Category.m
//  EIDDemoOC
//
//  Created by s on 16/5/31.
//  Copyright © 2016年 sunward. All rights reserved.
//

#import "NSData_Category.h"

@implementation NSData (AppBack)

-(NSString *)hexString{
    NSUInteger length = self.length;
    Byte *p = malloc(length);
    [self getBytes:p length:length];
    NSMutableString *mutableStr = [NSMutableString string];
    for (int i = 0; i < length; i++) {
        [mutableStr appendFormat:@"%02X",*(p+i)];
    }
    free(p);
    return mutableStr;
}

-(NSData *)backCode{
    if (self.length > 1) {
        NSData *data = [self subdataWithRange:NSMakeRange(self.length - 2, 2)];
        return data;
    }
    return nil;
}
-(NSData *)backData{
    if (self.length > 2) {
        NSData *data = [self subdataWithRange:NSMakeRange(0, self.length - 2)];
        return data;
    }
    return nil;
}


@end












