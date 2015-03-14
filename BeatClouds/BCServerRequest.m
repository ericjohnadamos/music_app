//
//  BCServerRequest.m
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 2/21/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import "BCServerRequest.h"

static NSTimeInterval const kRequestTimeout = 30.0f;

static NSString* const kBCRequestURLLogin
  = @"http://dev.beatclouds.south-soul.com/users/login";
static NSString* const kBCRequestURLFacebookLogin
  = @"http://dev.beatclouds.south-soul.com/users/login_fb";
static NSString* const kBCRequestURLResetPassword
  = @"http://dev.beatclouds.south-soul.com/users/forgot_password";
static NSString* const kBCRequestURLRegistration
  = @"http://dev.beatclouds.south-soul.com/users/register";
static NSString* const kBCRequestURLCheckMessage
  = @"http://dev.beatclouds.south-soul.com/message/check_new";

NSString* const BCRequestKeyStatus = @"status";
NSString* const BCRequestKeyResponse = @"response";
NSString* const BCRequestKeyUserToken = @"user_token";
NSString* const BCRequestKeyMessage = @"message";

NSString* const BCRequestParamsLogin = @"username=%@&password=%@";
NSString* const BCRequestParamsFacebookLogin
  = (@"fb_user_id=%@&access_token=%@&email=%@"
     @"&firstname=%@&lastname=%@&location=%@");
NSString* const BCRequestParamsResetPassword = @"email=%@";
NSString* const BCRequestParamsRegister
  = (@"username=%@&password=%@&email=%@&firstname=%@&lastname=%@&location=%@"
     @"&birthdate=%f&preferences=%@");
NSString* const BCRequestParamsCheckMessage = @"user_token=%@&timestamp=%d";

@implementation BCServerRequest

#pragma mark - Method implementation

+ (void) loginWithUsername: (NSString*)         username
                  password: (NSString*)         password
                completion: (BCLoginCompletion) completion
{
  if (username.length == 0 || password.length == 0)
  {
    if (completion != nil)
    {
      completion(nil, BCRequestResultNotImplemented);
    }
  }
  else
  {
    /* Run the request to background thread */
    dispatch_queue_t globalQueue
      = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^(void)
    {
      NSString* bodyString = [NSString stringWithFormat:
                              BCRequestParamsLogin, username, password];
      
      NSData* bodyData = [bodyString dataUsingEncoding: NSUTF8StringEncoding
                                  allowLossyConversion: NO];
      
      NSURL* loginURL = [NSURL URLWithString: kBCRequestURLLogin];
      NSURLRequestCachePolicy policy
        = NSURLRequestReloadIgnoringLocalCacheData;
      
      NSMutableURLRequest* request
        = [NSMutableURLRequest requestWithURL: loginURL
                                  cachePolicy: policy
                              timeoutInterval: kRequestTimeout];
      
      [request setHTTPMethod: @"POST"];
      [request setHTTPBody: bodyData];
      
      [request   setValue: [NSString stringWithFormat:
                            @"%lu", (unsigned long)bodyData.length]
       forHTTPHeaderField: @"Content-Length"];

      NSURLResponse* response = nil;
      NSError* urlError = nil;
      
      /* Send the request synchronously */
      NSData* data = [NSURLConnection sendSynchronousRequest: request
                                           returningResponse: &response
                                                       error: &urlError];
      if (urlError == nil)
      {
        if (completion != nil)
        {
          NSDictionary* dictionary
            = [NSJSONSerialization JSONObjectWithData: data
                                              options: kNilOptions
                                                error: nil];
          
          NSInteger status = [dictionary[BCRequestKeyStatus] intValue];
          NSString* token
            = dictionary[BCRequestKeyResponse][BCRequestKeyUserToken];
          
          /* Go back to the main queue */
          dispatch_async(dispatch_get_main_queue(), ^(void)
          {
            completion(token, (BCServerRequestResult)status);
          });
        }
        else
        {
          NSLog(@"Completion not found for %s", __PRETTY_FUNCTION__);
        }
      }
      else
      {
        NSLog(@"Request error for %s", __PRETTY_FUNCTION__);
        /* Go back to the main queue */
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
          completion(nil, BCRequestResultServerError);
        });
      }
    });
  }
}

+ (void) facebookLoginWithFbUser: (BCFBUser*)         user
                      completion: (BCLoginCompletion) completion
{
  if (![user isValid])
  {
    if (completion != nil)
    {
      completion(@"Please fill-up all fields", BCRequestResultNotImplemented);
    }
  }
  else
  {
    /* Run the request to background thread */
    dispatch_queue_t globalQueue
      = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^(void)
    {
      NSString* bodyString = [NSString stringWithFormat:
                              BCRequestParamsFacebookLogin,
                              user.userId,
                              user.accessToken,
                              user.email,
                              user.firstname,
                              user.lastname,
                              user.location];
      
      NSData* bodyData = [bodyString dataUsingEncoding: NSUTF8StringEncoding
                                  allowLossyConversion: NO];
      
      NSURL* loginURL = [NSURL URLWithString: kBCRequestURLFacebookLogin];
      
      NSURLRequestCachePolicy policy
        = NSURLRequestReloadIgnoringLocalCacheData;
      NSMutableURLRequest* request
        = [NSMutableURLRequest requestWithURL: loginURL
                                  cachePolicy: policy
                              timeoutInterval: kRequestTimeout];
      
      [request setHTTPMethod: @"POST"];
      [request setHTTPBody: bodyData];
      
      [request   setValue: [NSString stringWithFormat:
                            @"%lu", (unsigned long)bodyData.length]
       forHTTPHeaderField: @"Content-Length"];
      
      NSURLResponse* response = nil;
      NSError* urlError = nil;
      
      /* Send the request synchronously */
      NSData* data = [NSURLConnection sendSynchronousRequest: request
                                           returningResponse: &response
                                                       error: &urlError];
      if (urlError == nil)
      {
        if (completion != nil)
        {
          NSDictionary* dictionary
            = [NSJSONSerialization JSONObjectWithData: data
                                              options: kNilOptions
                                                error: nil];
          
          NSInteger status = [dictionary[BCRequestKeyStatus] intValue];
          NSString* token
            = dictionary[BCRequestKeyResponse][BCRequestKeyUserToken];
          
          /* Go back to the main queue */
          dispatch_async(dispatch_get_main_queue(), ^(void)
          {
            completion(token, (BCServerRequestResult)status);
          });
        }
        else
        {
          NSLog(@"Completion not found for %s", __PRETTY_FUNCTION__);
        }
      }
      else
      {
        NSLog(@"Request error for %s", __PRETTY_FUNCTION__);
        /* Go back to the main queue */
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
          completion(@"No internet connection.", BCRequestResultServerError);
        });
      }
    });
  }
}

+ (void) resetPasswordWithUsername: (NSString*)                 username
                        completion: (BCResetPasswordCompletion) completion
{
  if (username.length == 0)
  {
    if (completion != nil)
    {
      completion(BCRequestResultNotImplemented);
    }
  }
  else
  {
    /* Run the request to background thread */
    dispatch_queue_t globalQueue
      = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^(void)
    {
      NSString* bodyString = [NSString stringWithFormat:
                              BCRequestParamsResetPassword, username];
      NSData* bodyData = [bodyString dataUsingEncoding: NSUTF8StringEncoding
                                  allowLossyConversion: NO];
      NSURL* resetURL = [NSURL URLWithString: kBCRequestURLResetPassword];
      
      NSURLRequestCachePolicy policy
        = NSURLRequestReloadIgnoringLocalCacheData;
      NSMutableURLRequest* request
        = [NSMutableURLRequest requestWithURL: resetURL
                                  cachePolicy: policy
                              timeoutInterval: kRequestTimeout];
      
      [request setHTTPMethod: @"POST"];
      [request setHTTPBody: bodyData];
      
      [request   setValue: [NSString stringWithFormat:
                            @"%lu", (unsigned long)bodyData.length]
       forHTTPHeaderField: @"Content-Length"];
      
      NSURLResponse* response = nil;
      NSError* urlError = nil;

      /* Send the request synchronously */
      NSData* data = [NSURLConnection sendSynchronousRequest: request
                                           returningResponse: &response
                                                       error: &urlError];
      if (urlError == nil)
      {
        if (completion != nil)
        {
          NSDictionary* dictionary
            = [NSJSONSerialization JSONObjectWithData: data
                                              options: kNilOptions
                                                error: nil];
          
          NSInteger status = [dictionary[BCRequestKeyStatus] intValue];
          
          /* Go back to the main queue */
          dispatch_async(dispatch_get_main_queue(), ^(void)
          {
            completion((BCServerRequestResult)status);
          });
        }
        else
        {
          NSLog(@"Completion not found for %s", __PRETTY_FUNCTION__);
        }
      }
      else
      {
        NSLog(@"Request error for %s", __PRETTY_FUNCTION__);
        /* Go back to the main queue */
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
          completion(BCRequestResultServerError);
        });
      }
    });
  }
}

+ (void) registerWithUser: (BCUser*)              user
               completion: (BCRegisterCompletion) completion
{
  if (![user isValid])
  {
    if (completion != nil)
    {
      completion(@"Please fill-up all fields",
                 BCRequestResultNotImplemented);
    }
  }
  else
  {
    /* Run the request to background thread */
    dispatch_queue_t globalQueue
      = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^(void)
    {
      NSString* bodyString = [NSString stringWithFormat:
                              BCRequestParamsRegister,
                              user.username,
                              user.password,
                              user.email,
                              user.firstname,
                              user.lastname,
                              user.location,
                              user.birthday,
                              user.musicPreferences];
      
      NSData* bodyData = [bodyString dataUsingEncoding: NSUTF8StringEncoding
                                  allowLossyConversion: NO];
      
      NSURL* registrationURL = [NSURL URLWithString: kBCRequestURLRegistration];
      
      NSURLRequestCachePolicy policy
        = NSURLRequestReloadIgnoringLocalCacheData;
      NSMutableURLRequest* request
        = [NSMutableURLRequest requestWithURL: registrationURL
                                  cachePolicy: policy
                              timeoutInterval: kRequestTimeout];
      
      [request setHTTPMethod: @"POST"];
      [request setHTTPBody: bodyData];
      
      [request   setValue: [NSString stringWithFormat:
                            @"%lu", (unsigned long)bodyData.length]
       forHTTPHeaderField: @"Content-Length"];
      
      NSURLResponse* response = nil;
      NSError* urlError = nil;
      
      /* Send the request synchronously */
      NSData* data = [NSURLConnection sendSynchronousRequest: request
                                           returningResponse: &response
                                                       error: &urlError];
      if (urlError == nil)
      {
        if (completion != nil)
        {
          NSDictionary* dictionary
            = [NSJSONSerialization JSONObjectWithData: data
                                              options: kNilOptions
                                                error: nil];
          
          NSInteger status = [dictionary[BCRequestKeyStatus] intValue];
          NSString* response
            = dictionary[BCRequestKeyResponse][BCRequestKeyMessage];
          
          /* Go back to the main queue */
          dispatch_async(dispatch_get_main_queue(), ^(void)
          {
            completion(response, (BCServerRequestResult)status);
          });
        }
        else
        {
          NSLog(@"Completion not found for %s", __PRETTY_FUNCTION__);
        }
      }
      else
      {
        NSLog(@"Request error for %s", __PRETTY_FUNCTION__);
        /* Go back to the main queue */
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
          completion(@"No internet connection.", BCRequestResultServerError);
        });
      }
    });
  }
}

+ (void) messageCheckWithUserToken: (NSString*)                token
                         timestamp: (NSInteger)                timestamp
                        completion: (BCCheckMessageCompletion) completion
{
  if (token.length == 0)
  {
    if (completion != nil)
    {
      completion(nil, BCRequestResultNotImplemented);
    }
  }
  else
  {
    /* Run the request to background thread */
    dispatch_queue_t globalQueue
      = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^(void)
    {
      NSString* bodyString = [NSString stringWithFormat:
                              BCRequestParamsCheckMessage, token, timestamp];
      NSLog(@"%@", bodyString);
      NSData* bodyData = [bodyString dataUsingEncoding: NSUTF8StringEncoding
                                  allowLossyConversion: NO];
     
      NSURL* loginURL = [NSURL URLWithString: kBCRequestURLCheckMessage];
      NSURLRequestCachePolicy policy
        = NSURLRequestReloadIgnoringLocalCacheData;
     
      NSMutableURLRequest* request
        = [NSMutableURLRequest requestWithURL: loginURL
                                  cachePolicy: policy
                              timeoutInterval: kRequestTimeout];
     
      [request setHTTPMethod: @"POST"];
      [request setHTTPBody: bodyData];
     
      [request   setValue: [NSString stringWithFormat:
                            @"%lu", (unsigned long)bodyData.length]
       forHTTPHeaderField: @"Content-Length"];
     
      NSURLResponse* response = nil;
      NSError* urlError = nil;
     
      /* Send the request synchronously */
      NSData* data = [NSURLConnection sendSynchronousRequest: request
                                           returningResponse: &response
                                                       error: &urlError];
      if (urlError == nil)
      {
        if (completion != nil)
        {
          NSDictionary* dictionary
            = [NSJSONSerialization JSONObjectWithData: data
                                              options: kNilOptions
                                                error: nil];
         
          NSInteger status = [dictionary[BCRequestKeyStatus] intValue];
          NSArray* messages = dictionary[BCRequestKeyResponse];
          
          /* Go back to the main queue */
          dispatch_async(dispatch_get_main_queue(), ^(void)
          {
            completion(messages, (BCServerRequestResult)status);
          });
        }
        else
        {
          NSLog(@"Completion not found for %s", __PRETTY_FUNCTION__);
        }
      }
      else
      {
        NSLog(@"Request error for %s", __PRETTY_FUNCTION__);
        /* Go back to the main queue */
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
          completion(nil, BCRequestResultServerError);
        });
      }
    });
  }
}

@end
