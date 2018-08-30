//
//  RWebViewController.m
//  Hjyzg
//
//  Created by GengKC on 2018/4/13.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "RWebViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "PayViewController.h"
#import "ModifyPwdViewController.h"
#import "ModifyPayPwdViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>


@interface RWebViewController () <UIWebViewDelegate>

@end

@implementation RWebViewController

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.isTabCtl) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"nav"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"meau"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(menuShow)];
    }
    else {
        
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
    
    
}


- (void)setupWebViewWith:(NSString *)webUrl {
    _webUrl = webUrl;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-64)];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.scrollView.backgroundColor = [UIColor whiteColor];
    
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:webUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    //    [request setTimeoutInterval:60.0];
    //    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    //    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    //    [request setHTTPShouldHandleCookies:YES];
    //    [request setAllHTTPHeaderFields:headers];
    [_webView loadRequest:request];
    _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    [self.view addSubview:_webView];
    _webView.delegate = self;
    
    _progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progress.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 2);
    _progress.progressTintColor = [UIColor greenColor];
    
    _progress.progress = 0.1;
    
    [self.view addSubview:_progress];
    
    //
    _webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //        _progress.progress = 0.1;
        [_webView reload];
    }];
}

- (void)menuShow {
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)-120, 55, 120, 224)];
    imgView.image = [[UIImage imageNamed:@"title_function_bg.9"] resizableImageWithCapInsets:UIEdgeInsetsMake(35, 20, 20, 70) resizingMode:UIImageResizingModeStretch];
    UIViewController *alertCtl = [[UIViewController alloc] init];
    alertCtl.view.backgroundColor = [UIColor clearColor];
    [alertCtl.view addSubview:imgView];
    imgView.userInteractionEnabled = YES;
    
    NSArray *titleArr = @[@"家居建材",@"交物业费",@"我要装修",@"我要买房",@"我要租房",@"个人中心",@"路线导航",@"版本号"];
//    NSArray *btnImagArr = @[@"j_06",@"j_06",@"j_06",@"j_06",@"j_06",@"j_06",@"j_06",@"j_06"];
//    tab_icon1
    for (int i=0; i<titleArr.count; i++) {
        UIView *btnView = [self creatBtnWithRect:CGRectMake(0, 14+i*26, 120, 26) title:titleArr[i] titleImgStr:[NSString stringWithFormat:@"tab_icon%d",i+1] btnTag:200+i];
        [imgView addSubview:btnView];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMenuHide:)];
    [alertCtl.view addGestureRecognizer:tap];
    
    [UIApplication sharedApplication].keyWindow.rootViewController.definesPresentationContext = YES;
    alertCtl.modalPresentationStyle = UIModalPresentationOverCurrentContext;   // alertViewController背景透明
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertCtl animated:NO completion:nil];
}

- (void)tapMenuHide:(UITapGestureRecognizer *)tapGes {
    UIViewController *alertCtl = (UIViewController *)tapGes.view.nextResponder;
    [alertCtl dismissViewControllerAnimated:NO completion:nil];
}

- (UIView *)creatBtnWithRect:(CGRect)rect title:(NSString *)titleStr titleImgStr:(NSString *)imgStr btnTag:(NSInteger)tag {
    UIView *view = [[UIView alloc]
                    initWithFrame:rect];
    view.backgroundColor = [UIColor clearColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:titleStr forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)-1);
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 40)];
    [view addSubview:btn];
    btn.tag = tag;
    [btn addTarget:self action:@selector(btnCmdClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(rect)-1, CGRectGetWidth(rect), 1)];
    line.image = [UIImage imageNamed:@"mm_title_functionframe_line"];
    [view addSubview:line];
    
    return view;
}

- (void)btnCmdClick:(UIButton *)btn {
    UITabBarController *tabCtl = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    switch (btn.tag-200) {
        case 0: {
            [tabCtl setSelectedIndex:1];
        }
            break;
        case 1: {
            RWebViewController *wuyeCtl = [[RWebViewController alloc] init];
            [wuyeCtl setupWebViewWith:[NSString stringWithFormat:@"%@%@", wuyeWebUrl,[UtilTools getTimeFlag]]];
            wuyeCtl.hidesBottomBarWhenPushed = YES;
            wuyeCtl.isTabCtl = NO;
            [tabCtl.selectedViewController pushViewController:wuyeCtl animated:YES];
        }
            break;
        case 2: {
            [tabCtl setSelectedIndex:3];
        }
            break;
        case 3: {
            RWebViewController *rentalCtl = [[RWebViewController alloc] init];
            [rentalCtl setupWebViewWith:[NSString stringWithFormat:@"%@%@",shangpuWebUrl, [UtilTools getTimeFlag]]];
            rentalCtl.hidesBottomBarWhenPushed = YES;
            [tabCtl.selectedViewController pushViewController:rentalCtl animated:YES];
        }
            break;
        case 4: {
            RWebViewController *rentalCtl = [[RWebViewController alloc] init];
            [rentalCtl setupWebViewWith:[NSString stringWithFormat:@"%@%@",zufangWebUrl, [UtilTools getTimeFlag]]];
            rentalCtl.hidesBottomBarWhenPushed = YES;
            rentalCtl.isTabCtl = NO;
            [tabCtl.selectedViewController pushViewController:rentalCtl animated:YES];
        }
            break;
        case 5: {
            [tabCtl setSelectedIndex:4];
        }
            break;
        case 6: {
            [self onDaoHangForIOSMap];
        }
            break;
        case 7: {
            [UtilTools showAutoDismissHUDText:[NSString stringWithFormat:@"版本: %@",[UtilTools getVersion]]];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"版本: %@",[UtilTools getVersion]] message:@"惠家云直购版权所有" preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    [alert dismissViewControllerAnimated:YES completion:nil];
//                }];
//                [alert addAction:action];
//                [self presentViewController:alert animated:YES completion:nil];
//            });
        }
            break;
        default:
            break;
    }
    
    UIViewController *ctl = (UIViewController *)btn.superview.superview.superview.nextResponder;
    [ctl dismissViewControllerAnimated:NO completion:nil];
}

- (void)onDaoHangForIOSMap
{
    //起点 经纬度
    AppDelegate *appDele = (AppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocationCoordinate2D coor = appDele.userCoordinate;
    MKMapItem *currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]                         initWithCoordinate:coor  addressDictionary:nil]];
    currentLocation.name = @"我的位置";
    
    //目的地的位置
    // TODO: "35.840188","115.082342" 、、 申新泰富
    CLLocationCoordinate2D targetCoor = CLLocationCoordinate2DMake(35.840188, 115.082342);
    
    //    CLLocationCoordinate2D coords = self.location;
    
    
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:targetCoor addressDictionary:nil]];
    
    toLocation.name = @"申新泰富.国际商贸城";
    
    NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
    NSString * mode = MKLaunchOptionsDirectionsModeDriving; // def is Driving
    
    NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:mode, MKLaunchOptionsMapTypeKey: [NSNumber                                 numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES };
    //打开苹果自身地图应用，并呈现特定的item
    [MKMapItem openMapsWithItems:items launchOptions:options];
}

#pragma mark --- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    修改密码
    if ([request.URL.absoluteString isEqualToString:modifyPwdUrl]) {
        ModifyPwdViewController *ctl = [[ModifyPwdViewController alloc] init];
        ctl.isTabCtl = NO;
        ctl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ctl animated:YES];
        return NO;
    }
//    修改支付密码
    if ([request.URL.absoluteString isEqualToString:modifyPayUrl]) {
        ModifyPayPwdViewController *ctl = [[ModifyPayPwdViewController alloc] init];
        ctl.isTabCtl = NO;
        ctl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ctl animated:YES];
        return NO;
    }
    
    NSRange targetRange = [request.URL.absoluteString rangeOfString:@"target_id="];
    if (targetRange.length && targetRange.location != NSNotFound
        && ![request.URL.absoluteString isEqualToString:_webUrl]) {
        RWebViewController *tempCtl = [[RWebViewController alloc] init];
        [tempCtl setupWebViewWith:request.URL.absoluteString];
        if (_isTabCtl) {
            tempCtl.hidesBottomBarWhenPushed = YES;
        }
        [self.navigationController pushViewController:tempCtl animated:YES];
        
        return NO;
    }
    
//    NSString* reqUrl = request.URL.absoluteString;
    if ([request.URL.absoluteString rangeOfString:payWebUrl].location!=NSNotFound ) {
        PayViewController *tempCtl = [[PayViewController alloc] init];
//                [tempCtl setupWebViewWith:request.URL.absoluteString]; // TODO:
        [tempCtl setWebUrl:request.URL.absoluteString];
        [self.navigationController pushViewController:tempCtl animated:YES];
        return NO;
    }
//    if ([reqUrl hasPrefix:@"alipays://"] || [reqUrl hasPrefix:@"alipay://"]) {
//        BOOL bSucc = [[UIApplication sharedApplication] openURL:request.URL];
//        //bSucc是否成功调起支付宝
//    }
    
    return YES;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_progress setProgress:0.5 animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *htmlTitle = @"document.title";
    if (!_isTabCtl) {
        self.title = [webView stringByEvaluatingJavaScriptFromString:htmlTitle];
    }
    
    [_progress setProgress:1.0 animated:YES];
    
    [_progress removeFromSuperview];
    [_webView.scrollView.mj_header endRefreshing];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:userLoginStateDef]!=LoginStateSuccess) {
        return;
    }
    
//    NSString *str0 = [NSString stringWithFormat:@"http://%@/personal",webHostStr];
//    NSString *str1 = [NSString stringWithFormat:@"http://%@/shopcart",webHostStr];
//    NSRange personalRan = [_webUrl rangeOfString:str0];
//    NSRange shopCarRan = [_webUrl rangeOfString:str1];
//
//    if ((personalRan.location!=NSNotFound) || (shopCarRan.location!=NSNotFound)) {
//        [[WebRequestHelper shareInstance] checkLoginedStatusComplition:^(BOOL isLogin) {
//            if (!isLogin) {
//
//                [UtilTools clearWebCookies];
//
//                [self.navigationController popToRootViewControllerAnimated:NO];
//            }
//        }];
//    }
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSDictionary *config = [[NSUserDefaults standardUserDefaults] dictionaryForKey:loginUserConfigDef];
    [context evaluateScript:[NSString stringWithFormat:@"login_android_to_web(%@,%@)",config[@"phoneNum"],config[@"pwd"]]];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFailLoadWithError %@",error);
    
    [_progress removeFromSuperview];
    [_webView.scrollView.mj_header endRefreshing];
    
    [_webView stopLoading];
    
//    [UtilTools showAutoDismissHUDText:@"加载出错，请刷新重试"];
    
    BLYLogError(@"webView didFailLoadWith errorCode:%ld des:%@", (long)error.code ,error.description);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
