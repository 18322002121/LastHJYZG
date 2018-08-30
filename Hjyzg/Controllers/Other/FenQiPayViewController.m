//
//  FenQiPayViewController.m
//  Hjyzg
//
//  Created by GengKC on 2018/4/28.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "FenQiPayViewController.h"

@interface FenQiPayViewController ()

@end

@implementation FenQiPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self setupWebViewWith:self.webUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark --- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //    NSLog(@"%@",request);
    
    return YES;
}

@end
