//
//  WebRequestHelper.m
//  Hjyzg
//
//  Created by GengKC on 2018/4/14.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "WebRequestHelper.h"
#import <AFNetworking/AFNetworking.h>



//static NSString *loginUrl = @"http://app.hjyzg.net/login_u.asp?user_name=15220095233&user_pass=736be636d3fb3f1d&DateTime=1524030811384";

@interface WebRequestHelper ()
{
    AFHTTPSessionManager *_mgr;
}

@end


@implementation WebRequestHelper

+ (id)shareInstance {
    static WebRequestHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WebRequestHelper alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mgr = [AFHTTPSessionManager manager];
        //添加返回的值的类型
        _mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (void)setUpLoginStatus {
    //
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *userId = [NSString stringWithFormat:@"Userid_%@",[UtilTools getTimeFlag]];
    NSDictionary *config = [def dictionaryForKey:loginUserConfigDef];
    NSString *timeFlag = [NSString stringWithFormat:@"%@",[UtilTools getTimeFlag]];
//    BOOL isSuccessLogin = [def integerForKey:userLoginStateDef] == LoginStateSuccess;
    if (config) {
        userId = nil;
        NSString *num = config[@"phoneNum"];
        NSString *pwd = config[@"pwd"];
        NSString *loginUrl = [NSString stringWithFormat:@"%@user_name=%@&user_pass=%@&DateTime=%@",autoLoginUrl,num,pwd,timeFlag];
        //        userlogin
        
//        读取缓存 ，并设置cookie
        NSArray *myCookies = [NSKeyedUnarchiver unarchiveObjectWithData:[def objectForKey:cookieUserDef]];
        for (NSHTTPCookie *cookie in myCookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        
        [_mgr GET:loginUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSString *loginState = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"%@",loginState);
            if ([loginState isEqualToString:@"true"]) {
                [def setInteger:LoginStateSuccess forKey:userLoginStateDef];
            }
            else {
                [def setInteger:LoginStateError forKey:userLoginStateDef];
            }
            
            [def synchronize];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [def setInteger:LoginStateError forKey:userLoginStateDef];
            [def synchronize];
        }];
        
    }
    else {
        [def setInteger:LoginStateNoneUser forKey:userLoginStateDef];
    }
    
    [def setObject:userId forKey:UserId];
    [def synchronize];
}

- (void)checkLoginedStatusComplition:(void(^)(BOOL isLogin))complition {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSDictionary *config = [def dictionaryForKey:loginUserConfigDef];
    if (!config) {
        return;
    }
    NSMutableURLRequest *mutRes = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:checkStatusUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [mutRes setHTTPMethod:@"POST"];
    [mutRes setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    NSString *refer = [NSString stringWithFormat:@"http://%@/index.asp?uid=%@",webHostStr,[def objectForKey:UserId]];
    [mutRes setValue:refer forHTTPHeaderField:@"Referer"];
    [mutRes setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    NSString *pamar = [NSString stringWithFormat:@"mobile=%@&password=%@",config[@"phoneNum"],config[@"pwd"]];
    NSData *body = [pamar dataUsingEncoding:NSUTF8StringEncoding];
    [mutRes setHTTPBody:body];
    [mutRes setValue:[NSString stringWithFormat:@"%lu",(unsigned long)body.length] forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionDataTask *dataTask = [_mgr.session dataTaskWithRequest:mutRes completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"checkLoginedStatusComplition %@",error);
            complition(NO);
            [[NSUserDefaults standardUserDefaults] setInteger:LoginStateError forKey:userLoginStateDef];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            NSString *loginState = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"checkLoginedStatus %@",loginState);
            if ([loginState isEqualToString:@"false"]) {
                [[NSUserDefaults standardUserDefaults] setInteger:LoginStateError forKey:userLoginStateDef];
                [[NSUserDefaults standardUserDefaults] synchronize];
                complition(NO);
            }
            else {
                [[NSUserDefaults standardUserDefaults] setInteger:LoginStateSuccess forKey:userLoginStateDef];
                [[NSUserDefaults standardUserDefaults] synchronize];
                complition(YES);
            }
        }
    }];
    [dataTask resume];
    
    
//    [_mgr POST:checkStatusUrl parameters:@{@"mobile":config[@"phoneNum"], @"password":config[@"pwd"]} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//        NSString *loginState = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"checkLoginedStatus %@",loginState);
//        if ([loginState isEqualToString:@"false"]) {
//            [[NSUserDefaults standardUserDefaults] setInteger:LoginStateError forKey:userLoginState];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            complition(NO);
//        }
//        else {
//            [[NSUserDefaults standardUserDefaults] setInteger:LoginStateSuccess forKey:userLoginState];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            complition(YES);
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@",error);
//        complition(NO);
//        [[NSUserDefaults standardUserDefaults] setInteger:LoginStateError forKey:userLoginState];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }];
}

- (void)getVersionWith:(void(^)(NSString *))block {
    [_mgr GET:@"http://m.hjyzg.net/app/ver.json" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSString *jsonStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSRange loRange = [jsonStr rangeOfString:@"verName\":"];
        NSString *str = [jsonStr substringWithRange:NSMakeRange(loRange.location+loRange.length, 5)];
        block(str);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        block(nil);
    }];
}

- (void)postLocationMsg:(CLLocationCoordinate2D)userCoordinate {
    //    NSString *url = @"http://app.hjyzg.net/dingwei_session.asp?DateTime=1524029102452&user_temp_id=Userid_1524029094133&map_x=115.088875&map_y=35.841113";
    NSString *timeFlag = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    NSString *url = [NSString stringWithFormat:@"http://%@/dingwei_session.asp?DateTime=%@&map_x=%f&map_y=%f",webHostStr,timeFlag,userCoordinate.latitude,userCoordinate.longitude];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:UserId];
    NSDictionary *dic;
    if (userId) {
        dic = @{@"user_temp_id":userId};
    }
    else {
        //        user_name=15220095233&user_pass=736be636d3fb3f1d
        NSDictionary *config = [[NSUserDefaults standardUserDefaults] dictionaryForKey:loginUserConfigDef];
        dic = @{@"user_name":config[@"phoneNum"],@"user_pass":config[@"pwd"]};
    }
    
    [_mgr GET:url parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"dingwei_session success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"dingwei_session error,%@",error);
    }];
}


- (NSString *)getWebJsBridgeString {
    return @"function setupWebViewJavascriptBridge(callback) {  \
    if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }   \
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }   \
    window.WVJBCallbacks = [callback];  \
    var WVJBIframe = document.createElement('iframe');  \
    WVJBIframe.style.display = 'none';  \
    WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';  \
    document.documentElement.appendChild(WVJBIframe);   \
    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0) }    \
    setupWebViewJavascriptBridge(function(bridge) { \
    bridge.registerHandler('testJSFunction', function(data, responseCallback) { \
    alert('JS方法被调用:'+data); \
    responseCallback('js执行过了');})   \
    })";
}

- (void)uploadPhoto:(UIImage *)img imgName:(NSString *)name complication:(void(^)(BOOL isSuccess))complication {
    
    //    "http://app.hjyzg.net/upimg.asp?id="+shenxintaifu_Config.cookie_id+"&imgname="+filename;

    NSData *imgData = UIImagePNGRepresentation(img);
        //id=null  默认 null
    NSString *postUrl = [NSString stringWithFormat:@"%@id=nil&imgname=%@",photoUploadUrl,name];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:postUrl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"multipart/form-data;boundary=*****" forHTTPHeaderField:@"enctype"];
    [request setValue:@"UTF-8" forHTTPHeaderField:@"Charset"];
    [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    
    NSURLSessionUploadTask *uploadTask = [_mgr.session uploadTaskWithRequest:request fromData:imgData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"uploadTask Img %@",response);
        if (!error.code) {
            complication(YES);
        }
        else {
            complication(NO);
        }
    }];
    
    [uploadTask resume];
    
}

- (void)checkNetwork {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable: {
                NSLog(@"无网络");
                [UtilTools showAutoDismissHUDText:@"网络连接已断开..."];
                break;
            }
                
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                NSLog(@"WiFi网络");
                //                [UtilTools showAutoDismissHUDText:@"网络已断开..."];
                break;
                
            }
                
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                NSLog(@"3G网络");
                break;
                
            }
            default:
                break;
        }
    }];
}

- (void)sendWxPayUnifiedorderWith:(NSDictionary *)parma complication:(void(^)(id retData))complication {
    NSString *orderString = @"https://api.mch.weixin.qq.com/pay/unifiedorder";
    NSString *xmlStr = [UtilTools getwxFormatXmlOrderWith:parma];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:orderString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/html; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSData *content = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:content];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)content.length] forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionDataTask *task = [_mgr dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error.code) {
//            NSLog(@"dataTaskWithRequest %@",error);
            complication(nil);
        }
        else {
//            NSLog(@"%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            complication(responseObject);
        }
    }];
    [task resume];
}


@end
