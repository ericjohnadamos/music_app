//
//  AppDelegate.m
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 1/23/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "BCServerRequest.h"
#import "UserSettings.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)          application: (UIApplication*) application
didFinishLaunchingWithOptions: (NSDictionary*) launchOptions
{
  [FBLoginView class];
  [FBProfilePictureView class];
  
  __block UIBackgroundTaskIdentifier backgrountTask;
  backgrountTask = [application beginBackgroundTaskWithExpirationHandler:
                    ^(void)
  {
    [application endBackgroundTask: backgrountTask];
    backgrountTask = UIBackgroundTaskInvalid;
  }];
  
  return YES;
}

- (void) applicationWillResignActive: (UIApplication*) application
{
  /* TODO */
  
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void) applicationDidEnterBackground: (UIApplication*) application
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^(void)
  {
    [self requestForIncomingMessages];
  });
}

- (void) requestForIncomingMessages
{
  NSString* userToken = [UserSettings sharedInstance].token;
  
  if (userToken != nil || userToken.length > 0)
  {
    NSTimeInterval timestamp = [[NSDate new] timeIntervalSince1970];
    [BCServerRequest
     messageCheckWithUserToken: userToken
                     timestamp: timestamp
                    completion: ^(NSArray*              messages,
                                  BCServerRequestResult result)
     {
       if (result == BCRequestResultOK)
       {
         if (messages != nil)
         {
           /* Get all messages and display as popup */
           for (NSDictionary* data in messages)
           {
             UILocalNotification* localNotification = [UILocalNotification new];
             if (localNotification == nil)
             {
               return;
             }
             localNotification.applicationIconBadgeNumber = 0;
             localNotification.alertBody = data[@"email"];
             localNotification.soundName = UILocalNotificationDefaultSoundName;
             localNotification.fireDate
                = [NSDate dateWithTimeIntervalSinceNow: 0];
             localNotification.timeZone = [NSTimeZone defaultTimeZone];
             
             [[UIApplication sharedApplication] scheduleLocalNotification:
              localNotification];
           }
         }
       }
     }];
  }
}

- (void) applicationWillEnterForeground: (UIApplication*) application
{
  /* TODO */
  
  NSLog(@"%s", __PRETTY_FUNCTION__);
  
  [application endBackgroundTask:UIBackgroundTaskInvalid];
}

- (void) applicationDidBecomeActive: (UIApplication*) application
{
  /* TODO */
}

- (void) applicationWillTerminate: (UIApplication*) application
{
  /* TODO */
}

- (BOOL) application: (UIApplication*) application
             openURL: (NSURL*)         url
   sourceApplication: (NSString*)      sourceApplication
          annotation: (id)             annotation
{
  return [FBAppCall handleOpenURL: url
                sourceApplication: sourceApplication];
}

@end
