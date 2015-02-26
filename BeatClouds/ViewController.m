//
//  ViewController.m
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 1/23/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import "ViewController.h"
#import <FacebookSDK/FacebookSDK.h>

#import "BCLoginViewController.h"
#import "BCWebViewController.h"

#define kLoginIdentifier NSStringFromClass([BCLoginViewController class])
#define kWebviewIdentifier NSStringFromClass([BCWebViewController class])

NSString* const kStoryboard = @"Main";

@interface ViewController () <BCLoginViewDelegate>

@property (nonatomic, assign) BOOL firstTime;

@end

@implementation ViewController

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  self.firstTime = YES;
}

- (void) viewDidAppear: (BOOL) animated
{
  [super viewDidAppear: animated];
  
  if (self.firstTime)
  {
    self.firstTime = NO;
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: kStoryboard
                                                         bundle: nil];
    UIViewController* loginViewController
      = [storyboard instantiateViewControllerWithIdentifier: kLoginIdentifier];
    if ([loginViewController isKindOfClass: [BCLoginViewController class]])
    {
      ((BCLoginViewController*) loginViewController).delegate = self;
    }
    
    [self presentViewController: loginViewController
                       animated: NO
                     completion: nil];
  }
}

#pragma mark - BCLoginViewDelegate

- (void) loginViewControllerDidLogin: (BCLoginViewController*) controller
{
  UIStoryboard* storyboard = [UIStoryboard storyboardWithName: kStoryboard
                                                       bundle: nil];
  UIViewController* webViewController
    = [storyboard instantiateViewControllerWithIdentifier: kWebviewIdentifier];
  webViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [controller presentViewController: webViewController
                           animated: YES
                         completion: nil];
}

- (void) loginViewController: (BCLoginViewController*) controller
            didFetchUserInfo: (id<FBGraphUser>)        user
{
  /* TODO: Implement me */
}

- (void) loginViewControllerDidLogout: (BCLoginViewController*) controller
{
  /* TODO: Implement me */
}

- (void) loginViewController: (BCLoginViewController*) controller
                didShowError: (NSError*)               error
{
  /* TODO: Implement me */
}

@end
