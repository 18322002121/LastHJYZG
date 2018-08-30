//
//  ForgetPwdViewController.m
//  Hjyzg
//
//  Created by GengKC on 2018/5/1.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import "WebViewJavascriptBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>



@interface ForgetPwdViewController () <UIWebViewDelegate>

@property WebViewJavascriptBridge *webViewBridge;

@end

@implementation ForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupWebViewWith:userForgetPwd];
    
    _webViewBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [_webViewBridge setWebViewDelegate:self];
    
    
    // _webViewBridge recall
    [_webViewBridge registerHandler:@"swLoginClick" handler:^(id data, WVJBResponseCallback responseCallback) {
        //        NSLog(@"swLoginClick %@",data);
        //        responseCallback(scanResult);
        
        [UtilTools showAutoDismissHUDText:@"找回密码成功，请重新登录！"];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:@{@"phoneNum":data[@"phoneNum"], @"pwd":data[@"pwd"]} forKey:loginUserConfigDef];
        [def synchronize];
        
//        [[WebRequestHelper shareInstance] setUpLoginStatus]; //登录
//
//        [_userCtl.webView reload];
        [self.navigationController popViewControllerAnimated:YES];
        
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            [UtilTools dismissHUDIndicatorView];
        //        });
    }];
    
}


- (void)addJsCustomFun {
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
            
            [self.webView stringByEvaluatingJavaScriptFromString:@"$.ajax({     \
                                                             url:\"frogetpass_Result.asp?act=up\",    \
                                                            data:{  \
                                                                \"mobile\":$(\"#mobile\").val(),    \
                                                                \"password\":$(\"#password\").val(),    \
                                                                \"code\":$(\"#code\").val() \
                                                            },  \
                                                            type:\"post\",  \
                                                           async:false, \
                                                        dataType:\"text\",    \
                                                        success : function(data) {  \
                                                            if(data=='1'){  \
                                                                $.show_Prompt('验证码错误，请重新输入！')   \
                                                            } else if(data=='2'){   \
                                                                $.show_Prompt('验证码超时，请重新获取！')   \
                                                            }else if(data=='3'){    \
                                                                $.show_Prompt('联系电话格式错误，请根据提示重新输入！')    \
                                                            }else if(data=='4'){    \
                                                                $.show_Prompt('您的手机号没有注册，请先注册用户！')  \
                                                            }else if(data=='5'){    \
                                                            swLoginClick($('#mobile').val(), md5($('#password').val()).substr(8, 16));   \
                                                            }   \
                                                        },  \
                                                          error : function() {  \
                                                              $.show_Prompt('服务器故障');   \
                                                          } \
             });"];
            
        });
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --- UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *htmlTitle = @"document.title";
    if (!self.isTabCtl) {
        self.title = [webView stringByEvaluatingJavaScriptFromString:htmlTitle];
    }
    
    [self.progress setProgress:1.0 animated:YES];
    [self.progress removeFromSuperview];
    [self.webView.scrollView.mj_header endRefreshing];
    
    // add js custom fun
    [self addJsCustomFun];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}


@end
