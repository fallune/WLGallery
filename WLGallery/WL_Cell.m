//

//
//  Created by 王立 on 16/9/21.
//  Copyright © 2016年 王立. All rights reserved.
//

#import "WL_Cell.h"

@implementation WL_Cell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    // 重置image
    self.IMGVIEW.image = nil;
    
    // 更新位置
   // self.IMGVIEW.frame = self.contentView.bounds;
}


@end
