//
//  PhotoUploadViewController.m
//  Hjyzg
//
//  Created by GengKC on 2018/4/19.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "PhotoUploadViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "WebViewJavascriptBridge.h"
#import "UserViewController.h"
#import "UIImage+ResetImage.h"


@interface PhotoUploadViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIWebViewDelegate>

@property WebViewJavascriptBridge *webViewBridge;

@end

@implementation PhotoUploadViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupWebViewWith:photoUploadPageUrl];
    self.webView.scrollView.scrollEnabled = NO;
    
    _webViewBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [_webViewBridge setWebViewDelegate:self];
    
    
    // _webViewBridge Callback
    __weak PhotoUploadViewController *weakSelf = self;
    [_webViewBridge registerHandler:@"choosePicOCFun" handler:^(id data, WVJBResponseCallback responseCallback) {
        __strong PhotoUploadViewController *strongSelf = weakSelf;
//        NSLog(@"swLoginClick %@",data);
        
        UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *cameraImgPickCtl = [[UIImagePickerController alloc] init];
            cameraImgPickCtl.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraImgPickCtl.title = @"相机";
            cameraImgPickCtl.delegate = self;
            cameraImgPickCtl.allowsEditing = YES;
            [strongSelf presentViewController:cameraImgPickCtl animated:YES completion:^{
                
            }];
        }];
        UIAlertAction *actionLib = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *imgPickCtl = [[UIImagePickerController alloc] init];
            imgPickCtl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imgPickCtl.title = @"相册";
            imgPickCtl.delegate = self;
            imgPickCtl.allowsEditing = YES;
            [strongSelf presentViewController:imgPickCtl animated:YES completion:^{
                
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [alertCtl addAction:actionCamera];
            }
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                [alertCtl addAction:actionLib];
            }
            [alertCtl addAction:cancel];
            
            [strongSelf presentViewController:alertCtl animated:YES completion:nil];
        });
        
    }];
    
    
    [_webViewBridge registerHandler:@"callbackOC" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"callbackOC %@",data);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView reload];
            UITabBarController *tabCtl = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *nav = tabCtl.selectedViewController;
            UserViewController *userCtl = (UserViewController *)nav.viewControllers[0];
            NSString *jsEvalute = [NSString stringWithFormat:@"tx_imgload('%@')",data];
            JSContext *context = [userCtl.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
            [context evaluateScript:jsEvalute];
        });
        
    }];
}

- (void)addJsCustomFun {
    [self.webView stringByEvaluatingJavaScriptFromString:[[WebRequestHelper shareInstance] getWebJsBridgeString]];
    [self.webView stringByEvaluatingJavaScriptFromString:@"function choosePicOCFun() {   \
     WebViewJavascriptBridge.callHandler('choosePicOCFun', null, function(response) { })  \
     }"];
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"function callbackOC(html) {   \
     WebViewJavascriptBridge.callHandler('callbackOC', html, function(response) { })  \
     }"];
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"choosePic"] = ^() {
        ;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView stringByEvaluatingJavaScriptFromString:@"choosePicOCFun();"];
        });
    };
    
//    __weak PhotoUploadViewController *weakSelf = self;
    
    context[@"imgload"] = ^(JSValue *url) {
        NSLog(@"imgload :%@",url);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *urlOCString = [url toString];
            NSString *paramsOCString = [urlOCString substringFromIndex:7];
            
            NSString *jsString = [NSString stringWithFormat:@"\
                                  var params = { 'FileUpload_SelectBtn': '%@' };    \
                                  $.ajax({    \
                                  'type': 'post', \
                                  'url': 'photo_add.asp', \
                                  'dataType': 'html', \
                                  'timeout': 300000,  \
                                  'data': params, \
                                  success: function (html) {  \
                                  callbackOC(html);    \
                                  },  \
                                  error: function () {    \
                                  $.JAlert('服务器响应失败，请稍候重新再试!');  \
                                  $(Obj).attr('onclick', 'EditInfo(this)');   \
                                  }   \
                                  }); ", paramsOCString];
            
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

#pragma mark --- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"%@",info);
    UIImage *img = info[@"UIImagePickerControllerEditedImage"];
    __block UIImage *thumbImg = [UIImage thumbnailWithImageWithoutScale:img size:CGSizeMake(100, 100)];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyyMMddHHmmssfff";
    __block NSString *imgName = [NSString stringWithFormat:@"%@",[format stringFromDate:[NSDate date]]];
//    __block NSString *simgName = [NSString stringWithFormat:@"s_%@",[format stringFromDate:[NSDate date]]];
    
    __weak PhotoUploadViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[WebRequestHelper shareInstance] uploadPhoto:thumbImg imgName:imgName complication:^(BOOL isSuccess0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *jsEvalute = [NSString stringWithFormat:@"imgload('_photo_%@.jpg')",imgName];
                JSContext *context = [weakSelf.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
                [context evaluateScript:jsEvalute];
                
            });
        }];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:^{
        }];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
