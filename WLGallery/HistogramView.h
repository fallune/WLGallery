//
//  ViewController.h
//  Histogram
//
//  Created by Hadley on 18/10/12.
//  Copyright (c) 2012 Hadley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClsDraw.h"
#import "ClsDrawPoint.h"
#import <QuartzCore/QuartzCore.h>

@interface HistogramView:NSObject
{
   // NSMutableArray *arrAllPoints;
 
//    ClsDraw *redGraphView;
//    ClsDraw *blueGraphView;
//    ClsDraw *greenGraphView;
//
//    ClsDraw *BrightnessGraphView;
}

//@property(nonatomic,strong)   ClsDraw *redGraphView;
//@property(nonatomic,strong)   ClsDraw *blueGraphView;
//@property(nonatomic,strong)   ClsDraw *greenGraphView;
//@property(nonatomic,strong)   ClsDraw *BrightnessGraphView;


- (instancetype)initWithZone;
-(NSMutableDictionary*)readImage:(UIImage*)image;
@end
