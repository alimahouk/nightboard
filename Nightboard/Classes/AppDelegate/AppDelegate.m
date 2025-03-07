//
//  AppDelegate.m
//  Theboard
//
//  Created by MachOSX on 1/27/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import "AppDelegate.h"
#import "SHLoginViewController.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation AppDelegate

@class MainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _screenBounds = [[UIScreen mainScreen] bounds];
    
    _currentUser = [[NSMutableDictionary alloc] init];
    
    // Let the device know we want to receive push notifications.
    if ( [[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)] )
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    // Override point for customization after application launch.
    _mainView = [[SHMainViewController alloc] init];
    _mainNavigationController = [[UINavigationController alloc] initWithRootViewController:_mainView];
    
    _window = [[UIWindow alloc] initWithFrame:_screenBounds];
    _window.backgroundColor = [UIColor blackColor];
    _window.rootViewController = _mainNavigationController;
    [_window makeKeyAndVisible];
    
    _strobeLight = [[SHStrobeLight alloc] init];
    [_strobeLight setStrobeLightPosition:SHStrobeLightPositionStatusBar];
    [_window addSubview:_strobeLight];
    
    _modelManager = [[SHModelManager alloc] init];
    
    [self refreshCurrentUserData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _deviceToken = @"";
        
        _calendar = [NSCalendar currentCalendar];
        [_calendar setTimeZone:[NSTimeZone localTimeZone]];
        
        // Initialize the Keychain items.
        _credsKeychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"SHBD_CREDS" accessGroup:nil];
        [_credsKeychainItem setObject:@"SHBD_CREDS" forKey: (__bridge id)kSecAttrService];
        
        _contactManager = [[SHContactManager alloc] init];
        _locationManager = [[SHLocationManager alloc] init];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // Check if there's someone logged in.
        if ( [userDefaults stringForKey:@"SHSilphScope"] )
        {
            _SHToken = [_credsKeychainItem objectForKey:(__bridge id)(kSecValueData)];
            [_currentUser setObject:_SHToken forKey:@"access_token"];
            
            _preference_UseBluetooth = [[userDefaults stringForKey:@"SHBUseBluetooth"] boolValue];
            
            // Check if the app was launched via a push notif.
            NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_mainView loadCloud];
                
                if ( remoteNotification )
                {
                    [self handlePushNotification:remoteNotification withApplicationState:UIApplicationStateBackground];
                }
            });
        }
        else // Show login.
        {
            // Store default settings values.
            [userDefaults setObject:@"YES" forKey:@"SHBUseBluetooth"];
            _preference_UseBluetooth = YES;
            
            NSString *staleToken = [_credsKeychainItem objectForKey:(__bridge id)(kSecValueData)];
            
            SHLoginViewController *loginView = [[SHLoginViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginView];
            
            if ( staleToken && staleToken.length > 0 )
            {
                [loginView purgeStaleToken:staleToken]; // Clear out any old creds from the Keychain.
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_mainView stopWallpaperAnimation]; // Save power.
                [_mainNavigationController presentViewController:navigationController animated:NO completion:nil];
            });
        }
        
        _peerManager = [[SHPeerManager alloc] init];
    });
    
    // Automatically start and stop the network activity indicator in the status bar.
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ( _SHToken.length > 0 )
    {
        [_peerManager stopScanning]; // Save power, but keep advertising.
        [_mainView pauseTimeOfDayCheck];
        [_mainView stopWallpaperAnimation]; // Save power.
        
        // Hide the camera UI if it's visible (memory issues).
        if ( _mainView.mediaPickerSourceIsCamera )
        {
            [_mainView dismissMediaPicker];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if ( _SHToken.length > 0 )
    {
        [_peerManager dumpDiscoveredPeers];
        [_peerManager startScanning];
        [_contactManager requestRecommendationListForced:NO];
        [_mainView startTimeOfDayCheck];
        
        if ( !_mainView.wallpaperIsAnimating )
        {
            [_mainView resumeWallpaperAnimation];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_contactManager refreshMagicNumbersWithDB:nil callback:NO]; // Runs every 24 hours.
        });
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [_peerManager terminateConnections];
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    if ( _strobeLight.position != SHStrobeLightPositionFullScreen )
    {
        _strobeLight.position = _strobeLight.position; // Causes it to redraw itself in the right position.
    }
}

#pragma mark -
#pragma mark Push Notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    _deviceToken = [[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""];
    _deviceToken = [_deviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    _deviceToken = [_deviceToken stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    //UIAlertView *test = [[UIAlertView alloc] initWithTitle:@"" message:_deviceToken delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    //[test show];
    
    [_contactManager downloadLatestCurrentUserData]; // Contact refresh happens inside this method once it completes.
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get device token, error: %@", error);
    _deviceToken = @"";
    
    [_contactManager downloadLatestCurrentUserData];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ( userInfo )
    {
        [self handlePushNotification:userInfo withApplicationState:application.applicationState];
    }
}

- (void)handlePushNotification:(NSDictionary *)notification withApplicationState:(UIApplicationState)applicationState
{
    NSString *notificationType = [notification objectForKey:@"type"];
    
    if ( [notificationType isEqualToString:@"new_follower"] ) // New contact added the user.
    {
        NSString *userID = [notification objectForKey:@"user_id"];
        
        _mainView.profileView.ownerID = userID;
        [_mainView.profileView loadInfoOverNetwork];
    }
    else if ( [notificationType isEqualToString:@"board_request"] )
    {
        NSString *boardID = [notification objectForKey:@"board_id"];
        
        [_mainView showBoardForID:boardID];
    }
}

#pragma mark -
#pragma mark Delegate static functions.
// Return a shared delegate.
+ (AppDelegate *)sharedDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)refreshCurrentUserData
{
    _currentUser = [_modelManager refreshCurrentUserData];
    _SHToken = [_currentUser objectForKey:@"access_token"];
    _SHTokenID = [_currentUser objectForKey:@"access_token_id"];
}

- (void)lockdownApp
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"critical update required!" message:@"You're using an unsupported version of Nightboard! Some things might not work properly anymore. Go to the App Store & update to the latest version." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    [alert show];
}

- (void)logout
{
    
}

- (BOOL)isDeviceLanguageRTL
{
    return ( [NSLocale characterDirectionForLanguage:[[NSLocale preferredLanguages] objectAtIndex:0]] == NSLocaleLanguageDirectionRightToLeft );
}

#pragma mark -
#pragma mark Time

- (NSString *)relativeTimefromDate:(NSDate *)targetDate shortened:(BOOL)shortened condensed:(BOOL)condensed
{
    NSDate *currentTime = [NSDate date];
    
    NSDateComponents *targetDateComponents = [_calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:targetDate];
    NSInteger targetHour = [targetDateComponents hour];
    NSInteger targetMinute = [targetDateComponents minute];
    NSString *timePeriod = @"am";
    
    if ( targetHour > 12 ) // Convert back to 12-hour format for display purposes.
    {
        targetHour -= 12;
        timePeriod = @"pm";
    }
    
    if ( targetHour == 12 ) // This needs its own fix for the case of 12 pm.
    {
        timePeriod = @"pm";
    }
    
    if ( targetHour == 0 )
    {
        targetHour = 12;
        timePeriod = @"am";
    }
    
    int timeElapsed = [targetDate timeIntervalSinceDate:currentTime] * -1; // In seconds.
    int minute = 60;
    int hour = 60 * 60;
    int day = 60 * 60 * 24;
    int month = 60 * 60 * 24 * 30;
    
    if ( timeElapsed < 1 * minute )
    {
        if ( shortened )
        {
            return @"now";
        }
        
        return @"just now";
    }
    
    if ( timeElapsed < 2 * minute )
    {
        if ( condensed )
        {
            return @"1m ago";
        }
        
        return @"a minute ago";
    }
    
    if ( timeElapsed < 45 * minute )
    {
        if ( shortened )
        {
            return [NSString stringWithFormat:@"%dm ago", (int)floor(timeElapsed / minute)];
        }
        
        return [NSString stringWithFormat:@"%d minutes ago", (int)floor(timeElapsed / minute)];
    }
    
    if ( timeElapsed < 90 * minute - 30 )
    {
        if ( condensed )
        {
            return @"1h ago";
        }
        
        return @"an hour ago";
    }
    
    if ( timeElapsed < 90 * minute - 15 )
    {
        if ( condensed )
        {
            return @"1h ago";
        }
        
        return @"an hour & a half ago";
    }
    
    if ( timeElapsed < 24 * hour )
    {
        int hours = (int)ceil(timeElapsed / hour);
        
        if ( shortened )
        {
            return [NSString stringWithFormat:@"%dh ago", hours];
        }
        
        return [NSString stringWithFormat:@"%d hour%@ ago", hours, hours == 1 ? @"" : @"s"];
    }
    
    if ( timeElapsed < 36 * hour ) // Makes less sense to use exactly 48 hours.
    {
        if ( condensed )
        {
            return @"1d ago.";
        }
        
        return [NSString stringWithFormat:@"yesterday, %d:%02d %@", (int)targetHour, (int)targetMinute, timePeriod];
    }
    
    if ( timeElapsed < 30 * day )
    {
        int days = (int)floor(timeElapsed / day);
        
        if ( condensed )
        {
            return [NSString stringWithFormat:@"%dd ago", days];
        }
        
        if ( shortened )
        {
            return [NSString stringWithFormat:@"%dd ago, %d:%02d %@", days, (int)targetHour, (int)targetMinute, timePeriod];
        }
        
        return [NSString stringWithFormat:@"%d day%@ ago, %d:%02d %@", days, days == 1 ? @"" : @"s", (int)targetHour, (int)targetMinute, timePeriod];
    }
    
    if ( timeElapsed < 12 * month )
    {
        int months = floor(timeElapsed / day / 30);
        
        if ( condensed )
        {
            return [NSString stringWithFormat:@"%dmo ago", months];
        }
        
        if ( shortened )
        {
            return [NSString stringWithFormat:@"%dmo ago, %d:%02d %@", months, (int)targetHour, (int)targetMinute, timePeriod];
        }
        
        return [NSString stringWithFormat:@"%d month%@ ago, %d:%02d %@", months, months == 1 ? @"" : @"s", (int)targetHour, (int)targetMinute, timePeriod];
    }
    else
    {
        int years = floor(timeElapsed / day / 365);
        
        if ( condensed )
        {
            return [NSString stringWithFormat:@"%dy ago", years];
        }
        
        if ( shortened )
        {
            return [NSString stringWithFormat:@"%dy ago, %d:%02d %@", years, (int)targetHour, (int)targetMinute, timePeriod];
        }
        
        return [NSString stringWithFormat:@"%d year%@ ago, %d:%02d %@", years, years == 1 ? @"" : @"s", (int)targetHour, (int)targetMinute, timePeriod];
    }
}

- (NSString *)dayForTime:(NSDate *)targetDate relative:(BOOL)relative condensed:(BOOL)condensed
{
    if ( relative )
    {
        NSDate *dateToday = [NSDate date];
        
        NSDateComponents *dateTodayComponents = [_calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:dateToday];
        NSInteger dayToday = dateTodayComponents.day;
        NSInteger monthToday = dateTodayComponents.month;
        NSInteger yearToday = dateTodayComponents.year;
        
        NSDateComponents *targetDateComponents = [_calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:targetDate];
        NSInteger day = targetDateComponents.day;
        NSInteger month = targetDateComponents.month;
        NSInteger year = targetDateComponents.year;
        
        if ( day == dayToday && month == monthToday && year == yearToday )
        {
            return @"today";
        }
        else if ( day == dayToday - 1 && (month == monthToday || month == monthToday - 1) && year == yearToday ) // Account for the previous day being the last day of the previous month.
        {
            return @"yesterday";
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    if ( condensed )
    {
        [dateFormatter setDateFormat:@"ccc, d MMM, yyyy"];
    }
    else
    {
        [dateFormatter setDateFormat:@"cccc, d MMMM, yyyy"];
    }
    
    return [dateFormatter stringFromDate:targetDate];
}

#pragma mark -
#pragma mark Parallax Motion Effects

- (void)registerPrallaxEffectForView:(UIView *)aView depth:(CGFloat)depth
{
    UIInterpolatingMotionEffect *effectX;
    UIInterpolatingMotionEffect *effectY;
    effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                              type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                              type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    
    effectX.maximumRelativeValue = @(depth);
    effectX.minimumRelativeValue = @(-depth);
    effectY.maximumRelativeValue = @(depth);
    effectY.minimumRelativeValue = @(-depth);
    
    [aView addMotionEffect:effectX];
    [aView addMotionEffect:effectY];
}

- (void)registerPrallaxEffectForBackground:(UIView *)aView depth:(CGFloat)depth
{
    UIInterpolatingMotionEffect *effectX;
    UIInterpolatingMotionEffect *effectY;
    effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                              type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                              type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    
    effectX.maximumRelativeValue = @(-depth);
    effectX.minimumRelativeValue = @(depth);
    effectY.maximumRelativeValue = @(-depth);
    effectY.minimumRelativeValue = @(depth);
    
    [aView addMotionEffect:effectX];
    [aView addMotionEffect:effectY];
}

- (void)unregisterPrallaxEffectForView:(UIView *)aView
{
    aView.motionEffects = nil;
}

#pragma mark -
#pragma mark Images

// Convert the image's fill color to the passed in color.
- (UIImage *)imageFilledWith:(UIColor *)color using:(UIImage *)startImage
{
    // Create the proper sized rect
    CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(startImage.CGImage), CGImageGetHeight(startImage.CGImage));
    
    // Create a new bitmap context
    CGContextRef context = CGBitmapContextCreate(NULL, imageRect.size.width, imageRect.size.height, 8, 0, CGImageGetColorSpace(startImage.CGImage), kCGImageAlphaPremultipliedLast);
    
    // Use the passed in image as a clipping mask
    CGContextClipToMask(context, imageRect, startImage.CGImage);
    // Set the fill color
    CGContextSetFillColorWithColor(context, color.CGColor);
    // Fill with color
    CGContextFillRect(context, imageRect);
    
    // Generate a new image
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newCGImage scale:startImage.scale orientation:startImage.imageOrientation];
    
    // Cleanup
    CGContextRelease(context);
    CGImageRelease(newCGImage);
    
    return newImage;
}

- (UIColor *)colorForCode:(SHPostColor)code
{
    switch ( code )
    {
        case SHPostColorWhite:
            return [UIColor whiteColor];
            
        case SHPostColorRed:
            return [UIColor colorWithRed:255/255.0 green:138/255.0 blue:138/255.0 alpha:1.0];
            
        case SHPostColorGreen:
            return [UIColor colorWithRed:189/255.0 green:255/255.0 blue:138/255.0 alpha:1.0];
            
        case SHPostColorBlue:
            return [UIColor colorWithRed:189/255.0 green:236/255.0 blue:255/255.0 alpha:1.0];
            
        case SHPostColorPink:
            return [UIColor colorWithRed:255/255.0 green:214/255.0 blue:239/255.0 alpha:1.0];
            
        case SHPostColorYellow:
            return [UIColor colorWithRed:255/255.0 green:243/255.0 blue:112/255.0 alpha:1.0];
        default:
            return [UIColor whiteColor];
            break;
    }
}

@end
