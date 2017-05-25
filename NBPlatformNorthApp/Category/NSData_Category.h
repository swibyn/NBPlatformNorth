//
//  NSData_Category.h
//  EIDDemoOC
//
//  Created by s on 16/5/31.
//  Copyright © 2016年 sunward. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "CaSim/CaSim.h"

@interface NSData (AppBack)

-(NSString *)hexString;

//+(NSMutableData *)dataWithApdu:(BLE_APDU)apdu;
//
//+(NSMutableData *)dataWithApdu2:(BLE_APDU2)apdu;
//
//+(NSMutableData *)dataWithMutableAPDU:(BLE_MutableAPDU)mApdu;

//-(NSArray *)

@property (readonly) NSData *backCode;//应用返回的状态码
@property (readonly) NSData *backData;//应用返回的数据

@end

