//
//  ShoppingCarViewController.m
//  Hjyzg
//
//  Created by GengKC on 2018/4/11.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "ShoppingCarViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>


@interface ShoppingCarViewController ()

@end

@implementation ShoppingCarViewController

- (void)dealloc {
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [self setupWebViewWith:[NSString stringWithFormat:@"%@%@",shoppingCarUrl,[UtilTools getTimeFlag]]];
}

#pragma mark --- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSInteger loginStatus = [[NSUserDefaults standardUserDefaults] integerForKey:userLoginStateDef];
    if (loginStatus!=LoginStateSuccess) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请先登录账号" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITabBarController *tablCtl = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
            [tablCtl setSelectedIndex:4];
        }];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:^{
            [self.webView stopLoading];
        }];
        
        return NO;
    }
    
    
    NSRange targetRange = [request.URL.absoluteString rangeOfString:@"target_id="];
    NSRange navmainPageRange = [request.URL.absoluteString rangeOfString:[mainPageUrl substringToIndex:houseUrl.length-4]];
    
    if (navmainPageRange.length && navmainPageRange.location!=NSNotFound) {
        UITabBarController *tabCtl = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [tabCtl setSelectedIndex:0];
        
        return NO;
    }
    else if (targetRange.length && targetRange.location != NSNotFound
             && ![request.URL.absoluteString isEqualToString:self.webUrl]) {
        RWebViewController *tempCtl = [[RWebViewController alloc] init];
        [tempCtl setupWebViewWith:request.URL.absoluteString];
        if (self.isTabCtl) {
            tempCtl.hidesBottomBarWhenPushed = YES;
        }
        [self.navigationController pushViewController:tempCtl animated:YES];
        
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
    
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSDictionary *config = [[NSUserDefaults standardUserDefaults] dictionaryForKey:loginUserConfigDef];
    [context evaluateScript:[NSString stringWithFormat:@"login_android_to_web(%@,%@)",config[@"phoneNum"],config[@"pwd"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
