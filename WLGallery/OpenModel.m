//
//  OpenModel.m
//  WLGallery
//
//  Created by 王立 on 2017/4/26.
//  Copyright © 2017年 王立. All rights reserved.
//

#import "OpenModel.h"

@implementation OpenModel


static OpenModel* openstore;
+(instancetype) sharedStore
{
    if(!openstore)
    {
        openstore = [[self alloc] initPrivate];
    }
    return openstore;
}
-(instancetype)initPrivate
{
    self = [super init];
    if (self)
    {
        
        for (int i = 0 ; i<400; i++)
        {
            if(i%3 == 0)
            {
                [self.Array_ThumbsURL addObject:@"http://i-3.yxdown.com/2015/9/5/d300a23f-f31d-4f9d-807c-17d481feef74.png"];
            }
            else if(i%3 == 1)
            {
                [self.Array_ThumbsURL addObject:@"http://www.icosky.com/icon/png/Avatar/Elite%20Captains/Elite%20Captain%20Blue.png"];
            }
            else
            {
                
                [self.Array_ThumbsURL addObject:@"http://img.zcool.cn/community/031a27957e2a8010000018c1ba93c16.jpg@250w_188h_1c_1e_2o_100sh.jpg"];
                
            }
            
            
            
            
        }
        
        for (int i = 0 ; i<400; i++)
        {
          http://img3.imgtn.bdimg.com/it/u=1810722859,117825692&fm=23&gp=0.jpg
            
            if(i%3 == 0)
            {
                [self.Array_ImagesURL addObject:@"http://h7.86.cc/walls/20140729/1440x900_c97433d5c90d74b.jpg"];
            }
            else if(i%3 == 1)
            {
                [self.Array_ImagesURL addObject:@"http://pic77.nipic.com/file/20150905/4562496_090410604000_2.jpg"];
            }
            else
            {
                
                [self.Array_ImagesURL addObject:@"http://bizhi.zhuoku.com/2013/05/27/zhuoku/zhuoku149.jpg"];
                
            }
        }
        
        
        self.Array_Images = [NSMutableArray array];
    }
    return self;
}


-(NSMutableArray*)Array_ThumbsURL
{
    if(!_Array_ThumbsURL)
    {
        _Array_ThumbsURL = [NSMutableArray array];
    }
    return _Array_ThumbsURL;
}
-(NSMutableArray*)Array_ImagesURL
{
    if(!_Array_ImagesURL)
    {
        _Array_ImagesURL = [NSMutableArray array];
    }
    return _Array_ImagesURL;
}


-(instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use+[SGpop_Model sharedStore]" userInfo:nil];
    return nil;
}



@end
