//
//  ModifyPayPwdViewController.m
//  Hjyzg
//
//  Created by GengKC on 2018/5/2.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "ModifyPayPwdViewController.h"
#import "WebViewJavascriptBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>


@interface ModifyPayPwdViewController () <UIWebViewDelegate>

@property WebViewJavascriptBridge *webViewBridge;

@end

@implementation ModifyPayPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupWebViewWith:modifyPayUrl];
    
    _webViewBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [_webViewBridge setWebViewDelegate:self];
    
    
    // _webViewBridge recall
    [_webViewBridge registerHandler:@"swModifyPayPwd" handler:^(id data, WVJBResponseCallback responseCallback) {
        //        NSLog(@"swLoginClick %@",data);
        //        responseCallback(scanResult);
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addJsCustomFun {
    [self.webView stringByEvaluatingJavaScriptFromString:[[WebRequestHelper shareInstance] getWebJsBridgeString]];
    [self.webView stringByEvaluatingJavaScriptFromString:@"function swModifyPayPwd() {   \
     WebViewJavascriptBridge.callHandler('swModifyPayPwd', null, function(response) { })  \
     }"];
    
//    NSString *jsFun = @"$(\"#sendform\").click(function(){   \
//     $.ajax({   \
//    url:\"payment_check.asp?act=up\", \
//    data:{  \
//        \"mobile\":$(\"#mobile\").val(),    \
//        \"yanzhengma\":$(\"#yanzhengma\").val() ,   \
//        \"zhifumima\":data_1    \
//    },  \
//    type:\"post\",    \
//    async:false,    \
//    dataType:\"text\",    \
//        success : function(data) {  \
//            if(data=='true'){   \
//                $.show_Prompt_3(\"钱包密码设置成功！\");   \
//                setTimeout(function () {    \
//                swModifyPayPwd();   \
//                }, 3000);   \
//            } else if(data==\"0\") {  \
//                $.show_Prompt('输入验证码！');    \
//            }  else if(data==\"1\") { \
//                $.show_Prompt('验证码输入不正确！'); \
//            }   \
//        },  \
//        error : function() {    \
//            $.show_Prompt('服务器故障'); \
//        }   \
//    }); \
//     });";
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"click"] = ^() {
        [self.webView stringByEvaluatingJavaScriptFromString:@"alert('html');"];
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
