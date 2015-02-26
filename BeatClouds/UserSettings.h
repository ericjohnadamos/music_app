//
//  UserSettings.h
//  BeatClouds
//
//  Created by Eric John Adamos on 2/21/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

@property (nonatomic, copy) NSString* token;

+ (UserSettings*) sharedInstance;

@end
