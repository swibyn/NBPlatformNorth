//
//  WebApi.h
//  platformNorthTest
//
//  Created by s on 03/05/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import <Foundation/Foundation.h>

#define httpPOST @"POST"
#define httpGET @"GET"
#define httpDELETE  @"DELETE"
#define httpPUT  @"PUT"
#define httpBaseUrl @""
#define httpUrlStr @"UrlStr"

#define headerAPPKey @"app_key"
#define headerAuthorization @"Authorization"
#define headerBearer @"Bearer"
#define headerContentType @"Content-Type"
#define headerApplicationJson @"application/json"



@class WebApi;

@protocol WebApiDelegate <NSObject>

-(void)webApi:(WebApi *_Nonnull)webapi willSendRequest:(NSURLRequest * _Nullable)request;
-(void)webApi:(WebApi *_Nonnull)webapi didReceiveData:(NSData * _Nullable)data response:(NSURLResponse * _Nullable)response error:(NSError * _Nullable)error;

@end

typedef  void (^_Nullable CompletionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface WebApi : NSObject<NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

+(instancetype _Nonnull )shareWebApi;

@property (strong, nonatomic) _Nullable id<WebApiDelegate> webApiDelegate;

@property NSString * _Nullable appId;
//@property NSString * _Nullable secret;
@property NSString * _Nullable baseUrl;
@property NSString * _Nullable accessToken;
//
//@property NSDictionary * _Nullable authInfo;


#pragma mark 2.1 应用安全接入
//2.1.1 Auth(鉴权)
-(void)Auth:(NSDictionary *_Nullable)dic  completionHandler:(CompletionHandler)completionHandler;

//2.1.2 Refresh Token(刷新 token)
-(void)RefreshToken:(NSDictionary *_Nullable)dic  completionHandler:(CompletionHandler)completionHandler;

#pragma mark 2.2 设备管理
//2.2.1 注册设备
-(void)RegisterDevice:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

//2.2.2 设置设备信息
-(void)SetDeviceInfo:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

//2.2.3 查询设备激活状态
-(void)QueryDeviceActiveStatus:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

//2.2.4 删除直连设备
-(void)DeleteDevice:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

//2.2.6 设置应用信息
-(void)SetApplication:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

#pragma mark 2.3 数据采集
//2.3.1 按条件批量查询设备信息列表
-(void)QueryAllDevice:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;


//2.3.2 查询单个设备信息
-(void)QueryDevice:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

//2.3.3NA订阅CM的设备变更
-(void)SubscribeDeviceChangeInfo:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

//2.3.4 查询设备历史数据
-(void)DeviceDataHistory:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

//2.3.5 查询设备的服务能力
-(void)QueryDeviceCapability:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

//向设备投递异步命令
-(void)PostCommandToDevice:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

//查询异步命令
-(void)QueryCommand:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

//撤销异步命令
-(void)CancelCommand:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

//修改命令
-(void)UpdateCommand:(NSDictionary *_Nullable)dic completionHandler:(CompletionHandler)completionHandler;

@end








