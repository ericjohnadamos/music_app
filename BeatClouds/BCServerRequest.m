//
//  BCServerRequest.m
//  BeatClouds
//
//  Created by Eric John Adamos on 2/21/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import "BCServerRequest.h"

static NSString* kLoginURL
  = @"http://dev.beatclouds.south-soul.com/users/login";
static NSString* kResetURL
  = @"http://dev.beatclouds.south-soul.com/users/forgot_password";
static NSString* kRegisterURL
  = @"http://dev.beatclouds.south-soul.com/users/register";

static NSString* kLoginParams
  = @"username=%@&password=%@";
static NSString* kResetParams
  = @"email=%@";
static NSString* kRegisterParams
  = @"username=%@&password=%@&email=%@&firstname=%@&lastname=%@&location=%@";

@implementation BCServerRequest

+ (void) requestLoginWithUsername: (NSString*)              username
                         password: (NSString*)              password
                         callback: (void(^)(NSData*)) callback
{
  if (username.length == 0 || password.length == 0)
  {
    if (callback != nil) { callback(nil); }
  }
  else
  {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             0), ^(void)
    {
      NSString* query = [NSString stringWithFormat:
                         kLoginParams, username, password];
      
      NSData* data = [query dataUsingEncoding: NSASCIIStringEncoding
                         allowLossyConversion: YES];
      
      NSString* length = [NSString stringWithFormat: @"%d", [data length]];
     
      NSMutableURLRequest* request = [NSMutableURLRequest new];
      request.URL = [NSURL URLWithString: kLoginURL];
      request.HTTPMethod = @"POST";
      request.HTTPBody = data;
      [request   setValue: length
       forHTTPHeaderField: @"Content-Length"];
      [request   setValue: @"application/x-www-form-urlencoded"
       forHTTPHeaderField: @"Content-Type"];
     
      NSURLResponse* response = nil;
      NSData* resultData = [NSURLConnection sendSynchronousRequest: request
                                                 returningResponse: &response
                                                             error: nil];
      dispatch_async(dispatch_get_main_queue(), ^(void)
      {
        if (callback != nil)
        {
          callback(resultData);
        }
      });
    });
  }
}

+ (void) requestResetWithUsername: (NSString*)        username
                         callback: (void(^)(NSData*)) callback
{
  if (username.length == 0)
  {
    if (callback != nil) { callback(nil); }
  }
  else
  {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             0), ^(void)
    {
      NSString* query = [NSString stringWithFormat: kResetParams, username];
      NSData* data = [query dataUsingEncoding: NSASCIIStringEncoding
                         allowLossyConversion: YES];
      NSString* length = [NSString stringWithFormat: @"%d", [data length]];
      
      NSMutableURLRequest* request = [NSMutableURLRequest new];
      [request setURL: [NSURL URLWithString: kResetURL]];
      [request setHTTPMethod: @"POST"];
      [request   setValue: length
       forHTTPHeaderField: @"Content-Length"];
      [request   setValue: @"application/x-www-form-urlencoded"
       forHTTPHeaderField: @"Content-Type"];
      [request setHTTPBody: data];
      
      NSURLResponse* response = nil;
      NSData* resultData = [NSURLConnection sendSynchronousRequest: request
                                                 returningResponse: &response
                                                             error: nil];
      dispatch_async(dispatch_get_main_queue(), ^(void)
      {
        if (callback != nil)
        {
          callback(resultData);
        }
      });
    });
  }
}

+ (void) requestRegistrationWithUsername: (NSString*)         username
                                password: (NSString*)         password
                                   email: (NSString*)         email
                               firstname: (NSString*)         firstname
                                lastname: (NSString*)         lastname
                                location: (NSString*)         location
                                callback: (void (^)(NSData*)) callback
{
  if (   username.length == 0
      || password.length == 0
      || email.length == 0
      || firstname.length == 0
      || lastname.length == 0)
  {
    if (callback != nil) { callback(nil); }
  }
  else
  {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             0), ^(void)
    {
      NSString* query
        = [NSString stringWithFormat:
           kRegisterParams,
           username, password, email, firstname, lastname, location];
      
      NSData* data = [query dataUsingEncoding: NSASCIIStringEncoding
                         allowLossyConversion: YES];
      
      NSString* length = [NSString stringWithFormat: @"%d", [data length]];
      
      NSMutableURLRequest* request = [NSMutableURLRequest new];
      request.URL = [NSURL URLWithString: kRegisterURL];
      request.HTTPMethod = @"POST";
      request.HTTPBody = data;
      [request   setValue: length
       forHTTPHeaderField: @"Content-Length"];
      [request   setValue: @"application/x-www-form-urlencoded"
       forHTTPHeaderField: @"Content-Type"];
      
      NSURLResponse* response = nil;
      NSData* returnData = [NSURLConnection sendSynchronousRequest: request
                                                 returningResponse: &response
                                                             error: nil];
      dispatch_async(dispatch_get_main_queue(), ^(void)
      {
        if (callback != nil)
        {
          callback(returnData);
        }
      });
    });
  }
}

@end
