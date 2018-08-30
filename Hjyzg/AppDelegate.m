//
//  AppDelegate.m
//  Hjyzg
//
//  Created by GengKC on 2018/4/11.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//
// target_id, activity

#import "AppDelegate.h"
#import "MainViewController.h"
#import "HouseViewController.h"
#import "ShoppingCarViewController.h"
#import "RenovationViewController.h"
#import "UserViewController.h"
#import "UIImage+ResetImage.h"
#import "RWebViewController.h"
#import <WXApi.h>


static NSString * myAppId = @"com.sxtf.hjyzg";

@interface AppDelegate () <CLLocationManagerDelegate, WXApiDelegate>
{
    NSUInteger _tiCount;
}

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
//    [Bugly startWithAppId:myAppId];
    BuglyConfig * config = [[BuglyConfig alloc] init];
    // 设置自定义日志上报的级别，默认不上报自定义日志
    config.reportLogLevel = BuglyLogLevelError;
    [Bugly startWithAppId:myAppId config:config];
    
    
    
    [[WebRequestHelper shareInstance] checkNetwork]; // 检测网络
    [self setUpLocationFun]; // 位置信息
    [self registerWXApiPay]; //微信支付注册
    
    [self initMainUI];
    [[WebRequestHelper shareInstance] setUpLoginStatus]; //登录
    return YES;
}

- (void)initMainUI {
    // status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSArray *ctlArr = @[@"MainViewController", @"HouseViewController", @"ShoppingCarViewController", @"RenovationViewController", @"UserViewController"];
    NSArray *titleArr = @[@"首页", @"家居", @"购物车", @"装修", @"我"];
    NSArray *npgArr = @[@"ic_home", @"jiaju", @"gouwuche", @"zhuangxiu", @"center"];
    
    NSMutableArray *mutArr = [@[] mutableCopy];
    for (int i=0; i<ctlArr.count; i++) {
        RWebViewController *ctl = [[NSClassFromString(ctlArr[i]) alloc] init];
        ctl.isTabCtl = YES;
        UINavigationController *navCtl = [[UINavigationController alloc] initWithRootViewController:ctl];
        navCtl.tabBarItem = [[UITabBarItem alloc] initWithTitle:titleArr[i] image:[[UIImage imageNamed:npgArr[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:[NSString stringWithFormat:@"%@_down",npgArr[i]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [mutArr addObject:navCtl];
        
        [navCtl.navigationBar setBackgroundImage:[UIImage imageWithColor:NavRedColor] forBarMetrics:UIBarMetricsDefault];
        [navCtl.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        [ctl.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    }
    
    UITabBarController *tabCtl = [[UITabBarController alloc] init];
    [tabCtl.tabBar setTintColor:TabRedColor];
    tabCtl.viewControllers = mutArr;
    self.window.rootViewController = tabCtl;
    
    [self addLunchAnimation];
}

- (void)registerWXApiPay {
//    public String WX_APPID = "wx78e21cecad0208ad";
    [WXApi registerApp:wxpay_app_id];
}

- (void)setUpLocationFun {
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            
            [_locationManager requestWhenInUseAuthorization];
        }
        
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 5.0;
        
        [_locationManager startUpdatingLocation]; //开始定位
    }
}

- (void)addLunchAnimation {
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    //横屏请设置成 @"Landscape"
    NSString *viewOrientation = @"Portrait";
    UIImage *launchImage;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = [UIImage imageNamed:dict[@"UILaunchImageName"]];
        }
    }
    // suit iPhoneX
    CGFloat statusHight = (CGRectGetHeight([UIScreen mainScreen].bounds)>=812.0f) ? 44.0 : 20.0;
    
    UIImageView *lunchImgView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [lunchImgView setImage:launchImage];
    lunchImgView.userInteractionEnabled = YES;
    [self.window addSubview:lunchImgView];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)-120, statusHight+10, 100, 30)];
    l.layer.cornerRadius = 4.0;
    l.layer.masksToBounds = YES;
    l.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    l.font = [UIFont systemFontOfSize:15];
    l.text = @"跳过: 3秒";
    l.textAlignment = NSTextAlignmentCenter;
    [lunchImgView addSubview:l];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeView:)];
    [lunchImgView addGestureRecognizer:tap];
    
    _tiCount=3;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFun:) userInfo:l repeats:YES];
}

-  (void)removeView:(UITapGestureRecognizer *)ges {
    [ges.view removeFromSuperview];
}

- (void)timerFun:(NSTimer *)ti {
    _tiCount--;
    UILabel *lb = (UILabel *)ti.userInfo;
    [lb setText:[NSString stringWithFormat:@"跳过: %lu秒",(unsigned long)_tiCount]];
    if (_tiCount<=0) {
        [ti invalidate];
        ti = nil;
        [lb.superview removeFromSuperview];
    }
}

#pragma mark --- WXApiDelegate
//是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面。
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
         PayResp *response = (PayResp*)resp;
        switch (response.errCode) {
            case WXSuccess: {
//                服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:wxPayNotify object:nil];
                
                UITabBarController *tabCtl = (UITabBarController *)self.window.rootViewController;
                [tabCtl setSelectedIndex:4];
                UINavigationController *nav =  tabCtl.selectedViewController;
                UserViewController *userCtl = (UserViewController *)nav.topViewController;
                [userCtl setSelectOrderList];
            }
                break;
            case WXErrCodeUserCancel: {
                NSLog(@"用户取消");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:wxPayNotify object:nil];
                
                UITabBarController *tabCtl = (UITabBarController *)self.window.rootViewController;
                [tabCtl setSelectedIndex:4];
                UINavigationController *nav =  tabCtl.selectedViewController;
                UserViewController *userCtl = (UserViewController *)nav.topViewController;
                [userCtl setSelectOrderList];
                 
            }
                break;
            default: {
                 NSLog(@"支付失败，retcode=%d",resp.errCode);
                [UtilTools showAutoDismissHUDText:[NSString stringWithFormat:@"支付失败 %d",resp.errCode]];
            }
                break;
        }
    }
}

//如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。sendReq请求调用后，会切到微信终端程序界面。`
- (void)onReq:(BaseReq *)req {
    NSLog(@"onReq %@",req);
}

#pragma mark --- UIApplicationDelegate
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark --- CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *local = [locations lastObject];
    CLLocationCoordinate2D coordinate = local.coordinate;
    NSLog(@"用户经度 ：%f，维度： %f",coordinate.latitude, coordinate.longitude);
    self.userCoordinate = coordinate;
    
    [[WebRequestHelper shareInstance] postLocationMsg:coordinate];
    
}

#pragma mark --- UIApplicationDelegate
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
