//
//  SHSettingsMainViewController.m
//  Nightboard
//
//  Created by MachOSX on 2/11/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import "SHSettingsMainViewController.h"

#import "AppDelegate.h"
#import "SHSettingsViewController_Account.h"
#import "SHSettingsViewController_Corporate.h"
#import "SHSettingsViewController_Profile.h"

@implementation SHSettingsMainViewController

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
        
        if ( appDelegate.contactManager.countryList.count == 0 )
        {
            [appDelegate.contactManager fetchCountryList];
        }
        
        NSArray *arrTemp1 = [[NSArray alloc]
                             initWithObjects:NSLocalizedString(@"SETTINGS_OPTION_INVITE", nil), nil];
        NSArray *arrTemp2 = [[NSArray alloc]
                             initWithObjects:NSLocalizedString(@"SETTINGS_OPTION_PROFILE", nil), nil]; // NSLocalizedString(@"SETTINGS_OPTION_ACCOUNT", nil)
        NSArray *arrTemp3 = [[NSArray alloc]
                             initWithObjects:NSLocalizedString(@"SETTINGS_OPTION_BLUETOOTH", nil), nil]; //NSLocalizedString(@"SETTINGS_OPTION_ADD_USERNAME", nil)
        NSArray *arrTemp4 = [[NSArray alloc]
                             initWithObjects:NSLocalizedString(@"SETTINGS_OPTION_PRIVACY", nil), NSLocalizedString(@"SETTINGS_OPTION_TOS", nil), nil];
        NSDictionary *temp = [[NSDictionary alloc]
                              initWithObjectsAndKeys:arrTemp1, @"1", arrTemp2,
                              @"2", arrTemp3, @"3", arrTemp4, @"4", nil];
        
        tableContents = temp;
        sortedKeys =[[tableContents allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        shouldDisplayBluetoothMessage = NO;
    }
    
    return self;
}

- (void)loadView
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UIView *contentView = [[UIView alloc] initWithFrame:appDelegate.screenBounds];
    contentView.backgroundColor = [UIColor whiteColor];
    
    settingsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height) style:UITableViewStyleGrouped];
    settingsTableView.delegate = self;
    settingsTableView.dataSource = self;
    settingsTableView.backgroundView = nil; // Fix for iOS 6+.
    settingsTableView.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, settingsTableView.frame.size.width, 44)];
    settingsTableView.tableFooterView = tableFooterView;
    
    UILabel *copyright = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, appDelegate.screenBounds.size.width - 40, 14)];
    copyright.backgroundColor = [UIColor clearColor];
    copyright.opaque = YES;
    copyright.textColor = [UIColor colorWithRed:76/255.0 green:86/255.0 blue:108/255.0 alpha:1.0];
    copyright.font = [UIFont fontWithName:@"Georgia" size:SECONDARY_FONT_SIZE];
    copyright.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    copyright.shadowOffset = CGSizeMake(0, 1);
    copyright.numberOfLines = 1;
    copyright.textAlignment = NSTextAlignmentCenter;
    
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [appDelegate.calendar components:NSYearCalendarUnit fromDate:date];
    copyright.text = [NSString stringWithFormat:@"© %d. be original.", (int)dateComponents.year];
    
    if ( !(IS_IOS7) ) // Non-iOS 7 fixes.
    {
        settingsTableView.frame = CGRectMake(0, 0, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height - 64);
    }
    
    [tableFooterView addSubview:copyright];
    [contentView addSubview:settingsTableView];
    
    self.view = contentView;
}

- (void)viewDidLoad
{
    [self setTitle:NSLocalizedString(@"SETTINGS_TITLE_MAIN", nil)];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionNavigationBar];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    // We need to keep an updated reference to the new preference values.
    // It's better than reading them from the disk every time.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    appDelegate.preference_UseBluetooth = [[userDefaults stringForKey:@"SHBUseBluetooth"] boolValue];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if ( viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self ) // View is disappearing because a new view controller was pushed onto the stack.
    {
        
    }
    else if ( [viewControllers indexOfObject:self] == NSNotFound ) // View is disappearing because it was popped from the stack.
    {
        [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionStatusBar];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        appDelegate.mainView.profileView.ownerDataChunk = appDelegate.currentUser; // Update the profile chunk.
        [appDelegate.mainView.profileView refreshViewWithDP:NO];
    }
    
    [super viewWillDisappear:animated];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didToggleSwitch:(id)sender
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UISwitch *toggleSwitch = (UISwitch *)sender;
    
    [settingsTableView beginUpdates];
    
    shouldDisplayBluetoothMessage = YES;
    
    [settingsTableView endUpdates];
    
    BOOL switchOn = [toggleSwitch isOn];
    
    if ( switchOn )
    {
        [appDelegate.peerManager startAdvertising];
        [appDelegate.peerManager startScanning];
    }
    else
    {
        [appDelegate.peerManager stopAdvertising];
        [appDelegate.peerManager stopScanning];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSString stringWithFormat:@"%@", switchOn ? @"YES" : @"NO"] forKey:@"SHBUseBluetooth"];
}

#pragma mark -
#pragma mark UITableViewDataSource methods.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sortedKeys.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    NSArray *listData =[tableContents objectForKey:[sortedKeys objectAtIndex:section]];
    
    return listData.count;
}

- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section
{
    if ( section == 0 )
    {
        return 50;
    }
    else
    {
        return 10;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ( section == 0 )
    {
        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenBounds.size.width, 50)];
        NSNumber *versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        // Add the label.
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, appDelegate.screenBounds.size.width - 40, 50)];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.opaque = YES;
        headerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SETTINGS_SIGNATURE", nil), versionNumber];
        headerLabel.textColor = [UIColor colorWithRed:76/255.0 green:86/255.0 blue:108/255.0 alpha:1.0];
        headerLabel.font = [UIFont systemFontOfSize:16];
        headerLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        headerLabel.shadowOffset = CGSizeMake(0, 1);
        headerLabel.numberOfLines = 0;
        headerLabel.textAlignment = NSTextAlignmentCenter;
        
        [headerView addSubview:headerLabel];
        
        return headerView;
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)table heightForFooterInSection:(NSInteger)section
{
    if ( section == 2 && shouldDisplayBluetoothMessage )
    {
        return 50;
    }
    else
    {
        return 20;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenBounds.size.width, 50)];
    
    // Add the label.
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, appDelegate.screenBounds.size.width - 40, 50)];
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.opaque = YES;
    footerLabel.textColor = [UIColor colorWithRed:76/255.0 green:86/255.0 blue:108/255.0 alpha:1.0];
    footerLabel.font = [UIFont systemFontOfSize:16];
    footerLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    footerLabel.shadowOffset = CGSizeMake(0, 1);
    footerLabel.numberOfLines = 0;
    footerLabel.textAlignment = NSTextAlignmentCenter;
    
    [footerView addSubview:footerLabel];
    
    if ( section == 2 && shouldDisplayBluetoothMessage )
    {
        footerView.frame = CGRectMake(footerView.frame.origin.x, footerView.frame.origin.y, footerView.frame.size.width, 50);
        footerLabel.frame = CGRectMake(footerLabel.frame.origin.x, footerLabel.frame.origin.y, footerLabel.frame.size.width, 50);
        footerLabel.text = NSLocalizedString(@"SETTINGS_DESCRIPTION_BLUETOOTH", nil);
        
        return footerView;
    }
    else
    {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    NSArray *listData =[tableContents objectForKey:[sortedKeys objectAtIndex:indexPath.section]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // Set the accessory type.
    }
    
    if ( indexPath.section == 2 && indexPath.row == 0 ) // Use Address Book option has a UISwitch. No need for selection.
    {
        UISwitch *toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [toggleSwitch addTarget:self action:@selector(didToggleSwitch:) forControlEvents: UIControlEventTouchUpInside];
        toggleSwitch.tag = indexPath.row;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL switchOn = [[userDefaults stringForKey:@"SHBUseBluetooth"] boolValue];
        
        [toggleSwitch setOn:switchOn];
        
        cell.accessoryView = toggleSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        if ( indexPath.section == 1 )
        {
            if ( indexPath.row == 0 )
            {
                cell.imageView.image = [UIImage imageNamed:@"settings_account"];
                cell.imageView.highlightedImage = [appDelegate imageFilledWith:[UIColor whiteColor] using:[UIImage imageNamed:@"settings_account"]];
            }
            else if ( indexPath.row == 1 )
            {
                cell.imageView.image = [UIImage imageNamed:@"settings_profile"];
                cell.imageView.highlightedImage = [appDelegate imageFilledWith:[UIColor whiteColor] using:[UIImage imageNamed:@"settings_profile"]];
            }
        }
    }
    
    
    cell.textLabel.text = [listData objectAtIndex:indexPath.row];
    
    // Customization. Hide the accessory for the buttons that don't push new view controllers:
    // # Invite Friends
    if ( (indexPath.section == 0 && indexPath.row == 0) )
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( indexPath.section == 0 && indexPath.row == 0 ) // Invite Friends
    {
        NSArray *activityItems = @[NSLocalizedString(@"SETTINGS_INVITATION_BODY", nil), [NSURL URLWithString:@"https://itunes.apple.com/us/app/nightboard/id963223746?ls=1&mt=8"]];
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        [activityController setValue:NSLocalizedString(@"SETTINGS_INVITATION_SUBJECT", nil) forKey:@"subject"];
        
        if ( (IS_IOS7) )
        {
            activityController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop];
        }
        else
        {
            activityController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
        }
        
        [self.navigationController presentViewController:activityController animated:YES completion:nil];
    }
    else if ( indexPath.section == 1 && indexPath.row == 0) // Account
    {
        /*SHSettingsViewController_Account *accountSettings = [[SHSettingsViewController_Account alloc] init];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SETTINGS_TITLE_MAIN", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:accountSettings animated:YES];*/
        
        SHSettingsViewController_Profile *profileSettings = [[SHSettingsViewController_Profile alloc] init];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SETTINGS_TITLE_MAIN", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:profileSettings animated:YES];
    }
    else if ( indexPath.section == 1 && indexPath.row == 1 ) // Profile
    {
        SHSettingsViewController_Profile *profileSettings = [[SHSettingsViewController_Profile alloc] init];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SETTINGS_TITLE_MAIN", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:profileSettings animated:YES];
    }
    else if ( indexPath.section == 2 && indexPath.row == 1 ) // Add Contact By Username
    {
        /*SHRecipientPicker *recipientPicker = [[SHRecipientPicker alloc] initInMode:SHRecipientPickerModeAddByUsername];
        
        [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionStatusBar];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController pushViewController:recipientPicker animated:YES];*/
    }
    else if ( indexPath.section == 3 && indexPath.row == 0 ) // Privacy Policy
    {
        SHSettingsViewController_Corporate *privacyPolicyView = [[SHSettingsViewController_Corporate alloc] init];
        [privacyPolicyView setValue:@"privacy" forKey:@"type"];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SETTINGS_TITLE_MAIN", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:privacyPolicyView animated:YES];
    }
    else if ( indexPath.section == 3 && indexPath.row == 1 ) // TOS
    {
        SHSettingsViewController_Corporate *termsView = [[SHSettingsViewController_Corporate alloc] init];
        [termsView setValue:@"terms" forKey:@"type"];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SETTINGS_TITLE_MAIN", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:termsView animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
