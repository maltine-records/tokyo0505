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
    float width = self.preferredContentSize.width;
    float height = self.preferredContentSize.height;

    self.timetableView = [[UIView alloc] initWithFrame:
                          CGRectMake(self.view.frame.origin.x + 5, self.view.frame.origin.y + 5,
                                     width - 20, height - 20)];
    UITextView* timetableTextView = [[UITextView alloc] initWithFrame:
                                     CGRectMake(self.timetableView.frame.origin.x, self.timetableView.frame.origin.y,
                                                self.timetableView.frame.size.width, self.timetableView.frame.size.height)];
    timetableTextView.editable = NO;
    timetableTextView.font = [UIFont fontWithName:@"Helvetica" size:14];
    timetableTextView.text = @"お前を消す方法";
    [self.timetableView addSubview:timetableTextView];
    
    [mainView addSubview:self.timetableView];
}

@end
