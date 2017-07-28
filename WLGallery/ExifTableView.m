//
//  YN_PickerView.m
// 
//
//  Created by 王立 on 16/8/12.
//  Copyright © 2016年 王立. All rights reserved.
//
//  ExposureTime   曝光时间
//  FNumber       光圈
//ExposureBiasValue   ev值
//ISOSpeedRatings    ISO
//   FocalLength   焦距
// PixelXDimension    PixelYDimension   尺寸
//DateTimeOriginal   拍摄日期
// MeteringMode    测光模式

#import "ExifTableView.h"
#import "Masonry.h"
#import "WWimageExitInfo.h"
#import "HistogramView.h"
#import "MBProgressHUD.h"
#import "OpenModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>



#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
static NSString *CellIdentifier = @"infocell";

@interface ExifTableView()<UITableViewDelegate,UITableViewDataSource,MBProgressHUDDelegate>

@property (nonatomic,strong) UITableView* Table;
@property (nonatomic,strong) NSArray* InfoArray;
@property (nonatomic,strong)  NSArray*ArrayColorString ;
@property (nonatomic,strong)  NSMutableArray*ArrayColor ;
@property (nonatomic,strong)  HistogramView* myhistogram ;
@property (nonatomic,strong)  MBProgressHUD* Wait_hud;

@property (nonatomic,strong)  NSMutableDictionary* dic_RGB ;
@property (nonatomic,strong) NSDictionary * imageExifDictionary;
@end

@implementation ExifTableView

-(instancetype)init
{
    self = [super initWithFrame:CGRectZero];//先不要指定位置大小
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self initTable];
    }
    return  self;
}

-(void)setDic_RGB:(NSMutableDictionary *)dic
{
    if([dic isKindOfClass:[NSDictionary class]]&&dic )
    {
        _dic_RGB = dic;
        WS(weakSelf);
        dispatch_async(dispatch_get_main_queue(), ^{
            [_Wait_hud hideAnimated:NO];
            [weakSelf.Table setContentOffset:CGPointMake(0,0) animated:NO];
            NSLog(@"reload table");
            [weakSelf.Table reloadData];
        });
    }
}
-(void)initTable
{
    self.Table = [[UITableView alloc]initWithFrame:CGRectZero];
    self.Table.backgroundColor = [UIColor clearColor];
    
    self.Table.delegate = self;
    self.Table.dataSource = self;
    self.Table.layer.cornerRadius = 15;
    self.Table.layer.masksToBounds = NO;
    [self.Table registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self addSubview:self.Table];
}


- (void)setSelectedHandle:(PVSelectedHandle)selectedHandle
{
    _selectedHandle = selectedHandle;
}


-(void)showFromView:(UIView *)view animated:(BOOL)animated withPage:(NSInteger)page
{

    _Wait_hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    _Wait_hud.delegate = self;
    _Wait_hud.mode = MBProgressHUDModeIndeterminate;
    _Wait_hud.removeFromSuperViewOnHide = YES;
    [_Wait_hud hideAnimated:YES afterDelay:15];
    
    if(self.visible)// 已经显示了
    {
        [self removeFromSuperview];
    }
    
    [view addSubview:self];
    [self _showFromView:view animated:animated];
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make)
     {

         make.top.equalTo(view).with.offset(0);
         make.bottom.equalTo(view).with.offset(0);
         make.right.equalTo(view).with.offset(0);

         //为了美观   宽度 + 20
         make.width.mas_equalTo(view.bounds.size.width*3/7);
     }];
    [self.Table mas_remakeConstraints:^(MASConstraintMaker *make)
     {
         
         make.top.left.bottom.and.right.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
         
     }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        WLImage* theimage = [[OpenModel sharedStore] Array_Images][page];
        
        BOOL isExit = [[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:theimage.ImageUrl]];
        
        if (isExit)
        {
            NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:theimage.ImageUrl]];
            if (cacheImageKey.length)
            {
                NSString *cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
                if (cacheImagePath.length)
                {
                    
                    self.imageExifDictionary =[[[WWimageExitInfo alloc]initWithURL:[NSURL fileURLWithPath:cacheImagePath]] imageExifDictionary];
 
                    UIImage* image = [UIImage imageWithContentsOfFile:cacheImagePath];
                    self.dic_RGB =  [self.myhistogram readImage: image];
                     image = nil;
                }
        
            }
        
        }
    });
   
}

-(void)hide:(BOOL)animated
{
    [self _hideWithAnimated:animated];
}

-(BOOL)visible
{
    if (self.superview)
    {
        return YES;
    }
    return NO;
}

-(NSArray*)InfoArray
{
    if(!_InfoArray)
    {
        _InfoArray = @[NSLocalizedString(@"Exif_aperture", nil),NSLocalizedString(@"Exif_ev", nil),
                       NSLocalizedString(@"Exif_iso", nil),NSLocalizedString(@"Exif_shutter", nil),NSLocalizedString(@"Exif_focal_length", nil),
                       NSLocalizedString(@"Exif_metering", nil),
                       NSLocalizedString(@"Exif_size", nil),
                       NSLocalizedString(@"Exif_datetime", nil),NSLocalizedString(@"Exif_luminance", nil),NSLocalizedString(@"Exif_r", nil),NSLocalizedString(@"Exif_g", nil),NSLocalizedString(@"Exif_b", nil)];
    }
    return _InfoArray;
}

-(NSArray*)ArrayColorString
{
    if(!_ArrayColorString)
    {
        _ArrayColorString = @[@"whitepoints",@"redpoints",@"greenpoints",@"bluepoints"];
    }
    return _ArrayColorString;
}

-(NSMutableArray*)ArrayColor
{
    if(!_ArrayColor)
    {
        _ArrayColor = [NSMutableArray array];
        [_ArrayColor addObject:[UIColor whiteColor]];
        [_ArrayColor addObject:[UIColor redColor]];
        [_ArrayColor addObject:[UIColor greenColor]];
        [_ArrayColor addObject:[UIColor blueColor]];
    }
    return _ArrayColor;
}

#pragma mark - pickerview代理方法
// 当选中了pickerView的某一行的时候调用
// 会将选中的列号和行号作为参数传入
// 只有通过手指选中某一行的时候才会调用


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.InfoArray.count ;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = (UITableViewCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.backgroundColor =  [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
    cell.textLabel.text = _InfoArray[indexPath.row];
    NSString*TmpStr;

    if (indexPath.row<8)
    {
        
        switch (indexPath.row)
        {
            case 0:
                
                
                if([_imageExifDictionary[@"FNumber"] isKindOfClass:[NSNumber class] ]  )
                {
                   TmpStr =[_imageExifDictionary[@"FNumber"] stringValue];
                    
                    
                }
                else if([_imageExifDictionary[@"FNumber"] isKindOfClass:[NSString class]] )
                {
                    TmpStr = _imageExifDictionary[@"FNumber"];
                }
                break;
            case 1:
                if([_imageExifDictionary[@"ExposureBiasValue"] isKindOfClass:[NSNumber class] ]  )
                {
                    TmpStr = [_imageExifDictionary[@"ExposureBiasValue"] stringValue];;
                    
                }
                else if([_imageExifDictionary[@"ExposureBiasValue"] isKindOfClass:[NSString class]] )
                {
                    TmpStr = _imageExifDictionary[@"ExposureBiasValue"];
                }
                break;
            case 2:
                if([_imageExifDictionary[@"ISOSpeedRatings"] isKindOfClass:[NSNumber class] ]  )
                {
                    TmpStr = [_imageExifDictionary[@"ISOSpeedRatings"] stringValue];;
                    
                }
                else if([_imageExifDictionary[@"ISOSpeedRatings"] isKindOfClass:[NSString class]] )
                {
                    TmpStr = _imageExifDictionary[@"ISOSpeedRatings"];
                }
                else if([_imageExifDictionary[@"ISOSpeedRatings"] isKindOfClass:[NSArray class]] )
                {
                    TmpStr = [_imageExifDictionary[@"ISOSpeedRatings"][0] stringValue];
                    
                }
                break;
            case 3:
                if([_imageExifDictionary[@"ExposureTime"] isKindOfClass:[NSNumber class] ]  )
                {
                    TmpStr = [_imageExifDictionary[@"ExposureTime"] stringValue];;
                    
                }
                else if([_imageExifDictionary[@"ExposureTime"] isKindOfClass:[NSString class]] )
                {
                    TmpStr = _imageExifDictionary[@"ExposureTime"];
                }
                break;
            case 4:
                if([_imageExifDictionary[@"FocalLength"] isKindOfClass:[NSNumber class] ]  )
                {
                    TmpStr = [_imageExifDictionary[@"FocalLength"] stringValue];;
                    
                }
                else if([_imageExifDictionary[@"FocalLength"] isKindOfClass:[NSString class]] )
                {
                    TmpStr = _imageExifDictionary[@"FocalLength"];
                }
                break;
            case 5:
                if([_imageExifDictionary[@"MeteringMode"] isKindOfClass:[NSNumber class] ]  )
                {
                    TmpStr = [_imageExifDictionary[@"MeteringMode"] stringValue];;
                    
                }
                else if([_imageExifDictionary[@"MeteringMode"] isKindOfClass:[NSString class]] )
                {
                    TmpStr = _imageExifDictionary[@"MeteringMode"];
                }
                break;
            case 6:
            {
                NSString* str1;
                NSString* str2;
                if([_imageExifDictionary[@"PixelXDimension"] isKindOfClass:[NSNumber class] ]  )
                {
                    str1 = [_imageExifDictionary[@"PixelXDimension"] stringValue];;
                    
                }
                else if([_imageExifDictionary[@"PixelXDimension"] isKindOfClass:[NSString class]] )
                {
                    str1 = _imageExifDictionary[@"PixelXDimension"];
                }
                if([_imageExifDictionary[@"PixelYDimension"] isKindOfClass:[NSNumber class] ]  )
                {
                    str2 = [_imageExifDictionary[@"PixelYDimension"] stringValue];;
                    
                }
                else if([_imageExifDictionary[@"PixelYDimension"] isKindOfClass:[NSString class]] )
                {
                    str2 = _imageExifDictionary[@"PixelYDimension"];
                }
                
                TmpStr = [[str1
                                              stringByAppendingString:@"X"] stringByAppendingString:str2]
                ;
                
            }
                break;
            case 7:
                if([_imageExifDictionary[@"DateTimeOriginal"] isKindOfClass:[NSNumber class] ]  )
                {
                    TmpStr = [_imageExifDictionary[@"DateTimeOriginal"] stringValue];;
                    
                }
                else if([_imageExifDictionary[@"DateTimeOriginal"] isKindOfClass:[NSString class]] )
                {
                    TmpStr = _imageExifDictionary[@"DateTimeOriginal"];
                }
                break;
            default:
            {
                
            }
                break;
        }
        
        UILabel* SubLable = [[UILabel alloc]init];
        SubLable.text = TmpStr ;//substringToIndex:20];
        SubLable.textColor = [UIColor redColor];
        SubLable.font= [UIFont systemFontOfSize:13];
        SubLable.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:SubLable];
        SubLable.frame = CGRectMake(100  , 0, cell.bounds.size.width-100 - 20 , 44);
    }
    else
    {
      
        ClsDraw* clsview = [[ClsDraw alloc]init];
        
        [cell.contentView addSubview:clsview];
        clsview.frame = CGRectMake(100, 0, cell.bounds.size.width-100 -20, 100);
        clsview.graphColor  = self.ArrayColor[indexPath.row-8];
        
        [clsview drawGraphForArray:self.dic_RGB[self.ArrayColorString[indexPath.row-8]]];
        // NSLog(@",,,,%p",self.dic_RGB[self.ArrayColorString[indexPath.row-8]]);
        clsview.layer.transform = CATransform3DMakeRotation(M_PI, 1.0,0.0, 0.0);
    }
    return cell;
}
-(HistogramView*)myhistogram
{
    if(!_myhistogram)
    {
        _myhistogram = [[HistogramView alloc] initWithZone];
    }
    return _myhistogram;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<8)
    {
        return 44;
    }
    else
    {
        return 100;
    }
    
}

///////////////////////////

#pragma mark - Private Methods

static CAAnimation* _showAnimation()
{
    CAKeyframeAnimation *transform = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    transform.values = values;
    
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacity setFromValue:@0.0];
    [opacity setToValue:@1.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.2;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [group setAnimations:@[transform, opacity]];
    return group;
}

static CAAnimation* _hideAnimation()
{
    CAKeyframeAnimation *transform = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1.0)]];
    transform.values = values;
    
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacity setFromValue:@1.0];
    [opacity setToValue:@0.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    // group.duration = 0.1;
    group.duration = 0.02;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [group setAnimations:@[transform, opacity]];
    return group;
}



-(void)_showFromView:(UIView*)view animated:(BOOL)animated
{
    if(animated)
    {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            //[self.tableview flashScrollIndicators];
        }];
        [self.layer addAnimation:_showAnimation() forKey:nil];
        [CATransaction commit];
    }
}
-(void)_hideWithAnimated:(BOOL)animated
{
    if(animated)
    {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.layer removeAnimationForKey:@"transform"];
            [self.layer removeAnimationForKey:@"opacity"];
            [self removeFromSuperview];
        }];
        [self.layer addAnimation:_hideAnimation() forKey:nil];
        [CATransaction commit];
    }
    else
    {
        [self removeFromSuperview];
    }
}


///////////////////////////

- (void)hudWasHidden:(MBProgressHUD*)hud
{
    if(hud.superview)
    {
        [hud removeFromSuperview];
    }
    hud=nil;
}


@end
