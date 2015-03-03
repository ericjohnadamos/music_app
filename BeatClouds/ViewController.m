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

@property (nonatomic, strong) BCLoginViewController* loginViewController;
@end

@implementation ViewController

#pragma mark - Synthesize

@synthesize loginViewController = m_loginViewController;
#pragma mark - Properties

- (BCLoginViewController*) loginViewController
{
  if (m_loginViewController == nil)
  {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: kStoryboard
                                                         bundle: nil];
    UIViewController* loginViewController
      = [storyboard instantiateViewControllerWithIdentifier: kLoginIdentifier];
    loginViewController.modalTransitionStyle
      = UIModalTransitionStyleCrossDissolve;
    
    if ([loginViewController isKindOfClass: [BCLoginViewController class]])
    {
      ((BCLoginViewController*) loginViewController).delegate = self;
      
    }
    m_loginViewController = (BCLoginViewController*)loginViewController;
  }
  return m_loginViewController;
}

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
    
    [self presentViewController: self.loginViewController
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
