//
//  TokyoOverlayRenderer.m
//  tokyo0505
//
//  Created by cerevo on 2014/04/16.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import "TokyoOverlayRenderer.h"

@implementation TokyoOverlayRenderer


- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    UIImage *image = [UIImage imageNamed:@"access_floorguide.gif"];
    CGImageRef imageReference = image.CGImage;
    
    MKMapRect theMapRect = [self.overlay boundingMapRect];
    CGRect theRect = [self rectForMapRect:theMapRect];
    
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -theRect.size.height);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGContextSetAlpha(context, 0.5);
    CGContextDrawImage(context, theRect, imageReference);
}

- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale
{
    return YES;
}

@end
