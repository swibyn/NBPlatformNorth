//
//  NSArray_Category.m
//  platformNorthTest
//
//  Created by s on 22/05/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import "NSArray_Category.h"
#import "NSDictionary_Category.h"

@implementation NSArray (Category)

-(NSMutableArray*)deepMutableCopy{
    NSMutableArray *mutableSelf = [NSMutableArray array];
    for (NSObject *obj in self) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)obj;
            [mutableSelf addObject:[arr deepMutableCopy]];
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            NSDictionary *dic = (NSDictionary *)obj;
            [mutableSelf addObject:[dic deepMutableCopy]];
        }else{
            [mutableSelf addObject:obj];
        }
    }
    return mutableSelf;
}

@end
