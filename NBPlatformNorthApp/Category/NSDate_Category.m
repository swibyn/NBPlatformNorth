//
//  NSDate_Category.m
//  NBPlatformNorthApp
//
//  Created by s on 21/06/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import "NSDate_Category.h"

@implementation NSDate (Category)

-(NSString *)myDateString{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyyMMdd HH:mm:ss";
    return [df stringFromDate:self];
    
}

@end
