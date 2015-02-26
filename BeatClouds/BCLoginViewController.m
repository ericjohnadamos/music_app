//
//  BCLoginViewController.m
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 1/23/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import "BCLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "BCServerRequest.h"
#import "UserSettings.h"

typedef NS_ENUM(NSInteger, LoginRow)
{
  LoginRowUsername,
  LoginRowPassword,
};

NSString* const kUsernameCell = @"kUsernameCell";
NSString* const kPasswordCell = @"kPasswordCell";

NSInteger const kUsernameTextFieldTag = 9998;
NSInteger const kPasswordTextFieldTag = 9999;

@interface BCLoginViewController ()
  <FBLoginViewDelegate,
   UITableViewDataSource, UITableViewDelegate,
   UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet FBLoginView* fbLoginView;

@property (weak, nonatomic) IBOutlet UITableView* loginTableView;
@property (weak, nonatomic) IBOutlet UILabel* invalidCredentialsLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;

@end

@implementation BCLoginViewController

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  self.fbLoginView.delegate = self;
  self.fbLoginView.readPermissions = @[@"public_profile", @"email"];
  
  self.loginTableView.dataSource = self;
  self.loginTableView.delegate = self;
  
  self.activityIndicator.hidden = YES;
}
#pragma mark - FBLoginViewDelegate method

- (void) loginViewShowingLoggedInUser: (FBLoginView*) loginView
{
  if (   self.delegate != nil
      && [self.delegate respondsToSelector:
          @selector(loginViewControllerDidLogin:)])
  {
    [self.delegate loginViewControllerDidLogin: self];
  }
}

- (void) loginViewFetchedUserInfo: (FBLoginView*)    loginView
                             user: (id<FBGraphUser>) user
{
  if (   self.delegate != nil
      && [self.delegate respondsToSelector:
          @selector(loginViewController:didFetchUserInfo:)])
  {
    [self.delegate loginViewController: self
                      didFetchUserInfo: user];
  }
}

- (void) loginViewShowingLoggedOutUser: (FBLoginView*) loginView
{
  if (   self.delegate != nil
      && [self.delegate respondsToSelector:
          @selector(loginViewControllerDidLogout:)])
  {
    [self.delegate loginViewControllerDidLogout: self];
  }
}

- (void) loginView: (FBLoginView*) loginView
       handleError: (NSError*)     error
{
  if (   self.delegate != nil
      && [self.delegate respondsToSelector:
          @selector(loginViewController:didShowError:)])
  {
    [self.delegate loginViewController: self
                          didShowError: error];
  }
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger) tableView: (UITableView*) tableView
  numberOfRowsInSection: (NSInteger)    section
{
  return 2;
}

- (UITableViewCell*) tableView: (UITableView*) tableView
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
  UITableViewCell* cell = nil;
  if (indexPath.row == LoginRowUsername)
  {
    cell = [tableView dequeueReusableCellWithIdentifier: kUsernameCell];
  }
  else
  {
    cell = [tableView dequeueReusableCellWithIdentifier: kPasswordCell];
  }
  
  UIView* contentSubview = cell.contentView.subviews[0];
  if ([contentSubview isKindOfClass: [UITextField class]])
  {
    UITextField* textField = (UITextField*) contentSubview;
    textField.delegate = self;
  }
  return cell;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
  if (textField.tag == kUsernameTextFieldTag)
  {
    UIView* passwordTextField = [self.view viewWithTag: kPasswordTextFieldTag];
    if (   passwordTextField != nil
        && [passwordTextField isKindOfClass: [UITextField class]])
    {
      [passwordTextField becomeFirstResponder];
    }
  }
  else if (textField.tag == kPasswordTextFieldTag)
  {
    [textField resignFirstResponder];
  }
  
  return YES;
}

#pragma mark - Event handler

- (IBAction) onLoginButtonHit: (id) sender
{
  UIView* usernameView = [self.view viewWithTag: kUsernameTextFieldTag];
  UIView* passwordView = [self.view viewWithTag: kPasswordTextFieldTag];
  
  if (   [usernameView isKindOfClass: [UITextField class]]
      && [passwordView isKindOfClass: [UITextField class]])
  {
    self.activityIndicator.hidden = NO;
    self.invalidCredentialsLabel.hidden = YES;
    
    [BCServerRequest
     requestLoginWithUsername: ((UITextField*)usernameView).text
                     password: ((UITextField*)passwordView).text
                     callback: ^(NSData* data)
     {
       if (data != nil)
       {
         NSDictionary* dictionary
          = [NSJSONSerialization JSONObjectWithData: data
                                            options: kNilOptions
                                              error: nil];
         NSInteger status = [dictionary[@"status"] intValue];
         if (status == 200)
         {
           if (   self.delegate != nil
               && [self.delegate respondsToSelector:
                   @selector(loginViewControllerDidLogin:)])
           {
             NSString* token = dictionary[@"response"][@"user_token"];
             
             [[UserSettings sharedInstance] setToken: token];
             
             [self.delegate loginViewControllerDidLogin: self];
           }
           
           ((UITextField*)usernameView).text = @"";
           ((UITextField*)passwordView).text = @"";
         }
         else
         {
           self.invalidCredentialsLabel.hidden = NO;
         }
       }
       else
       {
         self.invalidCredentialsLabel.hidden = NO;
       }
       self.activityIndicator.hidden = YES;
     }];
  }
  else
  {
    self.invalidCredentialsLabel.hidden = NO;
  }
}

- (void) touchesBegan: (NSSet*)   touches
            withEvent: (UIEvent*) event
{
  [[self view] endEditing: YES];
}

@end
