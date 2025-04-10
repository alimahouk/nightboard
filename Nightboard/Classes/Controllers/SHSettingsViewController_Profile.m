//
//  SHSettingsViewController_Profile.m
//  Nightboard
//
//  Created by MachOSX on 2/11/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import "SHSettingsViewController_Profile.h"

#import "AFHTTPRequestOperationManager.h"
#import "AppDelegate.h"
#import "Constants.h"

@implementation SHSettingsViewController_Profile

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
        
        countries = [[NSMutableArray alloc] initWithObjects:@"…", nil];
        states = [[NSMutableArray alloc] initWithObjects:@"…",
                  @"Alabama",
                  @"Alaska",
                  @"Arizona",
                  @"Arkansas",
                  @"California",
                  @"Colorado",
                  @"Connecticut",
                  @"Delaware",
                  @"Florida",
                  @"Georgia",
                  @"Hawaii",
                  @"Idaho",
                  @"Illinois",
                  @"Indiana",
                  @"Iowa",
                  @"Kansas",
                  @"Kentucky",
                  @"Louisiana",
                  @"Maine",
                  @"Maryland",
                  @"Massachusetts",
                  @"Michigan",
                  @"Minnesota",
                  @"Mississippi",
                  @"Missouri",
                  @"Montana",
                  @"Nebraska",
                  @"Nevada",
                  @"New Hampshire",
                  @"New Jersey",
                  @"New Mexico",
                  @"New York",
                  @"North Carolina",
                  @"North Dakota",
                  @"Ohio",
                  @"Oklahoma",
                  @"Oregon",
                  @"Pennsylvania",
                  @"Rhode Island",
                  @"South Carolina",
                  @"South Dakota",
                  @"Tennessee",
                  @"Texas",
                  @"Utah",
                  @"Vermont",
                  @"Virginia",
                  @"Washington",
                  @"West Virgina",
                  @"Wisconsin",
                  @"Wyoming", nil];
        genders = [[NSMutableArray alloc] initWithObjects:@"Unspecified", @"Male", @"Female", nil];
        activeDataSource = [NSMutableArray array];
        
        shouldDismissKeyboard = YES;
        
        FMResultSet *s1 = [appDelegate.modelManager executeQuery:@"SELECT name FROM sh_country"
                                         withParameterDictionary:nil];
        
        while ( [s1 next] )
        {
            [countries addObject:[s1 stringForColumnIndex:0]];
        }
        
        [s1 close];
        [appDelegate.modelManager.results close];
        [appDelegate.modelManager.DB close];
    }
    
    return self;
}

- (void)loadView
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UIView *contentView = [[UIView alloc] initWithFrame:appDelegate.screenBounds];
    contentView.backgroundColor = [UIColor whiteColor];
    
    doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"GENERIC_SAVE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    doneButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    mainView = [[UIScrollView alloc] initWithFrame:appDelegate.screenBounds];
    mainView.contentSize = CGSizeMake(appDelegate.screenBounds.size.width, 700);
    mainView.delegate = self;
    mainView.tag = 0;
    
    int labelHeight = 20;
    int labelWidth_half = appDelegate.screenBounds.size.width / 2 - 20;
    int labelWidth_full = appDelegate.screenBounds.size.width - 40;
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, labelWidth_half, labelHeight)];
    nameLabel.text = NSLocalizedString(@"PROFILE_EDITOR_NAME", nil);
    nameLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    nameLabel.font = [UIFont systemFontOfSize:17];
    
    usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 105, labelWidth_half, labelHeight)];
    usernameLabel.text = NSLocalizedString(@"PROFILE_EDITOR_USER_HANDLE", nil);
    usernameLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    usernameLabel.font = [UIFont systemFontOfSize:17];
    
    UILabel *usernameAtLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 129, 20, labelHeight)];
    usernameAtLabel.text = @"@";
    usernameAtLabel.textColor = [UIColor colorWithRed:144.0/255.0 green:143.0/255.0 blue:149.0/255.0 alpha:1.0];
    usernameAtLabel.font = [UIFont systemFontOfSize:17];
    
    genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(appDelegate.screenBounds.size.width / 2 + 10, 105, labelWidth_half, labelHeight)];
    genderLabel.text = NSLocalizedString(@"PROFILE_EDITOR_GENDER", nil);
    genderLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    genderLabel.font = [UIFont systemFontOfSize:17];
    
    birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 190, labelWidth_full, labelHeight)];
    birthdayLabel.text = NSLocalizedString(@"PROFILE_EDITOR_BIRTHDAY", nil);
    birthdayLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    birthdayLabel.font = [UIFont systemFontOfSize:17];
    
    cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 275, labelWidth_half, labelHeight)];
    cityLabel.text = NSLocalizedString(@"PROFILE_EDITOR_CITY", nil);
    cityLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    cityLabel.font = [UIFont systemFontOfSize:17];
    
    stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(appDelegate.screenBounds.size.width / 2 + 10, 360, labelWidth_half, labelHeight)];
    stateLabel.text = NSLocalizedString(@"PROFILE_EDITOR_STATE", nil);
    stateLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    stateLabel.font = [UIFont systemFontOfSize:17];
    
    countryLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 360, labelWidth_full, labelHeight)];
    countryLabel.text = NSLocalizedString(@"PROFILE_EDITOR_COUNTRY", nil);
    countryLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    countryLabel.font = [UIFont systemFontOfSize:17];
    
    bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 445, labelWidth_full, labelHeight)];
    bioLabel.text = NSLocalizedString(@"PROFILE_EDITOR_BIO", nil);
    bioLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    bioLabel.font = [UIFont systemFontOfSize:17];
    
    websiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 615, labelWidth_full, labelHeight)];
    websiteLabel.text = NSLocalizedString(@"PROFILE_EDITOR_WEBSITE", nil);
    websiteLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    websiteLabel.font = [UIFont systemFontOfSize:17];
    
    nameField = [[UITextField alloc] initWithFrame:CGRectMake(20, 40, labelWidth_half, 25)];
    nameField.textColor  = [UIColor blackColor];
    nameField.font = [UIFont systemFontOfSize:17];
    nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    nameField.returnKeyType = UIReturnKeyDone;
    nameField.placeholder = @"Cave Johnson";
    nameField.tag = 0;
    nameField.delegate = self;
    
    usernameField = [[UITextField alloc] initWithFrame:CGRectMake(35, 125, labelWidth_half - 15, 25)];
    usernameField.textColor  = [UIColor blackColor];
    usernameField.font = [UIFont systemFontOfSize:17];
    usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    usernameField.keyboardType = UIKeyboardTypeTwitter;
    usernameField.returnKeyType = UIReturnKeyDone;
    usernameField.placeholder = @"lemons";
    usernameField.tag = 2;
    usernameField.delegate = self;
    
    websiteField = [[UITextField alloc] initWithFrame:CGRectMake(20, 635, labelWidth_full, 25)];
    websiteField.textColor  = [UIColor blackColor];
    websiteField.font = [UIFont systemFontOfSize:17];
    websiteField.clearButtonMode = UITextFieldViewModeWhileEditing;
    websiteField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    websiteField.keyboardType = UIKeyboardTypeURL;
    websiteField.returnKeyType = UIReturnKeyDone;
    websiteField.placeholder = @"http://";
    websiteField.tag = 4;
    websiteField.delegate = self;
    
    cityField = [[UITextField alloc] initWithFrame:CGRectMake(20, 295, labelWidth_full, 25)];
    cityField.textColor  = [UIColor blackColor];
    cityField.font = [UIFont systemFontOfSize:17];
    cityField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cityField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    cityField.returnKeyType = UIReturnKeyDone;
    cityField.placeholder = @"Dubai";
    cityField.tag = 5;
    cityField.delegate = self;
    
    bioField = [[UITextView alloc] initWithFrame:CGRectMake(15, 465, labelWidth_full, 110)];
    bioField.textColor = [UIColor blackColor];
    bioField.font = [UIFont systemFontOfSize:17];
    bioField.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    bioField.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    bioField.scrollsToTop = NO;
    bioField.tag = 9;
    bioField.delegate = self;
    
    genderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    genderButton.frame = CGRectMake(appDelegate.screenBounds.size.width / 2 + 10, 125, labelWidth_half, 25);
    [genderButton addTarget:self action:@selector(showGenderPicker) forControlEvents:UIControlEventTouchUpInside];
    [genderButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    genderButton.titleLabel.font = [UIFont systemFontOfSize:17];
    genderButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    birthdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    birthdayButton.frame = CGRectMake(20, 210, labelWidth_full, 25);
    [birthdayButton addTarget:self action:@selector(showBirthdayPicker) forControlEvents:UIControlEventTouchUpInside];
    [birthdayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    birthdayButton.titleLabel.font = [UIFont systemFontOfSize:17];
    birthdayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    removeBirthdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    removeBirthdayButton.backgroundColor = [UIColor clearColor];
    removeBirthdayButton.frame = CGRectMake(appDelegate.screenBounds.size.width - 42, birthdayLabel.frame.origin.y + birthdayLabel.frame.size.height + 5, 14, 14);
    removeBirthdayButton.hidden = YES;
    [removeBirthdayButton setBackgroundImage:[UIImage imageNamed:@"rounded_cross_gray"] forState:UIControlStateNormal];
    [removeBirthdayButton addTarget:self action:@selector(removeBirthday) forControlEvents:UIControlEventTouchUpInside];
    
    stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    stateButton.frame = CGRectMake(appDelegate.screenBounds.size.width / 2 + 10, 380, labelWidth_half, 25);
    [stateButton addTarget:self action:@selector(showStatePicker) forControlEvents:UIControlEventTouchUpInside];
    [stateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    stateButton.titleLabel.font = [UIFont systemFontOfSize:17];
    stateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    countryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    countryButton.frame = CGRectMake(20, 380, labelWidth_half, 25);
    [countryButton addTarget:self action:@selector(showCountryPicker) forControlEvents:UIControlEventTouchUpInside];
    [countryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    countryButton.titleLabel.font = [UIFont systemFontOfSize:17];
    countryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    bioFieldPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, -2, bioField.frame.size.width - 10, 45)];
    bioFieldPlaceholderLabel.numberOfLines = 0;
    bioFieldPlaceholderLabel.textColor = [UIColor colorWithRed:199/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
    bioFieldPlaceholderLabel.text = NSLocalizedString(@"PROFILE_EDITOR_PLACEHOLDER_BIO", nil);
    bioFieldPlaceholderLabel.font = [UIFont systemFontOfSize:17];
    
    bioFieldCounterLabel = [[UILabel alloc] initWithFrame:CGRectMake(appDelegate.screenBounds.size.width - 55, 445, bioField.frame.size.width, 25)];
    bioFieldCounterLabel.textColor = [UIColor colorWithRed:144.0/255.0 green:143.0/255.0 blue:149.0/255.0 alpha:1.0];
    bioFieldCounterLabel.text = [NSString stringWithFormat:@"%d", MAX_BIO_LENGTH];
    bioFieldCounterLabel.font = [UIFont systemFontOfSize:17];
    bioFieldCounterLabel.hidden = YES;
    
    horizontalSeparator_1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 85, appDelegate.screenBounds.size.width - 20, 1)];
    horizontalSeparator_1.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    horizontalSeparator_2 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 170, appDelegate.screenBounds.size.width - 20, 1)];
    horizontalSeparator_2.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    horizontalSeparator_3 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 255, appDelegate.screenBounds.size.width - 20, 1)];
    horizontalSeparator_3.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    horizontalSeparator_4 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 340, appDelegate.screenBounds.size.width - 20, 1)];
    horizontalSeparator_4.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    horizontalSeparator_5 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 425, appDelegate.screenBounds.size.width - 20, 1)];
    horizontalSeparator_5.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    horizontalSeparator_6 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 595, appDelegate.screenBounds.size.width - 20, 1)];
    horizontalSeparator_6.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    verticalSeparator_1 = [[UIImageView alloc] initWithFrame:CGRectMake(appDelegate.screenBounds.size.width / 2, -640, 1, 810)];
    verticalSeparator_1.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    verticalSeparator_2 = [[UIImageView alloc] initWithFrame:CGRectMake(appDelegate.screenBounds.size.width / 2, 340, 1, 85)];
    verticalSeparator_2.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    birthdayPicker = [[UIDatePicker alloc] init];
    birthdayPicker.backgroundColor = [UIColor whiteColor];
    birthdayPicker.frame = CGRectMake(0, appDelegate.screenBounds.size.height, appDelegate.screenBounds.size.width, 216);
    birthdayPicker.datePickerMode = UIDatePickerModeDate;
    birthdayPicker.maximumDate = [NSDate date]; // Don't allow more than the current date.
    [birthdayPicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    
    detailPicker = [[UIPickerView alloc] init];
    detailPicker.backgroundColor = [UIColor whiteColor];
    detailPicker.frame = CGRectMake(0, appDelegate.screenBounds.size.height, appDelegate.screenBounds.size.width, 216);
    detailPicker.delegate = self;
    detailPicker.dataSource = self;
    
    [bioField addSubview:bioFieldPlaceholderLabel];
    [mainView addSubview:nameLabel];
    [mainView addSubview:usernameLabel];
    [mainView addSubview:usernameAtLabel];
    [mainView addSubview:genderLabel];
    [mainView addSubview:birthdayLabel];
    [mainView addSubview:cityLabel];
    [mainView addSubview:stateLabel];
    [mainView addSubview:countryLabel];
    [mainView addSubview:bioLabel];
    [mainView addSubview:websiteLabel];
    [mainView addSubview:bioFieldCounterLabel];
    [mainView addSubview:nameField];
    [mainView addSubview:usernameField];
    [mainView addSubview:cityField];
    [mainView addSubview:bioField];
    [mainView addSubview:websiteField];
    [mainView addSubview:genderButton];
    [mainView addSubview:birthdayButton];
    [mainView addSubview:removeBirthdayButton];
    [mainView addSubview:stateButton];
    [mainView addSubview:countryButton];
    [mainView addSubview:horizontalSeparator_1];
    [mainView addSubview:horizontalSeparator_2];
    [mainView addSubview:horizontalSeparator_3];
    [mainView addSubview:horizontalSeparator_4];
    [mainView addSubview:horizontalSeparator_5];
    [mainView addSubview:horizontalSeparator_6];
    [mainView addSubview:verticalSeparator_1];
    [mainView addSubview:verticalSeparator_2];
    [contentView addSubview:mainView];
    [contentView addSubview:birthdayPicker];
    [contentView addSubview:detailPicker];
    
    self.view = contentView;
}

- (void)viewDidLoad
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [self setTitle:NSLocalizedString(@"SETTINGS_TITLE_PROFILE", nil)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    name = [appDelegate.currentUser objectForKey:@"name"];
    username = [appDelegate.currentUser objectForKey:@"user_handle"];
    gender = [appDelegate.currentUser objectForKey:@"gender"];
    birthday = [appDelegate.currentUser objectForKey:@"birthday"];
    location_country = [appDelegate.currentUser objectForKey:@"location_country"];
    location_state = [appDelegate.currentUser objectForKey:@"location_state"];
    location_city = [appDelegate.currentUser objectForKey:@"location_city"];
    website = [appDelegate.currentUser objectForKey:@"website"];
    bio = [appDelegate.currentUser objectForKey:@"bio"];
    
    nameField.text = name;
    usernameField.text = username;
    cityField.text = location_city;
    websiteField.text = website;
    bioField.text = bio;
    
    if ( birthday.length == 0 )
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        [birthdayButton setTitle:@"…" forState:UIControlStateNormal];
        [birthdayPicker setDate:[dateFormatter dateFromString:@"1992-5-6"]];
    }
    else
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *birthDate = [dateFormatter dateFromString:birthday];
        
        [dateFormatter setDateFormat:@"MMMM d, YYYY"];
        NSString *displayVersion = [dateFormatter stringFromDate:birthDate];
        
        [birthdayButton setTitle:displayVersion forState:UIControlStateNormal];
    }
    
    if ( location_country.length == 0 )
    {
        [countryButton setTitle:@"…" forState:UIControlStateNormal];
    }
    else
    {
        [countryButton setTitle:location_country forState:UIControlStateNormal];
    }
    
    if ( location_state.length == 0 )
    {
        [stateButton setTitle:@"…" forState:UIControlStateNormal];
    }
    else
    {
        [stateButton setTitle:location_state forState:UIControlStateNormal];
    }
    
    if ( gender.length == 0 )
    {
        [genderButton setTitle:@"Unspecified" forState:UIControlStateNormal];
    }
    else
    {
        if ( [[gender lowercaseString] isEqualToString:@"m"] )
        {
            [genderButton setTitle:@"Male" forState:UIControlStateNormal];
        }
        else if ( [[gender lowercaseString] isEqualToString:@"f"] )
        {
            [genderButton setTitle:@"Female" forState:UIControlStateNormal];
        }
        else
        {
            [genderButton setTitle:@"Unspecified" forState:UIControlStateNormal];
        }
    }
    
    if ( bio.length > 0 )
    {
        bioFieldPlaceholderLabel.hidden = YES;
    }
    
    if ( ![location_country isEqualToString:@"United States"] )
    {
        stateLabel.alpha = 0.0;
        stateButton.alpha = 0.0;
        verticalSeparator_2.alpha = 0.0;
        
        stateLabel.hidden = YES;
        stateButton.hidden = YES;
        verticalSeparator_2.hidden = YES;
        
        countryButton.frame = CGRectMake(countryButton.frame.origin.x, countryButton.frame.origin.y, appDelegate.screenBounds.size.width - 40, countryButton.frame.size.height);
    }
    
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    mainView.delegate = nil; // Delegate methods sometimes get called on the deallocated instance.
    [appDelegate.strobeLight deactivateStrobeLight];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)save
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( activeField )
    {
        [activeField resignFirstResponder];
    }
    
    [self dismissBirthdayPicker];
    [self dismissDetailPicker];
    
    name = nameField.text;
    username = usernameField.text;
    location_city = cityField.text;
    bio = bioField.text;
    website = websiteField.text;
    
    UIColor *normalTextColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    UIColor *errorTextColor = [UIColor colorWithRed:255/255.0 green:59/255.0 blue:48/255.0 alpha:1.0];
    
    nameLabel.textColor = normalTextColor;
    usernameLabel.textColor = normalTextColor;
    genderLabel.textColor = normalTextColor;
    birthdayLabel.textColor = normalTextColor;
    cityLabel.textColor = normalTextColor;
    stateLabel.textColor = normalTextColor;
    countryLabel.textColor = normalTextColor;
    bioLabel.textColor = normalTextColor;
    websiteLabel.textColor = normalTextColor;
    
    if ( name.length < 2 )
    {
        if ( name.length == 0 )
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedString(@"PROFILE_EDITOR_ERROR_NAME_BLANK", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"GENERIC_OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedString(@"PROFILE_EDITOR_ERROR_NAME_SHORT", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"GENERIC_OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        nameLabel.textColor = errorTextColor;
        
        [appDelegate.strobeLight negativeStrobeLight];
        
        return;
    }
    
    if ( name.length > 50 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"PROFILE_EDITOR_ERROR_NAME_LONG", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"GENERIC_OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        
        nameLabel.textColor = errorTextColor;
        
        [appDelegate.strobeLight negativeStrobeLight];
        
        return;
    }
    
    if ( username.length > 15 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"PROFILE_EDITOR_ERROR_USERNAME_LONG", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"GENERIC_OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        
        usernameLabel.textColor = errorTextColor;
        
        [appDelegate.strobeLight negativeStrobeLight];
        
        return;
    }
    
    if ( location_city.length > 45 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"PROFILE_EDITOR_ERROR_CITY_LONG", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"GENERIC_OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        
        cityLabel.textColor = errorTextColor;
        
        [appDelegate.strobeLight negativeStrobeLight];
        
        return;
    }
    
    if ( bio.length > 140 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"PROFILE_EDITOR_ERROR_BIO_LONG", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"GENERIC_OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        
        bioLabel.textColor = errorTextColor;
        
        [appDelegate.strobeLight negativeStrobeLight];
        
        return;
    }
    
    if ( website.length > 255 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"PROFILE_EDITOR_ERROR_WEBSITE_LONG", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"GENERIC_OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        
        websiteLabel.textColor = errorTextColor;
        
        [appDelegate.strobeLight negativeStrobeLight];
        
        return;
    }
    
    doneButton.enabled = NO;
    [appDelegate.strobeLight activateStrobeLight];
    
    // Show the HUD.
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] init];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.dimBackground = YES;
    HUD.delegate = self;
    [HUD show:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": appDelegate.SHToken,
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                 @"name": name,
                                 @"user_handle": username,
                                 @"gender": gender,
                                 @"birthday": birthday,
                                 @"location_country": location_country,
                                 @"location_state": location_state,
                                 @"location_city": location_city,
                                 @"bio": bio,
                                 @"website": website};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/updateprofile", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        if ( errorCode == 0 )
        {
            [appDelegate.strobeLight affirmativeStrobeLight];
            
            [HUD hide:YES];
            
            // We need a slight delay here.
            long double delayInSeconds = 0.45;
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_white"]];
                
                // Set custom view mode.
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.dimBackground = YES;
                HUD.delegate = self;
                
                [HUD show:YES];
                [HUD hide:YES afterDelay:2];
            });
            
            [appDelegate.modelManager executeUpdate:@"UPDATE sh_current_user SET name = :name, user_handle = :user_handle, gender = :gender, birthday = :birthday, location_country = :location_country, location_state = :location_state, location_city = :location_city, bio = :bio, website = :website"
                            withParameterDictionary:@{@"name": name,
                                                      @"user_handle": username,
                                                      @"gender": gender,
                                                      @"birthday": birthday,
                                                      @"location_country": location_country,
                                                      @"location_state": location_state,
                                                      @"location_city": location_city,
                                                      @"bio": bio,
                                                      @"website": website}];
            
            [appDelegate.modelManager executeUpdate:@"UPDATE sh_cloud SET name = :name, user_handle = :user_handle, gender = :gender, birthday = :birthday, location_country = :location_country, location_state = :location_state, location_city = :location_city, bio = :bio, website = :website "
             @"WHERE sh_user_id = :user_id"
                            withParameterDictionary:@{@"user_id": [appDelegate.currentUser objectForKey:@"user_id"],
                                                      @"name": name,
                                                      @"user_handle": username,
                                                      @"gender": gender,
                                                      @"birthday": birthday,
                                                      @"location_country": location_country,
                                                      @"location_state": location_state,
                                                      @"location_city": location_city,
                                                      @"bio": bio,
                                                      @"website": website}];
            
            [appDelegate refreshCurrentUserData];
        }
        else
        {
            doneButton.enabled = YES;
            [HUD hide:YES];
            
            if ( errorCode == 1 )
            {
                NSString *errorMessage = [[responseObject objectForKey:@"errorMessage"] firstObject]; // We only handle errors one at a time.
                NSString *alertString = @"";
                
                if ( [errorMessage isEqualToString:@"error_username"] )
                {
                    alertString = NSLocalizedString(@"PROFILE_EDITOR_ERROR_USERNAME", nil);
                    usernameLabel.textColor = errorTextColor;
                }
                else if ( [errorMessage isEqualToString:@"error_usernameExists"] )
                {
                    alertString = NSLocalizedString(@"PROFILE_EDITOR_ERROR_USERNAME_EXISTS", nil);
                    usernameLabel.textColor = errorTextColor;
                }
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:alertString
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"GENERIC_OK", nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            [appDelegate.strobeLight negativeStrobeLight];
        }
        
        NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showNetworkError];
        
        NSLog(@"Error: %@", operation.responseString);
    }];
}

- (void)removeBirthday
{
    birthday = @"";
    removeBirthdayButton.hidden = YES;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [birthdayButton setTitle:@"…" forState:UIControlStateNormal];
    [birthdayPicker setDate:[dateFormatter dateFromString:@"1992-5-6"]];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions keyboardAnimationCurve;
    
    switch ( animationCurve )
    {
        case UIViewAnimationCurveEaseInOut:
        {
            keyboardAnimationCurve = UIViewAnimationOptionCurveEaseInOut;
            break;
        }
            
        case UIViewAnimationCurveEaseIn:
        {
            keyboardAnimationCurve = UIViewAnimationOptionCurveEaseIn;
            break;
        }
            
        case UIViewAnimationCurveEaseOut:
        {
            keyboardAnimationCurve = UIViewAnimationOptionCurveEaseOut;
            break;
        }
            
        case UIViewAnimationCurveLinear:
        {
            keyboardAnimationCurve = UIViewAnimationOptionCurveLinear;
            break;
        }
            
        default:
        {
            keyboardAnimationCurve = 7 << 16; // For iOS 7.
        }
    }
    
    shouldDismissKeyboard = NO;
    
    [UIView animateWithDuration:keyboardAnimationDuration delay:0 options:keyboardAnimationCurve animations:^{
        mainView.contentInset = UIEdgeInsetsMake(mainView.contentInset.top, mainView.contentInset.left, keyboardSize.height + 25, mainView.contentInset.right);
        mainView.scrollIndicatorInsets = UIEdgeInsetsMake(mainView.scrollIndicatorInsets.top, mainView.scrollIndicatorInsets.left, keyboardSize.height + 25, mainView.scrollIndicatorInsets.right);
    } completion:^(BOOL finished){
        long double delayInSeconds = 0.35;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            shouldDismissKeyboard = YES;
        });
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger animationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions keyboardAnimationCurve;
    
    switch ( animationCurve )
    {
        case UIViewAnimationCurveEaseInOut:
        {
            keyboardAnimationCurve = UIViewAnimationOptionCurveEaseInOut;
            break;
        }
            
        case UIViewAnimationCurveEaseIn:
        {
            keyboardAnimationCurve = UIViewAnimationOptionCurveEaseIn;
            break;
        }
            
        case UIViewAnimationCurveEaseOut:
        {
            keyboardAnimationCurve = UIViewAnimationOptionCurveEaseOut;
            break;
        }
            
        case UIViewAnimationCurveLinear:
        {
            keyboardAnimationCurve = UIViewAnimationOptionCurveLinear;
            break;
        }
            
        default:
        {
            keyboardAnimationCurve = 7 << 16; // For iOS 7.
        }
    }
    
    [UIView animateWithDuration:keyboardAnimationDuration delay:0 options:keyboardAnimationCurve animations:^{
        mainView.contentInset = UIEdgeInsetsMake(mainView.contentInset.top, mainView.contentInset.left, 0, mainView.contentInset.right);
        mainView.scrollIndicatorInsets = UIEdgeInsetsMake(mainView.scrollIndicatorInsets.top, mainView.scrollIndicatorInsets.left, 0, mainView.scrollIndicatorInsets.right);
    } completion:^(BOOL finished){
        
    }];
}

- (void)showBirthdayPicker
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    doneButton.enabled = YES;
    
    if ( activeField )
    {
        [activeField resignFirstResponder];
    }
    
    if ( birthday.length == 0 )
    {
        removeBirthdayButton.hidden = YES;
    }
    else
    {
        removeBirthdayButton.hidden = NO;
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        birthdayPicker.frame = CGRectMake(0, appDelegate.screenBounds.size.height - 216, birthdayPicker.frame.size.width, 216);
    } completion:^(BOOL finished){
        
    }];
}

- (void)dismissBirthdayPicker
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    removeBirthdayButton.hidden = YES;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        birthdayPicker.frame = CGRectMake(0, appDelegate.screenBounds.size.height, birthdayPicker.frame.size.width, 216);
    } completion:^(BOOL finished){
        
    }];
}

- (void)showGenderPicker
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( activeField )
    {
        [activeField resignFirstResponder];
    }
    
    activeDataSource = genders;
    [detailPicker reloadAllComponents];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        detailPicker.frame = CGRectMake(0, appDelegate.screenBounds.size.height - 216, detailPicker.frame.size.width, 216);
    } completion:^(BOOL finished){
        
    }];
}

- (void)showStatePicker
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( activeField )
    {
        [activeField resignFirstResponder];
    }
    
    activeDataSource = states;
    [detailPicker reloadAllComponents];
    [detailPicker selectRow:0 inComponent:0 animated:NO];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        detailPicker.frame = CGRectMake(0, appDelegate.screenBounds.size.height - 216, detailPicker.frame.size.width, 216);
    } completion:^(BOOL finished){
        
    }];
}

- (void)showCountryPicker
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( activeField )
    {
        [activeField resignFirstResponder];
    }
    
    activeDataSource = countries;
    [detailPicker reloadAllComponents];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        detailPicker.frame = CGRectMake(0, appDelegate.screenBounds.size.height - 216, detailPicker.frame.size.width, 216);
    } completion:^(BOOL finished){
        
    }];
}

- (void)dismissDetailPicker
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        detailPicker.frame = CGRectMake(0, appDelegate.screenBounds.size.height, detailPicker.frame.size.width, 216);
    } completion:^(BOOL finished){
        
    }];
}

- (void)datePickerValueChanged
{
    removeBirthdayButton.hidden = NO;
    
    NSDate *selectedDate = birthdayPicker.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    birthday = [dateFormatter stringFromDate:selectedDate];
    
    [dateFormatter setDateFormat:@"MMMM d, YYYY"];
    NSString *displayVersion = [dateFormatter stringFromDate:selectedDate];
    
    [birthdayButton setTitle:displayVersion forState:UIControlStateNormal];
}

- (void)showNetworkError
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [appDelegate.strobeLight negativeStrobeLight];
    [HUD hide:YES];
    
    // We need a slight delay here.
    long double delayInSeconds = 0.45;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white"]];
        
        // Set custom view mode.
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.dimBackground = YES;
        HUD.delegate = self;
        HUD.labelText = NSLocalizedString(@"GENERIC_HUD_NETWORK_ERROR", nil);
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
    });
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    doneButton.enabled = YES;
    
    // Monitor keystrokes.
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if ( textField.tag == 4 && textField.text.length == 0 ) // Website field.
    {
        textField.text = @"http://"; // Set this as initial text.
    }
    
    [mainView scrollRectToVisible:textField.frame animated:YES];
    
    long double delayInSeconds = 0.4;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        activeField = textField;
    });
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField removeTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if ( textField.tag == 4 &&
        ([textField.text isEqualToString:@"http://"] || [textField.text isEqualToString:@"https://"])) // Website field.
    {
        textField.text = @""; // Clear out the http:// text.
    }
    
    activeField = nil;
}

- (void)textFieldDidChange:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    
    if ( textField.tag == 2 ) // Username box.
    {
        NSCharacterSet *notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@"!¿?,;:[]{}<>|@#%^&*()=+/\\…•'\""];
        textField.text = [[textField.text componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    else if ( textField.tag == 6 || textField.tag == 7 || textField.tag == 8 ) // Social profile usernames.
    {
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark -
#pragma mark UITextViewDelegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    doneButton.enabled = YES;
    
    [mainView scrollRectToVisible:textView.frame animated:YES];
    
    long double delayInSeconds = 0.4;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        activeField = textView;
    });
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    activeField = nil;
}

- (void)textViewDidChange:(UITextView *)textView
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( textView.text.length == 0 )
    {
        bioFieldPlaceholderLabel.hidden = NO;
    }
    else
    {
        bioFieldPlaceholderLabel.hidden = YES;
        bioFieldCounterLabel.text = [NSString stringWithFormat:@"%d", (int)(MAX_BIO_LENGTH - textView.text.length)];
        
        if ( textView.text.length >= MAX_BIO_LENGTH - 20 )
        {
            CGSize textSize_timestamp = [bioFieldCounterLabel.text sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(45, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            bioFieldCounterLabel.frame = CGRectMake(appDelegate.screenBounds.size.width - 20 - textSize_timestamp.width, bioFieldCounterLabel.frame.origin.y, textSize_timestamp.width, bioFieldCounterLabel.frame.size.height);
            bioFieldCounterLabel.hidden = NO;
            
            if ( textView.text.length > MAX_BIO_LENGTH )
            {
                bioFieldCounterLabel.textColor = [UIColor redColor];
            }
            else
            {
                bioFieldCounterLabel.textColor = [UIColor colorWithRed:144.0/255.0 green:143.0/255.0 blue:149.0/255.0 alpha:1.0];
            }
        }
        else
        {
            bioFieldCounterLabel.hidden = YES;
        }
    }
}

#pragma mark -
#pragma mark UIPickerViewDelegate methods

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [activeDataSource objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    NSString *selection = [activeDataSource objectAtIndex:row];
    doneButton.enabled = YES;
    
    if ( [activeDataSource isEqualToArray:genders] )
    {
        [genderButton setTitle:selection forState:UIControlStateNormal];
        
        if ( row == 0 )
        {
            gender = @"";
        }
        else
        {
            if ( [[selection lowercaseString] isEqualToString:@"male"] )
            {
                gender = @"m";
            }
            else if ( [[selection lowercaseString] isEqualToString:@"female"] )
            {
                gender = @"f";
            }
        }
    }
    else if ( [activeDataSource isEqualToArray:states] )
    {
        [stateButton setTitle:selection forState:UIControlStateNormal];
        
        if ( row == 0 )
        {
            location_state = @"";
        }
        else
        {
            location_state = selection;
        }
    }
    else if ( [activeDataSource isEqualToArray:countries] )
    {
        [countryButton setTitle:selection forState:UIControlStateNormal];
        
        if ( row == 0 )
        {
            location_country = @"";
        }
        else
        {
            location_country = selection;
            
            if ( [location_country isEqualToString:@"United States"] )
            {
                stateLabel.hidden = NO;
                stateButton.hidden = NO;
                verticalSeparator_2.hidden = NO;
                
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    stateLabel.alpha = 1.0;
                    stateButton.alpha = 1.0;
                    verticalSeparator_2.alpha = 1.0;
                    
                    countryButton.frame = CGRectMake(countryButton.frame.origin.x, countryButton.frame.origin.y, appDelegate.screenBounds.size.width / 2 - 20, countryButton.frame.size.height);
                } completion:^(BOOL finished){
                    
                }];
            }
            else
            {
                location_state = @""; // Clear out the state value.
                [stateButton setTitle:@"…" forState:UIControlStateNormal];
                
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    stateLabel.alpha = 0.0;
                    stateButton.alpha = 0.0;
                    verticalSeparator_2.alpha = 0.0;
                    
                    countryButton.frame = CGRectMake(countryButton.frame.origin.x, countryButton.frame.origin.y, appDelegate.screenBounds.size.width - 40, countryButton.frame.size.height);
                } completion:^(BOOL finished){
                    stateLabel.hidden = YES;
                    stateButton.hidden = YES;
                    verticalSeparator_2.hidden = YES;
                }];
            }
        }
    }
}

#pragma mark -
#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return activeDataSource.count;
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( scrollView.tag == 0 )
    {
        if ( activeField && shouldDismissKeyboard )
        {
            [activeField resignFirstResponder];
        }
        
        [self dismissBirthdayPicker];
        [self dismissDetailPicker];
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods.

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	// Remove HUD from screen when the HUD was hidden.
	[HUD removeFromSuperview];
	HUD = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
