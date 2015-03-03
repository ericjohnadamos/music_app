//
//  BCUser.h
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 2/28/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCUser : NSObject

@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* firstname;
@property (nonatomic, copy) NSString* lastname;
@property (nonatomic, copy) NSString* location;
@property (nonatomic, copy) NSString* musicPreferences;
@property (nonatomic, assign) double birthday;

- (BOOL) isValid;

@end
