//
//  MapViewController.h
//  tokyo0505
//
//  Created by cerevo on 2014/04/16.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TimetableAnnotaion.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) TimetableAnnotaion *nogataAnnotation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSUUID *proximityUUID;
@property (strong, nonatomic) NSString *currentUUID;
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (weak, nonatomic) UIView *twitterPickerView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
