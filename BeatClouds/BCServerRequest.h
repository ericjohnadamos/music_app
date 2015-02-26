//
//  BCServerRequest.h
//  BeatClouds
//
//  Created by Eric John Adamos on 2/21/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCServerRequest : NSObject

/**
 * Create request for login running in background thread
 */
+ (void) requestLoginWithUsername: (NSString*)        username
                         password: (NSString*)        password
                         callback: (void(^)(NSData*)) callback;
/**
 * Create request for reset password running in background thread
 */
+ (void) requestResetWithUsername: (NSString*)        username
                         callback: (void(^)(NSData*)) callback;
/**
 * Create request for registration running in background thread
 */
+ (void) requestRegistrationWithUsername: (NSString*)        username
                                password: (NSString*)        password
                                   email: (NSString*)        email
                               firstname: (NSString*)        firstname
                                lastname: (NSString*)        lastname
                                location: (NSString*)        location
                                callback: (void(^)(NSData*)) callback;

@end
