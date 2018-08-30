//
//  UIImage+ColorImage.h
//  Hjyzg
//
//  Created by GengKC on 2018/4/12.
//  Copyright © 2018年 ShenXinTaiFu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ResetImage)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;

@end
