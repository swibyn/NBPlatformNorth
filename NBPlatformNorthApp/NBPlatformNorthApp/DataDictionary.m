//
//  DataDictionary.m
//  platformNorthTest
//
//  Created by s on 22/05/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import "DataDictionary.h"


//NSMutableDictionary *appInfoDict = nil;
NSMutableDictionary *requestDict = nil;
NSMutableDictionary *responseDict = nil;

@implementation NSDictionary (Paramas)

-(NSMutableDictionary *)mutableDictionaryForKey:(NSString *)key{
    NSMutableDictionary *dict = self[key];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        [self setValue:dict forKey:key];
    }
    return dict;
}

-(NSMutableDictionary *)mutableDictionaryForKey:(NSString *)key andKey:(NSString *)key2{
    NSMutableDictionary *dic = [self mutableDictionaryForKey:key];
    dic = [dic mutableDictionaryForKey:key2];
    return dic;
}

-(void)setObject:(NSObject*)obj forPath:(NSArray *)path{
    NSMutableDictionary *tmpdic = (NSMutableDictionary *)self;
    
    for (int i = 0; i < path.count - 1; i++) {
        NSString *key = path[i];
        NSMutableDictionary *value = tmpdic[key];
        if (!value) {
            value = [NSMutableDictionary dictionary];
            tmpdic[key] = value;
        }
        tmpdic = value;
    }
    NSString *key = (NSString *)path.lastObject;
    tmpdic[key] = obj;
    
}

-(id)objectForPath:(NSArray *)path{
    id dic = self;
    for (int i = 0; i < path.count; i++) {
        dic = dic[path[i]];
    }
    return dic;
}




@end
