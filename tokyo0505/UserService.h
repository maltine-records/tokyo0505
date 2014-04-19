//
//  UserService.h
//  tokyo0505
//
//  Created by 田島 逸郎 on 2014/04/19.
//  Copyright (c) 2014年 Nubot, inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserService : NSObject
-(void)startFetchUsers:(float)duration;
-(void)stopFetchUsers;
-(void)fetchUsers;
-(void)setCallback:(void (^)(NSDictionary* users))cb;
@end
