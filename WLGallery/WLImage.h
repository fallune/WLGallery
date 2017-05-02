//
//  WLImage.h
//  WLGallery
//
//  Created by 王立 on 2017/4/26.
//  Copyright © 2017年 王立. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLImage : NSObject

@property (nonatomic,strong) NSString* ThumbUrl ;

@property (nonatomic,strong) NSString* ImageUrl ;

@property (nonatomic,assign) BOOL isSelected;

@end
