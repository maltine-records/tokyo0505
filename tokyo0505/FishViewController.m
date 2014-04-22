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
    [self addTimetableSubView:self.view];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)addTimetableSubView:(UIView *)mainView{
    self.timetableView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 10, self.view.frame.origin.y + 10, self.view.frame.size.width - 50, self.view.frame.size.height - 50)];
    UITextView* timetableTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.timetableView.frame.origin.x, self.timetableView.frame.origin.y, self.timetableView.frame.size.width, self.timetableView.frame.size.height)];
    timetableTextView.backgroundColor = [UIColor whiteColor];
    timetableTextView.editable = NO;
    timetableTextView.font = [UIFont fontWithName:@"Helvetica" size:14];
    timetableTextView.text = @"fish";
    [self.timetableView addSubview:timetableTextView];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, timetableTextView.frame.size.height, 320, 44)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                              target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"close"
                                   style:UIBarButtonItemStyleDone
                                   target:self action:@selector(doneButton)];
    [mainView addSubview:self.timetableView];
}

@end
