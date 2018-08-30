

//
//  UserViewController.m
//  Hjyzg
//
//  Created by GengKC on 2018/4/11.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "UserViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "WebViewJavascriptBridge.h"
#import "PhotoUploadViewController.h"
#import "FenQiPayViewController.h"
#import "ForgetPwdViewController.h"


@interface UserViewController () <UIWebViewDelegate>

@property WebViewJavascriptBridge *webViewBridge;

@end

@implementation UserViewController

- (void)dealloc {
    NSLog(@"%s",__func__);
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL isLogin = ([[NSUserDefaults standardUserDefaults] integerForKey:userLoginStateDef]==LoginStateSuccess);
    NSString *url = isLogin ? userUrl : userLoginUrl;
    
    [self setupWebViewWith:url];
    
    _webViewBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [_webViewBridge setWebViewDelegate:self];
    
    [self.view addSubview:self.webView];
    
    
    // _webViewBridge recall
    [_webViewBridge registerHandler:@"swLoginClick" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"swLoginClick %@",data);
//        responseCallback(scanResult);
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:@{@"phoneNum":data[@"phoneNum"], @"pwd":data[@"pwd"]} forKey:loginUserConfigDef];
        NSHTTPCookieStorage *myCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:[myCookie cookies]];
        [def setObject:cookieData forKey:cookieUserDef];
        [def setInteger:LoginStateSuccess forKey:userLoginStateDef];
        [def synchronize];
        
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [UtilTools dismissHUDIndicatorView];
//        });
    }];
    
    __weak UserViewController *weakSelf = self;
    [_webViewBridge registerHandler:@"swLogoutClick" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"swLogoutClick %@",data);
        //        responseCallback(scanResult);
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:loginUserConfigDef];
        [[NSUserDefaults standardUserDefaults] setInteger:LoginStateLogout forKey:userLoginStateDef];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        [UtilTools clearWebCookies];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//             [UtilTools dismissHUDIndicatorView];
            [weakSelf reloadLogoutViews];
        });
    }];
}

#pragma mark - private method
- (void)addJsSwitchLoginFun
{
    [self.webView stringByEvaluatingJavaScriptFromString:[[WebRequestHelper shareInstance] getWebJsBridgeString]];
    [self.webView stringByEvaluatingJavaScriptFromString:@"function swLoginClick(arg0, arg1) {   \
     WebViewJavascriptBridge.callHandler('swLoginClick', {'phoneNum' : arg0, 'pwd' : arg1 }, function(response) { })  \
     }"];
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"SendForm"] = ^() {
        ;
        // TODO: HUD
        dispatch_async(dispatch_get_main_queue(), ^{
//            [UtilTools showHUDIndicatorView];
            
            [self.webView stringByEvaluatingJavaScriptFromString:@"$.ajax({ \
            url:'login_check.asp?act=up', \
            data:{ \
                'mobile':$('#mobile').val(), \
                'password':$('#password').val() \
            }, \
            type:'post', \
            async:false, \
            dataType:'text', \
                success : function(data) { \
                    if(data=='true'){ \
             swLoginClick($('#mobile').val(), md5($('#password').val()).substr(8, 16));   \
                        window.location.href='member.asp'; \
                        \
                    } else { \
                        $.show_Prompt('用户名或密码错误'); \
                    } \
                }, \
                error : function() { \
                    $.show_Prompt('服务器故障'); \
                } \
             }); "];
            
        });
    };
    
}

- (void)addJsSwitchLogoutFun {
    [self.webView stringByEvaluatingJavaScriptFromString:[[WebRequestHelper shareInstance] getWebJsBridgeString]];
    [self.webView stringByEvaluatingJavaScriptFromString:@"function swLogoutClick() {   \
     WebViewJavascriptBridge.callHandler('swLogoutClick', 'swLogoutClick fun', function(response) { })  \
     }"];
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"tuichu"] = ^() {
        ;
        dispatch_async(dispatch_get_main_queue(), ^{
//            [UtilTools showHUDIndicatorView];
            
            [self.webView stringByEvaluatingJavaScriptFromString:@"$.ajax({ \
                                                             url:'exit.asp?act=up', \
                                                            data:{ },   \
                                                            type:'post',    \
                                                           async:false, \
                                                        dataType:'text',    \
                                                        success : function(data) {  \
                                                            if(data=='true'){   \
                                                                $('#tixianshow').hide();    \
                                                                swLogoutClick();   \
                                                            } else { }  \
                                                        },  \
                                                          error : function() {  \
                                                              $.show_Prompt('服务器故障');   \
                                                          } \
             });"];
        });
    };
}

- (void)addJsSwitchRegLoginFun {
    [self.webView stringByEvaluatingJavaScriptFromString:[[WebRequestHelper shareInstance] getWebJsBridgeString]];
    [self.webView stringByEvaluatingJavaScriptFromString:@"function swLoginClick(arg0, arg1) {   \
     WebViewJavascriptBridge.callHandler('swLoginClick', {'phoneNum' : arg0, 'pwd' : arg1 }, function(response) { })  \
     }"];
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"SendForm"] = ^() {
        ;
        // TODO: HUD
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [UtilTools showHUDIndicatorView];
            
            [self.webView stringByEvaluatingJavaScriptFromString:@"$.ajax({ \
                                                             url:\"reg_Result.asp?act=up\", \
                                                            data:{  \
                                                                \"mobile\":$(\"#mobile\").val(),    \
                                                                \"password\":$(\"#password\").val(),    \
                                                                \"code\":$(\"#code\").val()  \
                                                            },  \
                                                            type:\"post\",    \
                                                           async:false, \
                                                        dataType:\"text\",    \
                                                        success : function(data) {  \
                                                            if(data=='1'){  \
                                                                $.show_Prompt('验证码错误，请重新输入！')\
                                                            } else if(data=='2'){   \
                                                                $.show_Prompt('验证码超时，请重新获取！')   \
                                                            }else if(data=='3'){    \
                                                                $.show_Prompt('联系电话格式错误，请根据提示重新输入！')    \
                                                            }  else if(data=='4'){  \
                                                                $.show_Prompt('手机号已存在，请换个手机号注册！')   \
                                                            }   else if(data=='5'){ \
                                                            swLoginClick($('#mobile').val(), md5($('#password').val()).substr(8, 16));   \
                                                                window.location.href=\"member.asp\";  \
                                                            }   \
                                                        },  \
                                                          error : function() {  \
                                                              $.show_Prompt('服务器故障');   \
                                                          } \
             });"];
            
        });
    };
}

#pragma mark --- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSLog(@"shouldStartLoadWithRequest %@  navigationType  %ld",request.description,(long)navigationType);
    NSRange range = [request.URL.absoluteString rangeOfString:@"target_id="];
    NSRange photoRange = [request.URL.absoluteString rangeOfString:photoUploadPageUrl];
    NSRange fenqiPayRange = [request.URL.absoluteString rangeOfString:fenqiPayListUrl];
    
//    忘记密码
    if ([request.URL.absoluteString isEqualToString:userForgetPwd]) {
        ForgetPwdViewController *ctl = [[ForgetPwdViewController alloc] init];
        ctl.isTabCtl = NO;
        ctl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ctl animated:YES];
        return NO;
    }
    
    // special 客服中心
    if ([request.URL.absoluteString rangeOfString:kefuzhongxin_special].location!=NSNotFound) {
        return NO;
    }
    
    // specail 分期购
    if (fenqiPayRange.length && fenqiPayRange.location!=NSNotFound) {
        FenQiPayViewController *fCtl = [[FenQiPayViewController alloc] init];
        [fCtl setupWebViewWith:request.URL.absoluteString];
        fCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:fCtl animated:YES];
        return NO;
    }
//    specail 头像页面
    if (photoRange.length && photoRange.location!=NSNotFound) {
        PhotoUploadViewController *pCtl = [[PhotoUploadViewController alloc] init];
        pCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pCtl animated:YES];
        return NO;
    }
    
    // special Open QQ
    if ([request.URL.absoluteString rangeOfString:openQQUrl_special].location!=NSNotFound) {
        RWebViewController *rCtl = [[RWebViewController alloc] init];
        [rCtl setupWebViewWith:@"mqq://im/chat?chat_type=wpa&uin=1099779883&version=1&src_type=web"]; // specail for iOS
        rCtl.isTabCtl = NO;
        rCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:rCtl animated:YES];
        return NO;
    }
//    special 打电话
    if ([request.URL.absoluteString rangeOfString:@"tel:0791-12345678"].location!=NSNotFound) {
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",@"0393-2091777"];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
        
        return NO;
    }
    
    if (range.length && range.location!=NSNotFound) {
        RWebViewController *rCtl = [[RWebViewController alloc] init];
        [rCtl setupWebViewWith:request.URL.absoluteString];
        rCtl.isTabCtl = NO;
        rCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:rCtl animated:YES];
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *htmlTitle = @"document.title";
    if (!self.isTabCtl) {
        self.title = [webView stringByEvaluatingJavaScriptFromString:htmlTitle];
    }
    
    [self.progress setProgress:1.0 animated:YES];
    
    [self.progress removeFromSuperview];
    [self.webView.scrollView.mj_header endRefreshing];
    
//    注册
    if ([webView.request.URL.absoluteString isEqualToString:userRegsterUrl]) {
        [self addJsSwitchRegLoginFun];
        return;
    }
    
    // add js custom fun
    NSRange loginRange = [webView.request.URL.absoluteString rangeOfString:userLoginUrl];
    BOOL isLogin = (loginRange.location!=NSNotFound) && loginRange.length;
    if (isLogin) {
        [self addJsSwitchLoginFun];
        return;
    }
    [self addJsSwitchLogoutFun];
}

- (void)reloadLogoutViews {
//    BOOL isLogin = ([[NSUserDefaults standardUserDefaults] integerForKey:userLoginState]==LoginStateSuccess);
//    NSString *url = isLogin ? userUrl : userLoginUrl;
    
    NSURL *htmlURL = [NSURL URLWithString:userLoginUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:htmlURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [self.webView loadRequest:request];
    
}

- (void)setSelectOrderList {
    RWebViewController *rCtl = [[RWebViewController alloc] init];
    [rCtl setupWebViewWith:getOrderListUrl];
    rCtl.isTabCtl = NO;
    rCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rCtl animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
