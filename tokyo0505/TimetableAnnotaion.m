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

@synthesize coordinate, subtitle, title, imageName, timetableView, isSub;

- (id) initWithCoordinate:(CLLocationCoordinate2D)c {
	coordinate = c;
	return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)c {
    coordinate = c;
}

NSString* mainTimetableStr =
@"15:00~15:50 Carpainter - Naohiro Yako\n"
"15:50~16:30 Pa's Lam System - GraphersRock\n"
"16:30~17:10 PARKGOLF - Naohiro Yako\n"
"17:10~17:50 DJ WILDPARTY - huze\n"
"17:50~18:25 okadada - huze\n"
"18:25~18:30 Gonbuto - huze\n"
"18:30~19:00 PPS - VIDEO BOY\n"
"19:00~19:20 Acid White House - GraphersRock\n"
"19:20~20:00 MEISHI SMILE - ?\n"
"20:00~20:40 tofubeats - VIDEO BOY\n"
"20:40~21:20 Sugar's Campaign - VIDEO BOY\n"
"21:20~22:00 bo en - ?";

NSString* subTimetableStr =
@"15:00~15:40 Qrion\n"
"15:40~16:20 Hercelot\n"
"16:20~17:00 Yoshino Yoshikawa\n"
"17:00~17:30 ラブリーサマーちゃん\n"
"17:30~18:10 Miii\n"
"18:10~18:50 fazerock\n"
"18:50~19:30 Tomggg\n"
"19:30~20:00 三毛猫ホームレス\n"
"20:00~20:40 Madmaid\n"
"20:40~21:20 Gigandect\n"
"21:20~21:50 パジャマパーティズ\n";

- (void)addTimetableSubView:(UIView *)mainView{
    self.timetableView = [[UIView alloc] initWithFrame:CGRectMake(0, 150, 320, 264)];
    UITextView* timetableTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 220)];
    timetableTextView.backgroundColor = [UIColor whiteColor];
    timetableTextView.editable = NO;
    timetableTextView.font = [UIFont fontWithName:@"Helvetica" size:14];
    if (self.isSub) {
        timetableTextView.text = subTimetableStr;
    }else{
        timetableTextView.text = mainTimetableStr;
    }
    [self.timetableView addSubview:timetableTextView];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, timetableTextView.frame.size.height, 320, 44)];
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
