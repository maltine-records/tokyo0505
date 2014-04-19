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

@synthesize coordinate, subtitle, title, imageName, timetableView;

- (id) initWithCoordinate:(CLLocationCoordinate2D)c {
	coordinate = c;
	return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)c {
    coordinate = c;
}

- (void)addTimetableSubView:(UIView *)mainView{
    self.timetableView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 320, 344)];
    UIView* timetableTextView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
    timetableTextView.backgroundColor = [UIColor whiteColor];
    [self.timetableView addSubview:timetableTextView];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 300, 320, 44)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                              target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"close"
                                   style:UIBarButtonItemStyleDone
                                   target:self action:@selector(doneButton)];
    [toolbar setItems:[NSArray arrayWithObjects:space, doneButton, nil]];
    [self.timetableView addSubview:toolbar];
    [mainView addSubview:self.timetableView];
}
-(void)doneButton{
    [self.timetableView removeFromSuperview];
}

@end
