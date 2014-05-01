//
//  MapViewController.h
//  tokyo0505
//
//  Created by cerevo on 2014/04/16.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "TimetableAnnotaion.h"
#import "BeaconAnnotation.h"
#import "UserAnnotation.h"
#import "FishViewController.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate,
                                                 UIPickerViewDelegate, UIPickerViewDataSource,
                                                 UIPopoverControllerDelegate, DismisPopoverDelegate>

@property (strong, nonatomic) NSDictionary *bigbrotherCache;
@property (strong, nonatomic) NSDictionary *currentBeaconDict;


@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSUUID *proximityUUID;

@property (strong, nonatomic) NSString *currentMainUUID;
@property (strong, nonatomic) NSString *currentSubUUID;
@property (strong, nonatomic) NSNumber *currentProximity;


@property (strong, nonatomic) NSArray *twitterAccounts;
@property (strong, nonatomic) ACAccount *twitterAccount;
@property (strong, nonatomic) UIView *twitterPickerView;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIPopoverController *poc;
@property (nonatomic, retain) IBOutlet UIButton *fishButton;

-(void)dismisPopover:(NSDictionary *)dismisWithData;
-(void)zoomInToSelf;
-(void)zoomInToScreenName:(NSString*)screen_name;
-(void)zoomOutToSite;
@end
