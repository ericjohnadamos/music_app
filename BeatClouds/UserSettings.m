//
//  UserSettings.m
//  BeatClouds
//
//  Created by Eric John Adamos on 2/21/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import "UserSettings.h"


static NSString* kUserToken = @"userToken";
static UserSettings* sm_userSettings = nil;

@interface UserSettings ()

@end

@implementation UserSettings

- (void) setToken: (NSString*) token
{
  [[NSUserDefaults standardUserDefaults] setValue: token
                                           forKey: kUserToken];
}

- (NSString*) token
{
  return [[NSUserDefaults standardUserDefaults] valueForKey: kUserToken];
}

+ (UserSettings*) sharedInstance
{
  if (sm_userSettings == nil)
  {
    sm_userSettings = [[UserSettings alloc] init];
  }
  
  return sm_userSettings;
}

@end
