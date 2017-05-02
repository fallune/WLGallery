//
//  ViewController.m
//  Histogram
//
//  Created by Hadley on 18/10/12.
//  Copyright (c) 2012 Hadley. All rights reserved.
//

#import "HistogramView.h"
#define scale 100


float fltR[256],fltG[256],fltB[256],fltL[256];

@interface HistogramView ()

@end

//static unsigned char *rawData = nil;

@implementation HistogramView

- (instancetype)initWithZone
{
   
    if (self = [super init])
    {
        NSLog(@"Reading....");
    }
    return self;
    
    // Do any additional setup after loading the view, typically from a nib.
    
}

-(NSMutableDictionary*)readImage:(UIImage*)image1
{
    
    NSMutableDictionary* dic= nil ;
   
     UIImage* image=    [self imageCompressForSize:image1];
    
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    // CGColorSpaceCreateDeviceGray
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *
    rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;

    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);

    CGContextRelease(context);
    
    for (NSUInteger yy=0;yy<height; yy++)
    {
        for (NSUInteger xx=0; xx<width; xx++)
        {
            // Now your rawData contains the image data in the RGBA8888 pixel format.
            NSUInteger byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
            for (NSUInteger ii = 0 ; ii < 1 ; ++ii)
            {
                CGFloat red   = (rawData[byteIndex]     * 1.0) ;
                CGFloat green = (rawData[byteIndex + 1] * 1.0) ;
                CGFloat blue  = (rawData[byteIndex + 2] * 1.0) ;
                // CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
                //wangli
                CGFloat brightness = (red)*0.299 + (green)*0.587 + (blue)*0.114;
                
                byteIndex += 4;
                
                // TYPE CASTING ABOVE FLOAT VALUES TO THAT THEY CAN BE MATCHED WITH ARRAY'S INDEX.
                
                NSUInteger redValue;
                NSUInteger greenValue;
                NSUInteger blueValue;
                //wangli
                NSUInteger rightnessValue ;
                // THESE COUNTERS COUNT " TOTAL NUMBER OF PIXELS " FOR THAT  Red , Green or Blue Value IN ENTIRE IMAGE.
                
                red> 255?redValue=255: (redValue = (NSUInteger)red);
                green> 255?greenValue=255: (greenValue = (NSUInteger)green);
                blue> 255?blueValue=255: (blueValue = (NSUInteger)blue);
                brightness> 255?rightnessValue=255: (rightnessValue = (NSUInteger)brightness);

                fltR[redValue]++;
                fltG[greenValue]++;
                fltB[blueValue]++;
                fltL[rightnessValue]++;
                
            }
        }
    }
    dic =  [self makeArrays];
    free(rawData);

    return dic;
    
}



// 在原基础上  增加了    亮度 的 计算方法  wangli
-(NSMutableDictionary*)makeArrays
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    float max=0;
    int maxR=0;
    int maxG=0;
    int maxB=0;
    //wangli
    int maxL=0;
    
    
    // PERFORMING SUMMESION OF ALL RED , GREEN AND BLUE VLAUES GRADUALLY TO TAKE AVERAGE OF THEM
    for (int i=0; i<256; i++)
    {
        maxR += fltR[i];
        maxG += fltG[i];
        maxB += fltB[i];
        //wangli
        maxL += fltL[i];
    }
    
    
    // CALCULATING AVERAGE OF ALL red, green and blue values.
    maxR = maxR/256;
    maxG = maxG/256;
    maxB = maxB/256;
    //wangli
    maxL = maxL/256;
    

    //wangli
    max =(maxR+maxG+maxB+maxL)/4;
    
    // DEVIDED BY 8 TO GET GRAPH OF THE SAME SIZE AS ITS IN PREVIEW
    max = max*8;
    
    NSMutableArray* arrAllPoints_R = [NSMutableArray array];
   
    NSMutableArray* arrAllPoints_G = [NSMutableArray array];
    NSMutableArray* arrAllPoints_B = [NSMutableArray array];
    NSMutableArray* arrAllPoints_W = [NSMutableArray array];


    for (int i=0; i<256; i++)
    {
       
        ClsDrawPoint *objPoint = [[ClsDrawPoint alloc] init];
        objPoint.x = i;
        objPoint.y = fltR[i]*scale/max;
        [arrAllPoints_R addObject:objPoint];
        
       
        
    }
    [dic setValue:arrAllPoints_R forKey:@"redpoints"];
    
    for (int i=0; i<256; i++)
    {
        ClsDrawPoint *objPoint = [[ClsDrawPoint alloc] init];
        objPoint.x = i;
        objPoint.y = fltG[i]*scale/max;
        [arrAllPoints_G addObject:objPoint];
        
       
    }

    [dic setValue: arrAllPoints_G forKey:@"greenpoints"];
    
    
    for (int i=0; i<256; i++)
    {
        ClsDrawPoint *objPoint = [[ClsDrawPoint alloc] init];
        objPoint.x = i;
        objPoint.y = fltB[i]*scale/max;
        [arrAllPoints_B addObject:objPoint];
        
    
    }

    [dic setValue:arrAllPoints_B forKey:@"bluepoints"];
    

    
    for (int i=0; i<256; i++)
    {
        ClsDrawPoint *objPoint = [[ClsDrawPoint alloc] init];
        objPoint.x = i;
        objPoint.y = fltL[i]*scale/max;
        [arrAllPoints_W addObject:objPoint];
        
    }
    [dic setValue:arrAllPoints_W forKey:@"whitepoints"];
      return dic;
}

-(UIImage *) imageCompressForSize:(UIImage *)sourceImage// targetSize:(CGSize)size{
{
    CGSize size;

    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    

    size.height = 256;
    
    size.width = 256/height *width;
    
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}



@end




