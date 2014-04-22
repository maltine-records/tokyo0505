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
    
    self.titles = @[@"何か御用ですか？", @"ん？"];
    self.section1 = @[@"自分の位置にズーム", @"会場全体にズームアウト"];
    self.section2 = @[@"tomad", @"boenyeah", @"MeishiSmile"];
    self.sections = @[self.section1, self.section2];

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
    return 2;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.titles objectAtIndex:section];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sections objectAtIndex:section] count];
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1)
        return nil;
    else
        return indexPath;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* rowValues = [self.sections objectAtIndex:indexPath.section];
    NSString* rowText = [rowValues objectAtIndex:indexPath.row];
    
    UITableViewCell *cell;
    if (indexPath.section==0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell0"];
    } else if (indexPath.section==1){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.imageView.image = [UIImage imageNamed:@"twitter.png"];
    }

    cell.textLabel.text = rowText;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d, %d", indexPath.section, indexPath.row);
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            [self.delegate dismisPopover:@{@"selector": @"zoomInToSelf"}];
        }else if (indexPath.row==1){
            [self.delegate dismisPopover:@{@"selector": @"zoomOutToSite"}];
        }
    }
}

@end
