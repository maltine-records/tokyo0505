//
//  TimetableAnnotaion.m
//  tokyo0505
//
//  Created by cerevo on 2014/04/16.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import "TimetableAnnotaion.h"
#import <MapKit/MapKit.h>

@implementation TimetableAnnotaion 

@synthesize coordinate, subtitle, title;

- (id) initWithCoordinate:(CLLocationCoordinate2D)c {
	coordinate = c;
	return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)c {
    coordinate = c;
}


@end
