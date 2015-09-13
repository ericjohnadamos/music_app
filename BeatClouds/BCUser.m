//
//  BCUser.m
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 2/28/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import "BCUser.h"

@implementation BCUser

#pragma mark - Exposed method

- (BOOL) isValid
{
  return (   self.username != nil && self.username.length > 0
          && self.password != nil && self.password.length > 0
          && self.email != nil && self.email.length > 0
          && self.firstname != nil && self.firstname.length > 0
          && self.lastname != nil && self.lastname.length > 0
          && self.musicPreferences != nil && self.musicPreferences.length > 0);
}

@end
