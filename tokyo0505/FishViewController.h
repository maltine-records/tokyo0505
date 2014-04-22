//
//  FishViewController.h
//  tokyo0505
//
//  Created by 田島 逸郎 on 2014/04/22.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DismisPopoverDelegate
- (void) dismisPopover:(NSObject *)dismisWithData;
@end

@interface FishViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    id<DismisPopoverDelegate> delegate;
}
@property (nonatomic, retain) NSArray *titles;
@property (nonatomic, retain) NSArray *section1;
@property (nonatomic, retain) NSArray *section2;
@property (nonatomic, retain) NSArray *sections;

@property (nonatomic, assign) id<DismisPopoverDelegate> delegate;
@property (nonatomic, retain) UITableView *fishTableView;
@end
