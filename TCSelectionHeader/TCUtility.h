//
//  TCUtility.h
//  TCSelectionHeaderDemo
//
//  Created by Xie Hong on 6/26/15.
//  Copyright (c) 2015 timecoco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define SCREEN_WIDTH        (getScreenSize().width)
#define SCREEN_HEIGHT       (getScreenSize().height)
@interface UIImage (Extensions)

+(UIImage *)imageFromColor:(UIColor *)color;

@end

@interface TCUtility : NSObject

CGSize getScreenSize();

@end
