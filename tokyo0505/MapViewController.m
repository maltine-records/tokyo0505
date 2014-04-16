//
//  MapViewController.m
//  tokyo0505
//
//  Created by cerevo on 2014/04/16.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import "MapViewController.h"
#import "TokyoOverlayRenderer.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self setupMapView];
    [self setupBeaconMonitor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupMapView
{
    CLLocationCoordinate2D koukyo;
    koukyo.latitude = 35.683833;
    koukyo.longitude = 139.753972;
    CLLocationCoordinate2D tokyoeki;
    tokyoeki.latitude = 35.681382;
    tokyoeki.longitude = 139.766084;
    CLLocationCoordinate2D tocho;
    tocho.latitude = 35.68664111;
    tocho.longitude = 139.6948839;
    CLLocationCoordinate2D nogata;
    nogata.latitude = 35.7200116;
    nogata.longitude = 139.6522843;

    self.mapView.mapType = MKMapTypeHybrid;
    // move center
    [self.mapView setCenterCoordinate:koukyo];
    MKCoordinateRegion region = self.mapView.region;
    region.center = koukyo;
    region.span.latitudeDelta = 0.5;
    region.span.longitudeDelta = 0.5;
    [self.mapView setRegion:region animated:TRUE];
    // add overlay
    int radius = 10000;
    MKCircle *c = [MKCircle circleWithCenterCoordinate:koukyo radius:radius];
    [self.mapView addOverlay:c];
    
    // add annotation
    TimetableAnnotaion *maintt = [[TimetableAnnotaion alloc] init];
    maintt.coordinate = tokyoeki;
    maintt.title = @"東東京";
    [self.mapView addAnnotation:maintt];
    

    
    TimetableAnnotaion *subtt = [[TimetableAnnotaion alloc] init];
    subtt.coordinate = tocho;
    subtt.title = @"西東京";
    [self.mapView addAnnotation:subtt];
    
    //prepare for beacon
    self.nogataAnnotation = [[TimetableAnnotaion alloc] init];
    self.nogataAnnotation.coordinate = nogata;
    self.nogataAnnotation.title = @"野方";
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    return [[TokyoOverlayRenderer alloc] initWithOverlay:overlay];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setupBeaconMonitor
{
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        // CLLocationManagerの生成とデリゲートの設定
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        
        // NSUUIDを作成
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"00000000-31d9-1001-b000-001c4dc4c8af"];
        // CLBeaconRegionを作成
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:@"com.nubot.tokyo0505.testregion"];
        // Beaconによる領域観測を開始
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside: // リージョン内にいる
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            }
            break;
        case CLRegionStateOutside:
        case CLRegionStateUnknown:
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.mapView addAnnotation:self.nogataAnnotation];
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.mapView removeAnnotation:self.nogataAnnotation];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        
        NSString *rangeMessage;
        
        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                rangeMessage = @"Range Immediate: ";
                break;
            case CLProximityNear:
                rangeMessage = @"Range Near: ";
                break;
            case CLProximityFar:
                rangeMessage = @"Range Far: ";
                break;
            default:
                rangeMessage = @"Range Unknown: ";
                break;
        }
        
        NSString *message = [NSString stringWithFormat:@"major:%@, minor:%@, accuracy:%f, rssi:%d",
                             nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, nearestBeacon.rssi];
        NSLog(message);
    }
}

@end
