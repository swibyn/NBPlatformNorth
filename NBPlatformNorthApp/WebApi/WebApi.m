//
//  WebApi.m
//  platformNorthTest
//
//  Created by s on 03/05/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import "WebApi.h"
#import "JsonField.h"
#import <UIKit/UIKit.h>
#import "NSDictionary_Category.h"
//#import "DataDictionary.h"

/*
 应用对接信息
 App ID
 aphfRfLLHFbB0_2uMRRuwYQIbr8a
 密钥
 tfWyoIbcyY8idnE74o1fiQH_2Vwa
 应用对接地址
 58.251.166.192
 应用对接端口
 HTTPS: 8743
 设备对接信息
 设备对接地址
 58.251.166.192
 设备对接端口
 COAPS/DTLS/TCP: 5683
 Softradio对接信息
 Softradio对接地址
 58.251.166.192
 Softradio对接端口
 8081
 平台Portal
 平台portal链接
 https:// 58.251.166.192:8843
 登录账号/密码
 Shua_nbiot/Shua12#$
 */


@interface WebApi()
@property id trustedCertificates;
@end

@implementation WebApi

+(instancetype)shareWebApi{
    static WebApi *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
    });
    return sharedInstance;
}

#pragma mark - NSURLSessionDelegate
-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    NSLog(@"didBecomeInvalidWithError:%@",error);
}


/*
 CA证书   此证书用于校验 （此证书不需要包含私钥）
 ca.jks JKS格式证书，密码Huawei@123（JKS格式必须要有密码）
 ca.crt CERT格式证书，无密码
 ca.pem PEM格式证书，无密码
 
 设备证书   此证书用于证明自身身份 （双向认证场景下使用）
 outgoing.CertwithKey.pkcs12   PKCS12格式证书 包含证书和私钥，私钥密码IoM@1234
 outgoing.CertwithKey.pem      PEM格式证书  包含证书和私钥，私钥密码IoM@1234
 server.crt与server.key        CERT格式证书 server.crt是证书，server.key是私钥 ，私钥密码IoM@1234
 
 备注：
 1、NA与Platform是双向认证的，既校验对端又被对端校验：
 从NA角度看，NA需要校验Platform身份，因此需要CA证书；（校验对端）
 NA需要提供证书证明自己身份，因此需要设备证书。（被对端校验）
 
 2、APP对接到NA 或者 网关对接到Platform是单向认证的，只有客户端会校验证书
 单向认证场景下，客户端并不提供自身证书，因此只需要CA证书用以校验服务端；
 （服务端对客户端的身份校验在业务层）
 */
-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    NSLog(@"didReceiveChallenge:%@",challenge.protectionSpace.authenticationMethod);
    
    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    NSString *authenticationMethod = [protectionSpace authenticationMethod];
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    NSRange range = [systemVersion rangeOfString:@"."];
    NSString *sv = [systemVersion substringToIndex:range.location];
    NSUInteger iv = [sv integerValue];
    BOOL bAfter9 = iv > 8;
    
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
    {
        NSString *p12Path = [[NSBundle mainBundle] pathForResource:@"outgoing.CertwithKey" ofType:@"pkcs12"];
//        NSString *caPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"jks"];
        NSData *pkcs12Data = [NSData dataWithContentsOfFile:p12Path];
        
        SecIdentityRef identity = [WebApi copyIdentityAndTrustWithCertData:(CFDataRef)pkcs12Data password:(CFStringRef)@"IoM@1234"];
        
        NSURLCredential* credential = [WebApi getCredentialFromCert:identity];
        
        if ( credential == nil )
        {
            if(bAfter9){
                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,nil);
            }else{
                [[challenge sender] cancelAuthenticationChallenge:challenge];

            }
        }
        else
        {
            if(bAfter9){
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);// >=ios9
            }else{
                [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];// <=ios8
            }
        }
    }
    else if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
#if 1
//        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
//        if(completionHandler)
//            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
//        
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        if(bAfter9){
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }else{
            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        }
#elif 0
        //先导入证书
        
        NSString * cerPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"crt"]; //证书的路径
        
        NSData * cerData = [NSData dataWithContentsOfFile:cerPath];
        
        SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)(cerData));
        
        self.trustedCertificates = @[CFBridgingRelease(certificate)];
        
        //1)获取trust object
        
        SecTrustRef trust = challenge.protectionSpace.serverTrust;
        
        SecTrustResultType result;
        
        //注意：这里将之前导入的证书设置成下面验证的Trust Object的anchor certificate
        
        SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef)self.trustedCertificates);
        
        //2)SecTrustEvaluate会查找前面SecTrustSetAnchorCertificates设置的证书或者系统默认提供的证书，对trust进行验证
        
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == errSecSuccess &&
            
            (result == kSecTrustResultProceed ||
             
             result == kSecTrustResultUnspecified)) {
                
                //3)验证成功，生成NSURLCredential凭证cred，告知challenge的sender使用这个凭证来继续连接
                
                NSURLCredential *cred = [NSURLCredential credentialForTrust:trust];
                
                [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
                completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
                
            } else {
                
                //5)验证失败，取消这次验证流程
                
//                [challenge.sender cancelAuthenticationChallenge:challenge];
                
                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
                
                
                
            }
#endif
    }
    else if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodNTLM] || [authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
    {
//        self.lastProtSpace = [challenge protectionSpace];
//        if ([challenge previousFailureCount] > 2)
//        {
//            [[challenge sender] cancelAuthenticationChallenge:challenge];
//        }
//        else
//        {
//            [[challenge sender]  useCredential:[self buildCredential] forAuthenticationChallenge:challenge];
//        }
        
    }
    else
    {
//
        if (bAfter9)
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,nil);
        else
            [[challenge sender] cancelAuthenticationChallenge:challenge];
    }

}

#pragma mark - NSURLSessionDataDelegate

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
     NSLog(@"%s",__FUNCTION__);
    NSLog(@"%@",error);
}

#pragma mark - NSURLSessionTaskDelegate

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSLog(@"DidFinishEventsForBackground:%@",session);
}

+ (SecIdentityRef)copyIdentityAndTrustWithCertData:(CFDataRef)inPKCS12Data password:(CFStringRef)keyPassword
{
    SecIdentityRef extractedIdentity = nil;
    OSStatus securityError = errSecSuccess;
    
    const void *keys[] = {kSecImportExportPassphrase};
    const void *values[] = {keyPassword};
    CFDictionaryRef optionsDictionary = NULL;
    
    optionsDictionary = CFDictionaryCreate(NULL, keys, values, (keyPassword ? 1 : 0), NULL, NULL);
    
    CFArrayRef items = NULL;
    securityError = SecPKCS12Import(inPKCS12Data, optionsDictionary, &items);
    
    if (securityError == errSecSuccess) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
        
        // get identity from dictionary
        extractedIdentity = (SecIdentityRef)CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        CFRetain(extractedIdentity);
    }
    
    if (optionsDictionary) {
        CFRelease(optionsDictionary);
    }
    
    if (items) {
        CFRelease(items);
    }
    
    return extractedIdentity;
}

+ (NSURLCredential *)getCredentialFromCert:(SecIdentityRef)identity
{
    SecCertificateRef certificateRef = NULL;
    SecIdentityCopyCertificate(identity, &certificateRef);
    
    NSArray *certificateArray = [[NSArray alloc] initWithObjects:(__bridge_transfer id)(certificateRef), nil];
    NSURLCredentialPersistence persistence = NSURLCredentialPersistenceForSession;
    
    NSURLCredential *credential = [[NSURLCredential alloc] initWithIdentity:identity
                                                               certificates:certificateArray
                                                                persistence:persistence];
    
    return credential;
}

#pragma mark - url

//#define fapplication_json @"application/json"


-(void)sendRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    [self.webApiDelegate webApi:self willSendRequest:request];
    //send
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
   
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webApiDelegate webApi:self didReceiveData:data response:response error:error];
            completionHandler(data,response,error);
        });
        
    }];
    [dataTask resume];
}

/*
 默认值
 HTTPMethod: POST
 Content-Type: application/json
 */
-(NSMutableURLRequest *)mutableRequestWithUrl:(NSString *)subURL httpMethod:(NSString *)httpMethod dic:(NSDictionary *)dic{
    //request
    NSString *urlStr = [_baseUrl stringByAppendingString:subURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData  timeoutInterval:5.0];
    request.HTTPMethod = httpMethod;
    
    //header
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (self.appId) {
        [request setValue:_appId forHTTPHeaderField:@"app_key"];
    }
    if (self.accessToken) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@",_accessToken] forHTTPHeaderField:@"Authorization"];
    }
    
    //body
    if (dic[fbody]) {
        
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic[fbody] options:NSJSONWritingPrettyPrinted error:&error];
        
        [request setHTTPBody:data];
    }
    
    return request;
}

#pragma mark 2.1 应用安全接入
//2.1.1 Auth(鉴权)
-(void)Auth:(NSDictionary *)dic  completionHandler:(CompletionHandler)completionHandler{
    //request
    NSString *urlStr = [_baseUrl stringByAppendingString:@"/iocm/app/sec/v1.1.0/login"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData  timeoutInterval:5.0];
    request.HTTPMethod = httpPOST;
    
    //header
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *bodyDic = dic[fbody];
    NSString *str = [NSString stringWithFormat:@"appId=%@\nsecret=%@",bodyDic[fappId],bodyDic[fsecret]];
    [request setHTTPBody:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}

//2.1.2 Refresh Token(刷新 token)
-(void)RefreshToken:(NSDictionary *)dic  completionHandler:(CompletionHandler)completionHandler{

    NSMutableURLRequest *request = [self mutableRequestWithUrl:@"/iocm/app/sec/v1.1.0/refreshToken" httpMethod:httpPOST dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}

#pragma mark 2.2 设备管理
//注册设备
-(void)RegisterDevice:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
    
    NSMutableURLRequest *request = [self mutableRequestWithUrl:@"/iocm/app/reg/v1.2.0/devices" httpMethod:httpPOST dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}

//设置设备信息
-(void)SetDeviceInfo:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
   
    NSString *deviceId = dic[fdeviceId];
    NSString *url = [NSString stringWithFormat:@"/iocm/app/dm/v1.2.0/devices/%@?appId=%@",deviceId,dic[fappId]];
    
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpPUT dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}

//2.2.3 查询设备激活状态
-(void)QueryDeviceActiveStatus:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{

    NSString *deviceId = dic[fdeviceId];
    NSString *url = [NSString stringWithFormat:@"/iocm/app/reg/v1.1.0/devices/%@",deviceId];
    
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpGET dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}

//删除设备
-(void)DeleteDevice:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
  
    NSString *deviceId = dic[fdeviceId];
    NSString *url = [NSString stringWithFormat:@"/iocm/app/dm/v1.1.0/devices/%@?appId=%@",deviceId,dic[fappId]];
    
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpDELETE dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}

//设置应用信息
-(void)SetApplication:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
   
    NSString *appid = dic[fid];
    NSString *url = [NSString stringWithFormat:@"/iocm/app/am/v1.1.0/applications/%@",appid];
    
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpPUT dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}
//
////2.2.6 修改设备信息
//-(void)ModifyDevice:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
//    
//    NSDictionary *bodyDic = dic;
//    NSString *deviceId = dic[fdeviceId];
//    NSString *url = [NSString stringWithFormat:@"/iocm/app/dm/v1.1.0/devices/%@",deviceId];
//    
//    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpPUT bodyDic:bodyDic];
//    
//    [self sendRequest:request completionHandler:completionHandler];
//    
//}

#pragma mark 2.3 数据采集
//2.3.1 按条件批量查询设备信息列表

-(void)QueryAllDevice:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
    
    NSString *parama = [dic stringValuesWithKeys:@[fappId,fgatewayId,fnodeType,fpageNo,fpageSize,fstatus,fstartTime,fendTime,fsort] andSeparate:@"&"];
    
    NSString *url = [NSString stringWithFormat:@"/iocm/app/dm/v1.1.0/devices?%@",parama];
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpGET dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}

//2.3.2 查询单个设备信息
-(void)QueryDevice:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
    
    NSString *deviceId = dic[fdeviceId];
    NSString *appId = dic[fappId];
    
    NSString *url = [NSString stringWithFormat:@"/iocm/app/dm/v1.1.0/devices/%@?appId=%@",deviceId,appId];
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpGET dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}

//NA订阅CM的设备变更
-(void)SubscribeDeviceChangeInfo:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
    
    NSString *url = [NSString stringWithFormat:@"/iocm/app/sub/v1.2.0/subscribe"];
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpGET dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}

//查询设备历史数据
-(void)DeviceDataHistory:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
    
    NSString *parama = [dic stringValuesWithKeys:@[fdeviceId,fgatewayId,fserviceId,fpageNo,fpageSize,fstartTime,fendTime] andSeparate:@"&"];
    
    NSString *url = [NSString stringWithFormat:@"/iocm/app/data/v1.1.0/deviceDataHistory?%@",parama];
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpGET dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}

//查询设备的服务能力
-(void)QueryDeviceCapability:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
    
//    NSString *parama = [dic stringValuesWithKeys:@[fgatewayId,fdeviceId] andSeparate:@"&"];
    NSString *deviceId = dic[fdeviceId];
    NSString *url = [NSString stringWithFormat:@"/iocm/app/data/v1.1.0/deviceCapabilities?deviceId=%@",deviceId];
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpGET dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}

#pragma mark - 下发消息
//2.4 向设备投递异步命令
-(void)PostCommandToDevice:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
   
    NSString *deviceId = dic[fdeviceId];
    
    NSString *url = [NSString stringWithFormat:@"/iocm/app/cmd/v1.2.0/devices/%@/commands",deviceId];
    
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpPOST dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}
//查询异步命令
-(void)QueryCommand:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
    
    NSString *parameters = [dic stringValuesWithKeys:@[fdeviceId,fpageNo,fpageSize,fstartTime,fendTime] andSeparate:@"&"];
    
    NSString *url = [NSString stringWithFormat:@"/iocm/app/cmd/v1.2.0/queryCmd?%@",parameters];
    
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpGET dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}
//撤销异步命令
-(void)CancelCommand:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
    
    NSString *url = [NSString stringWithFormat:@"/iocm/app/cmd/v1.2.0/cancelCmd"];
    
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpPOST dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}
//修改命令
-(void)UpdateCommand:(NSDictionary *)dic completionHandler:(CompletionHandler)completionHandler{
    
    NSString *deviceId = dic[fdeviceId];
    NSString *commandId = dic[fcommandId];
    
    NSString *url = [NSString stringWithFormat:@"/iocm/app/cmd/v1.2.0/devices/%@/commands/%@",deviceId,commandId];
    
    NSMutableURLRequest *request = [self mutableRequestWithUrl:url httpMethod:httpPUT dic:dic];
    
    [self sendRequest:request completionHandler:completionHandler];
    
}


@end





















