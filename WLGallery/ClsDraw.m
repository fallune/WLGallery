//
//  ClsDraw.m
//  GraphDrawingOperations
//
//  Created by hadley on 10/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ClsDraw.h"


@implementation ClsDraw
//@synthesize arrRedPoints,arrGreenPoints,arrBluePoints,graphColor,arrPoints;

-(instancetype)init
{
	//[self setBackgroundColor:[UIColor blueColor]];
	
    if (self = [super init])
    {
        self.backgroundColor = [UIColor clearColor];
    }
    
	return self;
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	NSLog(@"Touched");
//    //boolCancelDrawing = YES;
////	[self drawGraphForArray:arrPoints];
////	[self setNeedsDisplay];
//}

//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//
//
//}
//
-(void)drawGraphForArray:(NSMutableArray*)parrPoints
{
  //  boolCancelDrawing = YES;
    self.arrPoints = parrPoints;
	
	NSInteger counter=0;
	
	for (ClsDrawPoint *objPoint in self.arrPoints)
	{
		objPoint.x = counter;	
		counter++;
	}	
	[self setNeedsDisplay];
   // NSLog(@"setneddsdisplay");
}

- (void)drawRect:(CGRect)rect
{
  //  NSLog(@"drawrect被调用");
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if ([self.arrPoints count] > 0)
    {
        CGContextSetLineWidth(ctx, 1);
        CGContextSetStrokeColorWithColor(ctx, self.graphColor.CGColor);
        CGContextSetAlpha(ctx, 0.8);
        ClsDrawPoint *objPoint;
        CGContextBeginPath(ctx);
        
        
        for (int i = 0 ; i < [self.arrPoints count] ; i++)
        {
            objPoint = [self.arrPoints objectAtIndex:i];
            CGContextMoveToPoint(ctx, objPoint.x,0);
            // CGContextMoveToPoint(ctx, objPoint.x,0);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            CGContextSetLineJoin(ctx, kCGLineJoinRound);
            CGContextAddLineToPoint(ctx, objPoint.x,objPoint.y);
            CGContextMoveToPoint(ctx, objPoint.x,objPoint.y);
            CGContextStrokePath(ctx);
            
        }				
    }
    
}


@end
