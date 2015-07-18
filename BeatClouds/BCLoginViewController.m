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
CGFloat const kAnimateDuration = 0.35f;

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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* logoTopSpace;
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
  
  [self.logoImageView setNeedsUpdateConstraints];
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
    [[self view] endEditing: YES];
    [UIView animateWithDuration: kAnimateDuration
                     animations: ^(void)
     {
       [self enableLoader];
     }
                     completion: ^(BOOL isFinished)
     {
       self.activityIndicator.hidden = NO;
     }];
    
    BCFBUser* fbUser = [BCFBUser new];
    [[FBRequest requestForMe]
     startWithCompletionHandler: ^(FBRequestConnection* connection,
                                   FBGraphObject*       result,
                                   NSError*             error)
    {
      if (result && !error)
      {
        fbUser.userId = result[@"id"];
        fbUser.accessToken = [NSString stringWithFormat: @"%@",
                              [FBSession activeSession].accessTokenData];
        fbUser.email = result[@"email"];
        fbUser.firstname = result[@"first_name"];
        fbUser.lastname = result[@"last_name"];
        fbUser.location = result[@"locale"];
        
        [BCServerRequest
         facebookLoginWithFbUser: fbUser
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
             [UIView animateWithDuration: kAnimateDuration
                              animations: ^(void)
              {
                /* Show error to the user */
                self.invalidCredentialsLabel.hidden = NO;
                [self disableLoader];
              }
                              completion: ^(BOOL isFinished)
              {
                self.activityIndicator.hidden = YES;
              }];
           }
           
           [self.delegate loginViewController: self
                             didFetchUserInfo: user];
         }];
      }
      else
      {
        NSLog(@"Error in processing facebook login");
      }
    }];
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

- (void) enableLoader
{
  self.loginTableView.alpha = 0.0f;
  self.loginButton.alpha = 0.0f;
  self.forgotPasswordButton.alpha = 0.0f;
  self.signupButton.alpha = 0.0f;
  self.fbLoginView.alpha = 0.0f;
  
  self.invalidCredentialsLabel.hidden = YES;
  
  self.logoTopSpace.constant = 164.0f;
  [self.logoImageView layoutIfNeeded];
}

- (void) disableLoader
{
  self.loginTableView.alpha = 1.0f;
  self.loginButton.alpha = 1.0f;
  self.forgotPasswordButton.alpha = 1.0f;
  self.signupButton.alpha = 1.0f;
  self.fbLoginView.alpha = 1.0f;
  
  self.logoTopSpace.constant = kDefaultLogoTopSpace;
  [self.logoImageView layoutIfNeeded];
}

- (void) prepareForDismiss
{
  [self disableLoader];
  self.activityIndicator.hidden = YES;
}

- (IBAction) onLoginButtonHit: (id) sender
{
  [[self view] endEditing: YES];
  [UIView animateWithDuration: kAnimateDuration
                   animations: ^(void)
   {
     [self enableLoader];
   }
                   completion: ^(BOOL isFinished)
   {
     self.activityIndicator.hidden = NO;
   }];
  
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
       [UIView animateWithDuration: kAnimateDuration
                        animations: ^(void)
        {
          /* Show error to the user */
          self.invalidCredentialsLabel.hidden = NO;
          [self disableLoader];
        }
                        completion: ^(BOOL isFinished)
        {
          self.activityIndicator.hidden = YES;
        }];
     }
   }];
}

- (void) touchesBegan: (NSSet*)   touches
            withEvent: (UIEvent*) event
{
  [[self view] endEditing: YES];
}

@end
