//
//  UtilTools.m
//  Hjyzg
//
//  Created by GengKC on 2018/4/22.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "UtilTools.h"
#import <AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "CocoaSecurity.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>


#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"



MBProgressHUD *_gHud;

@implementation UtilTools


+ (NSString *)getTimeFlag {
    return [NSString stringWithFormat:@"%.0f",[NSDate date].timeIntervalSince1970];
}

// showHUDText只显示文字
+ (void)showAutoDismissHUDText:(NSString *)string {
    __block MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    hud.label.text = string;
    hud.label.font = [UIFont systemFontOfSize:14];
    hud.label.textAlignment = NSTextAlignmentCenter;
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    hud.mode = MBProgressHUDModeText;
    [hud showAnimated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud removeFromSuperview];
        hud = nil;
    });
}


+ (void)showHUDIndicatorView {
    if (!_gHud) {
        _gHud = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:_gHud];
        _gHud.mode = MBProgressHUDModeIndeterminate;
        _gHud.contentColor = [UIColor whiteColor];
        _gHud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        _gHud.bezelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    }
    [_gHud showAnimated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_gHud removeFromSuperview];
        _gHud = nil;
    });
}

+ (void)dismissHUDIndicatorView {
    [_gHud removeFromSuperview];
    _gHud = nil;
}

+ (NSDictionary *)createWxPayOrderWith:(NSDictionary *)param {
    NSMutableDictionary *mutDic = [param mutableCopy];
    mutDic[@"appid"] = wxpay_app_id;
    mutDic[@"mch_id"] = wxpay_mch_id;
    mutDic[@"nonce_str"] = [self getRandomNonceStr];
    mutDic[@"body"] = param[@"body"];
    mutDic[@"out_trade_no"] = param[@"out_trade_no"];
    mutDic[@"total_fee"] = param[@"total_fee"];
    mutDic[@"spbill_create_ip"] = [self getIPAddress:YES];
    mutDic[@"notify_url"] = notify_url;
    mutDic[@"trade_type"] = @"NATIVE";
    mutDic[@"product_id"] = param[@"product_id"];
    
    mutDic[@"sign"] = [[self getwxSignWith:mutDic] copy];
    
    return mutDic;
}

+ (NSString *)getwxFormatXmlOrderWith:(NSDictionary *)parma {
    NSDictionary *orderDic = [self createWxPayOrderWith:parma];
    
    NSMutableString *mutString = [@"" mutableCopy];
    [mutString appendString:@"<xml>"];
    for (NSString *key in orderDic.allKeys) {
        [mutString appendFormat:@"<%@>",key];
        [mutString appendFormat:@"%@",orderDic[key]];
        [mutString appendFormat:@"</%@>",key];
    }
    [mutString appendString:@"</xml>"];
    
    return mutString;
}

+ (NSString *)getRandomNonceStr {
    NSData *data = [[NSString stringWithFormat:@"%f::%@",arc4random()/100.0, [NSDate date]] dataUsingEncoding:NSUTF8StringEncoding];

    return [[[data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] uppercaseString] substringToIndex:30];
}

+ (NSString *)getwxSignWith:(NSDictionary *)dic {
    NSMutableString *stringA = [NSMutableString string];
    //按字典key升序排序
    NSArray *sortKeys = [[dic allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    //拼接格式 “key0=value0&key1=value1&key2=value2”
    for (NSString *key in sortKeys) {
        [stringA appendString:[NSString stringWithFormat:@"%@=%@&", key, dic[key]]];
    }
    //拼接商户签名,,,,kShopSign 要和微信平台上填写的密钥一样，（密钥就是签名）
    [stringA appendString:[NSString stringWithFormat:@"key=%@", wxShopSignID]];
    //MD5加密
    NSString *stringB = [CocoaSecurity md5:[stringA copy]].hex;
    //返回大写字母
    return stringB.uppercaseString;
}

//
//+ (void)urlRequestOperation:(void(^)(NSString *ipAdress))complication {
//    NSString *URLTmp = @"http://ip.taobao.com/service/getIpInfo.php?ip=myip";
//    NSString *URLTmp1 = [URLTmp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  //转码成UTF-8  否则可能会出现错误
//    //    [URLTmp stringByAddingPercentEncodingWithAllowedCharacters:(nonnull NSCharacterSet *)]
//    URLTmp = URLTmp1;
//    NSURLRequest *request =
//    [NSURLRequest requestWithURL:[NSURL URLWithString: URLTmp]];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setCompletionBlockWithSuccess:
//     ^(AFHTTPRequestOperation *operation, id responseObject) {
//         NSLog(@"Success: %@", operation.responseString);
//         NSString *requestTmp = [NSString stringWithString:operation.responseString];
//         NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
//         //系统自带JSON解析
//         NSDictionary *resultDic =
//         [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
////         NSLog(@"aaaaaaa=====%@",resultDic.description);
//
//         complication(resultDic[@"data"][@"ip"]);
//
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         NSLog(@"Failure: %@", error);
//         complication(nil);
//     }];
//    [operation start];
//}


#pragma mark - 获取设备当前网络IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (void)clearWebCookies {
    //清空web Cookie
    NSHTTPCookieStorage *myCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [myCookie cookies])
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    //删除沙盒自动生成的Cookies.binarycookies文件
    NSString *path = NSHomeDirectory();
    NSString *filePath = [path stringByAppendingPathComponent:@"/Library/Cookies/Cookies.binarycookies"];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:filePath error:nil];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:cookieUserDef];
}

+ (NSString *)getVersion {
    
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

@end
