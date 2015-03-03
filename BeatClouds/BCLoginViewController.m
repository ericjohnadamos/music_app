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

/* Cell identifiers */
NSString* const kUsernameCell = @"kUsernameCell";
NSString* const kPasswordCell = @"kPasswordCell";

/* Component tags */
NSInteger const kUsernameTextFieldTag = 9998;
NSInteger const kPasswordTextFieldTag = 9999;

CGFloat const kDefaultLogoTopSpace = 38.0f;

@interface BCLoginViewController ()
  <FBLoginViewDelegate,
   UITableViewDataSource,
   UITableViewDelegate,
   UITextFieldDelegate>

@property (nonatomic, assign) NSString* username;
@property (nonatomic, assign) NSString* password;

@property (weak, nonatomic) IBOutlet FBLoginView* fbLoginView;
@property (weak, nonatomic) IBOutlet UITableView* loginTableView;
@property (weak, nonatomic) IBOutlet UILabel* invalidCredentialsLabel;
@property (weak, nonatomic) IBOutlet UIButton* loginButton;
@property (weak, nonatomic) IBOutlet UIButton* forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton* signupButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* logoTopSpace;
@property (weak, nonatomic) IBOutlet UIImageView* logoImageView;

@end

@implementation BCLoginViewController

#pragma mark - View Lifecycle

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  /* Set the facebook properties */
  self.fbLoginView.delegate = self;
  self.fbLoginView.readPermissions = @[@"public_profile", @"email"];
  
  self.loginTableView.dataSource = self;
  self.loginTableView.delegate = self;
  
  /* hide the activity indicator */
  self.activityIndicator.hidden = YES;
}

#pragma mark - Properties

- (NSString*) username
{
  NSString* returnValue = @"";
  UITextField* textfield = (UITextField*)[self.view viewWithTag:
                                          kUsernameTextFieldTag];
  if (textfield != nil)
  {
    returnValue = textfield.text;
  }
  return returnValue;
}

- (NSString*) password
{
  NSString* returnValue = @"";
  UITextField* textfield = (UITextField*)[self.view viewWithTag:
                                          kPasswordTextFieldTag];
  if (textfield != nil)
  {
    returnValue = textfield.text;
  }
  return returnValue;
}

#pragma mark - Class methods

- (void) clearAllText
{
  UITextField* usernameTextField = (UITextField*)[self.view viewWithTag:
                                                  kUsernameTextFieldTag];
  UITextField* passwordTextField = (UITextField*)[self.view viewWithTag:
                                                  kPasswordTextFieldTag];
  usernameTextField.text = @"";
  passwordTextField.text = @"";
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

- (void) loginViewShowingLoggedOutUser: (FBLoginView*) loginView
{
  if (   self.delegate != nil
      && [self.delegate respondsToSelector:
          @selector(loginViewControllerDidLogout:)])
  {
    [self.delegate loginViewControllerDidLogout: self];
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
  /* Table contains username and password fields */
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
  self.activityIndicator.hidden = NO;
  self.invalidCredentialsLabel.hidden = YES;
  
  /* Communicate server to login */
  [BCServerRequest loginWithUsername: self.username
                            password: self.password
                          completion: ^(NSString*             token,
                                        BCServerRequestResult result)
   {
     if (result == BCRequestResultOK)
     {
       if (   self.delegate != nil
           && [self.delegate respondsToSelector:
               @selector(loginViewControllerDidLogin:)])
       {
         [[UserSettings sharedInstance] setToken: token];
         
         /* Begin to inform the delegate about the successful login */
         [self.delegate loginViewControllerDidLogin: self];
       }
       /* Clear username and password textfield */
       [self clearAllText];
     }
     else
     {
       /* Show error to the user */
       self.invalidCredentialsLabel.hidden = NO;
     }
     /* Close the throbber view */
     self.activityIndicator.hidden = YES;
   }];
}

- (void) touchesBegan: (NSSet*)   touches
            withEvent: (UIEvent*) event
{
  [[self view] endEditing: YES];
}

@end
