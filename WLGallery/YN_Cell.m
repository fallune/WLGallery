//
//  YN_Cell.m
//  YN_CamFi
//
//  Created by 王立 on 16/9/21.
//  Copyright © 2016年 王立. All rights reserved.
//

#import "YN_Cell.h"

@implementation YN_Cell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    // 重置image
    self.IMGVIEW.image = nil;
    
    // 更新位置
   // self.IMGVIEW.frame = self.contentView.bounds;
}


@end
