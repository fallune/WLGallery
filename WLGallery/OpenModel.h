//
//  OpenModel.h
//  WLGallery
//
//  Created by 王立 on 2017/4/26.
//  Copyright © 2017年 王立. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLImage.h"
@interface OpenModel : NSObject
@property(nonatomic,strong)NSMutableArray* Array_ThumbsURL;
@property(nonatomic,strong)NSMutableArray* Array_ImagesURL;
@property(atomic,strong)NSMutableArray* Array_Images;

+(instancetype) sharedStore;
@end
