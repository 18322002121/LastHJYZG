//
//  RWebViewController.h
//  Hjyzg
//
//  Created by GengKC on 2018/4/13.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <MJRefresh/MJRefresh.h>


@interface RWebViewController : UIViewController;

@property (nonatomic, assign) BOOL isTabCtl; // must ,def if NO;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *webUrl;

@property (nonatomic, strong) UIProgressView *progress;

- (void)setupWebViewWith:(NSString *)webUrl;

@end
