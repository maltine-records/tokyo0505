//
//  TimetableAnnotaion.h
//  tokyo0505
//
//  Created by cerevo on 2014/04/16.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface TimetableAnnotaion : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString* subtitle;
	NSString* title;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic, copy) NSString* title;

- (id) initWithCoordinate:(CLLocationCoordinate2D) coordinate;


@end
