//
//  UserService.m
//  tokyo0505
//
//  Created by 田島 逸郎 on 2014/04/19.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import "UserService.h"
#import "AFNetworking/AFNetworking.h"
#import "Common.h"

@implementation UserService
{
    NSTimer *timer;
    void (^callback)(NSDictionary* users);
}
-(id)init {
    self = [super init];
    if(self) {
        callback = nil;
    }
    return self;
}
-(void)startFetchUsers:(float)duration {
    timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(fetchUsers:) userInfo:nil repeats:YES];
}
-(void)stopFetchUsers {
    [timer invalidate];
}
-(void)fetchUsers:(NSTimer *)timer {
    NSString *url_str = [NSString stringWithFormat:@"%@/user", UrlEndPoint];
    NSLog(@"%@", url_str);
    AFHTTPRequestOperationManager *man = [AFHTTPRequestOperationManager manager];
    man.requestSerializer = [AFJSONRequestSerializer serializer];
    [man GET:url_str parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          callback(responseObject);
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"failed...");
          NSLog(@"%@", error);
      }];
}
-(void)setCallback:(void (^)(NSDictionary* users))cb {
    callback = cb;
}
@end
