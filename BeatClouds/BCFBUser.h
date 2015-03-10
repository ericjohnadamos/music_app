//
//  BCFBUser.h
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 3/10/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCFBUser : NSObject

@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* accessToken;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* firstname;
@property (nonatomic, copy) NSString* lastname;
@property (nonatomic, copy) NSString* location;

- (BOOL) isValid;

@end
