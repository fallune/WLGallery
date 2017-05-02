//
//  YN_GalleryVC.h
//  YN_CamFi
//
//  Created by 王立 on 16/7/6.
//  Copyright © 2016年 王立. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbsGalleryVC : UIViewController
{
     NSMutableArray *_selections;
}
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

@property (nonatomic, assign) NSInteger Select_Card;


@end
