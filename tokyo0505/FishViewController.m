//
//  FishViewController.m
//  tokyo0505
//
//  Created by 田島 逸郎 on 2014/04/22.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import "FishViewController.h"

@interface FishViewController ()

@end

@implementation FishViewController

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
    // load view
    float width = self.preferredContentSize.width;
    float height = self.preferredContentSize.height;
    self.view = [[UIView alloc] initWithFrame:
                 CGRectMake(self.view.frame.origin.x + 10, self.view.frame.origin.y + 10,
                            width - 20, height - 20)];
    [self loadFishTableView:self.view];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFishTableView:(UIView *)mainView{
    // テスト用のテキストビュー
    UITextView* timetableTextView = [[UITextView alloc] initWithFrame:self.view.frame];
    timetableTextView.editable = NO;
    timetableTextView.font = [UIFont fontWithName:@"Helvetica" size:14];
    timetableTextView.text = @"お前を消す方法";
    [self.view addSubview:timetableTextView];
    
    
}

# pragma mark UITableView delegate



@end
