//
//  netConfig.h
//  Hjyzg
//
//  Created by GengKC on 2018/5/10.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#ifndef netConfig_h
#define netConfig_h

#if DEBUG
//#define testWebConfig
#endif


// 仅供测试环境  192.168.1.175:8000
#ifdef testWebConfig

static NSString *webHostStr = @"192.168.1.175:8000";

static NSString *mainPageUrl = @"http://192.168.1.175:8000/index.asp?uid=";
static NSString *houseUrl = @"http://192.168.1.175:8000/speed.asp?md=";
static NSString *shoppingCarUrl = @"http://192.168.1.175:8000/shopcart.asp?md=";
static NSString *renovationUrl = @"http://192.168.1.175:8000/zhuangxiu/Designpic_list.asp?md=";

static NSString *autoLoginUrl = @"http://192.168.1.175:8000/login_u.asp?";
static NSString * userUrl = @"http://192.168.1.175:8000/personal/member.asp?md=";
static NSString * userLoginUrl = @"http://192.168.1.175:8000/personal/login.asp";
static NSString * userRegsterUrl = @"http://192.168.1.175:8000/personal/reg.asp";
static NSString * userForgetPwd = @"http://192.168.1.175:8000/personal/forgetpassword.asp?target_id=blank_show";

static NSString *photoUploadPageUrl = @"http://192.168.1.175:8000/personal/photo.asp?target_id=blank_list";

static NSString *photoUploadUrl = @"http://192.168.1.175:8000/upimg.asp?";
static NSString *shangpuWebUrl = @"http://192.168.1.175:8000/shangpu/shangpu.asp?target_id=blank_list&md=";
static NSString *wuyeWebUrl = @"http://192.168.1.175:8000/personal/property_fee.asp?target_id=blank_list&md=";
static NSString *zufangWebUrl = @"http://192.168.1.175:8000/lease_house.asp?target_id=blank_list&md=";
//static NSString *shopcartChangeUrl = @"http://192.168.1.175:8000/shopcart.asp?act=add";

static NSString *payWebUrl = @"http://192.168.1.175:8000/personal/pay.asp?";
static NSString *inlineAlipayUrl = @"http://192.168.1.175:8000/alipay_wap/alipayapi.asp";

static NSString *openQQUrl_special = @"http://wpa.qq.com/msgrd?";
static NSString *kefuzhongxin_special = @"showarticle.asp?";

static NSString *checkStatusUrl = @"http://192.168.1.175:8000/personal/android_login_check.asp?act=up";

static NSString *getOrderListUrl = @"http://192.168.1.175:8000/personal/orderlist.asp?target_id=blank_list";
static NSString *fenqiPayListUrl = @"http://192.168.1.175:8000/personal/fenqilist.asp?target_id=blank_show";

static NSString *modifyPwdUrl = @"http://192.168.1.175:8000/personal/password.asp";
static NSString *modifyPayUrl = @"http://192.168.1.175:8000/personal/payment.asp?target_id=blank_show";



#else

//
static NSString *webHostStr = @"192.168.1.175:8000";

static NSString *mainPageUrl = @"http://app.hjyzg.net/index.asp?uid=";
static NSString *houseUrl = @"http://app.hjyzg.net/speed.asp?md=";
static NSString *shoppingCarUrl = @"http://app.hjyzg.net/shopcart.asp?md=";
static NSString *renovationUrl = @"http://app.hjyzg.net/zhuangxiu/Designpic_list.asp?md=";

static NSString *autoLoginUrl = @"http://app.hjyzg.net/login_u.asp?";
static NSString * userUrl = @"http://app.hjyzg.net/personal/member.asp?md=";
static NSString * userLoginUrl = @"http://app.hjyzg.net/personal/login.asp";
static NSString * userRegsterUrl = @"http://app.hjyzg.net/personal/reg.asp";
static NSString * userForgetPwd = @"http://app.hjyzg.net/personal/forgetpassword.asp?target_id=blank_show";

static NSString *photoUploadPageUrl = @"http://app.hjyzg.net/personal/photo.asp?target_id=blank_list";

static NSString *photoUploadUrl = @"http://app.hjyzg.net/upimg.asp?";
static NSString *shangpuWebUrl = @"http://app.hjyzg.net/shangpu/shangpu.asp?target_id=blank_list&md=";
static NSString *wuyeWebUrl = @"http://app.hjyzg.net/personal/property_fee.asp?target_id=blank_list&md=";
static NSString *zufangWebUrl = @"http://app.hjyzg.net/lease_house.asp?target_id=blank_list&md=";
//static NSString *shopcartChangeUrl = @"http://app.hjyzg.net/shopcart.asp?act=add";

static NSString *payWebUrl = @"http://app.hjyzg.net/personal/pay.asp?";
static NSString *inlineAlipayUrl = @"http://app.hjyzg.net/alipay_wap/alipayapi.asp";

static NSString *openQQUrl_special = @"http://wpa.qq.com/msgrd?";
static NSString *kefuzhongxin_special = @"showarticle.asp?";

static NSString *checkStatusUrl = @"http://app.hjyzg.net/personal/android_login_check.asp?act=up";

static NSString *getOrderListUrl = @"http://app.hjyzg.net/personal/orderlist.asp?target_id=blank_list";
static NSString *fenqiPayListUrl = @"http://app.hjyzg.net/personal/fenqilist.asp?target_id=blank_show";

static NSString *modifyPwdUrl = @"http://app.hjyzg.net/personal/password.asp";
static NSString *modifyPayUrl = @"http://app.hjyzg.net/personal/payment.asp?target_id=blank_show";


#endif




#endif /* netConfig_h */
