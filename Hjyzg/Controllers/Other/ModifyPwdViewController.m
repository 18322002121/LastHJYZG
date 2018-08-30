//
//  ModifyPwdViewController.m
//  Hjyzg
//
//  Created by GengKC on 2018/5/2.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "ModifyPwdViewController.h"
#import "WebViewJavascriptBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "UserViewController.h"


@interface ModifyPwdViewController () <UIWebViewDelegate>

@property WebViewJavascriptBridge *webViewBridge;

@end

@implementation ModifyPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupWebViewWith:modifyPwdUrl];
    
    _webViewBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [_webViewBridge setWebViewDelegate:self];
    
    
    // _webViewBridge recall
    [_webViewBridge registerHandler:@"swModifyPwd" handler:^(id data, WVJBResponseCallback responseCallback) {
        //        NSLog(@"swLoginClick %@",data);
        //        responseCallback(scanResult);
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改密码成功，请重新登录！" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self.navigationController popToRootViewControllerAnimated:NO];
        }];
        [alert addAction:confirm];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        [[NSUserDefaults standardUserDefaults] setInteger:LoginStateLogout forKey:userLoginStateDef];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:loginUserConfigDef];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [UtilTools clearWebCookies];
        
        UserViewController *userCtl = (UserViewController *)self.navigationController.viewControllers[0];
        [userCtl.webView reload];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)addJsCustomFun {
    [self.webView stringByEvaluatingJavaScriptFromString:[[WebRequestHelper shareInstance] getWebJsBridgeString]];
    [self.webView stringByEvaluatingJavaScriptFromString:@"function swModifyPwd(arg0) {   \
     WebViewJavascriptBridge.callHandler('swModifyPwd', {'pwd' : arg0 }, function(response) { })  \
     }"];
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"SendForm"] = ^() {
            // TODO: HUD
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [UtilTools showHUDIndicatorView];
            
            [self.webView stringByEvaluatingJavaScriptFromString:@"$.ajax({ \
                                                             url:\"password_check.asp?act=up\",   \
                                                            data:{  \
                                                                \"passmoren\":0,    \
                                                                \"oldpassword\":$(\"#oldpassword\").val(),  \
                                                                \"password\":$(\"#password\").val() \
                                                            },  \
                                                            type:\"post\",    \
                                                           async:false, \
                                                        dataType:\"text\",    \
                                                        success : function(data) {  \
                                                            if(data=='true'){   \
                                                                swModifyPwd(md5($(\"#password\").val()).substr(8, 16));  \
                                                            } else {    \
                                                                $.show_Prompt('旧密码错误'); \
                                                            }   \
                                                        },  \
                                                          error : function() {  \
                                                              alert(\"3\");   \
                                                              $.show_Prompt('服务器故障');   \
                                                          } \
             }); "];
            
        });
    };
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
