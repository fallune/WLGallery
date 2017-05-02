

//  YN_GalleryVC.m
//  YN_CamFi
//
//  Created by 王立 on 16/7/6.
//  Copyright © 2016年 王立. All rights reserved.
//

#import "YN_GalleryVC.h"
#import "WLImage.h"
#import "OpenModel.h"
#import "Image_Show_VC.h"
#import "MJRefresh.h"
#import "STAlertView.h"
#import "MBProgressHUD.h"
#import "STPhotoBrowserController.h"
#import "Image_Show_VC.h"
#import <SDWebImage/UIImageView+WebCache.h>
//static const CGFloat MJDuration = 0.6;//2.0;
//static NSInteger count ;


static BOOL had_selected = 0;
static BOOL _set = 0;
static BOOL Is_FirstRefresh = NO;
static NSInteger Thumbs_Count = 0;
static NSInteger SelectedNum;

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT  [UIScreen mainScreen].bounds.size.height
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface YN_GalleryVC ()<UICollectionViewDataSource,UICollectionViewDelegate,MBProgressHUDDelegate>/** 存放假数据 */

@property (nonatomic,strong)  NSMutableArray*  Array_Delete;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionView;
@property (weak, nonatomic) IBOutlet UIView *ToolBar_Outlet;
@property (weak, nonatomic) IBOutlet UIView *Navigation_Outlet;
@property (weak, nonatomic) IBOutlet UIButton *DeleteButton_Outlet;
@property (strong,nonatomic) MBProgressHUD *Hud_ThumbList;
@property (strong,nonatomic) MBProgressHUD *Hud_Delete;


//@property (nonatomic,strong)  NSMutableArray* ThumbsArray;

@end

@implementation YN_GalleryVC


static NSString * const reuseIdentifier = @"imgcell";
static NSInteger   PicNum_ONCE;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.Navigation_Outlet setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
    [self.ToolBar_Outlet setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
    self.ToolBar_Outlet.hidden = YES;
    [self Init_ViewRefresh];
    NSInteger num_width = WIDTH/100;
    NSInteger num_height = (HEIGHT-40)/100+1;
    PicNum_ONCE =num_width*num_height;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.CollectionView.mj_header beginRefreshing];
    had_selected = 0;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)Delete_Btn:(id)sender
{
    WS(weakSelf);
    [self.Array_Delete removeAllObjects];
    NSInteger copy_count = [[OpenModel sharedStore] Array_Images].count;
    for (NSInteger i = 0; i< copy_count; i++)//已经下载的缩略图
    {
        WLImage* theimage=  [[OpenModel sharedStore] Array_Images][i];
        if(theimage.isSelected)
        {
            //  NSLog(@"删除：被选项是%ld",(long)i);
            [self.Array_Delete addObject:[NSNumber numberWithInteger:i]];
            //删除整体cammedia数组的被选项
        }
    }
    
    if(self.Array_Delete.count)
    {
         for(id obj in self.Array_Delete )
         {
             [[[OpenModel sharedStore] Array_Images] removeObjectAtIndex:[obj integerValue]];
         }
        [self ResetImgSelect];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.CollectionView reloadData];
        });
    }
    else// 没有选中项目
    {
        //只显示文字
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.delegate = self;
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"No_Select", nil);
        hud.margin = 10.f;
        hud.offset  = CGPointMake(0, 0);
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:1];
    }
}


- (IBAction)Select_Btn:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    if (had_selected)  //按下 cancel       ---------      取消所有被选项
    {
        self.ToolBar_Outlet.hidden = YES;
        had_selected = NO;
        [btn setTitle:NSLocalizedString(@"Select", nil) forState:UIControlStateNormal];

        [self ResetImgSelect];
        
    }
    else
    {
        self.ToolBar_Outlet.hidden = NO;
        had_selected = YES;
        [btn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    }
}
-(void)ResetImgSelect
{
    NSMutableArray* array = [[OpenModel sharedStore] Array_Images];
    for (id obj in array )
    {
        ((WLImage*)obj).isSelected = NO;
    }
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.CollectionView reloadData];
        
    });
}
#pragma mark - 数据相关
-(NSMutableArray*)Array_Delete
{
    if(!_Array_Delete)
    {
        _Array_Delete= [NSMutableArray array];
    }
    return _Array_Delete;
}


- (void)Init_ViewRefresh
{
    WS(weakSelf);
    // 下拉刷新
    self.CollectionView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 数据重新更新
        NSMutableArray* array = [[OpenModel sharedStore] Array_Images];
        [array removeAllObjects];
        for (int i = 0 ; i< PicNum_ONCE; i++)
        {
            WLImage* newIMG = [[WLImage alloc] init];
            newIMG.ThumbUrl = [[OpenModel sharedStore] Array_ThumbsURL][i];
            newIMG.ImageUrl = [[OpenModel sharedStore] Array_ImagesURL][i];
            newIMG.isSelected = NO;
            [array insertObject:newIMG atIndex:0];
        }
        // 模拟延迟加载数据，因此2秒后才调用
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.CollectionView reloadData];
            // 结束刷新
            [weakSelf.CollectionView.mj_header endRefreshing];
        });
        
        
    }];
    
    // 上拉刷新
    self.CollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 增加15条数据
        NSMutableArray* array = [[OpenModel sharedStore] Array_Images];
        if(array.count < PicNum_ONCE*6)
        {
            
            for (int i = 0; i<PicNum_ONCE; i++)
            {
                WLImage* newIMG = [[WLImage alloc] init];
                newIMG.ThumbUrl = [[OpenModel sharedStore] Array_ThumbsURL][i+array.count];
                newIMG.ImageUrl = [[OpenModel sharedStore] Array_ImagesURL][i+array.count];
                newIMG.isSelected = NO;
               
                [array insertObject:newIMG atIndex:0];
                
            }
            
            // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.CollectionView reloadData];
                
                // 结束刷新
                [weakSelf.CollectionView.mj_footer endRefreshing];
            });
            
        }
        else// 全部加载完毕
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.CollectionView.mj_footer  endRefreshingWithNoMoreData];
                
            });
            
        }
    }];
    // 默认先隐藏footer
    self.CollectionView.mj_footer.hidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any r esources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // 设置尾部控件的显示和隐藏
    self.CollectionView.mj_footer.hidden = [[OpenModel sharedStore] Array_Images].count == 0;
    return [[OpenModel sharedStore] Array_Images].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [[cell.contentView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView* ImageSee = [[UIImageView alloc]init];

    
    WLImage* theimage = [[OpenModel sharedStore] Array_Images] [indexPath.row];

    [ImageSee sd_setImageWithURL:[NSURL URLWithString:theimage.ThumbUrl]
                placeholderImage:[UIImage imageNamed:@"placeholder"] options:0];

    [cell.contentView addSubview:ImageSee];
    ImageSee.frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
    
    UIImageView* ImageSelect = [[UIImageView alloc]init];
    
    //被选对勾
    if(had_selected)
    {
        ImageSelect.image = theimage.isSelected?[UIImage imageNamed:@"select"]:nil;
    }

    [cell.contentView addSubview:ImageSelect];
    ImageSelect.frame = CGRectMake(cell.bounds.size.width-30, 0, 30, 30);
    
    cell.backgroundColor = [UIColor blackColor];
    
    return cell;
}


#pragma mark <UICollectionViewDelegate>

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

- (void)collectionView: (UICollectionView *)collectionView
didSelectItemAtIndexPath: (NSIndexPath *)indexPath
{
    
    if(had_selected)//  选择要删除/保存的图片s
    {
        WLImage* theimage = [[OpenModel sharedStore] Array_Images] [indexPath.row];
        theimage.isSelected = !theimage.isSelected;
        
        //刷新指定的
        [self.CollectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    else
    {
        SelectedNum = indexPath.row;
  
        Image_Show_VC* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"detailimage"];
        vc.CurrentSelectedImg = SelectedNum;
        vc.HadLoadImgNum = Thumbs_Count;
        
        [self presentViewController:vc animated:YES     completion:nil];
        
    }
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
