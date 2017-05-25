//
//  NSDictinary_Category.m
//  platformNorthTest
//
//  Created by s on 15/05/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import "NSDictionary_Category.h"
#import "NSString_Category.h"
#import "NSArray_Category.h"

@implementation  NSDictionary (Category)

-(NSString *)stringValuesWithKeys:(NSArray *)keys andSeparate:(NSString *)separate{
    NSMutableString *mutableStr = [NSMutableString string];
    for (NSString *key in keys) {
        NSString *value = self[key];
        if (value) {
            if (mutableStr.length > 0) {
                [mutableStr appendString:separate];
            }
            [mutableStr appendFormat:@"%@=%@",key,value];
        }
    }
    return mutableStr;
}

-(NSMutableDictionary *)deepMutableCopy{
    NSMutableDictionary *mutableSelf = [NSMutableDictionary dictionary];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)obj;
            [mutableSelf setValue:[arr deepMutableCopy] forKey:key];
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            NSDictionary *dic = (NSDictionary *)obj;
            [mutableSelf setValue:[dic deepMutableCopy] forKey:key];
        }else{
            [mutableSelf setValue:obj forKey:key];
        }
    }];
    
    return mutableSelf;
    
}

@end


@implementation NSMutableDictionary (statistic)


- (id)mutableDictionaryForKeyCreate:(id)aKey
{
    
    id obj = [self objectForKey: aKey];
    if (!obj) {
        obj = [NSMutableDictionary dictionary];
        [self setObject:obj forKey:aKey];
    }
    return obj;
    
}

- (id)mutableArrayForKeyCreate:(id)aKey
{
    id obj = [self objectForKey:aKey];
    if (!obj) {
        obj = [NSMutableArray array];
        [self setObject:obj forKey:aKey];
    }
    return obj;
}


- (void)increaseValueForKey:(id)aKey
{
    id obj = [self objectForKey:aKey];
    if (!obj) {
        [self setObject:[NSNumber numberWithInt:1] forKey:aKey];
    }else{
        int value = [obj intValue];
        [self setObject:[NSNumber numberWithInt:++value] forKey:aKey];
    }
}


@end

/*
 {
 Details =     (
 {
 Parameter = <07>;
 apiEnText = "btc_unit_controlState";
 apiZhText = "\U63a7\U5236\U72b6\U6001";
 },
 {
 Parameter = <01>;
 apiEnText = "btc_unit_componentType";
 apiZhText = "\U7ec4\U4ef6\U7c7b\U578b";
 }
 );
 apiEnText = "btc_unit";
 apiZhText = "\U7ec4\U4ef6\U63a7\U5236";
 }
 */


//@implementation NSMutableDictionary (ApiText)
//
//+(instancetype)mutableDictionaryWithApiText:(NSString *)apiText{
//    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
//    [mutableDic setObject:apiText.leftText forKey:apiEnText];
//    [mutableDic setObject:apiText.rightText forKey:apiZhText];
//    return mutableDic;
//}
//
//-(void)addParamater:(NSObject *)paramater withApiText:(NSString *)apiText{
//    NSObject *obj = [self objectForKey:kDetails];
//    NSMutableArray *mutableArray;
//    if ([obj isKindOfClass:[NSMutableArray class]]) {
//        mutableArray = (NSMutableArray *)obj;
//    }else if(obj == nil){
//        mutableArray = [NSMutableArray array];
//        [self setObject:mutableArray forKey:kDetails];
//    }else{
//        NSLog(@"error object for key %@",kDetails);
//    }
//    NSMutableDictionary *dic = [NSMutableDictionary mutableDictionaryWithApiText:apiText];
//    [dic setObject:paramater forKey:sParameter];
//    [mutableArray addObject:dic];
//    
//}
//
//
//-(id)objectForApiEnTextInDetail:(NSString *)apiText{
//    NSString *apiEnTextValue = apiText.leftText;
//    NSArray *array = [self objectForKey:kDetails];
//    
//    __block NSObject *retObj;
//    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSDictionary *dic = obj;
//        NSString *value = [dic objectForKey:apiEnText];
//        if ([value isEqualToString:apiEnTextValue]) {
//            *stop = YES;
//            retObj = [dic objectForKey:sParameter];
//        }
//    }];
//    return retObj;
//}
//
//-(void)setObject:(NSObject *)obj forApiEnTextInDetail :(NSString *)apiText{
//    NSString *apiEnTextValue = apiText.leftText;
//    NSArray *array = [self objectForKey:kDetails];
//    
//    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSMutableDictionary *dic = obj;
//        NSString *value = [dic objectForKey:apiEnText];
//        if ([value isEqualToString:apiEnTextValue]) {
//            *stop = YES;
//            [dic setObject:obj forKey:apiEnTextValue];
//        }
//    }];
//}
//
//-(void)addDetails:(NSArray<NSDictionary *> *)details{
//    NSArray *array = [self objectForKey:kDetails];
//    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
//    [mutableArray addObjectsFromArray:details];
//    [self setObject:mutableArray forKey:kDetails];
//    
//}
//
//
//@end

//@implementation NSMutableDictionary (CBPeripheral)
//
//-(void)copyPeripheralInfo:(CBPeripheral *)peripheral{
//    [self setObject:peripheral.name forKey:kPeripheralName];
//    [self setObject:peripheral.identifier.UUIDString forKey:kPeripheralIdentifier];
//}
//
//-(void)copyCharacteristicInfo:(CBCharacteristic *)characteristic{
//    [self setObject:characteristic.UUID.UUIDString forKey:kPeripheralCharacteristicUUID];
//    if (characteristic.service) {
//        [self setObject:characteristic.service.UUID.UUIDString forKey:kPeripheralSeviceUUID];
//    }
//}
//
//@end

//@implementation NSDictionary (EIDAdvertisementData)
//
//-(BOOL)isNoGoodEIDAdvertisementData{
//    
//    NSString *name = self[CBAdvertisementDataLocalNameKey];
//    NSString *manufacturerData = self[CBAdvertisementDataManufacturerDataKey];
//    if ([name hasPrefix:@"eID_"] && (manufacturerData.length != 17)) {
//        return true;
//    }
//    return false;
//}
//
//@end
//
//
//@implementation NSDictionary (ApiText)
//
//-(NSString *)commandText{
//    
//    NSString *zhText = [self objectForKey:apiZhText];
//    NSString *enText = [self objectForKey:apiEnText];
//    NSString *cmdStr = [NSString stringWithFormat:@"%@/%@",enText,zhText];
//    return cmdStr;
//    
//}
//
//@end

@implementation NSDictionary (backCode)

-(NSString *)MsgWithCode:(int)code
{
    NSString *codeStr = [NSString stringWithFormat:@"%04x",code];
    return [self objectForKey:codeStr];
    
}
@end
