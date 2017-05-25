//
//  DataDictionary.h
//  platformNorthTest
//
//  Created by s on 22/05/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import <Foundation/Foundation.h>

#define vbaseUrl @"baseUrl"
#define vauthInfo @"authInfo"

#define vappInfoDict @"appInfoDict"
#define vrequestDict @"requestDict"
#define vresponseDict @"responseDict"

//记录应用信息
//extern NSMutableDictionary *appInfoDict;

//记录请求时需要用到的信息
/*
  @{
    @"method1":@{@"key1":@"value1",
                   @"key2":@"value2",
                 @"body":@{@"keya":@"valuea",@"keyb":@"valueb"}
                 }
    }
 */
extern NSMutableDictionary *requestDict;

//记录服务器返回的信息
extern NSMutableDictionary *responseDict;


@interface NSDictionary (Paramas)

-(NSMutableDictionary *)mutableDictionaryForKey:(NSString *)key;
-(NSMutableDictionary *)mutableDictionaryForKey:(NSString *)key andKey:(NSString *)key2;

-(void)setObject:(NSObject *)obj forPath:(NSArray *)path;
-(id)objectForPath:(NSArray *)path;

@end
