//
//  FishViewController.m
//  tokyo0505
//
//  Created by 田島 逸郎 on 2014/04/22.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import "FishViewController.h"
#import "UIImageView+AFNetworking.h"

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
    
    self.titles = @[@"何か御用ですか？", @"ん？", @"その他"];
    self.section1 = @[@"ツイート！", @"自分の位置にズーム", @"会場全体にズームアウト"];
    self.section2 = @[@"tomad", @"boenyeah", @"MeishiSmile"];
    self.section3 = @[@"Twitterアカウント再選択"];
    self.sections = @[self.section1, self.section2, self.section3];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFishTableView:(UIView *)mainView{
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
    return [self.sections count];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.titles objectAtIndex:section];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sections objectAtIndex:section] count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* rowValues = [self.sections objectAtIndex:indexPath.section];
    NSString* rowText = [rowValues objectAtIndex:indexPath.row];
    
    UITableViewCell *cell;
    if (indexPath.section==0 || indexPath.section==2) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell0"];
    } else if (indexPath.section==1){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
        NSString *who = [[NSString alloc] initWithFormat:@"met_%@", rowText];
        NSString *imgName = [[NSString alloc] initWithFormat:@"%@.png", rowText];
        cell.imageView.image = [UIImage imageNamed:imgName];
        BOOL met = [[NSUserDefaults standardUserDefaults] boolForKey:who];
        // 会っていないひとはグレーアウトして選択不可
        if (!met) {
            cell.imageView.alpha = 0.5;
            cell.backgroundColor = [UIColor grayColor];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }

    cell.textLabel.text = rowText;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d, %d", indexPath.section, indexPath.row);
    if (indexPath.section==0) {
        if (indexPath.row==0){
            [self.delegate dismisPopover:@{@"selector": @"tweetCompose"}];
        }else if (indexPath.row==1) {
            [self.delegate dismisPopover:@{@"selector": @"zoomInToSelf"}];
        }else if (indexPath.row==2){
            [self.delegate dismisPopover:@{@"selector": @"zoomOutToSite"}];
        }
    }else if (indexPath.section==1){
        if (indexPath.row==0) {
            [self.delegate dismisPopover:@{@"sendMetDirectMessage": @"tomad"}];
        }else if (indexPath.row==1){
            [self.delegate dismisPopover:@{@"sendMetDirectMessage": @"boenyeah"}];
        }else if (indexPath.row==2){
            [self.delegate dismisPopover:@{@"sendMetDirectMessage": @"MeishiSmile"}];
        }
    }else if (indexPath.section==2){
        if (indexPath.row==0) {
            [self.delegate dismisPopover:@{@"selector": @"changeTwitterAccount"}];
        }
    }
}

@end
