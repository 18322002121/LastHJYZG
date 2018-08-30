//
//  HouseViewController.m
//  Hjyzg
//
//  Created by GengKC on 2018/4/11.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import "HouseViewController.h"


@interface HouseViewController ()

@end

@implementation HouseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupWebViewWith:[NSString stringWithFormat:@"%@%.0f",houseUrl,[NSDate date].timeIntervalSince1970]];
    
}

    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
