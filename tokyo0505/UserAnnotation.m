//
//  UserAnnotation.m
//  tokyo0505
//
//  Created by 田島 逸郎 on 2014/04/19.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import "UserAnnotation.h"

@implementation UserAnnotation

@synthesize coordinate, subtitle, title, imageUrl;

- (id) initWithCoordinate:(CLLocationCoordinate2D)c {
	coordinate = c;
	return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)c {
    coordinate = c;
}

@end
