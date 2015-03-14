//
//  BCServerRequest.h
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 2/21/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCUser.h"
#import "BCFBUser.h"

typedef NS_ENUM(NSInteger, BCServerRequestResult)
{
  BCRequestResultOK = 200,
  BCRequestResultBadRequest = 400,
  BCRequestResultUnauthorized = 401,
  BCRequestResultNotFound = 404,
  BCRequestResultServerError = 500,
  BCRequestResultNotImplemented = 501
};

typedef void (^BCLoginCompletion)(NSString*             token,
                                  BCServerRequestResult result);
typedef void (^BCResetPasswordCompletion)(BCServerRequestResult result);
typedef void (^BCRegisterCompletion)(NSString*             serverResponse,
                                     BCServerRequestResult result);
typedef void (^BCCheckMessageCompletion)(NSArray*              messages,
                                         BCServerRequestResult result);

@interface BCServerRequest : NSObject

extern NSString* const BCRequestKeyStatus;
extern NSString* const BCRequestKeyResponse;
extern NSString* const BCRequestKeyUserToken;
extern NSString* const BCRequestKeyMessage;

extern NSString* const BCRequestParamsLogin;
extern NSString* const BCRequestParamsResetPassword;
extern NSString* const BCRequestParamsRegister;
extern NSString* const BCRequestParamsCheckMessage;

/* Login to the server in background thread */
+ (void) loginWithUsername: (NSString*)         username
                  password: (NSString*)         password
                completion: (BCLoginCompletion) completion;

/* Login to the facebook server in background thread */
+ (void) facebookLoginWithFbUser: (BCFBUser*)         user
                      completion: (BCLoginCompletion) completion;

/* Request reset password in background thread */
+ (void) resetPasswordWithUsername: (NSString*)                 username
                        completion: (BCResetPasswordCompletion) completion;

/* Request registration in background thread */
+ (void) registerWithUser: (BCUser*)              user
               completion: (BCRegisterCompletion) completion;

/* Request check new messages given the user token and current timestamp UTC */
+ (void) messageCheckWithUserToken: (NSString*)                token
                         timestamp: (NSInteger)                timestamp
                        completion: (BCCheckMessageCompletion) completion;

@end
