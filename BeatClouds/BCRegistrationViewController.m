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
NSInteger const kBirthdayTag = 9996;
NSInteger const kCountryTag = 9995;

@interface BCRegistrationViewController ()
  <UITableViewDataSource,
   UITableViewDelegate,
   UITextFieldDelegate,
   UIPickerViewDataSource,
   UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* cancelBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* doneBarButton;

@property (strong, nonatomic) UIDatePicker* datePicker;
@property (strong, nonatomic) UIToolbar* datePickerToolbar;
@property (strong, nonatomic) UIPickerView* countryPickerView;

@property (strong, nonatomic) NSArray* sectionHeaders;
@property (strong, nonatomic) NSArray* userInformationPlaceholders;
@property (strong, nonatomic) NSArray* musicPreferences;
@property (strong, nonatomic) NSMutableArray* userMusicPreferences;
@property (strong, nonatomic) NSArray* countries;

@property (nonatomic, assign) double birthdayTimestamp;
@property (nonatomic, copy) NSString* country;

@end

@implementation BCRegistrationViewController

#pragma mark - Synthesize properties

@synthesize userInformationPlaceholders = m_userInformationPlaceholders;
@synthesize musicPreferences = m_musicPreferences;
@synthesize userMusicPreferences = m_userMusicPreferences;
@synthesize countries = m_countries;
@synthesize sectionHeaders = m_sectionHeaders;
@synthesize datePicker = m_datePicker;
@synthesize datePickerToolbar = m_datePickerToolbar;
@synthesize countryPickerView = m_countryPickerView;

#pragma mark - Memory management

- (void) dealloc
{
  self.datePicker = nil;
  self.datePickerToolbar = nil;
  self.countryPickerView = nil;
  
  self.sectionHeaders = nil;
  self.userInformationPlaceholders = nil;
  self.musicPreferences = nil;
  self.userMusicPreferences = nil;
  self.countries = nil;
}

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
                                     @"Birthday",
                                     @"Country", nil];
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

- (NSMutableArray*) userMusicPreferences
{
  if (m_userMusicPreferences == nil)
  {
    m_userMusicPreferences = [NSMutableArray new];
  }
  return m_userMusicPreferences;
}

- (NSArray*) countries
{
  if (m_countries == nil)
  {
    NSLocale* locale = [NSLocale currentLocale];
    NSArray* countryArray = [NSLocale ISOCountryCodes];
    
    NSMutableDictionary* sortedCountryDic = [[NSMutableDictionary alloc] init];
    
    for (NSString* countryCode in countryArray)
    {
      NSString* displayNameString
        = [locale displayNameForKey: NSLocaleCountryCode
                              value: countryCode];
      [sortedCountryDic setObject: countryCode
                           forKey: displayNameString];
    }

    m_countries = [[sortedCountryDic allKeys] sortedArrayUsingSelector:
                   @selector(localizedCompare:)];
  }
  return m_countries;
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

- (UIDatePicker*) datePicker
{
  if (m_datePicker == nil)
  {
    m_datePicker = [UIDatePicker new];
    m_datePicker.datePickerMode = UIDatePickerModeDate;
    
    NSDate* now = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* nowWithoutSecondsComponents
      = [calendar components: (  NSCalendarUnitEra
                               | NSCalendarUnitYear
                               | NSCalendarUnitMonth
                               | NSCalendarUnitDay)
                    fromDate: now];
    
    NSDate* dateNow = [calendar dateFromComponents:
                       nowWithoutSecondsComponents];
    m_datePicker.maximumDate = dateNow;
    
    [m_datePicker addTarget: self
                     action: @selector(datePickerDidChangeValue:)
           forControlEvents: UIControlEventValueChanged];
  }
  return m_datePicker;
}

- (UIToolbar*) datePickerToolbar
{
  if (m_datePickerToolbar == nil)
  {
    m_datePickerToolbar = [UIToolbar new];
    m_datePickerToolbar.frame
      = CGRectMake(0, 0, self.view.bounds.size.width, 44);
    
    UIBarButtonItem* extraSpace
      = [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                              target: nil
                              action: nil];
    UIBarButtonItem* doneButton
      = [[UIBarButtonItem alloc]
         initWithTitle: @"Done"
                 style: UIBarButtonItemStyleDone
                target: self
                action: @selector(dismissPicker:)];
    
    m_datePickerToolbar.items = [NSArray arrayWithObjects:
                                 extraSpace, doneButton, nil];
  }
  return m_datePickerToolbar;
}

- (UIPickerView*) countryPickerView
{
  if (m_countryPickerView == nil)
  {
    m_countryPickerView = [UIPickerView new];
    m_countryPickerView.dataSource = self;
    m_countryPickerView.delegate = self;
  }
  return m_countryPickerView;
}

#pragma mark - Methods

-(void) dismissPicker: (id) sender
{
  [self datePickerDidChangeValue: self.datePicker];
  
  NSIndexPath* indexPath
    = [NSIndexPath indexPathForRow: self.userInformationPlaceholders.count - 2
                         inSection: RegistrationRowUserInformation];
  UITableViewCell* cell = [self.tableView cellForRowAtIndexPath: indexPath];
  UITextField* textField = (UITextField*)[cell viewWithTag: kBirthdayTag];
  [textField resignFirstResponder];
}

- (void) datePickerDidChangeValue: (id) sender
{
  NSDate* selectedDate = self.datePicker.date;
  
  NSDateFormatter* formatter = [NSDateFormatter new];
  [formatter setDateFormat: @"E d MMM yyyy"];
  
  NSIndexPath* indexPath
    = [NSIndexPath indexPathForRow: self.userInformationPlaceholders.count - 2
                         inSection: RegistrationRowUserInformation];
  UITableViewCell* cell = [self.tableView cellForRowAtIndexPath: indexPath];
  UITextField* textField = (UITextField*)[cell viewWithTag: kBirthdayTag];
  textField.text = [formatter stringFromDate: selectedDate];
  
  NSTimeInterval timestamp = [selectedDate timeIntervalSince1970];
  self.birthdayTimestamp = timestamp;
}

- (void) changeDateFromLabel: (id) sender
{
  NSInteger row =[self.countryPickerView selectedRowInComponent: 0];
  NSString* country = self.countries[row];
  
  NSIndexPath* indexPath
    = [NSIndexPath indexPathForRow: self.userInformationPlaceholders.count - 1
                         inSection: RegistrationRowUserInformation];
  UITableViewCell* cell = [self.tableView cellForRowAtIndexPath: indexPath];
  UITextField* textField = (UITextField*)[cell viewWithTag: kCountryTag];
  textField.text = country;
  self.country = country;
  
  [textField resignFirstResponder];
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
    if (indexPath.row == self.userInformationPlaceholders.count - 2)
    {
      cell = [tableView dequeueReusableCellWithIdentifier: @"BirthdayCell"];
      
      UITextField* textField = (UITextField*)[cell viewWithTag: kBirthdayTag];
      textField.inputView = self.datePicker;
      textField.inputAccessoryView = self.datePickerToolbar;
      [[textField valueForKey: @"textInputTraits"] setValue:
       [UIColor clearColor] forKey: @"insertionPointColor"];
    }
    else if (indexPath.row == self.userInformationPlaceholders.count - 1)
    {
      cell = [tableView dequeueReusableCellWithIdentifier: @"CountryCell"];
      
      UITextField* textField = (UITextField*)[cell viewWithTag: kCountryTag];
      textField.inputView = self.countryPickerView;
      [[textField valueForKey: @"textInputTraits"] setValue:
       [UIColor clearColor] forKey: @"insertionPointColor"];
    }
    else
    {
      cell = [tableView dequeueReusableCellWithIdentifier: @"TextfieldCell"];
      
      UITextField* textField = (UITextField*)[cell viewWithTag: kTextfieldTag];
      textField.delegate = self;
      textField.placeholder = self.userInformationPlaceholders[indexPath.row];
      
      if (indexPath.row == 1)
      {
        textField.secureTextEntry = YES;
      }
    }
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
  else if (section == RegistrationRowMusicPreferences)
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
  
  if (section == RegistrationRowUserInformation)
  {
    view.backgroundColor = [UIColor colorWithRed: 236 / 256.0f
                                           green: 136 / 256.0f
                                            blue: 060 / 256.0f
                                           alpha: 1];
  }
  
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
    
    int actualRow = (int)indexPath.row + 1;
    
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
      label.textColor = [UIColor blackColor];
      
      [self.userMusicPreferences addObject:
       [NSNumber numberWithInt: actualRow]];
    }
    else
    {
      cell.accessoryType = UITableViewCellAccessoryNone;
      label.textColor = [UIColor lightGrayColor];
      
      [self.userMusicPreferences removeObject:
       [NSNumber numberWithInt: actualRow]];
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
  self.activityIndicator.hidden = NO;
  self.cancelBarButton.enabled = NO;
  self.doneBarButton.enabled = NO;
  
  [self.tableView scrollRectToVisible: CGRectMake(0, 0, 1, 1)
                             animated: NO];
  self.tableView.userInteractionEnabled = NO;
  
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
  
  NSString* userMusicPreferences = @"";
  if (self.userMusicPreferences != nil)
  {
    for (id item in self.userMusicPreferences)
    {
      if ([item isKindOfClass: NSNumber.class])
      {
        NSNumber* number = (NSNumber*)item;
        userMusicPreferences = [userMusicPreferences stringByAppendingFormat:
                                @"%@,", [number stringValue]];
      }
    }
    if (userMusicPreferences.length > 0)
    {
      /* Truncate the last character */
      userMusicPreferences = [userMusicPreferences substringToIndex:
                              userMusicPreferences.length - 1];
    }
  }
  
  BCUser* user = [BCUser new];
  user.username = username;
  user.password = password;
  user.email = emailAddress;
  user.firstname = firstname;
  user.lastname = lastname;
  user.location = self.country;
  user.birthday = self.birthdayTimestamp;
  user.musicPreferences = userMusicPreferences;
  
  [BCServerRequest registerWithUser: user
                         completion: ^(NSString*             serverResponse,
                                       BCServerRequestResult result)
   {
     if (result == BCRequestResultOK)
     {
       [self dismissViewControllerAnimated: YES
                                completion: nil];
     }
     else
     {
       NSString* response = @"Unable to register";
       if (serverResponse != nil && serverResponse.length > 0)
       {
         response = serverResponse;
       }
       
       [[[UIAlertView alloc] initWithTitle: @"BeatClouds"
                                   message: response
                                  delegate: nil
                         cancelButtonTitle: nil
                         otherButtonTitles: @"Try again", nil] show];
     }
     self.tableView.userInteractionEnabled = YES;
     self.activityIndicator.hidden = YES;
     self.cancelBarButton.enabled = YES;
     self.doneBarButton.enabled = YES;
   }];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView*) pickerView
{
  return 1;
}

- (NSInteger) pickerView: (UIPickerView*) pickerView
 numberOfRowsInComponent: (NSInteger)     component;
{
  return self.countries.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString*) pickerView: (UIPickerView*) pickerView
             titleForRow: (NSInteger)     row
            forComponent: (NSInteger)     component
{
  return [self.countries objectAtIndex: row];
}

- (void) pickerView: (UIPickerView*) pickerView
       didSelectRow: (NSInteger)     row
        inComponent: (NSInteger)     component
{
  [self changeDateFromLabel: self.countryPickerView];
}
- (IBAction) didSelectCancelButton: (UIBarButtonItem*) sender
{
  [self dismissViewControllerAnimated: YES
                           completion: nil];
}

@end
