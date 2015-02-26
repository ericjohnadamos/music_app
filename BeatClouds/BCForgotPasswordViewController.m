//
//  BCForgotPasswordViewController.m
//  BeatClouds
//
//  Created by Eric John Adamos on 2/17/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import "BCForgotPasswordViewController.h"
#import "BCServerRequest.h"

@interface BCForgotPasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField* usernameTextfield;
@property (weak, nonatomic) IBOutlet UIButton* submitButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;

@end

@implementation BCForgotPasswordViewController

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  self.usernameTextfield.delegate = self;
  
  self.activityIndicator.hidden = YES;
}

- (IBAction) onBackButtonHit: (id) sender
{
  [self dismissViewControllerAnimated: YES
                           completion: nil];
}

- (IBAction) onSubmitButtonHit: (id) sender
{
  NSString* value = self.usernameTextfield.text;
  if (value.length > 0)
  {
    self.usernameTextfield.enabled = NO;
    self.submitButton.enabled = NO;
    self.activityIndicator.hidden = NO;
    
    [BCServerRequest
     requestResetWithUsername: value
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
           self.usernameTextfield.enabled = YES;
           self.submitButton.enabled = YES;
           self.activityIndicator.hidden = YES;
           
           [self dismissViewControllerAnimated: YES
                                    completion: nil];
         }
         else
         {
           [[[UIAlertView alloc] initWithTitle: @"BeatClouds"
                                       message: @"Email address not found"
                                      delegate: nil
                             cancelButtonTitle: nil
                             otherButtonTitles: @"Try again", nil] show];
         }
       }
       
       self.usernameTextfield.enabled = YES;
       self.submitButton.enabled = YES;
       self.activityIndicator.hidden = YES;
     }];
  }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
  [textField resignFirstResponder];
  
  return YES;
}

@end
