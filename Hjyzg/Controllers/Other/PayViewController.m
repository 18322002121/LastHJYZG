//
//  PayViewController.m
//  Hjyzg
//
//  Created by GengKC on 2018/4/21.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "PayViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "WebViewJavascriptBridge.h"
#import <GDataXML-HTML/GDataXMLNode.h>
#import <WXApi.h>
#import "UserViewController.h"


@interface PayViewController () <UIWebViewDelegate>

@property WebViewJavascriptBridge *webViewBridge;

@end

@implementation PayViewController

- (void)dealloc {
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPayView:) name:wxPayNotify object:nil];
    
    [self setupWebViewWith:self.webUrl];
    
    _webViewBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [_webViewBridge setWebViewDelegate:self];
    
    
    [_webViewBridge registerHandler:@"callOnOCWeixinPay" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@" callOnOCWeixinPay %@", data);
        [[WebRequestHelper shareInstance] sendWxPayUnifiedorderWith:data complication:^(id retData) {
            if (retData) {
                GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:retData encoding:NSUTF8StringEncoding error:nil];
                NSString * retCode = [[[xmlDoc rootElement] elementsForName:@"return_code"][0] stringValue];
                if ([retCode isEqualToString:@"SUCCESS"]) {
                    
                    NSMutableDictionary *mutDic = [@{} mutableCopy];
                    mutDic[@"appid"] = wxpay_app_id;
                    mutDic[@"partnerid"] = wxpay_mch_id;
                    mutDic[@"prepayid"] = [[[xmlDoc rootElement] elementsForName:@"prepay_id"][0] stringValue];
                    mutDic[@"package"] = @"Sign=WXPay";
                    mutDic[@"noncestr"] = [UtilTools getRandomNonceStr];
                    mutDic[@"timestamp"] = [UtilTools getTimeFlag];
                    
                    mutDic[@"sign"] = [UtilTools getwxSignWith:[mutDic copy]];
                    
                    PayReq *payRequest = [[PayReq alloc] init];
                    payRequest.partnerId = mutDic[@"partnerid"];
                    payRequest.prepayId =  mutDic[@"prepayid"];
                    payRequest.package = @"Sign=WXPay";
                    payRequest.nonceStr = mutDic[@"noncestr"];
                    payRequest.timeStamp = [mutDic[@"timestamp"] intValue];
                    payRequest.sign= mutDic[@"sign"];
                    
                    // 微信支付
                    [WXApi sendReq:payRequest];
                }
                else {
                    [UtilTools showAutoDismissHUDText:@"提交订单失败"];
                }
            }
        }];
        
        // 将结果返回给js
//        responseCallback(location);
    }];
}

- (void)refreshPayView:(NSNotification *)notify {
    if ([notify.name isEqualToString:wxPayNotify]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}


- (void)addJsCustomFun {
    [self.webView stringByEvaluatingJavaScriptFromString:[[WebRequestHelper shareInstance] getWebJsBridgeString]];
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"function callOnOCWeixinPay(params) {   \
                            WebViewJavascriptBridge.callHandler('callOnOCWeixinPay',params,function(response) { }); \
                            }"];
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"sendfrom"] = ^() {
        ;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *jsString = @" \
            if ($('input:radio[name=\"zhifufangshi\"]:checked').val()==2){  \
            $(\".ftc_wzsf\").show();    \
        }else if($('input:radio[name=\"zhifufangshi\"]:checked').val()==1){ \
            PARAMS={\"order_no\":$(\"#order_no\").val(),\"product_name\":$(\"#product_name\").val(),\"order_price\":$(\"#order_price\").val(),\"WIDshow_url\":$(\"#WIDshow_url\").val()};   \
            var temp_form = document.createElement(\"form\");   \
            temp_form .action = \"../alipay_wap/alipayapi.asp\";    \
            temp_form .target = \"_blank\"; \
            temp_form .method = \"post\";   \
            temp_form .style.display = \"none\";    \
            for (var x in PARAMS)   \
            {   \
                var opt = document.createElement(\"input\");    \
                opt.name = x;   \
                opt.value = PARAMS[x];  \
                temp_form .appendChild(opt);    \
            }   \
            document.body.appendChild(temp_form);   \
            temp_form .submit();    \
        }else if ($('input:radio[name=\"zhifufangshi\"]:checked').val()==3){    \
            var params = {'body':$(\"#product_name\").val(), 'out_trade_no':$(\"#order_no\").val(), 'total_fee':$(\"#order_price\").val()*100, 'product_id':$(\"#product_id\").val()}; \
            callOnOCWeixinPay(params);   \
        }";
            
//            NSString *jsText = @"if ($('input:radio[name=\"zhifufangshi\"]:checked').val()==3){    \
//            alert(['eqeqw','iamda',129012,'21212']);   \
//            }";
            
            [self.webView stringByEvaluatingJavaScriptFromString:jsString];
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
//    NSLog(@"%@",request);
    NSString *str = [NSString stringWithFormat:@"http://%@/",webHostStr];
    if ([request.URL.absoluteString isEqualToString:str]) { //回到主页
        [self.navigationController popViewControllerAnimated:YES];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
