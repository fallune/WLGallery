//
//  ClsDraw.h
//  GraphDrawingOperations
//
//  Created by hadley on 10/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClsDrawPoint.h"
#import <UIKit/UIKit.h>

@interface ClsDraw : UIView

@property (nonatomic,retain) NSMutableArray *arrRedPoints;
@property (nonatomic,retain) NSMutableArray *arrGreenPoints;
@property (nonatomic,retain) NSMutableArray *arrBluePoints;

@property (nonatomic,retain) NSMutableArray *arrPoints;

@property (nonatomic,assign) UIColor *graphColor;

-(instancetype)init;
-(void)drawGraphForArray:(NSMutableArray*)parrPoints;

@end
