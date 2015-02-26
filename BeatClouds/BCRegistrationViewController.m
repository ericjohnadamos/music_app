//
//  BCRegistrationViewController.m
//  BeatClouds
//
//  Created by Eric John Adamos on 2/20/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import "BCRegistrationViewController.h"
#import "BCServerRequest.h"

typedef NS_ENUM(NSInteger, RegistrationRow)
{
  RegistrationRowUserInformation,
  RegistrationRowMusicPreferences,
};

NSInteger const kTextfieldTag = 9999;
NSInteger const kLabelTag = 9998;
NSInteger const kDoneTag = 9997;

@interface BCRegistrationViewController ()
  <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (strong, nonatomic) NSArray* sectionHeaders;
@property (strong, nonatomic) NSArray* userInformationPlaceholders;
@property (strong, nonatomic) NSArray* musicPreferences;

@end

@implementation BCRegistrationViewController

#pragma mark - Synthesize properties

@synthesize userInformationPlaceholders = m_userInformationPlaceholders;
@synthesize musicPreferences = m_musicPreferences;
@synthesize sectionHeaders = m_sectionHeaders;

#pragma mark - Lifecycle

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  
  self.activityIndicator.hidden = YES;
}

#pragma mark - Properties

- (NSArray*) userInformationPlaceholders
{
  if (m_userInformationPlaceholders == nil)
  {
    m_userInformationPlaceholders = [NSArray arrayWithObjects:
                                     @"Username",
                                     @"Password",
                                     @"Email Address",
                                     @"First name",
                                     @"Last name",
                                     @"Location", nil];
  }
  return m_userInformationPlaceholders;
}

- (NSArray*) musicPreferences
{
  if (m_musicPreferences == nil)
  {
    m_musicPreferences = [NSArray arrayWithObjects:
                          @"EDM",
                          @"House",
                          @"Deep house",
                          @"Progressive House",
                          @"Electronica",
                          @"Techno",
                          @"Tech House",
                          @"Minimal",
                          @"Trance",
                          @"Drum n Bass",
                          @"Beats",
                          @"Others",
                          nil];
  }
  return m_musicPreferences;
}

- (NSArray*) sectionHeaders
{
  if (m_sectionHeaders == nil)
  {
    m_sectionHeaders = [NSArray arrayWithObjects:
                          @"USER INFORMATION",
                          @"MUSIC PREFERENCES", nil];
  }
  return m_sectionHeaders;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger) tableView: (UITableView*) tableView
  numberOfRowsInSection: (NSInteger)    section
{
  if (section == RegistrationRowUserInformation)
  {
    return self.userInformationPlaceholders.count;
  }
  return self.musicPreferences.count;
}

- (UITableViewCell*) tableView: (UITableView*) tableView
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
  UITableViewCell* cell;
  
  if (indexPath.section == RegistrationRowUserInformation)
  {
    cell = [tableView dequeueReusableCellWithIdentifier: @"TextfieldCell"];
    
    UITextField* textField = (UITextField*)[cell viewWithTag: kTextfieldTag];
    textField.delegate = self;
    textField.placeholder = self.userInformationPlaceholders[indexPath.row];
  }
  else
  {
    cell = [tableView dequeueReusableCellWithIdentifier: @"PrefencesCell"];
    
    UILabel* label = (UILabel*)[cell viewWithTag: kLabelTag];
    label.text = self.musicPreferences[indexPath.row];
  }
  
  return cell;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
  return self.sectionHeaders.count;
}

- (NSString*) tableView: (UITableView*) tableView
titleForHeaderInSection: (NSInteger)    section
{
  return self.sectionHeaders[section];
}

#pragma mark - UITableViewDelegate methods

- (UIView*)  tableView: (UITableView*) tableView
viewForHeaderInSection: (NSInteger)    section
{
  UITableViewCell* cell;
  if (section == RegistrationRowUserInformation)
  {
    cell = [tableView dequeueReusableCellWithIdentifier:
            @"UserInfoHeaderView"];
  }
  else
  {
    cell = [tableView dequeueReusableCellWithIdentifier:
            @"MusicPreferencesHeaderView"];
  }
  return cell;
}

- (UIView*)  tableView: (UITableView*) tableView
viewForFooterInSection: (NSInteger)    section
{
  UIView* view = [UIView new];
  CGRect frame = tableView.bounds;
  frame.origin.y = 0.0f;
  frame.size.height = 20.0f;
  
  view.backgroundColor = [UIColor colorWithRed: 236/256.0f
                                         green: 136/256.0f
                                          blue: 60/256.0f
                                         alpha: 1];
  return view;
}

- (CGFloat)   tableView: (UITableView*) tableView
heightForHeaderInSection: (NSInteger) section
{
  return 20.0f;
}
- (CGFloat)    tableView: (UITableView*) tableView
heightForFooterInSection: (NSInteger)    section
{
  return 1.0f;
}

- (void)      tableView: (UITableView*) tableView
didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
  if (indexPath.section == RegistrationRowMusicPreferences)
  {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath: indexPath];
    UILabel* label = (UILabel*)[cell viewWithTag: kLabelTag];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
      label.textColor = [UIColor blackColor];
    }
    else
    {
      cell.accessoryType = UITableViewCellAccessoryNone;
      label.textColor = [UIColor lightGrayColor];
    }
  }
}

- (CGFloat)            tableView: (UITableView*) tableView
estimatedHeightForRowAtIndexPath: (NSIndexPath*) indexPath
{
  return 44.0f;
}

- (CGFloat)   tableView: (UITableView*) tableView
heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
  return 44.0f;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
  [textField resignFirstResponder];
  
  return YES;
}

- (IBAction) onDoneButtonHit: (id) sender
{
  UITableViewCell* cell = nil;
  NSIndexPath* indexPath = nil;
  
  indexPath = [NSIndexPath indexPathForRow: 0
                                 inSection: RegistrationRowUserInformation];
  cell = [self.tableView cellForRowAtIndexPath: indexPath];
  UITextField* textField = (UITextField*)[cell viewWithTag: kTextfieldTag];
  NSString* username = textField.text;
  
  indexPath = [NSIndexPath indexPathForRow: 1
                                 inSection: RegistrationRowUserInformation];
  cell = [self.tableView cellForRowAtIndexPath: indexPath];
  textField = (UITextField*)[cell viewWithTag: kTextfieldTag];
  NSString* password = textField.text;
  
  indexPath = [NSIndexPath indexPathForRow: 2
                                 inSection: RegistrationRowUserInformation];
  cell = [self.tableView cellForRowAtIndexPath: indexPath];
  textField = (UITextField*)[cell viewWithTag: kTextfieldTag];
  NSString* emailAddress = textField.text;
  
  indexPath = [NSIndexPath indexPathForRow: 3
                                 inSection: RegistrationRowUserInformation];
  cell = [self.tableView cellForRowAtIndexPath: indexPath];
  textField = (UITextField*)[cell viewWithTag: kTextfieldTag];
  NSString* firstname = textField.text;
  
  indexPath = [NSIndexPath indexPathForRow: 4
                                 inSection: RegistrationRowUserInformation];
  cell = [self.tableView cellForRowAtIndexPath: indexPath];
  textField = (UITextField*)[cell viewWithTag: kTextfieldTag];
  NSString* lastname = textField.text;
  
  indexPath = [NSIndexPath indexPathForRow: 5
                                 inSection: RegistrationRowUserInformation];
  cell = [self.tableView cellForRowAtIndexPath: indexPath];
  textField = (UITextField*)[cell viewWithTag: kTextfieldTag];
  NSString* location = textField.text;
  
  
  self.activityIndicator.hidden = NO;
  [BCServerRequest requestRegistrationWithUsername: username
                                          password: password
                                             email: emailAddress
                                         firstname: firstname
                                          lastname: lastname
                                          location: location
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
         [self dismissViewControllerAnimated: YES
                                  completion: nil];
       }
     }
     else
     {
       [[[UIAlertView alloc] initWithTitle: @"BeatClouds"
                                   message: @"Fill in required fields"
                                  delegate: nil
                         cancelButtonTitle: nil
                         otherButtonTitles: @"Try again", nil] show];
     }
     self.activityIndicator.hidden = YES;
   }];
}

@end
