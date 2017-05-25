//
//  NSString_Extent.h
//  EIDDemoOC
//
//  Created by s on 16/5/30.
//  Copyright © 2016年 sunward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)

@property (readonly) NSString *leftText;
@property (readonly) NSString *rightText;
-(NSString *)setRightText:(NSString *)rightText;

//字符串转成16进制
@property (readonly) NSData *hexData;

-(NSString *)swapString;

@end
