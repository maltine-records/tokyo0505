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
    
    self.fishTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.fishTableView.delegate = self;
    self.fishTableView.dataSource = self;
    [self.view addSubview:self.fishTableView];
}

# pragma mark UITableView delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"何か御用ですか？";
    } else if (section==1) {
        return @"実績";
    }
    return @"null";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = @"hoge";
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d, %d", indexPath.section, indexPath.row);

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSLog(@"%d", indexPath.row);
        //NSDictionary *rowData = [self.deviceEvents objectAtIndex:indexPath.row];
        //self.detailViewController.detailItem = rowData;
    }
}

@end
