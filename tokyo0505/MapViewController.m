//
//  MapViewController.m
//  tokyo0505
//
//  Created by cerevo on 2014/04/16.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import "MapViewController.h"
#import "TokyoOverlayRenderer.h"
#import "AFNetworking.h"
#import "Common.h"


@interface MapViewController ()

@end

@implementation MapViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.currentUUID = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self setupMapView];
    [self setupBeaconMonitor];
    NSString *screen_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen_name"];
    if ([screen_name length] == 0) {
        [self requestTwitterAccount];
    } else {
        NSLog(@"screen_name: %@", screen_name);
    }
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
        // [self.locationManager startMonitoringForRegion:self.beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSString* gotUUID;
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
        
        NSString *message = [NSString stringWithFormat:@"UUID:%@, major:%@, minor:%@, accuracy:%f, rssi:%d",
                             nearestBeacon.proximityUUID,nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, nearestBeacon.rssi];
        gotUUID = [NSString stringWithFormat:@"%@-%@-%@", [nearestBeacon.proximityUUID UUIDString], nearestBeacon.major, nearestBeacon.minor];
        //NSLog(message);
    } else {
        gotUUID = @"";
    }
    //check if UUID changed
    if(![gotUUID isEqualToString:self.currentUUID]) {
        NSLog(@"俺は変わった %@ to %@", self.currentUUID, gotUUID);
        if(![gotUUID isEqualToString:@""]) {
            NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"beacon_uuid":gotUUID}];
            [self postUserData:param withCallback:^(void) {
            }];
        }
    }
    self.currentUUID = [NSString stringWithString:gotUUID];
}


# pragma mark bigbrother api
- (void)postUserData:(NSMutableDictionary *)params withCallback:(void (^)())callback {
    NSUUID *vendorUUID = [UIDevice currentDevice].identifierForVendor;
    [params setObject:[vendorUUID UUIDString] forKey:@"uuid"];
    NSLog(@"postUserData params : %@", params);

    NSString *url_str = [NSString stringWithFormat:@"%@/user", UrlEndPoint];
    AFHTTPRequestOperationManager *man = [AFHTTPRequestOperationManager manager];
    man.requestSerializer = [AFJSONRequestSerializer serializer];
    [man POST:url_str parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          callback();
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"failed...");
          NSLog(@"%@", error);
      }];
}
- (void)postTwitterData {
    [self getTwitterProfileImage:^(NSString *url) {
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen_name"];
        NSMutableDictionary *param = [NSMutableDictionary
                                      dictionaryWithDictionary:@{
                                                                 @"screen_name": username,
                                                                 @"icon_url": url
                                                                 }];
        [self postUserData:param withCallback:^{}];
    }];


}

# pragma mark pick twitter account

- (void)requestTwitterAccount
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *twitterAC = [accountStore
                                    accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore
         requestAccessToAccountsWithType:twitterAC
         options:NULL
         completion:^(BOOL granted, NSError *error) {
            if (granted) {
                self.twitterAccounts = [accountStore accountsWithAccountType:twitterAC];
                [self showTwitterPickerView];
            }
        }];
    }
    
}

- (void)showTwitterPickerView{
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    CGRect pf = pickerView.frame;
    // pickerViewの下に表示したい
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, pf.size.height, 320, 44)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                              target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"このTwitterアカウントを使う"
                                   style:UIBarButtonItemStyleDone
                                   target:self action:@selector(doneTwitterPick)];
    [toolbar setItems:[NSArray arrayWithObjects:space, doneButton, nil]];
    // pickerView height + toolbar height
    CGRect pbf = CGRectMake(pf.origin.x, pf.origin.y, pf.size.width, pf.size.height+44);
    UIView *pickerViewBackView = [[UIView alloc] initWithFrame:pbf];
    pickerViewBackView.backgroundColor = [UIColor whiteColor];
    pickerViewBackView.center = self.view.center;
    [pickerViewBackView addSubview:toolbar];
    [pickerViewBackView addSubview:pickerView];
    self.twitterPickerView = pickerViewBackView;
    [self.view addSubview:self.twitterPickerView];
}

-(void)doneTwitterPick{
    // 一度もdidSelectRowが呼ばれていない場合、先頭のやつとする
    if (!didSelected) {
        self.twitterAccount = [self.twitterAccounts objectAtIndex:0];
        NSString *username = [self.twitterAccount username];
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"screen_name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self postTwitterData];
    // close picker view
    [self.twitterPickerView removeFromSuperview];
}

# pragma mark UIPickerView Delegate
BOOL didSelected = false;
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    didSelected = true;
    self.twitterAccount = [self.twitterAccounts objectAtIndex:row];
    NSString *username = [self.twitterAccount username];
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"screen_name"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

# pragma mark UIPickerView DataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.twitterAccounts count];
}
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [[self.twitterAccounts objectAtIndex:row] username];
}

# pragma mark twitter profile image
-(void)getTwitterProfileImage:(void(^)(NSString*url))callback{
    if (!self.twitterAccount) {
        return;
    }
    NSDictionary *param = [NSDictionary dictionaryWithObject:[self.twitterAccount username] forKey:@"screen_name"];
    SLRequest *twreq = [SLRequest
                            requestForServiceType:SLServiceTypeTwitter
                            requestMethod:SLRequestMethodGET
                            URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"]
                            parameters:param];
    [twreq setAccount:self.twitterAccount];
    [twreq performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([urlResponse statusCode] == 429) {
                NSLog(@"Rate limit reached");
                return;
            }
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                return;
            }
            if (responseData) {
                NSError *error = nil;
                NSArray *twres = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                //NSString *screen_name = [(NSDictionary *)twres objectForKey:@"screen_name"];
                //NSString *name = [(NSDictionary *)twres objectForKey:@"name"];
                NSString *profileImageStringURL = [(NSDictionary *)twres objectForKey:@"profile_image_url"];
                // original profile image
                //profileImageStringURL = [profileImageStringURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                callback(profileImageStringURL);
            }
        });
    }];
}




@end
