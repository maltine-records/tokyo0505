//
//  MapViewController.m
//  tokyo0505
//
//  Created by cerevo on 2014/04/16.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"
#import "Common.h"
#import "UserService.h"
#import "TokyoOverlayRenderer.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+animatedGif.h"
#import "FishViewController.h"


@interface MapViewController ()

@end

@implementation MapViewController
{
    UserService *userService;
    __block NSDictionary* beacons;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.currentMainUUID = @"null"; //実在しない値
        self.currentSubUUID = @"null";
        userService = [[UserService alloc] init];
        [self getBeaconsData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.mapView setDelegate:self];
    [self setupFishButton];
    [self setupMapView];
    [self setupBeaconMonitor];
    [self setupUserService];
    NSString *screen_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen_name"];
    if ([screen_name length] == 0) {
        [self requestTwitterAccount];
    } else {
        NSLog(@"screen_name: %@", screen_name);
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [userService startFetchUsers:10.0f];
    [userService fetchUsers];
}

-(void)viewWillDisappear:(BOOL)animated {
    [userService stopFetchUsers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark setup view

- (void)setupFishButton
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fish" ofType:@"gif"]];
    UIImage *img = [UIImage animatedImageWithAnimatedGIFURL:url];
    self.fishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fishButton setBackgroundImage:img forState:UIControlStateNormal];
    float fWidth = 60;
    float fHeight = 40;
    float fPadding = 10;
    self.fishButton.frame = CGRectMake(fPadding, self.view.frame.size.height-fHeight-fPadding, fWidth, fHeight);
    [self.fishButton addTarget:self action:@selector(fishAction:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.fishButton];
}

- (void)fishAction:(UIButton *)button {
    // すでに開いてたら一回閉じる
    if (self.poc) {
        if ([self.poc isPopoverVisible]) {
            [self.poc dismissPopoverAnimated:YES];
        }
    }
    FishViewController *fishViewController = [FishViewController new];
    fishViewController.preferredContentSize = CGSizeMake(280, 350);
    fishViewController.delegate = self;
    self.poc = [[UIPopoverController alloc] initWithContentViewController:fishViewController];
    [self.poc setDelegate:self];
    [self.poc presentPopoverFromRect:self.fishButton.frame
                              inView:self.view
            permittedArrowDirections:UIPopoverArrowDirectionDown
                            animated:YES];
}
-(void)dismisPopover:(NSDictionary *)dismisWithData
{
    [self.poc dismissPopoverAnimated:YES];
    NSLog(@"%@", dismisWithData);
    NSString* selector = [dismisWithData valueForKey:@"selector"];
    if ([selector isEqualToString:@"zoomInToSelf"]) {
        [self zoomInToSelf];
    }else if ([selector isEqualToString:@"zoomOutToSite"]){
        [self zoomOutToSite];
    }else if ([selector isEqualToString:@"changeTwitterAccount"]){
        [self requestTwitterAccount];
    }
    NSString*screen_name = [dismisWithData valueForKey:@"sendMetDirectMessage"];
    if (screen_name) {
        [self sendMetDirectMessage:screen_name];
    }
    
}

-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return YES;
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [self.poc dismissPopoverAnimated:YES];
}

- (void)setupMapView
{
    // map type
    self.mapView.mapType = MKMapTypeHybrid;
    [self zoomOutToSite];
    
    // add overlay
    // TODO 縦横比を画像と合わせないと歪む
    CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D)*4);
    coords[0] = CLLocationCoordinate2DMake(35.727523, 139.632645);//左上
    coords[1] = CLLocationCoordinate2DMake(35.603426, 139.632645);//左下
    coords[2] = CLLocationCoordinate2DMake(35.727523, 139.864241);//右上
    coords[3] = CLLocationCoordinate2DMake(35.630224, 139.864241);//右下
    MKPolygon *p = [MKPolygon polygonWithCoordinates:coords count:4];
    [self.mapView addOverlay:p];

    [self addTimetableAnnotations];
}

- (void) addTimetableAnnotations
{
    CLLocationCoordinate2D asakusa = CLLocationCoordinate2DMake(35.712074, 139.79843);
    CLLocationCoordinate2D nogata = CLLocationCoordinate2DMake(35.7200116, 139.6522843);
    TimetableAnnotaion *maintt = [[TimetableAnnotaion alloc] init];
    maintt.coordinate = asakusa;
    maintt.title = @"メイン";
    maintt.imageName = @"time-main.png";
    maintt.isSub = false;
    [self.mapView addAnnotation:maintt];
    TimetableAnnotaion *subtt = [[TimetableAnnotaion alloc] init];
    subtt.coordinate = nogata;
    subtt.title = @"サブ";
    subtt.isSub = true;
    subtt.imageName = @"time-sub.png";
    [self.mapView addAnnotation:subtt];
}

- (void)setupUserService
{
    //when get user, annotation changes
    __unsafe_unretained typeof(self) weakSelf = self;
    [userService setCallback:^(NSDictionary *users) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSPredicate* isMatchClassBeaconA = [NSPredicate
                                                predicateWithFormat:@"self isKindOfClass: %@", [BeaconAnnotation class]];
            NSArray* beaconA = [weakSelf.mapView.annotations filteredArrayUsingPredicate:isMatchClassBeaconA];
            [weakSelf.mapView removeAnnotations:beaconA];
            NSPredicate* isMatchClassUserA = [NSPredicate
                                              predicateWithFormat:@"self isKindOfClass: %@", [UserAnnotation class]];
            NSArray* userA = [weakSelf.mapView.annotations filteredArrayUsingPredicate:isMatchClassUserA];
            [weakSelf.mapView removeAnnotations:userA];
            
            //drawing beacons
            for(NSString* beaconKey in users) {
                NSDictionary *beaconDict = [users objectForKey:beaconKey];
                CLLocationCoordinate2D tmpLocation;
                tmpLocation.latitude = [[beaconDict objectForKey:@"lat"] doubleValue];
                tmpLocation.longitude = [[beaconDict objectForKey:@"lon"] doubleValue];
                BeaconAnnotation *tmpAnnotation = [[BeaconAnnotation alloc] init];
                tmpAnnotation.coordinate = tmpLocation;
                tmpAnnotation.title = [beaconDict objectForKey:@"name"];
                [weakSelf.mapView addAnnotation:tmpAnnotation];
                //drawing users
                for(NSDictionary *user in [beaconDict objectForKey:@"users"]) {
                    CLLocationCoordinate2D tmpUserLocation;
                    tmpUserLocation.latitude = [[beaconDict objectForKey:@"lat"] doubleValue] + ((double)arc4random() / 0x100000000) * annotation_random * 2 - annotation_random;
                    tmpUserLocation.longitude = [[beaconDict objectForKey:@"lon"] doubleValue] + ((double)arc4random() / 0x100000000) * annotation_random * 2 - annotation_random;
                    UserAnnotation *tmpUserAnnotation = [[UserAnnotation alloc] init];
                    tmpUserAnnotation.coordinate = tmpUserLocation;
                    tmpUserAnnotation.title = [user objectForKey:@"screen_name"];
                    tmpUserAnnotation.imageUrl = [NSURL URLWithString:[user objectForKey:@"icon_url"]];
                    [weakSelf.mapView addAnnotation:tmpUserAnnotation];
                }
            }
        });
    }];
}

#pragma mark
-(void)zoomInToSelf
{
    NSString *screen_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"screen_name"];
    if ([screen_name length] == 0) {
        [self requestTwitterAccount];
    } else {
        [self zoomInToScreenName:screen_name];
    }
}
-(void)zoomInToScreenName:(NSString *)screen_name
{
    // 特定のスクリーンネームを探して表示する
    NSLog(@"screen_name: %@", screen_name);
    NSPredicate* isMatchClassUserA = [NSPredicate
                                      predicateWithFormat:@"self isKindOfClass: %@", [UserAnnotation class]];
    NSArray* users= [self.mapView.annotations filteredArrayUsingPredicate:isMatchClassUserA];
    CLLocationCoordinate2D point=kCLLocationCoordinate2DInvalid;
    for (UserAnnotation*user in users) {
        if ([user.title isEqualToString:screen_name]){
            point = user.coordinate;
        }
    }
    if (CLLocationCoordinate2DIsValid(point)) {
        MKCoordinateRegion region = self.mapView.region;
        region.center = point;
        NSLog(@"%f, %f", point.latitude, point.longitude);
        region.span.latitudeDelta = 0.08;
        region.span.longitudeDelta = 0.08;
        [self.mapView setRegion:region animated:YES];
    }
}
-(void)zoomOutToSite
{
    // 会場全体を表示する
    // move center
    CLLocationCoordinate2D koukyo = CLLocationCoordinate2DMake(35.683833, 139.753972);
    [self.mapView setCenterCoordinate:koukyo];
    MKCoordinateRegion region = self.mapView.region;
    region.center = koukyo;
    region.span.latitudeDelta = 0.25;
    region.span.longitudeDelta = 0.25;
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - MKMapViewDelegate
// KASANE
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    return [[TokyoOverlayRenderer alloc] initWithOverlay:overlay];
}
// pin
-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // user icon
    if ([annotation isKindOfClass:[UserAnnotation class]])
    {
        MKAnnotationView *av = nil; // なぜかreuseすると破滅
        if(av == nil) {
            av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"user"];
            UIImageView *imageView = [[UIImageView alloc] init];
            UserAnnotation *an = annotation;
            [imageView setImageWithURL:an.imageUrl placeholderImage:[UIImage imageNamed:@"twitter.png"]];
            [imageView setFrame:CGRectMake(0, 0, 22, 22)];
            av.canShowCallout = YES;
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            //[btn setBackgroundImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
            //[btn setImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
            av.rightCalloutAccessoryView = btn;
            [av addSubview:imageView];
            av.frame = imageView.frame;
            return av;
        }
    }
    // beacon
    if ([annotation isKindOfClass:[BeaconAnnotation class]])
    {
        MKAnnotationView *av=(MKPinAnnotationView*)[mapView
                                                    dequeueReusableAnnotationViewWithIdentifier:@"beacon"];
        if (av==nil) {
            av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"beacon"];
            UIImage *image = [UIImage imageNamed:@"bacon-40.png"];
            av.image = image;
            av.canShowCallout = YES;
        }
        return av;
    }
    // timetable
    if ([annotation isKindOfClass:[TimetableAnnotaion class]])
    {
        TimetableAnnotaion* tta = (TimetableAnnotaion*)annotation;
        MKAnnotationView *av=nil;
        NSString* reuseIdentifier;
        if (tta.isSub) {
            reuseIdentifier = @"timetable-sub";
        } else {
            reuseIdentifier = @"timetable-main";
        }
        av = (MKAnnotationView*)[mapView
                                 dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        if (av==nil) {
            av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
        UIImage *image = [UIImage imageNamed:tta.imageName];

        av.image = image;
        av.canShowCallout = YES;
        av.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
        return av;
    }
    // なんでもないようなアノテーション
    return nil;
}
// ピン表示の被りを調節
- (void) mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views
{
    for (MKAnnotationView*view in views) {
        if ([view.annotation isKindOfClass:[UserAnnotation class]]) {
            [[view superview] bringSubviewToFront:view];
        }
        if ([view.annotation isKindOfClass:[BeaconAnnotation class]] || [view.annotation isKindOfClass:[TimetableAnnotaion class]]){
            [[view superview] sendSubviewToBack:view];
        }
    }
}
// ピンの吹き出し内コントロールがタップされたときの処理
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[TimetableAnnotaion class]]) {
        TimetableAnnotaion* tta = (TimetableAnnotaion*)view.annotation;
        [tta addTimetableSubView:self.view];
    }else if ([view.annotation isKindOfClass:[UserAnnotation class]]){
        UserAnnotation*ua =(UserAnnotation*) view.annotation;
        NSString *url = [NSString stringWithFormat:@"twitter://user?screen_name=%@", ua.title];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}


# pragma mark iBeacon

- (void)setupBeaconMonitor
{
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        // CLLocationManagerの生成とデリゲートの設定
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        
        // NSUUIDを作成
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"00000000-31d9-1001-b000-001c4dc4c8af"];
        // CLBeaconRegionを作成
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:@"com.nubot.tokyo0505.mainregion"];
        self.beaconRegion.notifyEntryStateOnDisplay = YES;
        // Beaconによる領域観測を開始
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
        
        
        NSUUID* proximityUUID2 = [[NSUUID alloc] initWithUUIDString:@"00000000-879F-1001-B000-001C4DE6C3AB"];
        CLBeaconRegion* beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID2 identifier:@"com.nubot.tokyo0505.subregion"];
        beaconRegion2.notifyEntryStateOnDisplay = YES;
        [self.locationManager startMonitoringForRegion:beaconRegion2];
        [self.locationManager startRangingBeaconsInRegion:beaconRegion2];
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)rangeBeacons inRegion:(CLBeaconRegion *)region
{
    NSMutableArray* gotBeacons = [NSMutableArray arrayWithArray:rangeBeacons];
    NSString* gotUUID;
    NSString* gotRegion;
    NSNumber* proximity;
    NSString* message;
    // 先にbeacons配列からtomadと外人のぶんを除外しておく（そうしないと、近くにいた場合位置がとれなくなってしまう）
    for (CLBeacon *beacon in gotBeacons) {
        NSString *uuidstr = [NSString stringWithFormat:@"%@-%@-%@",
                             [beacon.proximityUUID UUIDString], beacon.major, beacon.minor];
        if ([uuidstr isEqualToString:@"00000000-31D9-1001-B000-001C4DC4C8AF-1-3"]) {
            [gotBeacons removeObject:beacon];
            [self metPeople:@"boenyeah"];
        }else if ([uuidstr isEqualToString:@"00000000-31D9-1001-B000-001C4DC4C8AF-1-4"]){
            [gotBeacons removeObject:beacon];
            [self metPeople:@"MeishiSmile"];
        }else if ([uuidstr isEqualToString:@"00000000-879F-1001-B000-001C4DE6C3AB-1-4"]){
            [gotBeacons removeObject:beacon];
            [self metPeople:@"tomad"];
        }
    }
    
    if (gotBeacons.count > 0) {
        CLBeacon *nearestBeacon = gotBeacons.firstObject;
        NSString *rangeMessage;
        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                rangeMessage = @"Range Immediate: ";
                proximity = @5;
                break;
            case CLProximityNear:
                rangeMessage = @"Range Near: ";
                proximity = @10;
                break;
            case CLProximityFar:
                rangeMessage = @"Range Far: ";
                proximity = @30;
                break;
            default:
                rangeMessage = @"Range Unknown: ";
                break;
        }
        message = [NSString stringWithFormat:@"UUID:%@, major:%@, minor:%@, accuracy:%f, rssi:%d",
                             nearestBeacon.proximityUUID, nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, nearestBeacon.rssi];
        gotUUID = [NSString stringWithFormat:@"%@-%@-%@", [nearestBeacon.proximityUUID UUIDString], nearestBeacon.major, nearestBeacon.minor];
        gotRegion = [region identifier];
    } else {
        gotUUID = @"null";
        gotRegion = @"null";
    }
    
    if ([gotRegion isEqualToString:@"com.nubot.tokyo0505.mainregion"]) {
        if(![gotUUID isEqualToString:self.currentMainUUID]) {
            NSLog(@"俺は変わった %@ to %@", self.currentMainUUID, gotUUID);
            NSMutableDictionary *param = [NSMutableDictionary
                                          dictionaryWithDictionary:@{@"beacon_uuid":gotUUID, @"proximity":proximity}];
            [self postUserData:param withCallback:^(void) {}];
        }
        self.currentMainUUID = [NSString stringWithString:gotUUID];
    }else if ([gotRegion isEqualToString:@"com.nubot.tokyo0505.subregion"]){
        if(![gotUUID isEqualToString:self.currentSubUUID]) {
            NSLog(@"俺は変わった %@ to %@", self.currentSubUUID, gotUUID);
            NSMutableDictionary *param = [NSMutableDictionary
                                          dictionaryWithDictionary:@{@"beacon_uuid":gotUUID, @"proximity":proximity}];
            [self postUserData:param withCallback:^(void) {}];
        }
        self.currentSubUUID = [NSString stringWithString:gotUUID];
    } else if ([gotRegion isEqualToString:@"null"]) {
        if ([gotUUID isEqualToString:@"null"]) {
            NSLog(@"俺はもうダメだ〜どうすればいいんだ〜");
            NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"beacon_uuid":@"null"}];
            [self postUserData:param withCallback:^(void) {}];
        }
    }
}

-(void)metPeople:(NSString*)screen_name{
    NSString *who = [[NSString alloc] initWithFormat:@"met_%@", screen_name];
    NSLog(@"%@", who);
    BOOL hasmet = [[NSUserDefaults standardUserDefaults] boolForKey:who];
    if (!hasmet) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:who];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self sendMetDirectMessage:screen_name];
    }
}

-(void)sendMetDirectMessage:(NSString*)screen_name{
    // send direct message
    NSString *mp3url;
    if ([screen_name isEqualToString:@"tomad"]) {
        mp3url = @"http://maltinerecords.cs8.biz/Tokyo01.mp3";
    }else if ([screen_name isEqualToString:@"boenyeah"]){
        mp3url = @"http://maltinerecords.cs8.biz/Tokyo02.mp3";
    }else if ([screen_name isEqualToString:@"MeishiSmile"]){
        mp3url = @"http://maltinerecords.cs8.biz/Tokyo03.mp3";
    }
    NSString*text = [NSString stringWithFormat:
                     @"%@とすれ違いました。曲をプレゼント！ %@", screen_name, mp3url];
    [self sendTwitterDirectMessageToSelf:text];
}

# pragma mark bigbrother api

//fetch location of UUIDs
-(void)getBeaconsData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@/beacon", UrlEndPoint];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        beacons = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

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
    [self getTwitterProfileImage:^(NSMutableDictionary*param) {
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
    // close picker view
    [self.twitterPickerView removeFromSuperview];
    // 一度もdidSelectRowが呼ばれていない場合、先頭のやつとする
    if (!didSelected) {
        self.twitterAccount = [self.twitterAccounts objectAtIndex:0];
        NSString *username = [self.twitterAccount username];
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"screen_name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self postTwitterData];

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

# pragma mark twitter api
// profile image
-(void)getTwitterProfileImage:(void(^)(NSMutableDictionary*param))callback{
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
                NSString *screen_name = [(NSDictionary *)twres objectForKey:@"screen_name"];
                //NSString *name = [(NSDictionary *)twres objectForKey:@"name"];
                int followers = [[(NSDictionary *)twres objectForKey:@"followers_count"] integerValue];
                NSString *profileImageStringURL = [(NSDictionary *)twres objectForKey:@"profile_image_url"];
                // original profile image
                //profileImageStringURL = [profileImageStringURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                NSMutableDictionary *param = [NSMutableDictionary
                                              dictionaryWithDictionary:@{
                                                                         @"screen_name": screen_name,
                                                                         @"icon_url": profileImageStringURL,
                                                                         @"followers_count": [NSString stringWithFormat:@"%i", followers]
                                                                         }];
                callback(param);
            }
        });
    }];
}
// direct message
-(void)sendTwitterDirectMessageToSelf:(NSString*)text{
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1.1/direct_messages/new.json"];
    NSDictionary *parameters = @{@"text": text,
                                 @"screen_name": [self.twitterAccount username]};
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodPOST
                                                      URL:url
                                               parameters:parameters];
    
    [request setAccount:self.twitterAccount];
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponse,
                                         NSError *error)
     {
         NSError *jsonError = nil;
         id jsonData = [NSJSONSerialization JSONObjectWithData:responseData
                                                       options:0
                                                         error:&jsonError];
         if (error){
             
             NSLog(@"error:%@", error);
         }
         
         if (jsonError) {
             
             NSLog(@"jsonerror:%@", jsonError);
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             NSLog(@"jsondata:%@" , jsonData);
         });
     }];
}

@end
