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
    NSString* imageName;
    UIView* timetableView;
    BOOL isSub;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* imageName;
@property (nonatomic, strong) UIView *timetableView;
@property (nonatomic) BOOL isSub;

- (id) initWithCoordinate:(CLLocationCoordinate2D) coordinate;
- (void) addTimetableSubView:(UIView*)mainView;

@end
