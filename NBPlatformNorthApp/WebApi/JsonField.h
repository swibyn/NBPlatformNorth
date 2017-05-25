//
//  JsonField.h
//  platformNorthTest
//
//  Created by s on 03/05/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#ifndef JsonField_h
#define JsonField_h

// Auth(鉴权)
#define fappId @"appId"
#define fsecret @"secret"

#define fscope @"scope"
#define ftokenType @"tokenType"
#define fexpiresIn  @"expiresIn"
#define faccessToken  @"accessToken"
#define frefreshToken @"refreshToken"

//2.1.2 Refresh Token(刷新 token)

// 注册设备
#define fverifyCode @"verifyCode"
#define fnodeId @"nodeId"
#define fendUserId @"endUserId"
#define ftimeout @"timeout"

#define fdeviceId @"deviceId"
#define fpsk @"psk"

//3.2.1 Set device info(设置设备信息)
#define fname @"name"
#define fendUser @"endUser"
#define fmute @"mute"
#define fmanufacturerId @"manufacturerId"
#define fmanufacturerName @"manufacturerName"
#define flocation @"location"
#define fdeviceType @"deviceType"
#define fprotocolType @"protocolType"
#define fmodel @"model"


//2.2.3 查询设备激活状态
#define factivated @"activated"

//2.2.4 删除设备

//3.2.4 Set Application(设置应用信息)
#define fid @"id"
#define fdeviceStatusTimeConfig @"deviceStatusTimeConfig"
#define fabnormalTime @"abnormalTime"
#define fofflineTime @"offlineTime"

//按条件批量查询设备信息列表
#define fgatewayId @"gatewayId"
#define fnodeType @"nodeType"
#define fpageNo @"pageNo"
#define fpageSize @"pageSize"
#define fstatus @"status"
#define fstartTime @"startTime"
#define fendTime @"endTime"
#define fsort @"sort"
#define ftotalCount @"totalCount"
#define fdevices @"devices"
#define fcreationTime @"creationTime"
#define flastModifiedTime @"lastModifiedTime"
#define fdeviceInfo @"deviceInfo"
#define fservices @"services"

//2.3.2 查询单个设备信息
#define fcreateTime @"createTime"
#define flastModifiedTime @"lastModifiedTime"

//NA订阅CM的设备变更
#define fnotifyType @"notifyType"
#define fcallbackurl @"callbackurl"

//#define fbindDevice @"bindDevice"
//#define fdeviceAdded @"deviceAdded"
//#define fdeviceInfoChanged @"deviceInfoChanged"
//#define fdeviceDataChanged @"deviceDataChanged"
//#define fdeviceDeleted @"deviceDeleted"
//#define fdeviceEvent @"deviceEvent"
//#define fmessageConfirm @"messageConfirm"
//#define fcommandRsp @"commandRsp"
//#define fserviceInfoChanged @"serviceInfoChanged"
//#define fruleEvent @"ruleEvent"

//2.3.4 查询设备历史数据
#define fdeviceDataHistoryDTOs @"deviceDataHistoryDTOs"
#define fserviceId @"serviceId"
#define ftimestamp @"timestamp"

//查询设备的服务能力
#define fdeviceCapabilities @"deviceCapabilities"
#define fserviceCapabilities @"serviceCapabilities"
#define foption @"option"
#define fdescription @"description"
#define fcommands @"commands"
#define fproperties @"properties"
#define fcommandName @"commandName"
#define fparas @"paras"
#define fparaName  @"paraName"
#define fdataType  @"dataType"
#define frequired  @"required"
#define fmin  @"min"
#define fmax  @"max"
#define fstep  @"step"
#define fmaxLength  @"maxLength"
#define funit  @"unit"
#define fenumList  @"enumList"
#define fpropertyName  @"propertyName"
#define fdataType  @"dataType"
#define fmethod  @"method"

//向设备投递异步命令
#define fbody  @"body"
#define frequestId  @"requestId"
#define fcommand  @"command"
#define fexpireTime  @"expireTime"
#define fcommandId @"commandId"

//查询异步命令
#define flist @"list"
#define fcallbackUrl @"callbackUrl"
#define fresult @"result"
#define fexecuteTime @"executeTime"
#define fresultCode @"resultCode"
#define fresultDetail @"resultDetail"

//撤销异步命令
//Update command (修改命令)
//#define f @""
//#define f @""
//#define f @""
//#define f @""
//#define f @""
//#define f @""
//#define f @""
//#define f @""
//#define f @""
//#define f @""
//#define f @""
//#define f @""





















#endif /* JsonField_h */














