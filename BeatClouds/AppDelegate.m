//
//  AppDelegate.m
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 1/23/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)          application: (UIApplication*) application
didFinishLaunchingWithOptions: (NSDictionary*) launchOptions
{
  [FBLoginView class];
  [FBProfilePictureView class];
  
  return YES;
}

- (void) applicationWillResignActive: (UIApplication*) application
{
  /* TODO */
}

- (void) applicationDidEnterBackground: (UIApplication*) application
{
  /* TODO */
}

- (void) applicationWillEnterForeground: (UIApplication*) application
{
  /* TODO */
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
