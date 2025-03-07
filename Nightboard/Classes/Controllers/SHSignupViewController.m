//
//  SHSignupViewController.m
//  Nightboard
//
//  Created by MachOSX on 2/7/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import "SHSignupViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "AFHTTPRequestOperationManager.h"
#import "AppDelegate.h"
#import "UIDeviceHardware.h"

@implementation SHSignupViewController

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        wallpaperShouldAnimate = YES;
        wallpaperIsAnimatingRight = NO;
        wallpaperDidChange_dawn = NO;
        wallpaperDidChange_day = NO;
        wallpaperDidChange_dusk = NO;
        wallpaperDidChange_night = NO;
        
        selectedImage = nil;
    }
    
    return self;
}

- (void)loadView
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UIView *contentView = [[UIView alloc] initWithFrame:appDelegate.screenBounds];
    contentView.backgroundColor = [UIColor blackColor];
    
    [self.navigationItem setHidesBackButton:YES]; // You can't go back beyond this point.
    
    photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.mediaTypes = @[(NSString *)kUTTypeImage];
    photoPicker.allowsEditing = YES;
    photoPicker.delegate = self;
    
    float scaleFactor = appDelegate.screenBounds.size.height / 568;
    
    wallpaper = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 750 * scaleFactor, appDelegate.screenBounds.size.height)];
    wallpaper.backgroundColor = [UIColor blackColor];
    wallpaper.opaque = YES;
    
    welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 175, appDelegate.screenBounds.size.width - 40, 65)];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:MAIN_FONT_SIZE];
    welcomeLabel.numberOfLines = 0;
    welcomeLabel.textColor = [UIColor whiteColor];
    welcomeLabel.text = NSLocalizedString(@"SIGNUP_WELCOME", nil);
    
    nameFieldBG = [[UIImageView alloc] initWithFrame:CGRectMake(20, 340, appDelegate.screenBounds.size.width - 40, 35)];
    nameFieldBG.image = [[UIImage imageNamed:@"button_round_white_transparent"] stretchableImageWithLeftCapWidth:18 topCapHeight:18];
    nameFieldBG.userInteractionEnabled = YES;
    
    nameField = [[UITextField alloc] initWithFrame:CGRectMake(13, 6, nameFieldBG.frame.size.width - 13, 24)];
    nameField.textColor  = [UIColor whiteColor];
    nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    nameField.returnKeyType = UIReturnKeyDone;
    nameField.enablesReturnKeyAutomatically = YES;
    nameField.tag = 1;
    nameField.delegate = self;
    
    nameFieldPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 6, nameFieldBG.frame.size.width - 11, 24)];
    nameFieldPlaceholderLabel.backgroundColor = [UIColor clearColor];
    nameFieldPlaceholderLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:MAIN_FONT_SIZE];
    nameFieldPlaceholderLabel.numberOfLines = 1;
    nameFieldPlaceholderLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    nameFieldPlaceholderLabel.text = NSLocalizedString(@"SIGNUP_PLACEHOLDER_NAME", nil);
    
    DPPreview = [[SHChatBubble alloc] initWithFrame:CGRectMake((appDelegate.screenBounds.size.width / 2) - (CHAT_CLOUD_BUBBLE_SIZE / 2), 80, CHAT_CLOUD_BUBBLE_SIZE, CHAT_CLOUD_BUBBLE_SIZE) withMiniModeEnabled:NO];
    DPPreview.delegate = self;
    
    if ( !(IS_IOS7) ) // Non-iOS 7 fixes.
    {
        DPPreview.frame = CGRectMake(120, 20, CHAT_CLOUD_BUBBLE_SIZE, CHAT_CLOUD_BUBBLE_SIZE);
        welcomeLabel.frame = CGRectMake(20, 115, 280, 65);
        nameFieldBG.frame = CGRectMake(20, 245, 280, 33);
    }
    
    [nameFieldBG addSubview:nameFieldPlaceholderLabel];
    [nameFieldBG addSubview:nameField];
    [contentView addSubview:wallpaper];
    [contentView addSubview:DPPreview];
    [contentView addSubview:welcomeLabel];
    [contentView addSubview:nameFieldBG];
    
    self.view = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"SIGNUP_TITLE", nil)];
    [DPPreview setImage:[UIImage imageNamed:@"user_placeholder"]];
    
    [self checkTimeOfDay];
    [self startWallpaperAnimation];
    
    timer_timeOfDayCheck = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(checkTimeOfDay) userInfo:nil repeats:YES]; // Run this every 1 minute.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionStatusBar];
    
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Live Wallpaper

- (void)startWallpaperAnimation
{
    // Keep the animation slow & mellow.
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        if ( wallpaperIsAnimatingRight )
        {
            if ( wallpaper.frame.origin.x < 0 )
            {
                wallpaper.frame = CGRectMake(wallpaper.frame.origin.x + 1, wallpaper.frame.origin.y, wallpaper.frame.size.width, wallpaper.frame.size.height);
            }
            else
            {
                wallpaperIsAnimatingRight = NO; // Go left now.
            }
        }
        else // Animating left.
        {
            if ( wallpaper.frame.origin.x > 320 - wallpaper.frame.size.width )
            {
                wallpaper.frame = CGRectMake(wallpaper.frame.origin.x - 1, wallpaper.frame.origin.y, wallpaper.frame.size.width, wallpaper.frame.size.height);
            }
            else
            {
                wallpaperIsAnimatingRight = YES; // Go right now.
            }
        }
    } completion:^(BOOL finished){
        if ( wallpaperShouldAnimate )
        {
            [self startWallpaperAnimation];
        }
    }];
}

- (void)stopWallpaperAnimation
{
    wallpaperShouldAnimate = NO;
}

#pragma mark -
#pragma mark Check the time of the day to set the wallpaper accordingly.

- (void)checkTimeOfDay
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDate *now = [NSDate date];
    NSDateComponents *components = [appDelegate.calendar components:NSHourCalendarUnit fromDate:now];
    
    if ( components.hour >= 6 && components.hour < 8 && !wallpaperDidChange_dawn )        // Dawn.
    {
        wallpaperImageName = @"wallpaper_dawn_1";
        wallpaperDidChange_dawn = YES;
        wallpaperDidChange_night = NO;
        
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            wallpaper.alpha = 0.0;
        } completion:^(BOOL finished){
            wallpaper.image = [UIImage imageNamed:wallpaperImageName];
            
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                wallpaper.alpha = 1.0;
            } completion:^(BOOL finished){
                
            }];
        }];
    }
    else if ( components.hour >= 8 && components.hour <= 16 && !wallpaperDidChange_day )  // Day.
    {
        wallpaperImageName = @"wallpaper_day_1";
        wallpaperDidChange_dawn = NO;
        wallpaperDidChange_day = YES;
        
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            wallpaper.alpha = 0.0;
        } completion:^(BOOL finished){
            wallpaper.image = [UIImage imageNamed:wallpaperImageName];
            
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                wallpaper.alpha = 1.0;
            } completion:^(BOOL finished){
                
            }];
        }];
    }
    else if ( components.hour >= 17 && components.hour <= 19 && !wallpaperDidChange_dusk ) // Dusk.
    {
        wallpaperImageName = @"wallpaper_dusk_1";
        wallpaperDidChange_day = NO;
        wallpaperDidChange_dusk = YES;
        // Each one resets the one before it.
        
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            wallpaper.alpha = 0.0;
        } completion:^(BOOL finished){
            wallpaper.image = [UIImage imageNamed:wallpaperImageName];
            
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                wallpaper.alpha = 1.0;
            } completion:^(BOOL finished){
                
            }];
        }];
    }
    else if ( (components.hour >= 20 || components.hour <= 5) && !wallpaperDidChange_night ) // Night.
    {
        // Since we use different images here, the selection is random.
        NSInteger randomChoice = arc4random_uniform(3);
        
        switch ( randomChoice )
        {
            case 0:
                wallpaperImageName = @"wallpaper_night_1";
                break;
                
            case 1:
                wallpaperImageName = @"wallpaper_night_2";
                break;
                
            case 2:
                wallpaperImageName = @"wallpaper_night_3";
                break;
                
            default:
                break;
        }
        
        wallpaperDidChange_dusk = NO;
        wallpaperDidChange_night = YES;
        
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            wallpaper.alpha = 0.0;
        } completion:^(BOOL finished){
            wallpaper.image = [UIImage imageNamed:wallpaperImageName];
            
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                wallpaper.alpha = 1.0;
            } completion:^(BOOL finished){
                
            }];
        }];
    }
}

#pragma mark -
#pragma mark Account Creation

- (void)createAccount
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    [appDelegate.strobeLight activateStrobeLight];
    
    NSString *name = nameField.text;
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ( name.length > 30 )
    {
        [appDelegate.strobeLight negativeStrobeLight];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GENERIC_TITLE_ERROR", nil)
                                                        message:NSLocalizedString(@"SIGNUP_ERROR_LENGTH_FIRST_NAME", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"GENERIC_OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSData *imageData = nil;
    
    if ( !_email )
    {
        [appDelegate.strobeLight negativeStrobeLight];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GENERIC_TITLE_ERROR", nil)
                                                        message:NSLocalizedString(@"SIGNUP_ERROR_EMAIL", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"GENERIC_OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ( selectedImage )
    {
        imageData = UIImageJPEGRepresentation(selectedImage, 1.0);
    }
    else
    {
        [appDelegate.strobeLight negativeStrobeLight];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GENERIC_TITLE_ERROR", nil)
                                                        message:NSLocalizedString(@"SIGNUP_ERROR_DP", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"GENERIC_OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [nameField resignFirstResponder];
    
    // Disable the fields.
    nameField.enabled = NO;
    DPPreview.enabled = NO;
    
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
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"name": name,
                                 @"email_address": _email,
                                 @"locale": [[NSLocale preferredLanguages] objectAtIndex:0],
                                 @"timezone": [NSNumber numberWithFloat:timezoneoffset],
                                 @"os_name": @"ios",
                                 @"os_version": [[UIDevice currentDevice] systemVersion],
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                 @"device_name": [[UIDevice currentDevice] name],
                                 @"device_type": [UIDeviceHardware platformNumericString],
                                 @"device_token": appDelegate.deviceToken};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/signup", SH_DOMAIN] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if ( selectedImage )
        {
            [formData appendPartWithFileData:imageData name:@"image_file" fileName:@"image_file.jpg" mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        [HUD hide:YES];
        
        if ( errorCode == 0 ) // Success!
        {
            NSDictionary *response = [responseObject objectForKey:@"response"];
            NSDictionary *userData = [response objectForKey:@"user_data"];
            userID = [NSString stringWithFormat:@"%@", [response objectForKey:@"userID"]];
            appDelegate.SHToken = [response objectForKey:@"SHToken"];
            appDelegate.SHTokenID = [response objectForKey:@"SHToken_id"];
            
            /*NSString *alias = @"";
            NSString *userHandle = @"";
            NSString *imageData_alias = @""; // Insert this as a blank string since the user can't have an alias DP for themselves.
            NSString *gender = @"";
            NSString *birthday = @"";
            NSString *location_country = @"";
            NSString *location_state = @"";
            NSString *location_city = @"";
            NSString *website = @"";
            NSString *bio = @"";
            NSString *joinDate = [userData objectForKey:@"join_date"];
            NSString *lastStatusID = [userData objectForKey:@"thread_id"];
            NSString *DPHash = [userData objectForKey:@"DP_hash"];
            NSData *DP = imageData;*/
            
            // Save the token in the Keychain.
            [appDelegate.credsKeychainItem setObject:appDelegate.SHToken forKey:(__bridge id)(kSecValueData)];
            
            // Save the token ID in the shared defaults.
            [[NSUserDefaults standardUserDefaults] setObject:appDelegate.SHTokenID forKey:@"SHSilphScope"];
            
            [appDelegate.modelManager saveCurrentUserData:userData];
            
            [appDelegate.strobeLight affirmativeStrobeLight];
            appDelegate.contactManager.delegate = appDelegate.mainView;
            
            [appDelegate.peerManager startScanning];
            [appDelegate.peerManager startAdvertising];
            
            [appDelegate.mainView showEmptyCloud];
            [self dismissViewControllerAnimated:YES completion:^{
                [appDelegate.mainView resumeWallpaperAnimation];
            }];
        }
        else if ( errorCode == 500 )
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@":(" message:NSLocalizedString(@"SIGNUP_ERROR_SIGNUP_HALT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"GENERIC_OK", nil) otherButtonTitles:nil];
            [alert show];
            
            [appDelegate.strobeLight negativeStrobeLight];
            
            // Re-enable the fields.
            nameField.enabled = YES;
            DPPreview.enabled = YES;
            
            [nameField becomeFirstResponder];
        }
        else
        {
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
                HUD.labelText = NSLocalizedString(@"GENERIC_HUD_NETWORK_RESPONSE_ERROR", nil);
                
                [HUD show:YES];
                [HUD hide:YES afterDelay:3];
                
                [appDelegate.strobeLight negativeStrobeLight];
                
                // Re-enable the fields.
                nameField.enabled = YES;
                DPPreview.enabled = YES;
                
                [nameField becomeFirstResponder];
            });
        }
        
        NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Re-enable the fields.
        nameField.enabled = YES;
        DPPreview.enabled = YES;
        
        [nameField becomeFirstResponder];
        
        [self showNetworkError];
        
        NSLog(@"Error: %@", operation.responseString);
    }];
}

#pragma mark -
#pragma mark DP Options

- (void)showDPOptions
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIActionSheet *actionSheet;
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) // If the device has a camera.
    {
        if ( !selectedImage )
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SIGNUP_DP_SHEET_TITLE", nil)
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:NSLocalizedString(@"GENERIC_PHOTO_CAMERA_VERBOSE", nil),
                           NSLocalizedString(@"GENERIC_PHOTO_LIBRARY_VERBOSE", nil),
                           NSLocalizedString(@"GENERIC_PHOTO_LAST_TAKEN", nil), nil];
        }
        else
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SIGNUP_DP_SHEET_TITLE", nil)
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                        destructiveButtonTitle:NSLocalizedString(@"GENERIC_PHOTO_REMOVE", nil)
                                             otherButtonTitles:NSLocalizedString(@"GENERIC_PHOTO_CAMERA_VERBOSE", nil),
                           NSLocalizedString(@"GENERIC_PHOTO_LIBRARY_VERBOSE", nil),
                           NSLocalizedString(@"GENERIC_PHOTO_LAST_TAKEN", nil), nil];
        }
    }
    else
    {
        if ( !selectedImage )
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SIGNUP_DP_SHEET_TITLE", nil)
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:NSLocalizedString(@"GENERIC_PHOTO_LIBRARY_VERBOSE", nil),
                           NSLocalizedString(@"GENERIC_PHOTO_LAST_TAKEN", nil), nil];
        }
        else
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SIGNUP_DP_SHEET_TITLE", nil)
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                        destructiveButtonTitle:NSLocalizedString(@"GENERIC_PHOTO_REMOVE", nil)
                                             otherButtonTitles:NSLocalizedString(@"GENERIC_PHOTO_LIBRARY_VERBOSE", nil),
                           NSLocalizedString(@"GENERIC_PHOTO_LAST_TAKEN", nil), nil];
        }
    }
    
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = 0;
    
    [actionSheet showFromRect:CGRectMake(0, screenBounds.size.height - 44, screenBounds.size.width, 44) inView:self.view animated:YES];
}

- (void)DP_Camera
{
    photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    photoPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self stopWallpaperAnimation];
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)DP_Library
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self stopWallpaperAnimation];
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)DP_UseLastPhotoTaken
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop){
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets] - 1] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop){
            
            // The end of the enumeration is signaled by asset == nil.
            if ( alAsset )
            {
                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                selectedImage = [UIImage imageWithCGImage:[representation fullScreenImage]];
                
                CGImageRef imageRef = CGImageCreateWithImageInRect([selectedImage CGImage], CGRectMake(selectedImage.size.width / 2 - 160, selectedImage.size.height / 2 - 160, 320, 320));
                selectedImage = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                
                UIImageView *preview = [[UIImageView alloc] initWithImage:selectedImage];
                preview.frame = CGRectMake(0, 0, 320, 320);
                
                // Next, we basically take a screenshot of it again.
                UIGraphicsBeginImageContext(preview.bounds.size);
                [preview.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [DPPreview setImage:thumbnail];
            }
        }];
    } failureBlock: ^(NSError *error){
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
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
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [self startWallpaperAnimation];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self startWallpaperAnimation];
    
    selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    container.clipsToBounds = YES;
    
    UIImageView *preview = [[UIImageView alloc] initWithImage:selectedImage];
    preview.contentMode = UIViewContentModeScaleAspectFill;
    preview.frame = CGRectMake(0, 0, 320, 320);
    
    // Center the preview inside the container.
    float oldWidth = selectedImage.size.width;
    float scaleFactor = container.frame.size.width / oldWidth;
    
    float newHeight = selectedImage.size.height * scaleFactor;
    
    if ( newHeight > container.frame.size.height )
    {
        int delta = fabs(newHeight - container.frame.size.height);
        preview.frame = CGRectMake(0, -delta / 2, preview.frame.size.width, preview.frame.size.height);
    }
    else
    {
        preview.frame = CGRectMake(0, 0, preview.frame.size.width, preview.frame.size.height);
    }
    
    [container addSubview:preview];
    
    // Next, we basically take a screenshot of it again.
    UIGraphicsBeginImageContext(container.bounds.size);
    [container.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [DPPreview setImage:thumbnail];
    
    if ( nameField.text.length > 0 )
    {
        [self createAccount];
    }
    else
    {
        [nameField becomeFirstResponder];
    }
}

#pragma mark -
#pragma mark SHChatBubbleDelegate methods.

// Forward these to the chat cloud delegate.
- (void)didSelectBubble:(SHChatBubble *)bubble
{
    [self showDPOptions];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods.

- (void)textFieldDidChange:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    NSString *text = textField.text;
    
    if ( text.length > 0 )
    {
        nameFieldPlaceholderLabel.hidden = YES;
    }
    else
    {
        nameFieldPlaceholderLabel.hidden = NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ( !(IS_IOS7) ) // Non-iOS 7 fixes.
    {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            welcomeLabel.alpha = 0.0;
            welcomeLabel.frame = CGRectMake(welcomeLabel.frame.origin.x, welcomeLabel.frame.origin.y - 5, welcomeLabel.frame.size.width, welcomeLabel.frame.size.height);
            nameFieldBG.frame = CGRectMake(nameFieldBG.frame.origin.x, 115, nameFieldBG.frame.size.width, nameFieldBG.frame.size.height);
        } completion:^(BOOL finished){
            welcomeLabel.hidden = YES;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            welcomeLabel.alpha = 0.0;
            welcomeLabel.frame = CGRectMake(welcomeLabel.frame.origin.x, welcomeLabel.frame.origin.y - 5, welcomeLabel.frame.size.width, welcomeLabel.frame.size.height);
            nameFieldBG.frame = CGRectMake(nameFieldBG.frame.origin.x, 175, nameFieldBG.frame.size.width, nameFieldBG.frame.size.height);
        } completion:^(BOOL finished){
            welcomeLabel.hidden = YES;
        }];
    }
    
    
    // Monitor keystrokes.
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField removeTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( nameField.text.length > 0 && selectedImage )
    {
        [self createAccount];
    }
    else if ( !selectedImage )
    {
        [self showDPOptions];
    }
    
    return NO;
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( actionSheet.tag == 0 ) // DP options.
    {
        if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) // If the device has a camera.
        {
            if ( !selectedImage )
            {
                if ( buttonIndex == 0 )      // Camera.
                {
                    [self DP_Camera];
                }
                else if ( buttonIndex == 1 ) // Library.
                {
                    [self DP_Library];
                }
                else if ( buttonIndex == 2 ) // Last photo taken.
                {
                    [self DP_UseLastPhotoTaken];
                }
            }
            else
            {
                if ( buttonIndex == 0 )      // Remove photo.
                {
                    UIImageView *preview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_placeholder"]];
                    preview.frame = CGRectMake(0, 0, 100, 100);
                    
                    // Next, we basically take a screenshot of it again.
                    UIGraphicsBeginImageContext(preview.bounds.size);
                    [preview.layer renderInContext:UIGraphicsGetCurrentContext()];
                    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    [DPPreview setImage:thumbnail];
                    
                    selectedImage = nil;
                }
                else if ( buttonIndex == 1 ) // Camera.
                {
                    [self DP_Camera];
                }
                else if ( buttonIndex == 2 ) // Library.
                {
                    [self DP_Library];
                }
                else if ( buttonIndex == 3 ) // Last photo taken.
                {
                    [self DP_UseLastPhotoTaken];
                }
            }
        }
        else
        {
            if ( !selectedImage )
            {
                if ( buttonIndex == 0 ) // Library.
                {
                    [self DP_Library];
                }
                else if ( buttonIndex == 1 ) // Last photo taken.
                {
                    [self DP_UseLastPhotoTaken];
                }
            }
            else
            {
                if ( buttonIndex == 0 )      // Remove photo.
                {
                    UIImageView *preview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_placeholder"]];
                    preview.frame = CGRectMake(0, 0, 100, 100);
                    
                    // Next, we basically take a screenshot of it again.
                    UIGraphicsBeginImageContext(preview.bounds.size);
                    [preview.layer renderInContext:UIGraphicsGetCurrentContext()];
                    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    [DPPreview setImage:thumbnail];
                    
                    selectedImage = nil;
                }
                else if ( buttonIndex == 1 ) // Library.
                {
                    [self DP_Library];
                }
                else if ( buttonIndex == 2 ) // Last photo taken.
                {
                    [self DP_UseLastPhotoTaken];
                }
            }
        }
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
