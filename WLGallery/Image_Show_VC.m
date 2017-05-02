//
//  Image_Show_VC.m
//
//
//  Created by 王立 on 16/7/25.
//  Copyright © 2016年 王立. All rights reserved.
//

#import "Image_Show_VC.h"
#import "STPhotoBrowserView.h"
#import "STConfig.h"
#import "STIndicatorView.h"
#import "STAlertView.h"
#import "Masonry.h"
#import "HistogramView.h"
#import <QuartzCore/QuartzCore.h>
#import "YN_Cell.h"
#import "MBProgressHUD.h"
#import "WWimageExitInfo.h"
#import "ExifTableView.h"
#import "CircleProgressView.h"
#import "WLImage.h"
#import "OpenModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

static BOOL Has_Hidden = false;
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
@interface Image_Show_VC()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *Thumbs_Show_Outlet;
@property (weak, nonatomic) IBOutlet UIView *Image_Show_Outlet;

@property (weak, nonatomic) IBOutlet UIView *Navigation_Outlet;
@property (weak, nonatomic) IBOutlet UIButton *Save_Button_Outlet;
@property (weak, nonatomic) IBOutlet UIButton *Delete_Button_Outlet;
@property (weak, nonatomic) IBOutlet UIButton *Info_Button_Outlet;
@property (nonatomic, strong) CircleProgressView *circleProgress;
@property (nonatomic, assign)NSInteger currentPage;
@property (nonatomic, assign)NSInteger LastPage;
@property (nonatomic, assign)NSInteger countImage;
@property (nonatomic, strong, nullable)UIScrollView *scrollView;
@property (nonatomic, strong, nullable)UILabel *labelIndex;
@property (nonatomic, strong, nullable)UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong, nullable)NSMutableArray *arrayPhotoBrowserView;
@property (nonatomic,assign) BOOL hasShowedPhotoBrowser;
@property (nonatomic,strong) ExifTableView* ExifTableView;
@end

@implementation Image_Show_VC


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.Navigation_Outlet setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.countImage =  [[OpenModel sharedStore] Array_Images].count ;// 一共显示300个图片
    self.currentPage = _CurrentSelectedImg;
    [self ImageViewInit];
    [self getCurrentImg:self.currentPage];
    
    [UIView animateWithDuration:0.25
                     animations: ^{ [_Thumbs_Show_Outlet reloadData]; }
                     completion:^(BOOL finished) {
                         NSIndexPath *iPath = [NSIndexPath indexPathForItem:_currentPage inSection:0];
                         [_Thumbs_Show_Outlet scrollToItemAtIndexPath:iPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                     }];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    for (STPhotoBrowserView *photoBrowserView in self.scrollView.subviews)
    {
        photoBrowserView.imageView.image = nil;
    }
}


- (IBAction)Return_Button:(id)sender
{
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)Delete_Button:(id)sender
{
    WS(weakSelf);
    STPhotoBrowserView *currentView = self.scrollView.subviews[self.currentPage];
    
    if(currentView.imageView.image)//如果图片存在
    {
        currentView.imageView.image = nil;
        WLImage* theimage = [[OpenModel sharedStore] Array_Images ][self.currentPage];
        [[SDImageCache sharedImageCache]removeImageForKey:theimage.ImageUrl];
        [[[OpenModel sharedStore] Array_Images] removeObjectAtIndex:self.currentPage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.countImage = [[OpenModel sharedStore] Array_Images].count;// 总数量减一
            // 相当于 删除了 平铺的 最后一个（countImage已经被删了一个了）
            [weakSelf.scrollView.subviews[weakSelf.countImage] removeFromSuperview];
            weakSelf.scrollView.contentSize = CGSizeMake(weakSelf.scrollView.subviews.count * weakSelf.scrollView.width,ScreenHeight);
            weakSelf.labelIndex.text = [NSString stringWithFormat:@"%ld/%ld",(long)(self.currentPage+1),(long)self.countImage];
            [weakSelf getCurrentImg:weakSelf.currentPage];
            [_Thumbs_Show_Outlet reloadData];
            for(NSInteger x = weakSelf.currentPage-1;x<=weakSelf.currentPage+1;x++)
            {
                if(x<0){x = 0;}
                if(x> _scrollView.subviews.count){x = _scrollView.subviews.count;}
                STPhotoBrowserView *photoBrowserView =   _scrollView.subviews[x];
                photoBrowserView.imageView.image = nil;
            }
        });
    }
}

- (IBAction)Save_Button:(id)sender
{
    NSLog(@"保存");
    STPhotoBrowserView *currentView = self.scrollView.subviews[self.currentPage];
    
    if(currentView.imageView.image)
    {
        UIImageWriteToSavedPhotosAlbum(currentView.imageView.image,
                                       self,
                                       @selector(savedPhotosAlbumWithImage:didFinishSavingWithError:contextInfo:),
                                       NULL);
        [[UIApplication sharedApplication].keyWindow addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
    }
}
- (IBAction)Info_Button:(id)sender
{
        self.Navigation_Outlet.alpha = 0;
        self.Thumbs_Show_Outlet.alpha = 0;
        Has_Hidden = YES;
        self.scrollView.scrollEnabled = NO;
        [self.ExifTableView showFromView:self.view animated:YES withPage:_currentPage];
}

-(void)ImageViewInit
{
    self.Image_Show_Outlet.backgroundColor = [UIColor blackColor];
    self.hasShowedPhotoBrowser = NO;
    [self.arrayPhotoBrowserView removeAllObjects];
    for (int i = 0; i<self.countImage; i++)
    {
        STPhotoBrowserView *photoBrowserView = [STPhotoBrowserView new];
        [self.arrayPhotoBrowserView addObject:photoBrowserView];
        __weak __typeof(self)weakself = self;
        //如果图片被点击了
        photoBrowserView.singleTapBlock = ^(UITapGestureRecognizer *recognizer){
            if (!Has_Hidden)
            {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationDelegate:self];
                weakself.Thumbs_Show_Outlet.alpha = 0 ;
                weakself.Navigation_Outlet.alpha = 0;
                [UIView commitAnimations];
                Has_Hidden = YES;
            }
            else
            {
                weakself.Thumbs_Show_Outlet.alpha = 1 ;
                Has_Hidden = NO;
                weakself.Navigation_Outlet.alpha = 1;
                if (weakself.ExifTableView.visible)//如果出现了EXIF table
                {
                    [weakself.ExifTableView hide:YES];
                    weakself.scrollView.scrollEnabled = YES;
                }
            }
            
        };
        [self.scrollView addSubview:photoBrowserView];
    }
    [self.Image_Show_Outlet addSubview:self.scrollView];
    
    WS(ws);
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.edges.equalTo(ws.Image_Show_Outlet).with.insets(UIEdgeInsetsMake(0,0,0,0));
     }];
    
    if (self.countImage>1)
    {
        self.labelIndex.text = [NSString stringWithFormat:@"%ld/%ld",(long)(self.currentPage+1),(long)self.countImage];
        [self.labelIndex setHidden:NO];
        //  [self.Image_Show_Outlet addSubview:self.labelIndex];
        [self.Navigation_Outlet addSubview:self.labelIndex];
    }
    else
    {
        [self.labelIndex setHidden:YES];
    }
    
    //对scroll里面的图片进行铺装
    [self setupFrame];
    self.hasShowedPhotoBrowser = YES;
    self.scrollView.hidden = NO;
    self.labelIndex.hidden = NO;
    // self.buttonSave.hidden = NO;
    Has_Hidden = false;
}

-(void)setupFrame
{
    CGRect rectSelf = self.view.bounds;
    rectSelf.size.width += STMargin * 2;
    self.scrollView.bounds = rectSelf;
    self.scrollView.center = CGPointMake(ScreenWidth / 2, ScreenHeight / 2);
    
    __block CGFloat photoX = 0;
    __block CGFloat photoY = 0;
    __block CGFloat photoW =  ScreenWidth;
    __block CGFloat photoH =  ScreenHeight;
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof STPhotoBrowserView* _Nonnull obj,NSUInteger idx,BOOL* _Nonnull stop){
        
        photoX = STMargin + idx * (STMargin * 2 + photoW);
        [obj setFrame:CGRectMake(photoX, photoY, photoW, photoH)];
        
    }];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.subviews.count * self.scrollView.width,
                                             ScreenHeight);

    CGPoint point = CGPointMake(self.currentPage*self.scrollView.width, 0);
    [self.scrollView setContentOffset:point animated:NO];

    CGFloat indexW = 100;
    CGFloat indexH = 28;
    CGFloat indexCenterX = ScreenWidth / 2;
    CGFloat indexCenterY = 20;
    
    self.labelIndex.bounds = CGRectMake(0, 0, indexW, indexH);
    self.labelIndex.center = CGPointMake(indexCenterX, indexCenterY);
    [self.labelIndex.layer setCornerRadius:indexH/2];
}

-(void)getCurrentImg:(NSInteger)num
{
    NSLog(@"获取%ld图片",(long)num);
    _currentPage = num;

    STPhotoBrowserView* photoBrowserView = self.scrollView.subviews[num];
    WLImage* theimage = [[OpenModel sharedStore] Array_Images][num];

    [photoBrowserView setImageWithURL:[NSURL URLWithString:theimage.ImageUrl]
                         placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"内存不足");
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setupFrame];
}

// collection delegate//////////////////////////////////////
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.countImage;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YN_Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellYN" forIndexPath:indexPath];

    WLImage* theimage = [[OpenModel sharedStore] Array_Images][indexPath.row];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        if(indexPath.row ==  _currentPage)//如果是被选中项
        {
            cell.layer.borderColor = [UIColor redColor].CGColor;
            cell.layer.borderWidth = 3;
        }
        else
        {
            
            cell.layer.borderColor = [UIColor blackColor].CGColor;
            cell.layer.borderWidth = 0.5;
        }
    
        [cell.IMGVIEW sd_setImageWithURL:[NSURL URLWithString:theimage.ThumbUrl]
                    placeholderImage:[UIImage imageNamed:@"placeholder"] options:0];

        cell.IMGVIEW.highlighted =YES;
        
    });

    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentPage != indexPath.item)
    {
        NSLog(@"选中第%ld张图片",(long)indexPath.item);
        
        CGPoint point   = CGPointMake(indexPath.item*self.scrollView.width, 0);
        WS(weakSelf);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.scrollView setContentOffset:point animated:YES];
        });
    }
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        [_scrollView setDelegate:self];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setBackgroundColor:[UIColor blackColor]];
    }
    return _scrollView;
}
#pragma mark - 2.上方分页Label
- (UILabel *)labelIndex
{
    if (!_labelIndex) {
        _labelIndex = [[UILabel alloc]init];
        [_labelIndex setBackgroundColor:RGBA(0, 0, 0, 50.0/255)];
        [_labelIndex setTextAlignment:NSTextAlignmentCenter];
        [_labelIndex setTextColor:[UIColor whiteColor]];
        [_labelIndex setFont:[UIFont boldSystemFontOfSize:17]];
        
        [_labelIndex setClipsToBounds:YES];
        [_labelIndex setShadowOffset:CGSizeMake(0, -0.5)];
        [_labelIndex setShadowColor:RGBA(0, 0, 0, 110.0/255)];
    }
    return _labelIndex;
}


- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc]init];
        [_indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_indicatorView setCenter:self.Image_Show_Outlet.center];
        [_indicatorView setBackgroundColor:[UIColor redColor]];
    }
    return _indicatorView;
}

- (NSMutableArray *)arrayPhotoBrowserView
{
    if (!_arrayPhotoBrowserView) {
        _arrayPhotoBrowserView = [NSMutableArray array];
    }
    return _arrayPhotoBrowserView;
}

#pragma mark - 1.scrollview代理方法


// 惯性减速停止之后
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self scrollViewDidEndScrollingAnimation:_scrollView];
    
}

// 当每次scrollView切换的时候就会调用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
 
    if (([scrollView isKindOfClass:[UICollectionView class]])||([scrollView isKindOfClass:[UITableView class]]) )
    {
        return;
    }
    
    NSInteger pageCurrent = scrollView.contentOffset.x / scrollView.width + 0.5;

    if (pageCurrent ==  self.countImage || pageCurrent < 0)
    {
        return;
    }
    // 2.设置标题
    self.labelIndex.text = [NSString stringWithFormat:@"%ld/%ld", (long)(pageCurrent + 1), (long)self.countImage];
    
    // 3.还原其他图片的尺寸
    if (pageCurrent != self.currentPage)
    {
        _LastPage = self.currentPage;
        self.currentPage = pageCurrent;
        NSLog(@"翻到新的一页%ld",(long)self.currentPage);
        for (STPhotoBrowserView *photoBrowserView in scrollView.subviews)
        {
            if (photoBrowserView != self.arrayPhotoBrowserView[self.currentPage])
            {
                photoBrowserView.scrollView.zoomScale = 1.0;
                if (ScreenWidth > ScreenHeight)
                {
                    photoBrowserView.imageView.origin = CGPointMake(0, 0);
                    photoBrowserView.imageView.center = photoBrowserView.scrollView.center;
                }
                else
                {
                    photoBrowserView.imageView.center = photoBrowserView.scrollView.center;
                }
                
                NSInteger x = [scrollView.subviews indexOfObject:photoBrowserView];
                
                if( x>self.currentPage+3 || x<self.currentPage-3 )
                {
                    photoBrowserView.imageView.image = nil;
                }
            }
            else//当前页
            {
                if (ScreenWidth > ScreenHeight)
                {
                    photoBrowserView.imageView.origin = CGPointMake(0, 0);
                    photoBrowserView.imageView.center = photoBrowserView.scrollView.center;
                }
                else
                {
                    photoBrowserView.imageView.center =
                    photoBrowserView.scrollView.center;
                }
            }
        }
        
        //如果
        if( _currentPage <  self.countImage)
        {
            
            [UIView animateWithDuration:0
                             animations: ^{
                                 NSIndexPath *Path1 = [NSIndexPath indexPathForItem:_LastPage inSection:0];
                                 NSIndexPath *Path2 = [NSIndexPath indexPathForItem:_currentPage inSection:0];
                                 [_Thumbs_Show_Outlet reloadItemsAtIndexPaths:@[Path1,Path2]];
    
                             }
                             completion:^(BOOL finished) {
                                 NSIndexPath *iPath = [NSIndexPath indexPathForItem:_currentPage inSection:0];
                               [_Thumbs_Show_Outlet scrollToItemAtIndexPath:iPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                             }];
            
            NSLog(@"will get the %ld pic",(long)self.currentPage);
            [self getCurrentImg:self.currentPage];
        }
    }
}
#pragma mark - 2.保存到相册
- (void)savedPhotosAlbumWithImage:(UIImage *)image
         didFinishSavingWithError:(NSError *)error
                      contextInfo:(void *)contextInfo
{
    
    [self.indicatorView removeFromSuperview];
    
    STAlertView *alert = [[STAlertView alloc]init];
    if (error) {
        [alert setStyle:STAlertViewStyleError];
    }else {
        [alert setStyle:STAlertViewStyleSuccess];
    }
    [alert show];
}

#pragma mark  --  tableview  delegate
/////////////////////////////////////////////////////////////
//////////////////////// 图片具体信息////////////////////
///////////////////////////////////////////////////////
// 点击  image
- (IBAction)Tap_Action:(id)sender
{
    [self.ExifTableView hide:YES];
    self.Navigation_Outlet.hidden = NO;
    self.Thumbs_Show_Outlet.hidden = NO;
}
//只有在 infotable 出现的时候 才执行
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.view];
    if (!self.ExifTableView.visible) {
        return  NO;
    }
    if ((self.ExifTableView.visible) && !CGRectContainsPoint(self.ExifTableView.frame, p)) {
        return YES;
    }
    return NO;
    
}

////////////////   progress 部分   /////////////////////////////////////////////////
- (CircleProgressView *)circleProgress
{
    if(!_circleProgress)
    {
        _circleProgress = [[CircleProgressView alloc] initWithFrame:CGRectMake(50, 80, 80, 80)];
        _circleProgress.backgroundColor = [UIColor clearColor];
        _circleProgress.textColor = [UIColor yellowColor];
    }
    return _circleProgress;
}

-(void)HideProgress
{
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        
       weakSelf.circleProgress.percent = 0;
        if(weakSelf.circleProgress.superview)
        {
            [weakSelf.circleProgress removeFromSuperview];
        }
    });
}

-(void)ShowAndSetProgress:(float)value Toview:(UIView*)view
{
     WS(weakSelf);
    if(value+0.1>=1)
    {
        [self HideProgress];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!weakSelf.circleProgress.superview)
        {
            [view addSubview:_circleProgress];
            weakSelf.circleProgress.center = CGPointMake(_Image_Show_Outlet.center.x, _Image_Show_Outlet.center.y) ;
        }
        float Value_Tmp =(value+0.1);
        if(Value_Tmp>=1)
        {
            Value_Tmp = 1;
        }
        
        weakSelf.circleProgress.percent = Value_Tmp;
        
        weakSelf.circleProgress.centerLabel.text = [NSString stringWithFormat:@"%.0f%%", self.circleProgress.percent*100];
    });
}
/////////////////////////////////////////////////////////////

-(void)DisableBtns
{
   self.Save_Button_Outlet.enabled = NO;
   self.Delete_Button_Outlet.enabled = NO;
   self.Info_Button_Outlet.enabled = NO;
}
-(void)enableBtns
{
    self.Save_Button_Outlet.enabled = YES;
    self.Delete_Button_Outlet.enabled = YES;
    self.Info_Button_Outlet.enabled = YES;
}

-(ExifTableView*)ExifTableView
{
    if(!_ExifTableView)
    {
        _ExifTableView = [[ExifTableView alloc]init];
    }
    return _ExifTableView;
}


- (void)hudWasHidden:(MBProgressHUD*)hud
{
    if(hud.superview)
    {
        [hud removeFromSuperview];
    }
    hud=nil;
}

@end



