//
//  AppDelegate.h
//  Hjyzg
//
//  Created by GengKC on 2018/4/11.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign) CLLocationCoordinate2D userCoordinate;

@end

