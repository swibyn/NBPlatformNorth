//
//  NBApisViewController.m
//  NBPlatformNorthApp
//
//  Created by s on 23/05/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import "NBApisViewController.h"
#import "WebApi.h"
#import "DataDictionary.h"
#import "JsonField.h"
#import "NSArray_Category.h"
#import "NSDictionary_Category.h"



//#define vResponse @"Response"
#define vAuth @"Auth"
#define vRefreshToken @"RefreshToken"
#define vRegisterDevice @"RegisterDevice"
#define vSetDeviceInfo @"SetDeviceInfo"
#define vQueryDeviceActiveStatus  @"QueryDeviceActiveStatus"
#define vDeleteDevice  @"DeleteDevice"
#define vSetApplication  @"SetApplication"
#define vQueryAllDevice @"QueryAllDevice"
#define vQueryDevice @"QueryDevice"
#define vSubscribeDeviceChangeInfo  @"SubscribeDeviceChangeInfo"
#define vDeviceDataHistory  @"DeviceDataHistory"
#define vQueryDeviceCapability  @"QueryDeviceCapability"
#define vPostCommandToDevice  @"PostCommandToDevice"
#define vQueryCommand  @"QueryCommand"
#define vCancelCommand  @"CancelCommand"
#define vUpdateCommand  @"UpdateCommand"

NSString *sKeyPath = @"KeyPath";
NSString *sTitle = @"Title";
NSString *sMethod = @"Method";
NSString *sItems = @"Items";
NSString *sDefaultValue = @"DefaultValue";
NSString *sValueWillChang = @"ValueWillChang";


@interface NSArray (apis)

-(NSMutableArray *)itemsForSection:(NSInteger)section;
-(NSString *)titleForSection:(NSInteger)section;

@end

@implementation NSArray (apis)

-(NSMutableArray *)itemsForSection:(NSInteger)section{
    NSDictionary *dict = self[section];
    NSMutableArray *array = dict[sItems];
    return array;
}

-(NSString *)titleForSection:(NSInteger)section{
    NSDictionary *dict = self[section];
    NSString *title = dict[sTitle];
    return title;
}

-(NSMutableDictionary *)dictionaryForIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = [self itemsForSection:indexPath.section];
    NSMutableDictionary *dict = array[indexPath.row];
    return dict;
}

-(NSMutableArray *)itemsForIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dict = [self dictionaryForIndexPath:indexPath];
    NSMutableArray *items = dict[sItems];
    return items;
}

-(NSMutableDictionary *)dictionaryForRow:(NSInteger)row atIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = [self itemsForIndexPath:indexPath];
    NSMutableDictionary *dict = array[row];
    return dict;
}

@end

@interface NSObject (jsonDescription)

-(NSString *)jsonDescription;

@end

@implementation NSObject (jsonDescription)

-(NSString *)jsonDescription{
    if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSDictionary class]]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        return str;
    }else{
        return  [self description];
    }
}

@end

@interface NSString (jsonObj)

-(NSObject *)jsonObjectLike:(NSObject *)obj;

@end

@implementation NSString (jsonObj)

-(NSObject *)jsonObjectLike:(NSObject *)obj{
    if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
        NSData *data = [self dataUsingEncoding:NSASCIIStringEncoding];
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        return jsonObj;
    }else if ([obj isKindOfClass:[NSNumber class]]){
        NSNumber *num = [NSNumber numberWithDouble: [self doubleValue]];
        return  num;
    }
    return self;
}

@end


@interface NBApisViewController ()<WebApiDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSIndexPath *accessoryButtonTappedIndexPath;
}

@end



@implementation NBApisViewController

+(instancetype)shareNBApisViewController
{
    static NBApisViewController *instance = nil;
    if (!instance) {
        instance = [[NBApisViewController alloc] initWithNibName:@"ApisViewController" bundle:nil];
    }
    return instance;
}



-(NSArray *)apisArray{
    return @[
             @{sTitle : @"应用安全接入", sItems : @[
                       @{sTitle:@"鉴权",sMethod:@"Auth:",sItems:@[
                                 @{sTitle:fappId,sMethod:@"Auth_appId:",sKeyPath:@[ fappId],sDefaultValue:@"aphfRfLLHFbB0_2uMRRuwYQIbr8a",sValueWillChang:@"Auth_appId_valueWillChang:"},
                                 @{sTitle:fsecret,sMethod:@"Auth_secret:",sKeyPath:@[ fsecret],sDefaultValue:@"tfWyoIbcyY8idnE74o1fiQH_2Vwa"},
                                 @{sTitle:vbaseUrl,sMethod:@"Auth_baseUrl:",sKeyPath:@[ vbaseUrl],sDefaultValue:@"https://112.93.129.156:8743",sValueWillChang:@"Auth_baseUrl_valueWillChang:"}
                                 ]},
                       @{sTitle:@"刷新 token",sMethod:@"RefreshToken:"}]},
             @{sTitle:@"设备管理",sItems:@[
                       @{sTitle:@"注册设备",sMethod:@"RegisterDevice:",sItems:@[
                                 @{sTitle:fverifyCode,sMethod:@"RegisterDevice_verifyCode:",sKeyPath:@[vRegisterDevice,fbody,fverifyCode]},
                                 @{sTitle:fnodeId,sMethod:@"RegisterDevice_nodeId:",sKeyPath:@[vRegisterDevice,fbody,fnodeId]},
                                 @{sTitle:fendUserId,sMethod:@"RegisterDevice_endUserId:",sKeyPath:@[vRegisterDevice,fbody,fendUserId]},
                                 @{sTitle:ftimeout,sMethod:@"RegisterDevice_timeout:",sKeyPath:@[vRegisterDevice,fbody,ftimeout]}
                                 ]},
                       @{sTitle:@"设置设备信息",sMethod:@"SetDeviceInfo:",sItems:@[
                                 @{sTitle:fname,sMethod:@"SetDeviceInfo_name:",sKeyPath:@[vSetDeviceInfo,fbody,fname]},
                                 @{sTitle:fendUser,sMethod:@"SetDeviceInfo_endUser:",sKeyPath:@[vSetDeviceInfo,fbody,fendUser]},
                                 @{sTitle:fmute,sMethod:@"SetDeviceInfo_mute:",sKeyPath:@[vSetDeviceInfo,fbody,fmute]},
                                 @{sTitle:fmanufacturerId,sMethod:@"SetDeviceInfo_manufacturerId:",sKeyPath:@[vSetDeviceInfo,fbody,fmanufacturerId]},
                                 @{sTitle:fmanufacturerName,sMethod:@"SetDeviceInfo_manufacturerName:",sKeyPath:@[vSetDeviceInfo,fbody,fmanufacturerName]},
                                 @{sTitle:flocation,sMethod:@"SetDeviceInfo_location:",sKeyPath:@[vSetDeviceInfo,fbody,flocation]},
                                 @{sTitle:fdeviceType,sMethod:@"SetDeviceInfo_deviceType:",sKeyPath:@[vSetDeviceInfo,fbody,fdeviceType]},
                                 @{sTitle:fprotocolType,sMethod:@"SetDeviceInfo_protocolType:",sKeyPath:@[vSetDeviceInfo,fbody,fprotocolType]},
                                 @{sTitle:fmodel,sMethod:@"SetDeviceInfo_model:",sKeyPath:@[vSetDeviceInfo,fbody,fmodel]}
                                 ]},
                       @{sTitle:@"查询设备激活状态",sMethod:@"QueryDeviceActiveStatus:"},
                       @{sTitle:@"删除设备",sMethod:@"DeleteDevice:"},
                       @{sTitle:@"设置应用信息",sMethod:@"SetApplication:",sItems:@[
                                 @{sTitle:fabnormalTime,sMethod:@"SetApplication_abnormalTime:",sKeyPath:@[vSetApplication,fbody,fdeviceStatusTimeConfig,fabnormalTime]},
                                 @{sTitle:fofflineTime,sMethod:@"SetApplication_offlineTime:",sKeyPath:@[vSetApplication,fbody,fdeviceStatusTimeConfig,fofflineTime]}
                                 ]}
                       ]},
             @{sTitle:@"数据采集",sItems:@[
                       @{sTitle:@"批量查询设备信息",sMethod:@"QueryAllDevice:",sItems:@[
                                 @{sTitle:fgatewayId,sMethod:@"QueryAllDevice_gatewayId:",sKeyPath:@[vQueryAllDevice,fgatewayId]},
                                 @{sTitle:fnodeType,sMethod:@"QueryAllDevice_nodeType:",sKeyPath:@[vQueryAllDevice,fnodeType]},
                                 @{sTitle:fpageNo,sMethod:@"QueryAllDevice_pageNo:",sKeyPath:@[vQueryAllDevice,fpageNo],sDefaultValue:@"0"},
                                 @{sTitle:fpageSize,sMethod:@"QueryAllDevice_pageSize:",sKeyPath:@[vQueryAllDevice,fpageSize],sDefaultValue:@"100"},
                                 @{sTitle:fstatus,sMethod:@"QueryAllDevice_status:",sKeyPath:@[vQueryAllDevice,fstatus]},
                                 @{sTitle:fstartTime,sMethod:@"QueryAllDevice_startTime:",sKeyPath:@[vQueryAllDevice,fstartTime]},
                                 @{sTitle:fendTime,sMethod:@"QueryAllDevice_endTime:",sKeyPath:@[vQueryAllDevice,fendTime]},
                                 @{sTitle:fsort,sMethod:@"QueryAllDevice_sort:",sKeyPath:@[vQueryAllDevice,fsort]}
                                 ]},
                       @{sTitle:@"选择设备",sMethod:@"SelectDevice:"},
                       @{sTitle:@"查询单个设备信息",sMethod:@"QueryDevice:"},
                       @{sTitle:@"NA订阅CM的设备变更",sMethod:@"SubscribeDeviceChangeInfo:",sItems:@[
                                 @{sTitle:fnotifyType,sMethod:@"SubscribeDeviceChangeInfo_notifyType:",sKeyPath:@[vSubscribeDeviceChangeInfo,fbody,fnotifyType]},
                                 @{sTitle:fcallbackurl,sMethod:@"SubscribeDeviceChangeInfo_callbackurl:",sKeyPath:@[vSubscribeDeviceChangeInfo,fbody,fcallbackurl]}
                                 ]},
                       @{sTitle:@"查询设备历史数据",sMethod:@"DeviceDataHistory:",sItems:@[
                                 @{sTitle:fgatewayId,sMethod:@"DeviceDataHistory_gatewayId:",sKeyPath:@[vDeviceDataHistory,fgatewayId]},
                                 @{sTitle:fserviceId,sMethod:@"DeviceDataHistory_serviceId:",sKeyPath:@[vDeviceDataHistory,fserviceId]},
                                 @{sTitle:fpageNo,sMethod:@"DeviceDataHistory_pageNo:",sKeyPath:@[vDeviceDataHistory,fpageNo]},
                                 @{sTitle:fpageSize,sMethod:@"DeviceDataHistory_pageSize:",sKeyPath:@[vDeviceDataHistory,fpageSize]},
                                 @{sTitle:fstartTime,sMethod:@"DeviceDataHistory_startTime:",sKeyPath:@[vDeviceDataHistory,fstartTime]},
                                 @{sTitle:fendTime,sMethod:@"DeviceDataHistory_endTime:",sKeyPath:@[vDeviceDataHistory,fendTime]}
                                 ]},
                       @{sTitle:@"查询设备的服务能力",sMethod:@"QueryDeviceCapability:"}
                       ]},
             @{sTitle:@"下发消息",sItems:@[
                       @{sTitle:@"向设备投递异步命令",sMethod:@"PostCommandToDevice:",sItems:@[
                                 @{sTitle:frequestId,sMethod:@"PostCommandToDevice_requestId:",sKeyPath:@[vPostCommandToDevice,fbody, frequestId]},
                                 @{sTitle:fserviceId,sMethod:@"PostCommandToDevice_command_serviceId:",sKeyPath:@[vPostCommandToDevice,fbody, fcommand,fserviceId],sDefaultValue:@"Parking"},
                                 @{sTitle:fmethod,sMethod:@"PostCommandToDevice_command_method:",sKeyPath:@[vPostCommandToDevice,fbody, fcommand,fmethod],sDefaultValue:@"SET_LOCK_PARAM"},
                                 @{sTitle:fparas,sMethod:@"PostCommandToDevice_command_paras:",sKeyPath:@[vPostCommandToDevice,fbody, fcommand,fparas],sDefaultValue:@{@"lockStatus":@0}},
                                 @{sTitle:fcallbackUrl,sMethod:@"PostCommandToDevice_callbackUrl:",sKeyPath:@[vPostCommandToDevice,fbody, fcallbackUrl]},
                                 @{sTitle:fexpireTime,sMethod:@"PostCommandToDevice_expireTime:",sKeyPath:@[vPostCommandToDevice,fbody, fexpireTime],sDefaultValue:@"100"}
                                 ]},
                       @{sTitle:@"查询异步命令",sMethod:@"QueryCommand:",sItems:@[
                                 @{sTitle:fpageNo,sMethod:@"QueryCommand_pageNo:",sKeyPath:@[vQueryCommand,fpageNo]},
                                 @{sTitle:fpageSize,sMethod:@"QueryCommand_pageSize:",sKeyPath:@[vQueryCommand,fpageSize]},
                                 @{sTitle:fstartTime,sMethod:@"QueryCommand_startTime:",sKeyPath:@[vQueryCommand,fstartTime]},
                                 @{sTitle:fendTime,sMethod:@"QueryCommand_endTime:",sKeyPath:@[vQueryCommand,fendTime]}
                                 ]},
                       @{sTitle:@"撤销异步命令",sMethod:@"CancelCommand:"},
                       @{sTitle:@"修改命令",sMethod:@"UpdateCommand:",sItems:@[
                                 @{sTitle:fcommandId,sMethod:@"UpdateCommand_commandId:",sKeyPath:@[vUpdateCommand,fcommandId]},
                                 @{sTitle:fresultCode,sMethod:@"UpdateCommand_result_resultCode:",sKeyPath:@[vUpdateCommand,fresult,fresultCode]},
                                 @{sTitle:fresultDetail,sMethod:@"UpdateCommand_result_resultDetail:",sKeyPath:@[vUpdateCommand,fresult,fresultDetail]}
                                 ]}
                       ]},
             @{sTitle:@"其它",sItems:@[
                       @{sTitle:@"恢复默认配置",sMethod:@"RestoreDefaultDict:"},
                       @{sTitle:@"当前配置信息",sMethod:@"CurrentDict:"}
                       ]}
             ];
}

//读取本地配置
-(void)readLocalDictData{
//    appInfoDict = [[NSUserDefaults standardUserDefaults] objectForKey:vappInfoDict];
//    appInfoDict = [appInfoDict deepMutableCopy];
//    if ([appInfoDict[fappId] length] == 0) {
//        appInfoDict = [NSMutableDictionary dictionary];
//        appInfoDict[fappId] = @"aphfRfLLHFbB0_2uMRRuwYQIbr8a";
//        appInfoDict[fsecret] = @"tfWyoIbcyY8idnE74o1fiQH_2Vwa";
//        appInfoDict[vbaseUrl] = @"https://112.93.129.156:8743";
//    }
    
    NSData *requestDictData = [[NSUserDefaults standardUserDefaults] objectForKey:vrequestDict];
    requestDict = [NSJSONSerialization JSONObjectWithData:requestDictData options:NSJSONReadingAllowFragments error:nil];
    requestDict = [requestDict deepMutableCopy];
    if (!requestDict) {
        requestDict = [NSMutableDictionary dictionary];
    }
    
    NSData *responseDictData = [[NSUserDefaults standardUserDefaults] objectForKey:vresponseDict];
    responseDict = [NSJSONSerialization JSONObjectWithData:responseDictData options:NSJSONReadingAllowFragments error:nil];
    responseDict = [responseDict deepMutableCopy];
    if (!responseDict) {
        responseDict = [NSMutableDictionary dictionary];
    }
}

//把container中的默认值赋值到mutableDict对应的地方，如果已有值不覆盖
-(void)setDefaultValueToDictionary:(NSMutableDictionary *)mutableDict in:(NSObject *)container{
    if ([container isKindOfClass:[NSArray class]]) {
        for (NSObject *obj in (NSArray *)container) {
            [self setDefaultValueToDictionary:mutableDict in:obj];
        }
    }else if ([container isKindOfClass:[NSDictionary class]]){
        NSDictionary *dicContainer = (NSDictionary *)container;
        NSObject *defaultvalue = dicContainer[sDefaultValue];
        NSArray *keyPath = dicContainer[sKeyPath];
        if (defaultvalue && keyPath) {
            NSObject *currentValue = [mutableDict objectForPath:keyPath];
            if (!currentValue) {
                [mutableDict setObject:defaultvalue forPath:keyPath];
            }
        }
        
        NSArray *items = dicContainer[sItems];
        for (NSObject *obj in items) {
            [self setDefaultValueToDictionary:mutableDict in:obj];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    funapis = [self apisArray];
    
    [self readLocalDictData];
    [self setDefaultValueToDictionary:requestDict in:funapis];
    
    WebApi *webApi = [WebApi shareWebApi];
    webApi.appId = requestDict[fappId];
    webApi.baseUrl = requestDict[vbaseUrl];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [WebApi shareWebApi].webApiDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return funapis.count;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        NSArray *items = [funapis itemsForSection:section];
        return items.count;
    }else if (tableView == self.tableViewDetail){
        NSArray *items = [funapis itemsForIndexPath:accessoryButtonTappedIndexPath];
        return items.count;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    //    NSDictionary *dict = nil;
    if (tableView == self.tableView) {
        NSDictionary *dict = [funapis dictionaryForIndexPath:indexPath];
        NSArray *items = dict[sItems];
        if (items.count > 0) {
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = dict[sTitle];
    }else if (tableView == self.tableViewDetail){
        NSDictionary *dict = [funapis dictionaryForRow:indexPath.row atIndexPath:accessoryButtonTappedIndexPath];
        cell.textLabel.text = dict[sTitle];
        NSArray *keyPath = dict[sKeyPath];
        NSString *text = [requestDict objectForPath:keyPath];
        cell.detailTextLabel.text = text;
    }
    
    //    cell.detailTextLabel.text = dict[sMethod];
    // Configure the cell...
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return [funapis titleForSection:section];
    }else if (tableView == self.tableViewDetail){
        NSDictionary *dict = [funapis dictionaryForIndexPath:accessoryButtonTappedIndexPath];
        return dict[sTitle];
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyyMMdd HH:mm:ss";
    NSString *str = [df stringFromDate:[NSDate date]];
    [self clearlog];
    [self addlog:str];
    
    NSDictionary *item = nil;
    if (tableView == self.tableView) {
        item = [funapis dictionaryForIndexPath:indexPath];
    }else if (tableView == self.tableViewDetail){
        item = [funapis dictionaryForRow:indexPath.row atIndexPath:accessoryButtonTappedIndexPath];
    }
    [self addlog:item[sTitle]];
    NSString *method = item[sMethod];
    NSArray *keyPath = item[sKeyPath];
    if (keyPath) {
        method = @"modifyValueForDictionary:";
    }
    SEL sel = NSSelectorFromString(method);
    if ([self respondsToSelector:sel]) {
        
        IMP imp = [self methodForSelector:sel];
        void (*func)(id,SEL,NSDictionary *) = (void *)imp;
        func(self, sel, item);
        
    }else{
        NSLog(@"method not found:(%@)",method);
        
    }
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        accessoryButtonTappedIndexPath = indexPath;
        self.tableViewDetail.hidden = NO;
        [self.tableViewDetail reloadData];
    }
}

#pragma mark -  UIScrollViewDelegate<NSObject>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    if ([scrollView isKindOfClass:[UITableView class]]) {
    //        UITableView* tableView = (UITableView*)scrollView;
    //        //    SelectedIndexPath = indexPath;
    //        selectedTableView = tableView;
    //        tableViewArray = [self getDataSource:tableView];
    //    }
    
    if (scrollView == self.tableView) {
        self.tableViewDetail.hidden = YES;
    }
    
}
#pragma mark - WebApiDelegate
-(void)webApi:(WebApi *)webapi willSendRequest:(NSURLRequest *)request{
    NSMutableString *mutableStr = [NSMutableString stringWithString:@"Request:"];
    [mutableStr appendFormat:@"\n%@ %@",request.HTTPMethod, request.URL];
    [mutableStr appendFormat:@"\nHead:\n%@",request.allHTTPHeaderFields];
    NSData *bodyData = request.HTTPBody;
    if (bodyData) {
        NSString *str = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        [mutableStr appendFormat:@"\nBody:\n%@",str];
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONReadingAllowFragments error:nil];
//        [mutableStr appendFormat:@"\nBody:\n%@",dic];
    }
    [self addlog:mutableStr];
}

-(void)webApi:(WebApi *)webapi didReceiveData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error{
    
    NSMutableString *mutableStr = [NSMutableString stringWithString:@"Response:"];
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        [mutableStr appendFormat:@"\nStatus Code:%ld %@",(long)httpResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
        [mutableStr appendFormat:@"\n%@",httpResponse.allHeaderFields];
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            [mutableStr appendFormat:@"\nBody:\n%@",dic];
            
        }
    }
    [self addlog:mutableStr];
}

#pragma mark - tools
//-(void)resetWebApi{
//}

#pragma mark - alert utils
-(void)alertWithTitle:(NSString *)title text:(NSString *)text handler:(void (^ __nullable)(UIAlertController *alertC, UIAlertAction *action))handler{
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    if (text) {
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = text;
        }];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(alertC,action);
    }];
    [alertC addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertC addAction:action];
    [self presentViewController:alertC animated:YES completion:nil];
}

-(void)inputAlertWithTitle:(NSString *)title forDic:(NSMutableDictionary *)dic forPath:(NSArray *)path{
//    [self alertWithTitle:title text:[dic objectForPath:path] handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [dic setObject:text forPath:path];
//        if (dic == appInfoDict){
//            [[NSUserDefaults standardUserDefaults] setObject:dic forKey:vappInfoDict];
//        }else if (dic == requestDict){
//            [[NSUserDefaults standardUserDefaults] setObject:dic forKey:vrequestDict];
//        }else if (dic == responseDict){
//            [[NSUserDefaults standardUserDefaults] setObject:dic forKey:vresponseDict];
//        }
//    }];
}

-(void)modifyValueForDictionary:(NSDictionary *)dict{
    NSLog(@"%s",__FUNCTION__);
    NSString *title = dict[sTitle];
    NSArray *keyPath = dict[sKeyPath];
    id currentValue = [requestDict objectForPath:keyPath];
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [currentValue jsonDescription];
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *text = alertC.textFields[0].text;
        NSObject *jsonobj = [text jsonObjectLike:currentValue];
        NSString *valueWillChang = dict[sValueWillChang];
        if (valueWillChang) {
            SEL sel = NSSelectorFromString(valueWillChang);
            if ([self respondsToSelector:sel]){
                IMP imp = [self methodForSelector:sel];
                void (*func)(id,SEL,NSObject *) = (void *)imp;
                func(self, sel, jsonobj);
            }
        }
        
        [requestDict setObject:jsonobj forPath:keyPath];
    }];
    [alertC addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertC addAction:action];
    [self presentViewController:alertC animated:YES completion:nil];
}

-(void)inputAlertWithTitle:(NSString *)title forRequestDicPath:(NSArray *)path{
//    [self inputAlertWithTitle:title forDic:requestDict forPath:path];
}


#pragma mark - 应用安全接入
-(void)Auth:(NSDictionary *)dic{
    NSDictionary *info = @{fbody:@{fappId:requestDict[fappId],fsecret:requestDict[fsecret]}};
    [[WebApi shareWebApi] Auth:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]){
            
            NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)response;
            if ((httpres.statusCode == 200)&& (data.length > 0)){
                NSError *error;
                NSDictionary *dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                responseDict[vauthInfo] = dic;
                [WebApi shareWebApi].accessToken = dic[faccessToken];
            }
        }
    }];
}

-(void)Auth_appId_valueWillChanged:(NSObject *)newValue{
    [WebApi shareWebApi].appId = (NSString *)newValue;
}

-(void)Auth_baseUrl_valueWillChanged:(NSObject *)newValue{
    [WebApi shareWebApi].baseUrl = (NSString *)newValue;
}


/*
//@{sTitle:fappId,sMethod:@"Auth_appId:"},
-(void)Auth_appId:(NSDictionary *)dic{
    [self inputAlertWithTitle:fappId forDic:requestDict forPath:@[fappId]];
}
//@{sTitle:fsecret,sMethod:@"Auth_secret:"},
-(void)Auth_secret:(NSDictionary *)dic{
    [self inputAlertWithTitle:fsecret forDic:requestDict forPath:@[fsecret]];
}
//@{sTitle:vbaseUrl,sMethod:@"Auth_baseUrl"}
-(void)Auth_baseUrl:(NSDictionary *)dic{
    [self inputAlertWithTitle:vbaseUrl forDic:requestDict forPath:@[vbaseUrl]];
}
*/

-(void)RefreshToken:(NSDictionary *)dic{
    NSString *refreshToken = responseDict[vauthInfo][frefreshToken];
    if (refreshToken == nil){
        [self addlog:@"refreshToken == nil"];
        return;
    }
    NSDictionary *info = @{fbody:@{fappId:requestDict[fappId],fsecret:requestDict[fsecret],frefreshToken:refreshToken}};
    [[WebApi shareWebApi] RefreshToken:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]){
            
            NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)response;
            if ((httpres.statusCode == 200)&& (data.length > 0)){
                NSError *error;
                NSDictionary *dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                responseDict[vauthInfo] = dic;
                [WebApi shareWebApi].accessToken = dic[faccessToken];
            }
        }
    }];
    
}

#pragma mark - 设备管理

//@{sTitle:@"注册设备",sMethod:@"RegisterDevice:"},
-(void)RegisterDevice:(NSDictionary *)dic{
    NSDictionary *info = requestDict[vRegisterDevice];
    [[WebApi shareWebApi] RegisterDevice:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
/*
//@{sTitle:fverifyCode,sMethod:@"RegisterDevice_verifyCode:"},
-(void)RegisterDevice_verifyCode:(NSDictionary *)dic{
    [self inputAlertWithTitle:fverifyCode forRequestDicPath:@[vRegisterDevice,fbody,fverifyCode]];
}
//@{sTitle:fnodeId,sMethod:@"RegisterDevice_nodeId"},
-(void)RegisterDevice_nodeId:(NSDictionary *)dic{
    [self inputAlertWithTitle:fverifyCode forRequestDicPath:@[vRegisterDevice,fbody,fnodeId]];
    
//    NSArray *path = @[vRegisterDevice,fnodeId];
//    [self alertWithTitle:fnodeId text:[requestDict objectForPath:path] handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict setObject:text forPath:path];
//    }];
    
}
//@{sTitle:fendUserId,sMethod:@"RegisterDevice_endUserId"},
-(void)RegisterDevice_endUserId:(NSDictionary *)dic{
    [self inputAlertWithTitle:fendUserId forRequestDicPath:@[vRegisterDevice,fbody,fendUserId]];
//    [self alertWithTitle:fendUserId text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict setObject:text forPath:@[vRegisterDevice,fendUserId]];
//    }];
    
}
//@{sTitle:ftimeout,sMethod:@"RegisterDevice_timeout"}
-(void)RegisterDevice_timeout:(NSDictionary *)dic{
    [self inputAlertWithTitle:ftimeout forRequestDicPath:@[vRegisterDevice,fbody,ftimeout]];
//    [self alertWithTitle:ftimeout text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict setObject:text forPath:@[vRegisterDevice,ftimeout]];
//    }];
    
}
*/
//@{sTitle:@"设置设备信息",sMethod:@"SetDeviceInfo:"},
-(void)SetDeviceInfo:(NSDictionary *)dic{
    NSDictionary *info = requestDict[vSetDeviceInfo];
    [[WebApi shareWebApi] SetDeviceInfo:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
/*
//@{sTitle:fname,sMethod:@"SetDeviceInfo_name:"},
-(void)SetDeviceInfo_name:(NSDictionary *)dic{
    [self inputAlertWithTitle:fname forRequestDicPath:@[vSetDeviceInfo,fbody,fname]];
//    [self alertWithTitle:fname text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict setObject:text forPath:@[vSetDeviceInfo,fname]];
//    }];
    
}
//@{sTitle:fendUser,sMethod:@"SetDeviceInfo_endUser:"},
-(void)SetDeviceInfo_endUser:(NSDictionary *)dic{
    [self inputAlertWithTitle:fendUser forRequestDicPath:@[vSetDeviceInfo,fbody,fendUser]];
//    [self alertWithTitle:fendUser text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict setObject:text forPath:@[vSetDeviceInfo,fendUser]];
//    }];
    
}
//@{sTitle:fmute,sMethod:@"SetDeviceInfo_mute:"},
-(void)SetDeviceInfo_mute:(NSDictionary *)dic{
    [self inputAlertWithTitle:fmute forRequestDicPath:@[vSetDeviceInfo,fbody,fmute]];
//    [self alertWithTitle:fmute text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict setObject:text forPath:@[vSetDeviceInfo,fmute]];
//    }];
    
}
//@{sTitle:fmanufacturerId,sMethod:@"SetDeviceInfo_manufacturerId:"},
-(void)SetDeviceInfo_manufacturerId:(NSDictionary *)dic{
    [self inputAlertWithTitle:fmanufacturerId forRequestDicPath:@[vSetDeviceInfo,fbody,fmanufacturerId]];
//    [self alertWithTitle:fmanufacturerId text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict setObject:text forPath:@[vSetDeviceInfo,fmanufacturerId]];
//    }];
    
}
//@{sTitle:fmanufacturerName,sMethod:@"SetDeviceInfo_manufacturerName:"},
-(void)SetDeviceInfo_manufacturerName:(NSDictionary *)dic{
    [self inputAlertWithTitle:fmanufacturerName forRequestDicPath:@[vSetDeviceInfo,fbody,fmanufacturerName]];
//    [self alertWithTitle:fmanufacturerName text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict setObject:text forPath:@[vSetDeviceInfo,fmanufacturerName]];
//    }];
    
}
//@{sTitle:flocation,sMethod:@"SetDeviceInfo_location:"},
-(void)SetDeviceInfo_location:(NSDictionary *)dic{
    [self inputAlertWithTitle:flocation forRequestDicPath:@[vSetDeviceInfo,fbody,flocation]];
//    [self alertWithTitle:flocation text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict setObject:text forPath:@[vSetDeviceInfo,flocation]];
//    }];
    
}
//@{sTitle:fdeviceType,sMethod:@"SetDeviceInfo_deviceType:"},
-(void)SetDeviceInfo_deviceType:(NSDictionary *)dic{
    [self inputAlertWithTitle:fdeviceType forRequestDicPath:@[vSetDeviceInfo,fbody,fdeviceType]];
//    [self alertWithTitle:fdeviceType text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict setObject:text forPath:@[vSetDeviceInfo,fdeviceType]];
//    }];
    
}
//@{sTitle:fprotocolType,sMethod:@"SetDeviceInfo_protocolType:"},
-(void)SetDeviceInfo_protocolType:(NSDictionary *)dic{
    [self inputAlertWithTitle:fprotocolType forRequestDicPath:@[vSetDeviceInfo,fbody,fprotocolType]];
//    [self alertWithTitle:fprotocolType text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict setObject:text forPath:@[vSetDeviceInfo,fprotocolType]];
//    }];
    
}
//@{sTitle:fmodel,sMethod:@"SetDeviceInfo_model:"}
-(void)SetDeviceInfo_model:(NSDictionary *)dic{
    [self inputAlertWithTitle:fmodel forRequestDicPath:@[vSetDeviceInfo,fbody,fmodel]];
//    [self alertWithTitle:fmodel text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict setObject:text forPath:@[vSetDeviceInfo,fmodel]];
//    }];
    
}
*/
//@{sTitle:@"查询设备激活状态",sMethod:@"QueryDeviceActiveStatus:"},
-(void)QueryDeviceActiveStatus:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey:vQueryDeviceActiveStatus];
    info[fdeviceId] = requestDict[fdeviceId];
    [[WebApi shareWebApi] QueryDeviceActiveStatus:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
//@{sTitle:@"删除设备",sMethod:@"DeleteDevice:"},
-(void)DeleteDevice:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey:vDeleteDevice];
    info[fdeviceId] = requestDict[fdeviceId];
    info[fappId] = requestDict[fappId];
    [[WebApi shareWebApi] DeleteDevice:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
//@{sTitle:@"设置应用信息",sMethod:@"SetApplication:"}]},
-(void)SetApplication:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey:vSetApplication];
    info[fid] = requestDict[fappId];
    [[WebApi shareWebApi] SetApplication:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
/*
//@{sTitle:fabnormalTime,sMethod:@"SetApplication_abnormalTime:"},
-(void)SetApplication_abnormalTime:(NSDictionary *)dic{
    [self inputAlertWithTitle:fabnormalTime forRequestDicPath:@[vSetApplication,fbody,fdeviceStatusTimeConfig,fabnormalTime]];
}
//@{sTitle:fofflineTime,sMethod:@"SetApplication_offlineTime:"}
-(void)SetApplication_offlineTime:(NSDictionary *)dic{
    [self inputAlertWithTitle:fofflineTime forRequestDicPath:@[vSetApplication,fbody,fdeviceStatusTimeConfig,fofflineTime]];
}
*/
#pragma mark - 数据采集

//@{sTitle:@"批量查询设备信息",sMethod:@"QueryAllDevice:",sItems:@[
-(void)QueryAllDevice:(NSDictionary *)dic{
    NSDictionary *Info = [requestDict mutableDictionaryForKey:vQueryAllDevice];
    
    [[WebApi shareWebApi] QueryAllDevice:Info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]){
            
            NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)response;
            if ((httpres.statusCode == 200)&& (data.length > 0)){
                NSError *error;
                NSDictionary *dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                responseDict[vQueryAllDevice] = dic;
            }
        }
    }];
    
}
/*
//@{sTitle:@"gatewayId",sMethod:@"QueryAllDevice_gatewayId:"},
-(void)QueryAllDevice_gatewayId:(NSDictionary *)dic{
    [self inputAlertWithTitle:fgatewayId forRequestDicPath:@[vQueryAllDevice,fgatewayId]];
//    [self alertWithTitle:fnodeType text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryAllDevice][fgatewayId] = text;
//    }];
    
}

//@{sTitle:@"nodeType",sMethod:@"QueryAllDevice_nodeType:"},
-(void)QueryAllDevice_nodeType:(NSDictionary *)dic{
    [self inputAlertWithTitle:fnodeType forRequestDicPath:@[vQueryAllDevice,fnodeType]];
//    [self alertWithTitle:fnodeType text:@"ALL" handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryAllDevice][fnodeType] = text;
//    }];
    
}

//@{sTitle:@"pageNo",sMethod:@"QueryAllDevice_pageNo"},
-(void)QueryAllDevice_pageNo:(NSDictionary *)dic{
    [self inputAlertWithTitle:fpageNo forRequestDicPath:@[vQueryAllDevice,fpageNo]];
//    [self alertWithTitle:fpageNo text:@"0" handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryAllDevice][fpageNo] = text;
//    }];
    
}
//@{sTitle:@"pageSize",sMethod:@"QueryAllDevice_pageSize"},
-(void)QueryAllDevice_pageSize:(NSDictionary *)dic{
    [self inputAlertWithTitle:fpageSize forRequestDicPath:@[vQueryAllDevice,fpageSize]];
//    [self alertWithTitle:fpageSize text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryAllDevice][fpageSize] = text;
//    }];
    
}
//@{sTitle:@"status",sMethod:@"QueryAllDevice_status"},
-(void)QueryAllDevice_status:(NSDictionary *)dic{
    [self inputAlertWithTitle:fstatus forRequestDicPath:@[vQueryAllDevice,fstatus]];
//    [self alertWithTitle:fstatus text:@"ALL" handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryAllDevice][fstatus] = text;
//    }];
    
}
//@{sTitle:@"startTime",sMethod:@"QueryAllDevice_startTime"},
-(void)QueryAllDevice_startTime:(NSDictionary *)dic{
    [self inputAlertWithTitle:fstartTime forRequestDicPath:@[vQueryAllDevice,fstartTime]];
//    [self alertWithTitle:fstartTime text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryAllDevice][fstartTime] = text;
//    }];
    
}
//@{sTitle:@"endTime",sMethod:@"QueryAllDevice_endTime"},
-(void)QueryAllDevice_endTime:(NSDictionary *)dic{
    [self inputAlertWithTitle:fendTime forRequestDicPath:@[vQueryAllDevice,fendTime]];
//    [self alertWithTitle:fendTime text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryAllDevice][fendTime] = text;
//    }];
//    
}
//@{sTitle:@"sort",sMethod:@"QueryAllDevice_sort"}
-(void)QueryAllDevice_sort:(NSDictionary *)dic{
    [self inputAlertWithTitle:fsort forRequestDicPath:@[vQueryAllDevice,fsort]];
//    [self alertWithTitle:fsort text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryAllDevice][fsort] = text;
//    }];
    
}
*/

//@{sTitle:@"选择设备",sMethod:@"SelectDevice:"},
-(void)SelectDevice:(NSDictionary *)dic{
    
    NSArray *devices = responseDict[vQueryAllDevice][fdevices];
    if (devices.count > 0) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"选择设备" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        for (NSDictionary *device in devices) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:device[fdeviceId] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                requestDict[fdeviceId] = device[fdeviceId];
                [self addlog:[NSString stringWithFormat:@"SelectDevice:%@",device]];
            }];
            [alertC addAction:action];
        }
        
        [self presentViewController:alertC animated:YES completion:nil];
    }else{
        [self addlog:@"No device found"];
    }

}
//@{sTitle:@"查询单个设备信息",sMethod:@"QueryDevice:"},
-(void)QueryDevice:(NSDictionary *)dic{
    NSDictionary *info = @{fdeviceId: requestDict[fdeviceId],fappId:requestDict[fappId]};
    
    [[WebApi shareWebApi] QueryDevice:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    
}
//@{sTitle:@"NA订阅CM的设备变更",sMethod:@"SubscribeDeviceChangeInfo:"},
-(void)SubscribeDeviceChangeInfo:(NSDictionary *)dic{
    NSDictionary *info = requestDict[vSubscribeDeviceChangeInfo];
    [[WebApi shareWebApi] SubscribeDeviceChangeInfo:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
/*
//@{sTitle:fnotifyType,sMethod:@"SubscribeDeviceChangeInfo_notifyType"},
-(void)SubscribeDeviceChangeInfo_notifyType:(NSDictionary *)dic{
    [self inputAlertWithTitle:fnotifyType forRequestDicPath:@[vSubscribeDeviceChangeInfo,fbody,fnotifyType]];
}
//@{sTitle:fcallbackurl,sMethod:@"SubscribeDeviceChangeInfo_callbackurl"}
-(void)SubscribeDeviceChangeInfo_callbackurl:(NSDictionary *)dic{
    [self inputAlertWithTitle:fcallbackurl forRequestDicPath:@[vSubscribeDeviceChangeInfo,fbody,fcallbackurl]];
}
*/
//@{sTitle:@"查询设备历史数据",sMethod:@"DeviceDataHistory:"},
-(void)DeviceDataHistory:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey:vDeleteDevice];
    info[fdeviceId] = requestDict[fdeviceId];
    [[WebApi shareWebApi] DeviceDataHistory:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
/*
//@{sTitle:fgatewayId,sMethod:@"DeviceDataHistory_gatewayId:"},
-(void)DeviceDataHistory_gatewayId:(NSDictionary *)dic{
    [self inputAlertWithTitle:fgatewayId forRequestDicPath:@[vDeviceDataHistory,fgatewayId]];
}
//@{sTitle:fserviceId,sMethod:@"DeviceDataHistory_serviceId:"},
-(void)DeviceDataHistory_serviceId:(NSDictionary *)dic{
    [self inputAlertWithTitle:fserviceId forRequestDicPath:@[vDeviceDataHistory,fserviceId]];
}
//@{sTitle:fpageNo,sMethod:@"DeviceDataHistory_pageNo:"},
-(void)DeviceDataHistory_pageNo:(NSDictionary *)dic{
    [self inputAlertWithTitle:fpageNo forRequestDicPath:@[vDeviceDataHistory,fpageNo]];
}
//@{sTitle:fpageSize,sMethod:@"DeviceDataHistory_pageSize:"},
-(void)DeviceDataHistory_pageSize:(NSDictionary *)dic{
    [self inputAlertWithTitle:fpageSize forRequestDicPath:@[vDeviceDataHistory,fpageSize]];
}
//@{sTitle:fstartTime,sMethod:@"DeviceDataHistory_startTime:"},
-(void)DeviceDataHistory_startTime:(NSDictionary *)dic{
    [self inputAlertWithTitle:fstartTime forRequestDicPath:@[vDeviceDataHistory,fstartTime]];
}
//@{sTitle:fendTime,sMethod:@"DeviceDataHistory_endTime:"}
-(void)DeviceDataHistory_endTime:(NSDictionary *)dic{
    [self inputAlertWithTitle:fendTime forRequestDicPath:@[vDeviceDataHistory,fendTime]];
}
*/
//@{sTitle:@"查询设备的服务能力",sMethod:@"QueryDeviceCapability:"}
-(void)QueryDeviceCapability:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey: vQueryDeviceCapability];
    info[fdeviceId] = requestDict[fdeviceId];
    [[WebApi shareWebApi] QueryDeviceCapability:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}

#pragma mark - 下发消息

//@{sTitle:@"向设备投递异步命令",sMethod:@"PostCommandToDevice:"},
-(void)PostCommandToDevice:(NSDictionary *)dic{
    NSMutableDictionary *Info = [requestDict mutableDictionaryForKey:vPostCommandToDevice];
    Info[fdeviceId] = requestDict[fdeviceId];
    
    [[WebApi shareWebApi] PostCommandToDevice:Info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
/*
//@{sTitle:frequestId,sMethod:@"PostCommandToDevice_requestId:"},
-(void)PostCommandToDevice_requestId:(NSDictionary *)dic{
    [self inputAlertWithTitle:frequestId forRequestDicPath:@[vPostCommandToDevice,fbody, frequestId]];
    
//    [self alertWithTitle:frequestId text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryDevice][frequestId] = text;
//    }];
    
}
//@{sTitle:fserviceId,sMethod:@"PostCommandToDevice_command_serviceId:"},
-(void)PostCommandToDevice_command_serviceId:(NSDictionary *)dic{
    [self inputAlertWithTitle:fserviceId forRequestDicPath:@[vPostCommandToDevice,fbody,fcommand,fserviceId]];
    
//    [self alertWithTitle:fserviceId text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryDevice andKey:fcommand][fserviceId] = text;
//    }];
    
}
//@{sTitle:fmethod,sMethod:@"PostCommandToDevice_command_method:"},
-(void)PostCommandToDevice_command_method:(NSDictionary *)dic{
    [self inputAlertWithTitle:fmethod forRequestDicPath:@[vPostCommandToDevice,fbody,fcommand,fmethod]];
    
    //    [self alertWithTitle:fmethod text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryDevice andKey:fcommand][fmethod] = text;
//    }];
    
}
//@{sTitle:fparas,sMethod:@"PostCommandToDevice_command_paras:"},
-(void)PostCommandToDevice_command_paras:(NSDictionary *)dic{
    [self inputAlertWithTitle:fparas forRequestDicPath:@[vPostCommandToDevice,fbody,fcommand,fparas]];
    
//    [self alertWithTitle:fparas text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryDevice andKey:fcommand][fparas] = text;
//    }];
    
}
//@{sTitle:fcallbackUrl,sMethod:@"PostCommandToDevice_callbackUrl:"},
-(void)PostCommandToDevice_callbackUrl:(NSDictionary *)dic{
    
    [self inputAlertWithTitle:fcallbackUrl forRequestDicPath:@[vPostCommandToDevice,fbody,fcallbackUrl]];
    
//    [self alertWithTitle:fcallbackUrl text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryDevice][fcallbackUrl] = text;
//    }];
    
}
//@{sTitle:fexpireTime,sMethod:@"PostCommandToDevice_expireTime:"},
-(void)PostCommandToDevice_expireTime:(NSDictionary *)dic{
    [self inputAlertWithTitle:fexpireTime forRequestDicPath:@[vPostCommandToDevice,fbody,fexpireTime]];
    
//    [self alertWithTitle:fexpireTime text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
//        NSString *text = alertC.textFields[0].text;
//        [requestDict mutableDictionaryForKey:vQueryDevice][fexpireTime] = text;
//    }];
    
}
*/

//@{sTitle:@"查询异步命令",sMethod:@"QueryCommand:"},
-(void)QueryCommand:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey:vQueryCommand];
    info[fdeviceId] = requestDict[fdeviceId];
    
    [[WebApi shareWebApi] QueryCommand:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
/*
//@{sTitle:fpageNo,sMethod:@"QueryCommand_pageNo:"},
-(void)QueryCommand_pageNo:(NSDictionary *)dic{
    [self inputAlertWithTitle:fpageNo forRequestDicPath:@[vQueryCommand,fpageNo]];
}
//@{sTitle:fpageSize,sMethod:@"QueryCommand_pageSize:"},
-(void)QueryCommand_pageSize:(NSDictionary *)dic{
    [self inputAlertWithTitle:fpageSize forRequestDicPath:@[vQueryCommand,fpageSize]];
}

//@{sTitle:fstartTime,sMethod:@"QueryCommand_startTime:"},
-(void)QueryCommand_startTime:(NSDictionary *)dic{
    [self inputAlertWithTitle:fstartTime forRequestDicPath:@[vQueryCommand,fstartTime]];
}

//@{sTitle:fendTime,sMethod:@"QueryCommand_endTime:"}
-(void)QueryCommand_endTime:(NSDictionary *)dic{
    [self inputAlertWithTitle:fendTime forRequestDicPath:@[vQueryCommand,fendTime]];
}
*/
//@{sTitle:@"撤销异步命令",sMethod:@"CancelCommand:"},
-(void)CancelCommand:(NSDictionary *)dic{
    NSDictionary *info = @{fbody:@{fdeviceId:requestDict[fdeviceId]}};
    
    [[WebApi shareWebApi] CancelCommand:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
//@{sTitle:@"修改命令",sMethod:@"UpdateCommand:"}
-(void)UpdateCommand:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey: vUpdateCommand];
    info[fdeviceId] = requestDict[fdeviceId];
    info[fcommandId] = requestDict[fcommandId];
    
    [[WebApi shareWebApi] UpdateCommand:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
/*
//@{sTitle:fcommandId,sMethod:@"UpdateCommand_commandId:"},
-(void)UpdateCommand_commandId:(NSDictionary *)dic{
    [self inputAlertWithTitle:fcommandId forRequestDicPath:@[vUpdateCommand,fcommandId]];
}
//@{sTitle:fresultCode,sMethod:@"UpdateCommand_result_resultCode:"},
-(void)UpdateCommand_result_resultCode:(NSDictionary *)dic{
    [self inputAlertWithTitle:fresultCode forRequestDicPath:@[vUpdateCommand,fresult,fresultCode]];
}
//@{sTitle:fresultDetail,sMethod:@"UpdateCommand_result_resultDetail:"}
-(void)UpdateCommand_result_resultDetail:(NSDictionary *)dic{
    [self inputAlertWithTitle:fresultDetail forRequestDicPath:@[vUpdateCommand,fresult,fresultDetail]];
}
*/
#pragma mark - 其它

//@{sTitle:@"恢复默认配置",sMethod:@"RestoreDefaultDict:"},
-(void)RestoreDefaultDict:(NSDictionary *)dic{
    [self alertWithTitle:@"恢复默认配置，之前的配置将失效" text:nil handler:^(UIAlertController *alertC, UIAlertAction *action) {
        
        [NSUserDefaults resetStandardUserDefaults];
        requestDict = [NSMutableDictionary dictionary];
        [self setDefaultValueToDictionary:requestDict in:funapis];
        responseDict = [NSMutableDictionary dictionary];

    }];
}

//@{sTitle:@"当前配置信息",sMethod:@"CurrentDict:"}
-(void)CurrentDict:(NSDictionary *)dic{
    [self clearlog];
    NSString *log = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",vrequestDict,requestDict,vresponseDict,responseDict];
    [self addlog:log];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

















