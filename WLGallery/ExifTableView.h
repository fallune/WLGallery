//
//  ExifTableView.h
//  
//
//  Created by 王立 on 2017/3/7.
//  Copyright © 2017年 王立. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef void (^PVSelectedHandle)(NSInteger selectedIndex);

@interface ExifTableView : UIView

@property (nonatomic,readonly) BOOL visible;

@property (nonatomic, copy) PVSelectedHandle selectedHandle;
-(instancetype)init;
-(void)showFromView:(UIView *)view animated:(BOOL)animated withPage:(NSInteger)page;
-(void)hide:(BOOL)animated;

@end
