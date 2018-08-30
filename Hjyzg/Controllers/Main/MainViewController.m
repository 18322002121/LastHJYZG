//
//  MainViewController.m
//  Hjyzg
//
//  Created by GengKC on 2018/4/11.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "MainViewController.h"


@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:UserId];
    [self setupWebViewWith:[NSString stringWithFormat:@"%@%@",mainPageUrl,uid]];
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(nonnull NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSLog(@"%@",request);
    NSRange targetRange = [request.URL.absoluteString rangeOfString:@"target_id="];
    NSRange navHouseRange = [request.URL.absoluteString rangeOfString:[houseUrl substringToIndex:houseUrl.length-4]];
    NSRange navRenovationRange = [request.URL.absoluteString rangeOfString:[renovationUrl substringToIndex:renovationUrl.length-4]];
    
    if (navHouseRange.length && navHouseRange.location!=NSNotFound) {
        UITabBarController *tabCtl = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [tabCtl setSelectedIndex:1];
        
        return NO;
    }
    else if (navRenovationRange.length && navRenovationRange.location!=NSNotFound) {
        UITabBarController *tabCtl = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [tabCtl setSelectedIndex:3];
        
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

@end
