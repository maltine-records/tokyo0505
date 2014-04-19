//
//  UserAnnotation.h
//  tokyo0505
//
//  Created by 田島 逸郎 on 2014/04/19.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UserAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
	NSString* subtitle;
	NSString* title;
    NSURL* imageUrl;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSURL* imageUrl;

- (id) initWithCoordinate:(CLLocationCoordinate2D) coordinate;

@end
