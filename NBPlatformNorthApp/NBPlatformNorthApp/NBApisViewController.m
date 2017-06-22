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
#import "DictionaryViewController.h"
#import "NSDate_Category.h"

//#define vResponse @"Response"
#define vAuth @"Auth"
#define vRefreshToken @"RefreshToken"
#define vRegisterDevice @"RegisterDevice"
#define vSetDeviceInfo @"SetDeviceInfo"
#define vQueryDeviceActiveStatus  @"QueryDeviceActiveStatus"
#define vDeleteDevice  @"DeleteDevice"
#define vSetApplication  @"SetApplication"
#define vQueryAllDevice @"QueryAllDevice"
#define vSelectDevice @"SelectDevice"
#define vQueryDevice @"QueryDevice"
#define vSubscribeDeviceChangeInfo  @"SubscribeDeviceChangeInfo"
#define vDeviceDataHistory  @"DeviceDataHistory"
#define vQueryDeviceCapability  @"QueryDeviceCapability"
#define vPostCommandToDevice  @"PostCommandToDevice"
#define vQueryCommand  @"QueryCommand"
#define vCancelCommand  @"CancelCommand"
#define vUpdateCommand  @"UpdateCommand"

static NSString *sKeyPath = @"KeyPath";
//static NSString *sTitle = @"Title";
//static NSString *sMethod = @"Method";
//static NSString *sItems = @"Items";
//static NSString *sDefaultValue = @"DefaultValue";
static NSString *sValueWillChang = @"ValueWillChang";


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


@interface NBApisViewController ()<WebApiDelegate,UITableViewDelegate,UITableViewDataSource,DictionaryViewControllerDelegate>
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
                                 @{sTitle:fappId,sKeyPath:@[ fappId],sDefaultValue:@"aphfRfLLHFbB0_2uMRRuwYQIbr8a",sValueWillChang:@"Auth_appId_valueWillChang:"},
                                 @{sTitle:fsecret,sKeyPath:@[ fsecret],sDefaultValue:@"tfWyoIbcyY8idnE74o1fiQH_2Vwa"},
                                 @{sTitle:vbaseUrl,sKeyPath:@[ vbaseUrl],sDefaultValue:@"https://112.93.129.156:8743",sValueWillChang:@"Auth_baseUrl_valueWillChang:"}
                                 ]},
                       @{sTitle:@"刷新 token",sMethod:@"RefreshToken:"}]},
             @{sTitle:@"设备管理",sItems:@[
                       @{sTitle:@"注册设备",sMethod:@"RegisterDevice:",sItems:@[
                                 @{sTitle:fverifyCode,sKeyPath:@[vRegisterDevice,fbody,fverifyCode]},
                                 @{sTitle:fnodeId,sKeyPath:@[vRegisterDevice,fbody,fnodeId]},
                                 @{sTitle:fendUserId,sKeyPath:@[vRegisterDevice,fbody,fendUserId]},
                                 @{sTitle:ftimeout,sKeyPath:@[vRegisterDevice,fbody,ftimeout]}
                                 ]},
                       @{sTitle:@"设置设备信息",sMethod:@"SetDeviceInfo:",sItems:@[
                                 @{sTitle:fname,sKeyPath:@[vSetDeviceInfo,fbody,fname]},
                                 @{sTitle:fendUser,sKeyPath:@[vSetDeviceInfo,fbody,fendUser]},
                                 @{sTitle:fmute,sKeyPath:@[vSetDeviceInfo,fbody,fmute]},
                                 @{sTitle:fmanufacturerId,sKeyPath:@[vSetDeviceInfo,fbody,fmanufacturerId]},
                                 @{sTitle:fmanufacturerName,sKeyPath:@[vSetDeviceInfo,fbody,fmanufacturerName]},
                                 @{sTitle:flocation,sKeyPath:@[vSetDeviceInfo,fbody,flocation]},
                                 @{sTitle:fdeviceType,sKeyPath:@[vSetDeviceInfo,fbody,fdeviceType]},
                                 @{sTitle:fprotocolType,sKeyPath:@[vSetDeviceInfo,fbody,fprotocolType]},
                                 @{sTitle:fmodel,sKeyPath:@[vSetDeviceInfo,fbody,fmodel]}
                                 ]},
                       @{sTitle:@"查询设备激活状态",sMethod:@"QueryDeviceActiveStatus:"},
                       @{sTitle:@"删除设备",sMethod:@"DeleteDevice:"},
                       @{sTitle:@"设置应用信息",sMethod:@"SetApplication:",sItems:@[
                                 @{sTitle:fabnormalTime,sKeyPath:@[vSetApplication,fbody,fdeviceStatusTimeConfig,fabnormalTime]},
                                 @{sTitle:fofflineTime,sKeyPath:@[vSetApplication,fbody,fdeviceStatusTimeConfig,fofflineTime]}
                                 ]}
                       ]},
             @{sTitle:@"数据采集",sItems:@[
                       @{sTitle:@"批量查询设备信息",sMethod:@"QueryAllDevice:",sItems:@[
                                 @{sTitle:fgatewayId,sKeyPath:@[vQueryAllDevice,fgatewayId]},
                                 @{sTitle:fnodeType,sKeyPath:@[vQueryAllDevice,fnodeType]},
                                 @{sTitle:fpageNo,sKeyPath:@[vQueryAllDevice,fpageNo],sDefaultValue:@"0"},
                                 @{sTitle:fpageSize,sKeyPath:@[vQueryAllDevice,fpageSize],sDefaultValue:@"100"},
                                 @{sTitle:fstatus,sKeyPath:@[vQueryAllDevice,fstatus]},
                                 @{sTitle:fstartTime,sKeyPath:@[vQueryAllDevice,fstartTime]},
                                 @{sTitle:fendTime,sKeyPath:@[vQueryAllDevice,fendTime]},
                                 @{sTitle:fsort,sKeyPath:@[vQueryAllDevice,fsort]}
                                 ]},
                       @{sTitle:@"选择设备",sMethod:@"SelectDevice:",sItems:@[
                                 @{sTitle:@"地磁模式",sMethod:@"SelectDevice_MagnetMode:"},
                                 @{sTitle:@"地锁模式",sMethod:@"SelectDevice_LockMode:"}
                                 ]},
                       @{sTitle:@"查询单个设备信息",sMethod:@"QueryDevice:"},
                       @{sTitle:@"NA订阅CM的设备变更",sMethod:@"SubscribeDeviceChangeInfo:",sItems:@[
                                 @{sTitle:fnotifyType,sKeyPath:@[vSubscribeDeviceChangeInfo,fbody,fnotifyType]},
                                 @{sTitle:fcallbackurl,sKeyPath:@[vSubscribeDeviceChangeInfo,fbody,fcallbackurl]}
                                 ]},
                       @{sTitle:@"查询设备历史数据",sMethod:@"DeviceDataHistory:",sItems:@[
//                                 @{sTitle:fgatewayId,sKeyPath:@[vDeviceDataHistory,fgatewayId]},
                                 @{sTitle:fserviceId,sKeyPath:@[vDeviceDataHistory,fserviceId]},
                                 @{sTitle:fpageNo,sKeyPath:@[vDeviceDataHistory,fpageNo],sDefaultValue:@"0"},
                                 @{sTitle:fpageSize,sKeyPath:@[vDeviceDataHistory,fpageSize],sDefaultValue:@"5"},
                                 @{sTitle:fstartTime,sKeyPath:@[vDeviceDataHistory,fstartTime]},
                                 @{sTitle:fendTime,sKeyPath:@[vDeviceDataHistory,fendTime]}
                                 ]},
                       @{sTitle:@"查询设备的服务能力",sMethod:@"QueryDeviceCapability:"}
                       ]},
             @{sTitle:@"下发消息",sItems:@[
                       @{sTitle:@"向设备投递异步命令",sMethod:@"PostCommandToDevice:",sItems:@[
                                 @{sTitle:frequestId,sKeyPath:@[vPostCommandToDevice,fbody, frequestId]},
                                 @{sTitle:fserviceId,sKeyPath:@[vPostCommandToDevice,fbody, fcommand,fserviceId],sDefaultValue:@"Parking"},
                                 @{sTitle:fmethod,sKeyPath:@[vPostCommandToDevice,fbody, fcommand,fmethod],sDefaultValue:@"SET_LOCK_PARAM"},
                                 @{sTitle:fparas,sKeyPath:@[vPostCommandToDevice,fbody, fcommand,fparas],sDefaultValue:@{@"lockStatus":@1}},
                                 @{sTitle:fcallbackUrl,sKeyPath:@[vPostCommandToDevice,fbody, fcallbackUrl]},
                                 @{sTitle:fexpireTime,sKeyPath:@[vPostCommandToDevice,fbody, fexpireTime],sDefaultValue:@"100"}
                                 ]},
                       @{sTitle:@"查询异步命令",sMethod:@"QueryCommand:",sItems:@[
                                 @{sTitle:fpageNo,sKeyPath:@[vQueryCommand,fpageNo],sDefaultValue:@"0"},
                                 @{sTitle:fpageSize,sKeyPath:@[vQueryCommand,fpageSize],sDefaultValue:@"5"},
                                 @{sTitle:fstartTime,sKeyPath:@[vQueryCommand,fstartTime]},
                                 @{sTitle:fendTime,sKeyPath:@[vQueryCommand,fendTime]}
                                 ]},
                       @{sTitle:@"撤销异步命令",sMethod:@"CancelCommand:"},
                       @{sTitle:@"修改命令",sMethod:@"UpdateCommand:",sItems:@[
                                 @{sTitle:fcommandId,sKeyPath:@[vUpdateCommand,fcommandId]},
                                 @{sTitle:fresultCode,sKeyPath:@[vUpdateCommand,fresult,fresultCode]},
                                 @{sTitle:fresultDetail,sKeyPath:@[vUpdateCommand,fresult,fresultDetail]}
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
    
    NSData *requestDictData = [[NSUserDefaults standardUserDefaults] objectForKey:vrequestDict];
    if (requestDictData) {
        requestDict = [NSJSONSerialization JSONObjectWithData:requestDictData options:NSJSONReadingAllowFragments error:nil];
        requestDict = [requestDict deepMutableCopy];
    }
    if (!requestDict) {
        requestDict = [NSMutableDictionary dictionary];
    }
    
    NSData *responseDictData = [[NSUserDefaults standardUserDefaults] objectForKey:vresponseDict];
    if (responseDictData) {
        responseDict = [NSJSONSerialization JSONObjectWithData:responseDictData options:NSJSONReadingAllowFragments error:nil];
        responseDict = [responseDict deepMutableCopy];
    }
    
    if (!responseDict) {
        responseDict = [NSMutableDictionary dictionary];
    }
}

-(void)saveDictData:(NSDictionary *)dict forKey:(NSString *)key{
    NSData *dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:dictData forKey:key];
}

-(void)saveLocalDictData{
    [self saveDictData:requestDict forKey:vrequestDict];
    [self saveDictData:responseDict forKey:vresponseDict];
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
//    NSLog(@"%@",funapis);
    
    [self readLocalDictData];
    [self setDefaultValueToDictionary:requestDict in:funapis];
    
    WebApi *webApi = [WebApi shareWebApi];
    webApi.appId = requestDict[fappId];
    webApi.baseUrl = requestDict[vbaseUrl];
    webApi.accessToken = responseDict[vauthInfo][faccessToken];
    
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
//    NSLog(@"%s section=%d",__FUNCTION__,section);
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
//    NSLog(@"%s indexPath=%@",__FUNCTION__,indexPath);
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
        NSString *text = nil;
        if (keyPath) {
            text = [requestDict objectForPath:keyPath];
        }
        cell.detailTextLabel.text = [text jsonDescription];
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
    
    [self clearlog];
    [self addlog:[[NSDate date] myDateString]];
    
    NSDictionary *item = nil;
    if (tableView == self.tableView) {
        item = [funapis dictionaryForIndexPath:indexPath];
    }else if (tableView == self.tableViewDetail){
        item = [funapis dictionaryForRow:indexPath.row atIndexPath:accessoryButtonTappedIndexPath];
    }
    [self addlog:item[sTitle]];
    NSString *method = item[sMethod];
    if (method == nil) {
        NSArray *keyPath = item[sKeyPath];
        if (keyPath) {
            method = @"modifyValueForDictionary:";
        }
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
//        [mutableStr appendFormat:@"\n%@",httpResponse.allHeaderFields];
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            [mutableStr appendFormat:@"\nBody:\n%@",dic];
            
        }
    }
    [self addlog:mutableStr];
}

#pragma mark - DictionaryViewControllerDelegate
-(void)DictionaryViewController:(DictionaryViewController *)dictionaryViewController viewDidAppear:(BOOL)animated{
    
}
-(void)DictionaryViewController:(DictionaryViewController *)dictionaryViewController viewDidDisappear:(BOOL)animated{
    
    
}

-(void)DictionaryViewController:(DictionaryViewController *)dictionaryViewController tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([dictionaryViewController.title isEqualToString: @"地锁模式"]) {
//        //@{sName:fstatus,sValuePath:@[fdeviceDataHistoryDTOs,@0,fdata,fstatus]}
//        NSDictionary *item = (NSDictionary *)[dictionaryViewController.showArray objectForIndexPath:indexPath];// [indexPath.section][sItems][indexPath.row];
//        if ([item[sName] isEqualToString:fstatus]) {
//            NSString *value = [item valueFromDictionary:dictionaryViewController.showData];
//            
//        }
//        
//    }
}

-(void)DictionaryViewController:(DictionaryViewController *)dictionaryViewController AlertController:(UIAlertController *)alertController AlertAction:(UIAlertAction *)alertAction forItem:(NSDictionary *)item{
    if ([dictionaryViewController.title isEqualToString:@"地锁模式"]) {
        if ([item[sName] isEqualToString:fstatus]) {
            
            NSMutableDictionary *Info = [[requestDict mutableDictionaryForKey:vPostCommandToDevice] mutableCopy];
            Info[fdeviceId] = requestDict[vSelectDevice][fdeviceId];
            NSDictionary *parasDict = nil;
            NSString *operation = nil;
            if ([alertAction.title isEqualToString:@"open"]) {
                parasDict = @{@"lockStatus":@1};
                operation = @"开锁";
            }else if ([alertAction.title isEqualToString:@"close"]){
                parasDict = @{@"lockStatus":@0};
                operation = @"关锁";
            }
            Info[fbody][fcommand][fparas] = parasDict;
            //@{sTitle:fparas,sKeyPath:@[vPostCommandToDevice,fbody, fcommand,fparas],sDefaultValue:@{@"lockStatus":@1}},
            [[WebApi shareWebApi] PostCommandToDevice:Info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                DictionaryViewController *dicVC = dictionaryViewController;
                if (error) {
                    NSMutableDictionary *mutableDic = [dicVC.showData mutableCopy];
                    mutableDic[@"statusCode"] = [error localizedDescription];
                    mutableDic[@"requestTime"] = [[NSDate date] myDateString];
                    dicVC.showData = mutableDic;
                    [dicVC.tableView reloadData];
                }
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    if (data) {
//                        NSMutableDictionary *mutableDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        
                        NSMutableDictionary *mutableDic = [dicVC.showData mutableCopy];
                        mutableDic[@"statusCode"] = @"指令发送成功";//[NSString stringWithFormat:@"%ld %@",(long)httpResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
                        mutableDic[@"requestTime"] = [[NSDate date] myDateString];
                        dicVC.showData = mutableDic;
                        [dicVC.tableView reloadData];
                    }
                }
//                completionHandler(data,response,error);
            }];
        }
    }
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
        [self.tableViewDetail reloadData];
        [self saveLocalDictData];
        
    }];
    [alertC addAction:action];
    
    NSObject *defaultValue = dict[sDefaultValue];
    if (defaultValue) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[defaultValue jsonDescription] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            NSString *text = alertC.textFields[0].text;
            NSObject *jsonobj = defaultValue;//[text jsonObjectLike:currentValue];
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
            [self.tableViewDetail reloadData];
            [self saveLocalDictData];
            
        }];
        [alertC addAction:action];

    }
    
    
    action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertC addAction:action];
    [self presentViewController:alertC animated:YES completion:nil];
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
                [self saveLocalDictData];
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
                [self saveLocalDictData];
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


//@{sTitle:@"设置设备信息",sMethod:@"SetDeviceInfo:"},
-(void)SetDeviceInfo:(NSDictionary *)dic{
    NSDictionary *info = requestDict[vSetDeviceInfo];
    [[WebApi shareWebApi] SetDeviceInfo:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}

//@{sTitle:@"查询设备激活状态",sMethod:@"QueryDeviceActiveStatus:"},
-(void)QueryDeviceActiveStatus:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey:vQueryDeviceActiveStatus];
    info[fdeviceId] = requestDict[vSelectDevice][fdeviceId];
    [[WebApi shareWebApi] QueryDeviceActiveStatus:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
//@{sTitle:@"删除设备",sMethod:@"DeleteDevice:"},
-(void)DeleteDevice:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey:vDeleteDevice];
    info[fdeviceId] = requestDict[vSelectDevice][fdeviceId];
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


//@{sTitle:@"选择设备",sMethod:@"SelectDevice:"},
-(void)SelectDevice:(NSDictionary *)dic{
    
    NSArray *devices = responseDict[vQueryAllDevice][fdevices];
    if (devices.count > 0) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"选择设备" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        for (NSDictionary *device in devices) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:device[fdeviceId] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                requestDict[vSelectDevice] = device;
                [self saveDictData:requestDict forKey:vrequestDict];
                [self addlog:[NSString stringWithFormat:@"SelectDevice:%@",device]];
            }];
            [alertC addAction:action];
        }
        
        [self presentViewController:alertC animated:YES completion:nil];
    }else{
        [self addlog:@"No device found"];
    }

}

-(void)SelectDevice_MagnetMode:(NSDictionary *)dic{
    DictionaryViewController *dicVC = [DictionaryViewController shareDictionaryViewController];
//    dicVC.showInfo = @{}
    dicVC.title = @"地磁模式";
    dicVC.showData = nil;
    dicVC.showArray =  @[
                         @{sTitle:@"数据信息",
                           sItems:@[
                                   @{sName:fappId,sValuePath:@[fdeviceDataHistoryDTOs,@0,fappId]},
                                   @{sName:fdeviceId,sValuePath:@[fdeviceDataHistoryDTOs,@0,fdeviceId]},
                                   @{sName:fgatewayId,sValuePath:@[fdeviceDataHistoryDTOs,@0,fgatewayId]},
                                   @{sName:fserviceId,sValuePath:@[fdeviceDataHistoryDTOs,@0,fserviceId]},
                                   @{sName:ftimestamp,sValuePath:@[fdeviceDataHistoryDTOs,@0,ftimestamp]},
                                   @{sName:fstatus,sValuePath:@[fdeviceDataHistoryDTOs,@0,fdata,fstatus],sValueMap:@{@"0":@"无车",@"1":@"有车"}}
                                   ]
                           },
                         @{sTitle:@"通讯信息",
                           sItems:@[
                                   @{sName:@"Status Code",sValuePath:@[@"statusCode"]},
                                   @{sName:@"通讯时间",sValuePath:@[@"requestTime"]}
                                   ]
                           }
                         ];
    dicVC.delegate = self;
    [self.navigationController showViewController:dicVC sender:self];
    [self SelectDevice_MagnetMode_refresh:dicVC];

    
}
//地磁模式刷新数据

-(void)SelectDevice_Mode_refresh:(DictionaryViewController *)dicVC completionHandler:(CompletionHandler)completionHandler{
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[fdeviceId] = requestDict[vSelectDevice][fdeviceId];
    info[fgatewayId] = requestDict[vSelectDevice][fgatewayId];
    info[fserviceId] = @"Parking";
    info[fpageNo] = @"0";
    info[fpageSize] = @"1";
    [[WebApi shareWebApi] DeviceDataHistory:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSMutableDictionary *mutableDic = [dicVC.showData mutableCopy];
            mutableDic[@"statusCode"] = [error localizedDescription];
            mutableDic[@"requestTime"] = [[NSDate date] myDateString];
            dicVC.showData = mutableDic;
            [dicVC.tableView reloadData];
        }
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (data) {
                NSMutableDictionary *mutableDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                mutableDic[@"statusCode"] = [NSString stringWithFormat:@"%ld %@",(long)httpResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
                mutableDic[@"requestTime"] = [[NSDate date] myDateString];
                dicVC.showData = mutableDic;
                [dicVC.tableView reloadData];
            }
        }
        completionHandler(data,response,error);
    }];
}

-(void)SelectDevice_MagnetMode_refresh:(DictionaryViewController *)dicVC{
    [self SelectDevice_Mode_refresh:dicVC completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (dicVC.navigationController.topViewController == dicVC) {
            [self performSelector:@selector(SelectDevice_MagnetMode_refresh:) withObject:dicVC afterDelay:2];
        }
    }];
}

-(void)SelectDevice_LockMode:(NSDictionary *)dic{
    DictionaryViewController *dicVC = [DictionaryViewController shareDictionaryViewController];
    dicVC.title = @"地锁模式";
    dicVC.showData = nil;
    dicVC.showArray =  @[
                         @{sTitle:@"数据信息",
                           sItems:@[
                                   @{sName:fappId,sValuePath:@[fdeviceDataHistoryDTOs,@0,fappId]},
                                   @{sName:fdeviceId,sValuePath:@[fdeviceDataHistoryDTOs,@0,fdeviceId]},
                                   @{sName:fgatewayId,sValuePath:@[fdeviceDataHistoryDTOs,@0,fgatewayId]},
                                   @{sName:fserviceId,sValuePath:@[fdeviceDataHistoryDTOs,@0,fserviceId]},
                                   @{sName:ftimestamp,sValuePath:@[fdeviceDataHistoryDTOs,@0,ftimestamp]},
                                   @{sName:fstatus,sValuePath:@[fdeviceDataHistoryDTOs,@0,fdata,fstatus],sOptions:@[@"open",@"close"],sValueMap:@{@"16":@"正常",@"17":@"报警"}}
                                   ]
                           },
                         @{sTitle:@"通讯信息",
                           sItems:@[
                                   @{sName:@"Status Code",sValuePath:@[@"statusCode"]},
                                   @{sName:@"通讯时间",sValuePath:@[@"requestTime"]}
                                   ]
                           }
                         ];
    dicVC.delegate = self;
    [self.navigationController showViewController:dicVC sender:self];
    [self SelectDevice_LockMode_refresh:dicVC];
    
}

-(void)SelectDevice_LockMode_refresh:(DictionaryViewController *)dicVC{
    [self SelectDevice_Mode_refresh:dicVC completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (dicVC.navigationController.topViewController == dicVC) {
            [self performSelector:@selector(SelectDevice_LockMode_refresh:) withObject:dicVC afterDelay:5];
        }
    }];
    
}

//@{sTitle:@"查询单个设备信息",sMethod:@"QueryDevice:"},
-(void)QueryDevice:(NSDictionary *)dic{
    NSDictionary *info = @{fdeviceId: requestDict[vSelectDevice][fdeviceId],fappId:requestDict[fappId]};
    
    [[WebApi shareWebApi] QueryDevice:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    
}
//@{sTitle:@"NA订阅CM的设备变更",sMethod:@"SubscribeDeviceChangeInfo:"},
-(void)SubscribeDeviceChangeInfo:(NSDictionary *)dic{
    NSDictionary *info = requestDict[vSubscribeDeviceChangeInfo];
    [[WebApi shareWebApi] SubscribeDeviceChangeInfo:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}

//@{sTitle:@"查询设备历史数据",sMethod:@"DeviceDataHistory:"},
-(void)DeviceDataHistory:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey:vDeviceDataHistory];
    info[fdeviceId] = requestDict[vSelectDevice][fdeviceId];
    info[fgatewayId] = requestDict[vSelectDevice][fgatewayId];
    [[WebApi shareWebApi] DeviceDataHistory:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}

//@{sTitle:@"查询设备的服务能力",sMethod:@"QueryDeviceCapability:"}
-(void)QueryDeviceCapability:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey: vQueryDeviceCapability];
    info[fdeviceId] = requestDict[vSelectDevice][fdeviceId];
    [[WebApi shareWebApi] QueryDeviceCapability:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}

#pragma mark - 下发消息

//@{sTitle:@"向设备投递异步命令",sMethod:@"PostCommandToDevice:"},
-(void)PostCommandToDevice:(NSDictionary *)dic{
    NSMutableDictionary *Info = [requestDict mutableDictionaryForKey:vPostCommandToDevice];
    Info[fdeviceId] = requestDict[vSelectDevice][fdeviceId];
    
    [[WebApi shareWebApi] PostCommandToDevice:Info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}


//@{sTitle:@"查询异步命令",sMethod:@"QueryCommand:"},
-(void)QueryCommand:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey:vQueryCommand];
    info[fdeviceId] = requestDict[vSelectDevice][fdeviceId];
    
    [[WebApi shareWebApi] QueryCommand:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}

//@{sTitle:@"撤销异步命令",sMethod:@"CancelCommand:"},
-(void)CancelCommand:(NSDictionary *)dic{
    NSDictionary *info = @{fbody:@{fdeviceId:requestDict[vSelectDevice][fdeviceId]}};
    
    [[WebApi shareWebApi] CancelCommand:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}
//@{sTitle:@"修改命令",sMethod:@"UpdateCommand:"}
-(void)UpdateCommand:(NSDictionary *)dic{
    NSMutableDictionary *info = [requestDict mutableDictionaryForKey: vUpdateCommand];
    info[fdeviceId] = requestDict[vSelectDevice][fdeviceId];
    info[fcommandId] = requestDict[fcommandId];
    
    [[WebApi shareWebApi] UpdateCommand:info completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}

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

















