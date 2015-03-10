//
//  BCFBUser.m
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 3/10/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import "BCFBUser.h"

#pragma mark - Exposed method

@implementation BCFBUser

- (BOOL) isValid
{
  return (   self.userId != nil && self.userId.length > 0
          && self.accessToken != nil && self.accessToken.length > 0
          && self.email != nil && self.email.length > 0
          && self.firstname != nil && self.firstname.length > 0
          && self.lastname != nil && self.lastname.length > 0
          && self.location != nil && self.location.length > 0);
}

@end
