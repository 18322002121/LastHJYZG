//
//  WebRequestHelper.h
//  Hjyzg
//
//  Created by GengKC on 2018/4/14.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "netConfig.h"


@interface WebRequestHelper : NSObject

+ (instancetype)shareInstance;

- (void)setUpLoginStatus;

//- (void)getVersionWith:(void(^)(NSString *))block;

- (void)postLocationMsg:(CLLocationCoordinate2D)userCoordinate;

- (void)checkLoginedStatusComplition:(void(^)(BOOL isLogin))complition;

- (NSString *)getWebJsBridgeString;

- (void)uploadPhoto:(UIImage *)img imgName:(NSString *)name complication:(void(^)(BOOL isSuccess))complication;

- (void)checkNetwork;

- (void)sendWxPayUnifiedorderWith:(NSDictionary *)parma complication:(void(^)(id retData))complication;

@end
