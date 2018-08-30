//
//  UtilTools.h
//  Hjyzg
//
//  Created by GengKC on 2018/4/22.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bugly/Bugly.h>


#define  UserId  @"User__UserId"
#define cookieUserDef  @"org.webCookie.UserDef"
static NSString *userLoginStateDef = @"userLoginState";
static NSString *loginUserConfigDef = @"loginUserConfigDef";


typedef enum : NSUInteger {
    LoginStateNoneUser,
    LoginStateSuccess,
    LoginStateError,
    LoginStateLogout,
} LoginState;


// wxPay
#define wxpay_app_id  @"wxa5910cce314f6fc6"
#define  wxpay_mch_id  @"1501692571"
#define  notify_url  @"http://app.hjyzg.net/weixin_pay/notify.asp" //测试不可用
#define  wxShopSignID  @"7zYl7gjBYRcOIcDmrGouocz9QQOGsuSC"
//AppSecret   = "90026dd7486d8a256b1e97cc7b65de4d"
//MchKey      = "7zYl7gjBYRcOIcDmrGouocz9QQOGsuSC"

#define  wxPayNotify  @"wxPayNotifyForReload"


@interface UtilTools : NSObject

+ (NSString *)getTimeFlag;

+ (void)showAutoDismissHUDText:(NSString *)string;
+ (void)showHUDIndicatorView;
+ (void)dismissHUDIndicatorView;

+ (NSString *)getwxFormatXmlOrderWith:(NSDictionary *)parma;

+ (NSString *)getRandomNonceStr;
+ (NSString *)getwxSignWith:(NSDictionary *)dic;

+ (void)clearWebCookies;

+ (NSString *)getVersion;

@end
