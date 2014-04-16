//
//  MapViewController.m
//  tokyo0505
//
//  Created by cerevo on 2014/04/16.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import "MapViewController.h"
#import "TokyoOverlayRenderer.h"
#import "TimetableAnnotaion.h"

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

@end
