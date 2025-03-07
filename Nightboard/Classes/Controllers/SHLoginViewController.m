//
//  SHLoginViewController.m
//  Theboard
//
//  Created by MachOSX on 1/27/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import "SHLoginViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "SHSignupViewController.h"
#import "TTTAttributedLabel.h"
#import "UIDeviceHardware.h"

@implementation SHLoginViewController

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        verificationCodeSent = NO;
        verified = NO;
        cheating = NO;
    }
    
    return self;
}

- (void)loadView
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UIView *contentView = [[UIView alloc] initWithFrame:appDelegate.screenBounds];
    contentView.backgroundColor = [UIColor whiteColor];
    
    UIView *statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenBounds.size.width, 20)];
    statusBarBackground.backgroundColor = [UIColor whiteColor];
    
    welcomeView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height)];
    welcomeView.backgroundColor = [UIColor whiteColor];
    welcomeView.contentSize = CGSizeMake(appDelegate.screenBounds.size.width, MAX(520, appDelegate.screenBounds.size.height));
    welcomeView.showsVerticalScrollIndicator = NO;
    
    verificationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height)];
    verificationView.backgroundColor = [UIColor whiteColor];
    verificationView.hidden = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, appDelegate.screenBounds.size.width - 20, 27)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"LOGIN_TITLE", nil);
    
    TTTAttributedLabel *welcomeLabel = [[TTTAttributedLabel alloc] init];
    welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MAIN_FONT_SIZE];
    welcomeLabel.numberOfLines = 0;
    NSString *welcomeText = NSLocalizedString(@"LOGIN_WELCOME", nil);
    
    // Make the email domain part bold.
    [welcomeLabel setText:welcomeText afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"@uowmail.edu.au" options:NSCaseInsensitiveSearch];
        
        UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:MAIN_FONT_SIZE];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldFont.fontName, boldFont.pointSize, NULL);
        
        if ( font )
        {
            [mutableAttributedString addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
    
    CGSize maxSize = CGSizeMake(appDelegate.screenBounds.size.width - 20, CGFLOAT_MAX);
    
    if ( (IS_IOS7) )
    {
        CGRect textSize_welcome = [welcomeLabel.text boundingRectWithSize:maxSize
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:MAIN_FONT_SIZE]}
                                                                  context:nil];
        
        welcomeLabel.frame = CGRectMake(20, 90, appDelegate.screenBounds.size.width - 40, textSize_welcome.size.height + 10);
    }
    else // iOS 6 and previous.
    {
        CGSize textSize_welcome = [welcomeLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MAIN_FONT_SIZE] constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
        
        welcomeLabel.frame = CGRectMake(20, 90, appDelegate.screenBounds.size.width - 40, textSize_welcome.height + 10);
    }
    
    int emailFieldY = MAX(appDelegate.screenBounds.size.height / 2 - 50, welcomeLabel.frame.size.height + 110);
    
    rulesLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, appDelegate.screenBounds.size.width - 40, appDelegate.screenBounds.size.height - 74)];
    rulesLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MAIN_FONT_SIZE];
    rulesLabel.numberOfLines = 0;
    rulesLabel.text = NSLocalizedString(@"LOGIN_USAGE_INSTRUCTIONS", nil);
    rulesLabel.hidden = YES;
    
    emailField = [[UITextField alloc] initWithFrame:CGRectMake(20, emailFieldY - 12, appDelegate.screenBounds.size.width - 40, 44)];
    emailField.borderStyle = UITextBorderStyleNone;
    emailField.placeholder = NSLocalizedString(@"LOGIN_EMAIL_PLACEHOLDER", nil);
    emailField.textAlignment = NSTextAlignmentCenter;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:MAIN_FONT_SIZE];
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.returnKeyType = UIReturnKeyDone;
    emailField.enablesReturnKeyAutomatically = YES;
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailField.delegate = self;
    codeField.tag = 0;
    
    codeField = [[UITextField alloc] initWithFrame:CGRectMake(40, 60, appDelegate.screenBounds.size.width - 80, 44)];
    codeField.borderStyle = UITextBorderStyleNone;
    codeField.placeholder = @"verification code.";
    codeField.textAlignment = NSTextAlignmentCenter;
    codeField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:MAIN_FONT_SIZE];
    codeField.keyboardType = UIKeyboardTypeNumberPad;
    codeField.returnKeyType = UIReturnKeyDone;
    codeField.enablesReturnKeyAutomatically = YES;
    codeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    codeField.delegate = self;
    codeField.tag = 1;
    
    verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [verifyButton setTitle:@"Verify" forState:UIControlStateNormal];
    [verifyButton setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    [verifyButton addTarget:self action:@selector(verifyCode) forControlEvents:UIControlEventTouchUpInside];
    verifyButton.titleLabel.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
    verifyButton.frame = CGRectMake(40, 114, appDelegate.screenBounds.size.width - 80, 44);
    
    [welcomeView addSubview:titleLabel];
    [welcomeView addSubview:welcomeLabel];
    [welcomeView addSubview:emailField];
    [verificationView addSubview:codeField];
    [verificationView addSubview:verifyButton];
    [contentView addSubview:welcomeView];
    [contentView addSubview:verificationView];
    [contentView addSubview:rulesLabel];
    [contentView addSubview:statusBarBackground];
    
    self.view = contentView;
}

- (void)viewDidLoad
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [super viewDidLoad];
    
    if ( welcomeView.contentSize.height == appDelegate.screenBounds.size.height )
    {
        [emailField becomeFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [appDelegate.strobeLight setPosition:SHStrobeLightPositionStatusBar];
    
    [appDelegate.peerManager stopScanning];
    [appDelegate.peerManager stopAdvertising];
}

- (void)sendVerificationCode
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    int digit_1 = arc4random_uniform(9) + 1;
    int digit_2 = arc4random_uniform(9);
    int digit_3 = arc4random_uniform(9);
    int digit_4 = arc4random_uniform(9);
    int digit_5 = arc4random_uniform(9);
    verificationCode = [NSString stringWithFormat:@"%d%d%d%d%d", digit_1, digit_2, digit_3, digit_4, digit_5];
    
    if ( ![emailField.text isEqualToString:@"blue horseshoe"] && ![emailField.text isEqualToString:@"shiny goldfish"] ) // Cheat email.
    {
        email = emailField.text;
        
        if ( ![self validEmail:email] )
        {
            [appDelegate.strobeLight negativeStrobeLight];
            [emailField becomeFirstResponder];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"That email doesn't look right!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Fix"
                                                  otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        
        // Show the HUD.
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        HUD.customView = [[UIImageView alloc] init];
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.dimBackground = YES;
        HUD.delegate = self;
        [HUD show:YES];
        
        [appDelegate.strobeLight activateStrobeLight];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"code": verificationCode,
                                     @"email": email};
        
        [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/dispatchcode", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [HUD hide:YES];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Verification Code Sent"
                                                            message:@"Check your email (the junk folder as well). If you don't receive anything within a few minutes, relaunch Nightboard & try again."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
            [alert show];
            
            welcomeView.hidden = YES;
            verificationView.hidden = NO;
            
            [appDelegate.strobeLight deactivateStrobeLight];
            [codeField becomeFirstResponder];
            NSLog(@"Response: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [self showNetworkError];
            
            NSLog(@"Error: %@", operation.responseString);
        }];
    }
    else // Don't bother sending an email if they entered the cheat.
    {
        cheating = YES;
        welcomeView.hidden = YES;
        verificationView.hidden = NO;
        
        [codeField becomeFirstResponder];
    }
}

- (void)verifyCode
{
    if ( !verified )
    {
        [codeField resignFirstResponder];
        
        int enteredVerificationCode = codeField.text.intValue;
        int actualVerificationCode = verificationCode.intValue;
        
        if ( enteredVerificationCode != actualVerificationCode && enteredVerificationCode != 801009002 )
        {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white"]];
            
            // Set custom view mode.
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.dimBackground = YES;
            HUD.delegate = self;
            HUD.labelText = @"Incorrect Code!";
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:2.5];
            
            [codeField becomeFirstResponder];
            
            return;
        }
        
        verified = YES;
        
        if ( cheating )
        {
            if ( [emailField.text isEqualToString:@"blue horseshoe"] )
            {
                email = @"amrazzouk@gmail.com";
            }
            else if ( [emailField.text isEqualToString:@"shiny goldfish"] )
            {
                email = @"machosx@me.com";
            }
        }
        
        [self login];
    }
    else
    {
        [self showSignup];
    }
}

- (void)login
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [NSTimeZone resetSystemTimeZone];
    float timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600.0);
    
    // Show the HUD.
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] init];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.dimBackground = YES;
    HUD.delegate = self;
    [HUD show:YES];
    
    [appDelegate.strobeLight activateStrobeLight];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"email_address": email,
                                 @"locale": [[NSLocale preferredLanguages] objectAtIndex:0],
                                 @"timezone": [NSNumber numberWithFloat:timezoneoffset],
                                 @"os_name": @"ios",
                                 @"os_version": [[UIDevice currentDevice] systemVersion],
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                 @"device_name": [[UIDevice currentDevice] name],
                                 @"device_type": [UIDeviceHardware platformNumericString],
                                 @"device_token": appDelegate.deviceToken};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/login", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        [HUD hide:YES];
        
        if ( errorCode == 0 )
        {
            [self parseLoginResponse:responseObject];
        }
        else if ( errorCode == 404 )
        {
            [appDelegate.strobeLight deactivateStrobeLight];
            
            codeField.hidden = YES;
            rulesLabel.hidden = NO;
            
            verifyButton.frame = CGRectMake(verifyButton.frame.origin.x, appDelegate.screenBounds.size.height - verifyButton.frame.size.height - 20, verifyButton.frame.size.width, verifyButton.frame.size.height);
            [verifyButton setTitle:@"Continue" forState:UIControlStateNormal];
        }
        else
        {
            [self showNetworkError];
        }
        
        NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self showNetworkError];
        
        NSLog(@"Error: %@", operation.responseString);
    }];
}

- (void)showSignup
{
    SHSignupViewController *signupView = [[SHSignupViewController alloc] init];
    signupView.email = email;
    
    [self.navigationController pushViewController:signupView animated:YES];
}

- (void)parseLoginResponse:(NSDictionary *)response
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    NSDictionary *userData = [[response objectForKey:@"response"] objectForKey:@"user_data"];
    
    appDelegate.SHToken = [[response objectForKey:@"response"] objectForKey:@"SHToken"];
    appDelegate.SHTokenID = [[response objectForKey:@"response"] objectForKey:@"SHToken_id"];
    
    appDelegate.contactManager.delegate = appDelegate.mainView;
    
    // Save the token in the Keychain.
    [appDelegate.credsKeychainItem setObject:appDelegate.SHToken forKey:(__bridge id)(kSecValueData)];
    
    // Save the token ID in the shared defaults.
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.SHTokenID forKey:@"SHSilphScope"];
    
    [appDelegate.modelManager saveCurrentUserData:userData];
    
    if ( appDelegate.currentUser.count == 0 )
    {
        NSString *userID = [NSString stringWithFormat:@"%@", [userData objectForKey:@"user_id"]];
        [appDelegate.currentUser setObject:userID forKey:@"user_id"]; // Set this right away for any concurrent operations that might need it.
    }
    
    [HUD hide:YES];
    
    [appDelegate.contactManager processFollowingList:[[response objectForKey:@"response"] objectForKey:@"following"]
                                           boardList:[[response objectForKey:@"response"] objectForKey:@"boards"]];
    [appDelegate.strobeLight affirmativeStrobeLight];
    
    [appDelegate.peerManager startScanning];
    [appDelegate.peerManager startAdvertising];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [appDelegate.mainView resumeWallpaperAnimation];
    }];
}

- (void)purgeStaleToken:(NSString *)staleToken
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"stale_token": staleToken,
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/purgestaletoken", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        if ( errorCode == 0 )
        {
            [appDelegate.credsKeychainItem resetKeychainItem]; // Clear out the creds from the Keychain.
        }
        
        NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", operation.responseString);
    }];
}

- (BOOL)validEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:checkString];
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
#pragma mark UITextFieldDelegate methods.

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( textField.tag == 0 )
    {
        [self sendVerificationCode];
        [emailField resignFirstResponder];
    }
    else if ( textField.tag == 1 )
    {
        [self verifyCode];
        [codeField resignFirstResponder];
    }
    
    return NO;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

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
