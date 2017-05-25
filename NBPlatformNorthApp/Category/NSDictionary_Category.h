//
//  NSDictinary_Category.h
//  platformNorthTest
//
//  Created by s on 15/05/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Category)

-(NSString *)stringValuesWithKeys:(NSArray *)keys andSeparate:(NSString *)separate;
-(NSMutableDictionary *)deepMutableCopy;

@end

@interface NSMutableDictionary (statistic)

- (id)mutableDictionaryForKeyCreate:(id)aKey;
- (id)mutableArrayForKeyCreate:(id)aKey;
- (void)increaseValueForKey:(id)aKey;

@end


//@interface NSMutableDictionary (ApiText)
//
//+(instancetype)mutableDictionaryWithApiText:(NSString *)apiText;
//-(void)addParamater:(NSObject *)paramater withApiText:(NSString *)apiText;
//-(id)objectForApiEnTextInDetail:(NSString *)apiText;
//-(void)setObject:(NSObject *)obj forApiEnTextInDetail:(NSString *)apiText;
//-(void)addDetails:(NSArray<NSDictionary *> *)details;
//
//@end

//@interface NSMutableDictionary (CBPeripheral)
//
//-(void)copyPeripheralInfo:(CBPeripheral *)peripheral;
//-(void)copyCharacteristicInfo:(CBCharacteristic *)characteristic;
//
//@end

//@interface NSDictionary (EIDAdvertisementData)
//
//-(BOOL)isNoGoodEIDAdvertisementData;
//
//@end
//
//@interface NSDictionary (ApiText)
//
//-(NSString *)commandText;
//
//@end

@interface NSDictionary (backCode)
-(NSString *)MsgWithCode:(int)code;
@end
