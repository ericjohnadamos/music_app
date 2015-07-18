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
#import "UserSettings.h"

#define kLoginIdentifier NSStringFromClass([BCLoginViewController class])
#define kWebviewIdentifier NSStringFromClass([BCWebViewController class])

NSString* const kStoryboard = @"Main";

@interface ViewController () <BCLoginViewDelegate, BCWebViewDelegate>

@property (nonatomic, assign) BOOL firstTime;

@property (nonatomic, strong) BCLoginViewController* loginViewController;
@property (nonatomic, strong) BCWebViewController* webViewController;

@end

@implementation ViewController

#pragma mark - Synthesize

@synthesize loginViewController = m_loginViewController;
@synthesize webViewController = m_webViewController;

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

- (BCWebViewController*) webViewController
{
  if (m_webViewController == nil)
  {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: kStoryboard
                                                         bundle: nil];
    UIViewController* viewController
      = [storyboard instantiateViewControllerWithIdentifier:
         kWebviewIdentifier];
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if ([viewController isKindOfClass: BCWebViewController.class])
    {
      BCWebViewController* webViewController
        = (BCWebViewController*) viewController;
      webViewController.delegate = self;
    }
    m_webViewController = (BCWebViewController*) viewController;
  }
  return m_webViewController;
}

#pragma mark - Lifecycle

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
    
    if (![self.loginViewController isBeingPresented])
    {
      [self presentViewController: self.loginViewController
                         animated: NO
                       completion: ^(void)
       {
         UserSettings* userSettings = [UserSettings sharedInstance];
         if (userSettings.token.length > 0)
         {
           NSLog(@"Token: %@", userSettings.token);
           [self.webViewController initWebView];
           
           [UIView animateWithDuration: 0.3f
                            animations: ^(void)
            {
              [self.loginViewController enableLoader];
            }
                            completion: ^(BOOL isFinished)
            {
              self.loginViewController.activityIndicator.hidden = NO;
            }];
         }
       }];
    }
  }
}

#pragma mark - BCLoginViewDelegate

- (void) loginViewControllerDidLogin: (BCLoginViewController*) controller
{
  [self.webViewController initWebView];
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

#pragma mark - BCWebViewDelegate

- (void) webViewControllerDidFinishPostLoad: (BCWebViewController*) controller
{
  if (![self.webViewController isBeingPresented])
  {
    [self.loginViewController presentViewController: self.webViewController
                                           animated: YES
                                         completion: ^(void)
     {
       [self.loginViewController prepareForDismiss];
     }];
  }
}

@end
