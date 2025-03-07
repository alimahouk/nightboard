//
//  SHMainViewController.m
//  Theboard
//
//  Created by MachOSX on 1/27/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <Audiotoolbox/AudioToolbox.h>
#import "SHMainViewController.h"

#import "NSString+Utils.h"

#import "AFHTTPRequestOperationManager.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "SHBoardViewController.h"
#import "SHCreateBoardViewController.h"

@implementation SHMainViewController

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        _wallpaperIsAnimating = NO;
        wallpaperShouldAnimate = YES;
        wallpaperIsAnimatingRight = NO;
        wallpaperDidChange_dawn = NO;
        wallpaperDidChange_day = NO;
        wallpaperDidChange_dusk = NO;
        wallpaperDidChange_night = NO;
        isShowingSearchInterface = NO;
        isShowingNewPeerNotification = NO;
        _isFullscreen = NO;
        _isRenamingContact = NO;
        _isPickingAliasDP = NO;
        _isPickingDP = NO;
        _isPickingMedia = NO;
        _shouldEnterFullscreen = YES;
        _mediaPickerSourceIsCamera = NO;
        
        _profileView = [[SHProfileViewController alloc] init];
        _profileView.callbackView = self;
        
        _mainWindowNavigationController = [[SHOrientationNavigationController alloc] initWithRootViewController:_profileView];
        _mainWindowNavigationController.autoRotates = NO;
        
        randomQuotes = @[@"Bazinga!",
                         @"I don't even know what a quail looks like.",
                         @"Too close for missiles, I'm switching to guns.",
                         @"That’s a negative, Ghostrider. The pattern is full.",
                         @"When life gives you lemons, make lemonade.",
                         @"The cake is a lie.",
                         @"Sarcasm Self Test complete.",
                         @"Now you know who you're fighting.",
                         @"an Ali Mahouk production",
                         @"We'll send you a Hogwarts toilet seat.",
                         @"Get the Snitch or die trying.",
                         @"I solemnly swear that I am up to no good.",
                         @"When 900 years old, you reach… Look as good, you will not.",
                         @"He’s holding a thermal detonator!",
                         @"It's a trap!",
                         @"Aren't you a little short for a stormtrooper?",
                         @"These aren’t the droids you’re looking for…",
                         @"I find your lack of faith disturbing.",
                         @"There's always a bigger fish.",
                         @"I am the one who knocks.",
                         @"Only a Sith deals in absolutes.",
                         @"Manners maketh man.",
                         @"A wizard is never late."];
    }
    
    return self;
}

- (void)loadView
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UIView *contentView = [[UIView alloc] initWithFrame:appDelegate.screenBounds];
    contentView.backgroundColor = [UIColor blackColor];
    contentView.clipsToBounds = YES;
    
    _mainWindowContainer = [[UIView alloc] initWithFrame:CGRectMake(appDelegate.screenBounds.size.width, 0, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height - ([UIApplication sharedApplication].statusBarFrame.size.height - 20))];
    
    photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.mediaTypes = @[(NSString *)kUTTypeImage];
    photoPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    photoPicker.videoMaximumDuration = 60 * 10;
    photoPicker.delegate = self;
    
    _contactCloud = [[SHContactCloud alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height)];
    _contactCloud.delegate = self;
    _contactCloud.cloudDelegate = self;
    _contactCloud.tag = 0;
    
    int rand = arc4random_uniform((int)randomQuotes.count);
    
    _contactCloud.footerLabel.text = [randomQuotes objectAtIndex:rand];
    
    float scaleFactor = appDelegate.screenBounds.size.height / 568;
    
    _wallpaper = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 750 * scaleFactor, appDelegate.screenBounds.size.height)];
    _wallpaper.backgroundColor = [UIColor blackColor];
    _wallpaper.opaque = YES;
    
    _windowSideShadow = [[UIImageView alloc] initWithFrame:CGRectMake(-7, 20, 7, appDelegate.screenBounds.size.height - 20)];
    _windowSideShadow.image = [[UIImage imageNamed:@"shadow_vertical_right"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    _windowSideShadow.opaque = YES;
    
    _windowCompositionLayer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height)];
    _windowCompositionLayer.contentSize = CGSizeMake(appDelegate.screenBounds.size.width * 2, appDelegate.screenBounds.size.height);
    _windowCompositionLayer.pagingEnabled = YES;
    _windowCompositionLayer.showsHorizontalScrollIndicator = NO;
    _windowCompositionLayer.showsVerticalScrollIndicator = NO;
    _windowCompositionLayer.scrollEnabled = NO;
    _windowCompositionLayer.scrollsToTop = NO;
    _windowCompositionLayer.delegate = self;
    _windowCompositionLayer.tag = 66;
    
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_searchButton setBackgroundImage:[[UIImage imageNamed:@"button_round_white_transparent"] stretchableImageWithLeftCapWidth:18 topCapHeight:18] forState:UIControlStateNormal];
    [_searchButton addTarget:self action:@selector(showSearchInterface) forControlEvents:UIControlEventTouchUpInside];
    _searchButton.frame = CGRectMake(10, 25, 35, 35);
    _searchButton.adjustsImageWhenDisabled = NO;
    _searchButton.showsTouchWhenHighlighted = YES;
    _searchButton.opaque = YES;
    
    _profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_profileButton setBackgroundImage:[[UIImage imageNamed:@"button_round_white_transparent"] stretchableImageWithLeftCapWidth:18 topCapHeight:18] forState:UIControlStateNormal];
    [_profileButton addTarget:self action:@selector(showUserProfile) forControlEvents:UIControlEventTouchUpInside];
    _profileButton.frame = CGRectMake(appDelegate.screenBounds.size.width / 2 - 80, 25, 35, 35);
    _profileButton.showsTouchWhenHighlighted = YES;
    _profileButton.opaque = YES;
    
    _createBoardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_createBoardButton setTitle:@"+" forState:UIControlStateNormal];
    [_createBoardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_createBoardButton setBackgroundImage:[[UIImage imageNamed:@"button_round_white_transparent"] stretchableImageWithLeftCapWidth:18 topCapHeight:18] forState:UIControlStateNormal];
    [_createBoardButton addTarget:self action:@selector(showBoardCreator) forControlEvents:UIControlEventTouchUpInside];
    [_createBoardButton setTitleEdgeInsets:UIEdgeInsetsMake(-5, 0, 0, 0)];
    _createBoardButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    _createBoardButton.frame = CGRectMake(appDelegate.screenBounds.size.width / 2 + 45, 25, 35, 35);
    _createBoardButton.showsTouchWhenHighlighted = YES;
    _createBoardButton.opaque = YES;
    
    _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_refreshButton setBackgroundImage:[[UIImage imageNamed:@"button_round_white_transparent"] stretchableImageWithLeftCapWidth:18 topCapHeight:18] forState:UIControlStateNormal];
    [_refreshButton addTarget:self action:@selector(refreshCloud) forControlEvents:UIControlEventTouchUpInside];
    _refreshButton.frame = CGRectMake(appDelegate.screenBounds.size.width - 45, 25, 35, 35);
    _refreshButton.showsTouchWhenHighlighted = YES;
    _refreshButton.opaque = YES;
    
    _chatCloudCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_chatCloudCenterButton setBackgroundImage:[[UIImage imageNamed:@"button_round_white_transparent"] stretchableImageWithLeftCapWidth:18 topCapHeight:18] forState:UIControlStateNormal];
    [_chatCloudCenterButton addTarget:self action:@selector(jumpToChatCloudCenter) forControlEvents:UIControlEventTouchUpInside];
    _chatCloudCenterButton.frame = CGRectMake(-33, appDelegate.screenBounds.size.height - 45, 35, 35);
    _chatCloudCenterButton.showsTouchWhenHighlighted = YES;
    _chatCloudCenterButton.alpha = 0.0;
    _chatCloudCenterButton.opaque = YES;
    _chatCloudCenterButton.hidden = YES;
    
    inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:NSLocalizedString(@"SETTINGS_OPTION_INVITE", nil) forState:UIControlStateNormal];
    [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [inviteButton addTarget:self action:@selector(showInvitationOptions) forControlEvents:UIControlEventTouchUpInside];
    inviteButton.frame = CGRectMake(20, (_contactCloud.frame.size.height / 2) + 50, _contactCloud.frame.size.width - 40, 33);
    inviteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MAIN_FONT_SIZE];
    inviteButton.titleLabel.clipsToBounds = NO;
    inviteButton.titleLabel.layer.masksToBounds = NO;
    inviteButton.titleLabel.layer.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    inviteButton.titleLabel.layer.shadowRadius = 4.0f;
    inviteButton.titleLabel.layer.shadowOpacity = 0.9;
    inviteButton.titleLabel.layer.shadowOffset = CGSizeZero;
    inviteButton.opaque = YES;
    inviteButton.hidden = YES;
    
    searchCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchCancelButton setBackgroundImage:[[UIImage imageNamed:@"button_rect_bg_white"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] forState:UIControlStateNormal];
    [searchCancelButton setTitle:NSLocalizedString(@"GENERIC_CANCEL", nil) forState:UIControlStateNormal];
    [searchCancelButton setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
    [searchCancelButton addTarget:self action:@selector(dismissSearchInterface) forControlEvents:UIControlEventTouchUpInside];
    searchCancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    searchCancelButton.frame = CGRectMake(250, 25, 70, 35);
    searchCancelButton.alpha = 0.0;
    searchCancelButton.opaque = YES;
    searchCancelButton.hidden = YES;
    
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 16, 16)];
    searchIcon.image = [UIImage imageNamed:@"search_white"];
    
    UIImageView *profileIcon = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 16, 16)];
    profileIcon.image = [UIImage imageNamed:@"profile_white"];
    
    UIImageView *refreshIcon = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 16, 16)];
    refreshIcon.image = [UIImage imageNamed:@"refresh_white"];
    
    UIImageView *chatCloudCenterIcon = [[UIImageView alloc] initWithFrame:CGRectMake(9.5, 9.5, 16, 16)];
    chatCloudCenterIcon.image = [UIImage imageNamed:@"center_white"];
    
    searchBox = [[UITextField alloc] initWithFrame:CGRectMake(30, 6, appDelegate.screenBounds.size.width - searchCancelButton.frame.size.width - 50, 24)];
    searchBox.textColor  = [UIColor whiteColor];
    searchBox.placeholder = NSLocalizedString(@"CHAT_CLOUD_PLACEHOLDER_SEARCH", nil);
    searchBox.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchBox.returnKeyType = UIReturnKeyGo;
    searchBox.enablesReturnKeyAutomatically = YES;
    searchBox.alpha = 0.0;
    searchBox.hidden = YES;
    searchBox.tag = 0;
    searchBox.delegate = self;
    
    contactCloudInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (_contactCloud.frame.size.height / 2 ) - 20, _contactCloud.frame.size.width - 40, 55)];
    contactCloudInfoLabel.backgroundColor = [UIColor clearColor];
    contactCloudInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:MAIN_FONT_SIZE];
    contactCloudInfoLabel.textColor = [UIColor whiteColor];
    contactCloudInfoLabel.textAlignment = NSTextAlignmentCenter;
    contactCloudInfoLabel.text = NSLocalizedString(@"CHAT_CLOUD_LOADING", nil);
    contactCloudInfoLabel.numberOfLines = 0;
    contactCloudInfoLabel.clipsToBounds = NO;
    contactCloudInfoLabel.layer.masksToBounds = NO;
    contactCloudInfoLabel.layer.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    contactCloudInfoLabel.layer.shadowRadius = 4.0;
    contactCloudInfoLabel.layer.shadowOpacity = 0.9;
    contactCloudInfoLabel.layer.shadowOffset = CGSizeZero;
    contactCloudInfoLabel.opaque = YES;
    
    UIColor *outerColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    UIColor *innerColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    
    // Adding transparency to the top & bottom of the Chat Cloud.
    maskLayer_ChatCloud = [CAGradientLayer layer];
    maskLayer_ChatCloud.colors = [NSArray arrayWithObjects:(__bridge id)innerColor.CGColor, (__bridge id)outerColor.CGColor, (__bridge id)outerColor.CGColor, (__bridge id)innerColor.CGColor, nil];
    maskLayer_ChatCloud.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                                     [NSNumber numberWithFloat:0.2],
                                     [NSNumber numberWithFloat:0.8],
                                     [NSNumber numberWithFloat:1.0], nil];
    
    maskLayer_ChatCloud.bounds = CGRectMake(0, 0, _contactCloud.frame.size.width, _contactCloud.frame.size.height);
    maskLayer_ChatCloud.position = CGPointMake(_contactCloud.contentOffset.x, _contactCloud.contentOffset.y);
    maskLayer_ChatCloud.anchorPoint = CGPointZero;
    _contactCloud.layer.mask = maskLayer_ChatCloud;
    
    if ( !(IS_IOS7) ) // Non-iOS 7 fixes.
    {
        _searchButton.frame = CGRectMake(10, 30, 33, 33);
        searchCancelButton.frame = CGRectMake(250, 30, 70, 33);
    }
    
    [_searchButton addSubview:searchIcon];
    [_profileButton addSubview:profileIcon];
    [_refreshButton addSubview:refreshIcon];
    [_chatCloudCenterButton addSubview:chatCloudCenterIcon];
    [_searchButton addSubview:searchBox];
    [_mainWindowContainer addSubview:_windowSideShadow];
    [_mainWindowContainer addSubview:_mainWindowNavigationController.view];
    [_windowCompositionLayer addSubview:_contactCloud];
    [_windowCompositionLayer addSubview:contactCloudInfoLabel];
    [_windowCompositionLayer addSubview:inviteButton];
    [_windowCompositionLayer addSubview:_profileButton];
    [_windowCompositionLayer addSubview:_createBoardButton];
    [_windowCompositionLayer addSubview:_refreshButton];
    [_windowCompositionLayer addSubview:_searchButton];
    [_windowCompositionLayer addSubview:_chatCloudCenterButton];
    [_windowCompositionLayer addSubview:searchCancelButton];
    [_windowCompositionLayer addSubview:_mainWindowContainer];
    [contentView addSubview:_wallpaper];
    [contentView addSubview:_windowCompositionLayer];
    
    self.view = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self startWallpaperAnimation];
    [self startTimeOfDayCheck];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionStatusBar];
}

#pragma mark -
#pragma mark Live Wallpaper

- (void)startWallpaperAnimation
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    // Keep the animation slow & mellow.
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        if ( wallpaperIsAnimatingRight )
        {
            if ( _wallpaper.frame.origin.x < 0 )
            {
                _wallpaper.frame = CGRectMake(_wallpaper.frame.origin.x + 1, _wallpaper.frame.origin.y, _wallpaper.frame.size.width, _wallpaper.frame.size.height);
            }
            else
            {
                wallpaperIsAnimatingRight = NO; // Go left now.
            }
        }
        else // Animating left.
        {
            if ( _wallpaper.frame.origin.x > appDelegate.screenBounds.size.width - _wallpaper.frame.size.width )
            {
                _wallpaper.frame = CGRectMake(_wallpaper.frame.origin.x - 1, _wallpaper.frame.origin.y, _wallpaper.frame.size.width, _wallpaper.frame.size.height);
            }
            else
            {
                wallpaperIsAnimatingRight = YES; // Go right now.
            }
        }
    } completion:^(BOOL finished){
        if ( wallpaperShouldAnimate )
        {
            _wallpaperIsAnimating = YES;
            
            [self startWallpaperAnimation];
        }
    }];
}

// Call this function only after pausing wallpaper animation, not to start it.
- (void)resumeWallpaperAnimation
{
    if ( !_wallpaperIsAnimating )
    {
        wallpaperShouldAnimate = YES;
        _wallpaperIsAnimating = YES;
        
        [self startWallpaperAnimation];
    }
}

- (void)stopWallpaperAnimation
{
    wallpaperShouldAnimate = NO;
    _wallpaperIsAnimating = NO;
}

#pragma mark -
#pragma mark Check the time of the day to set the wallpaper accordingly.

- (void)startTimeOfDayCheck
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkTimeOfDay];
        
        if ( timer_timeOfDayCheck )
        {
            [timer_timeOfDayCheck invalidate];
            timer_timeOfDayCheck = nil;
        }
        
        timer_timeOfDayCheck = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(checkTimeOfDay) userInfo:nil repeats:YES]; // Run this every 1 minute.
    });
}

- (void)pauseTimeOfDayCheck
{
    [timer_timeOfDayCheck invalidate];
    timer_timeOfDayCheck = nil;
}

- (void)checkTimeOfDay
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    NSDate *now = [NSDate date];
    NSDateComponents *components = [appDelegate.calendar components:NSHourCalendarUnit fromDate:now];
    
    if ( components.hour >= 6 && components.hour < 8 && !wallpaperDidChange_dawn )        // Dawn.
    {
        wallpaperImageName = @"wallpaper_dawn_1";
        wallpaperDidChange_dawn = YES;
        wallpaperDidChange_night = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                _wallpaper.alpha = 0.0;
            } completion:^(BOOL finished){
                _wallpaper.image = [UIImage imageNamed:wallpaperImageName];
                
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    _wallpaper.alpha = 1.0;
                } completion:^(BOOL finished){
                    
                }];
            }];
        });
    }
    else if ( components.hour >= 8 && components.hour <= 16 && !wallpaperDidChange_day )  // Day.
    {
        wallpaperImageName = @"wallpaper_day_1";
        wallpaperDidChange_dawn = NO;
        wallpaperDidChange_day = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                _wallpaper.alpha = 0.0;
            } completion:^(BOOL finished){
                _wallpaper.image = [UIImage imageNamed:wallpaperImageName];
                
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    _wallpaper.alpha = 1.0;
                } completion:^(BOOL finished){
                    
                }];
            }];
        });
    }
    else if ( components.hour >= 17 && components.hour <= 19 && !wallpaperDidChange_dusk ) // Dusk.
    {
        wallpaperImageName = @"wallpaper_dusk_1";
        wallpaperDidChange_day = NO;
        wallpaperDidChange_dusk = YES;
        // Each one resets the one before it.
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                _wallpaper.alpha = 0.0;
            } completion:^(BOOL finished){
                _wallpaper.image = [UIImage imageNamed:wallpaperImageName];
                
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    _wallpaper.alpha = 1.0;
                } completion:^(BOOL finished){
                    
                }];
            }];
        });
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
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                _wallpaper.alpha = 0.0;
            } completion:^(BOOL finished){
                _wallpaper.image = [UIImage imageNamed:wallpaperImageName];
                
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    _wallpaper.alpha = 1.0;
                } completion:^(BOOL finished){
                    
                }];
            }];
        });
    }
}

#pragma mark -
#pragma mark Invite Friends

- (void)showInvitationOptions
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
    
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark -
#pragma mark New Peer Notification

- (void)showNewPeerNotification
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( _windowCompositionLayer.contentOffset.x < appDelegate.screenBounds.size.width && !isShowingNewPeerNotification )
    {
        isShowingNewPeerNotification = YES;
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); // Vibrate.
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        UIView *peerNotificationBar = [[UIView alloc] initWithFrame:CGRectMake(0, -20, appDelegate.screenBounds.size.width, 20)];
        peerNotificationBar.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        peerNotificationBar.opaque = YES;
        
        UILabel *peerNotificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, peerNotificationBar.frame.size.width - 40, 20)];
        peerNotificationLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:SECONDARY_FONT_SIZE];
        peerNotificationLabel.textAlignment = NSTextAlignmentCenter;
        peerNotificationLabel.textColor = [UIColor whiteColor];
        peerNotificationLabel.text = NSLocalizedString(@"ALERT_NEW_PEER", nil);
        
        [peerNotificationBar addSubview:peerNotificationLabel];
        [self.view addSubview:peerNotificationBar];
        
        [UIView animateWithDuration:0.25 delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{
            peerNotificationBar.frame = CGRectMake(peerNotificationBar.frame.origin.x, 0, peerNotificationBar.frame.size.width, peerNotificationBar.frame.size.height);
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.25 delay:3.2 options:UIViewAnimationOptionCurveLinear animations:^{
                peerNotificationBar.frame = CGRectMake(peerNotificationBar.frame.origin.x, -20, peerNotificationBar.frame.size.width, peerNotificationBar.frame.size.height);
            } completion:^(BOOL finished){
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                [peerNotificationBar removeFromSuperview];
                
                isShowingNewPeerNotification = NO;
            }];
        }];
    }
}

#pragma mark -
#pragma mark Chat Cloud Search & Navigation

- (void)enableCompositionLayerScrolling
{
    _windowCompositionLayer.scrollEnabled = YES;
}

- (void)disableCompositionLayerScrolling
{
    _windowCompositionLayer.scrollEnabled = NO;
}

- (void)dismissWindow
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    _profileView.mainView.scrollsToTop = NO;
    _mainWindowContainer.hidden = NO;
    
    _windowCompositionLayer.frame = CGRectMake(0, 0, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height);
    _windowCompositionLayer.scrollEnabled = NO;
    
    [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionStatusBar];
    [_windowCompositionLayer setContentOffset:CGPointMake(0, 0) animated:YES];
    
    if ( !_wallpaperIsAnimating )
    {
        [self resumeWallpaperAnimation];
    }
    
    
    // Restore the bubble of the open profile.
    if ( [_profileView.ownerDataChunk objectForKey:@"user_id"] )
    {
        NSMutableDictionary *metadata = [_profileView.ownerDataChunk mutableCopy]; // Save a copy in case it gets overwritten.
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for ( SHChatBubble *theBubble in _contactCloud.cloudBubbles )
            {
                int activeBubbleUserID = [[metadata objectForKey:@"user_id"] intValue];
                int targetBubbleUserID = [[theBubble.metadata objectForKey:@"user_id"] intValue];
                
                if ( targetBubbleUserID == activeBubbleUserID )
                {
                    _profileView.ownerID = @"";
                    [_profileView.ownerDataChunk removeAllObjects];
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        theBubble.hidden = NO;
                        
                        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            theBubble.alpha = 1.0;
                        } completion:^(BOOL finished){
                            
                        }];
                    });
                    
                    break;
                }
            }
        });
    }
    
    _shouldEnterFullscreen = YES;
}

- (void)pushWindow:(SHAppWindowType)window
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    switch ( window )
    {
        case SHAppWindowTypeProfile:
        {
            _mainWindowNavigationController.viewControllers = @[_profileView];
            
            _windowSideShadow.frame = CGRectMake(_windowSideShadow.frame.origin.x, _profileView.BG.frame.origin.y + 10 - _profileView.mainView.contentOffset.y, _windowSideShadow.frame.size.width, _profileView.BG.frame.size.height);
            _windowCompositionLayer.contentSize = CGSizeMake(appDelegate.screenBounds.size.width * 2, appDelegate.screenBounds.size.height);
            _shouldEnterFullscreen = NO;
            _profileView.mainView.scrollsToTop = YES;
            
            [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionStatusBar];
            [_profileView.navigationController setNavigationBarHidden:YES animated:YES];
            
            _activeWindow = SHAppWindowTypeProfile;
            
            break;
        }
            
        default:
        {
            break;
        }
    }
    
    if ( _activeWindow ) // Check if there's a view previously loaded.
    {
        if ( _activeWindow == SHAppWindowTypeProfile )
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            [_profileView refreshViewWithDP:YES];
        }
        else
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        }
        
        if ( _activeWindow != SHAppWindowTypeProfile )
        {
            [self stopWallpaperAnimation];
        }
        
        _windowCompositionLayer.scrollEnabled = YES; // Unlock the layer.
        [_windowCompositionLayer scrollRectToVisible:CGRectMake(appDelegate.screenBounds.size.width, 0, _mainWindowContainer.frame.size.width, _mainWindowContainer.frame.size.height) animated:YES];
    }
}

- (void)restoreCurrentProfileBubble
{
    if ( [_profileView.ownerDataChunk objectForKey:@"user_id"] )
    {
        NSMutableDictionary *metadata = [_profileView.ownerDataChunk mutableCopy]; // Save a copy in case it gets overwritten.
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for ( SHChatBubble *theBubble in _contactCloud.cloudBubbles )
            {
                int activeBubbleUserID = [[metadata objectForKey:@"user_id"] intValue];
                int targetBubbleUserID = [[theBubble.metadata objectForKey:@"user_id"] intValue];
                
                if ( targetBubbleUserID == activeBubbleUserID )
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        theBubble.hidden = NO;
                        
                        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            theBubble.alpha = 1.0;
                        } completion:^(BOOL finished){
                            
                        }];
                    });
                    
                    break;
                }
            }
        });
    }
}

- (void)showUserProfile
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [self restoreCurrentProfileBubble];
    
    _profileView.ownerDataChunk = appDelegate.currentUser;
    [self pushWindow:SHAppWindowTypeProfile];
}

- (void)showBoardForID:(NSString *)boardID
{
    SHBoardViewController *boardView = [[SHBoardViewController alloc] init];
    SHOrientationNavigationController *navigationController = [[SHOrientationNavigationController alloc] initWithRootViewController:boardView];
    navigationController.autoRotates = NO;
    
    boardView.boardID = boardID;
    _shouldEnterFullscreen = NO;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)showBoardCreator
{
    SHCreateBoardViewController *boardCreator = [[SHCreateBoardViewController alloc] init];
    SHOrientationNavigationController *navigationController = [[SHOrientationNavigationController alloc] initWithRootViewController:boardCreator];
    navigationController.autoRotates = NO;
    
    _shouldEnterFullscreen = NO;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)showRenamingInterfaceForBubble:(SHChatBubble *)bubble
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UIView *renamingOverlay = [[UIView alloc] initWithFrame:appDelegate.screenBounds];
    renamingOverlay.opaque = YES;
    renamingOverlay.alpha = 0.0;
    renamingOverlay.tag = 777;
    
    UIImage *currentDP = [UIImage imageWithData:[bubble.metadata objectForKey:@"alias_dp"]];
    
    if ( !currentDP )
    {
        currentDP = [UIImage imageWithData:[bubble.metadata objectForKey:@"dp"]];
    }
    
    int upperPadding = 70;
    
    if ( _isFullscreen )
    {
        upperPadding = 5;
    }
    
    CGRect placeholderFrame = CGRectMake(appDelegate.screenBounds.size.width / 2 - (bubble.frame.size.width / 2), upperPadding, bubble.frame.size.width, bubble.frame.size.height);
    SHChatBubble *placeholderBubble = [[SHChatBubble alloc] initWithFrame:placeholderFrame andImage:currentDP withMiniModeEnabled:NO];
    placeholderBubble.enabled = NO;
    placeholderBubble.tag = 7770;
    
    UIImageView *textFieldBG = [[UIImageView alloc] initWithFrame:CGRectMake(20, placeholderBubble.frame.origin.y + placeholderBubble.frame.size.height + 15, appDelegate.screenBounds.size.width - 40, 35)];
    textFieldBG.image = [[UIImage imageNamed:@"button_round_white_transparent"] stretchableImageWithLeftCapWidth:18 topCapHeight:18];
    textFieldBG.userInteractionEnabled = YES;
    textFieldBG.opaque = YES;
    textFieldBG.tag = 7771;
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(13, 6, textFieldBG.frame.size.width - 15, 24)];
    textField.textColor  = [UIColor whiteColor];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    textField.returnKeyType = UIReturnKeyDone;
    textField.tag = 7772;
    textField.delegate = self;
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 6, textFieldBG.frame.size.width - 15, 24)];
    placeholderLabel.backgroundColor = [UIColor clearColor];
    placeholderLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:MAIN_FONT_SIZE];
    placeholderLabel.numberOfLines = 1;
    placeholderLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    placeholderLabel.text = [bubble.metadata objectForKey:@"name"];
    placeholderLabel.opaque = YES;
    placeholderLabel.tag = 7773;
    
    NSString *currentAlias = [bubble.metadata objectForKey:@"alias"];
    
    if ( currentAlias.length > 0 )
    {
        textField.text = currentAlias;
        placeholderLabel.hidden = YES;
    }
    
    [textFieldBG addSubview:textField];
    [textFieldBG addSubview:placeholderLabel];
    [renamingOverlay addSubview:textFieldBG];
    [renamingOverlay addSubview:placeholderBubble];
    [self.view addSubview:renamingOverlay];
    
    _isRenamingContact = YES;
    _chatCloudCenterButton.hidden = YES;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        searchCancelButton.alpha = 0.0;
        _contactCloud.alpha = 0.0;
        _searchButton.alpha = 0.0;
        _profileButton.alpha = 0.0;
        _createBoardButton.alpha = 0.0;
        _refreshButton.alpha = 0.0;
        _chatCloudCenterButton.alpha = 0.0;
        renamingOverlay.alpha = 1.0;
    } completion:^(BOOL finished){
        searchCancelButton.hidden = YES;
        _searchButton.hidden = YES;
        _profileButton.hidden = YES;
        _createBoardButton.hidden = YES;
        _refreshButton.hidden = YES;
        _contactCloud.hidden = YES;
        
        [textField becomeFirstResponder];
    }];
}

- (void)dismissRenamingInterface
{
    UIView *renamingOverlay = [self.view viewWithTag:777];
    UITextField *textField = (UITextField *)[renamingOverlay viewWithTag:7772];
    
    [_contactCloud renameBubble:textField.text forUser:[activeBubble.metadata objectForKey:@"user_id"]];
    
    _isRenamingContact = NO;
    _searchButton.hidden = NO;
    _profileButton.hidden = NO;
    _createBoardButton.hidden = NO;
    _refreshButton.hidden = NO;
    _contactCloud.hidden = NO;
    _chatCloudCenterButton.hidden = NO;
    
    if (isShowingSearchInterface )
    {
        searchCancelButton.hidden = NO;
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        if ( isShowingSearchInterface )
        {
            searchCancelButton.alpha = 1.0;
        }
        
        _contactCloud.alpha = 1.0;
        _searchButton.alpha = 1.0;
        _profileButton.alpha = 1.0;
        _createBoardButton.alpha = 1.0;
        _refreshButton.alpha = 1.0;
        _chatCloudCenterButton.alpha = 1.0;
        renamingOverlay.alpha = 0.0;
    } completion:^(BOOL finished){
        [renamingOverlay removeFromSuperview];
        
        activeBubble = nil; // Reset this.
    }];
}

- (void)showSearchInterface
{
    if ( !isShowingSearchInterface )
    {
        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
        
        searchBox.hidden = NO;
        searchCancelButton.hidden = NO;
        
        [searchBox becomeFirstResponder];
        [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionFullScreen];
        [_contactCloud jumpToCenter];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            searchCancelButton.alpha = 1.0;
            searchBox.alpha = 1.0;
            _profileButton.alpha = 0.0;
            _createBoardButton.alpha = 0.0;
            _refreshButton.alpha = 0.0;
            _mainWindowContainer.alpha = 0.0;
            
            if ( _isFullscreen )
            {
                _searchButton.frame = CGRectMake(_searchButton.frame.origin.x - 220 / 2, 10, 220, _searchButton.frame.size.height);
                searchCancelButton.frame = CGRectMake(_searchButton.frame.origin.x + _searchButton.frame.size.width + 10, 10, searchCancelButton.frame.size.width, searchCancelButton.frame.size.height);
            }
            else
            {
                _searchButton.frame = CGRectMake(_searchButton.frame.origin.x, 10, appDelegate.screenBounds.size.width - searchCancelButton.frame.size.width - (_searchButton.frame.origin.x * 2), _searchButton.frame.size.height);
                searchCancelButton.frame = CGRectMake(appDelegate.screenBounds.size.width - searchCancelButton.frame.size.width - _searchButton.frame.origin.x + 5, 10, searchCancelButton.frame.size.width, searchCancelButton.frame.size.height);
            }
        } completion:^(BOOL finished){
            _mainWindowContainer.hidden = YES;
            isShowingSearchInterface = YES;
        }];
    }
}

- (void)dismissSearchInterface
{
    if ( isShowingSearchInterface )
    {
        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
        
        [searchBox resignFirstResponder];
        
        if ( !_isFullscreen )
        {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionStatusBar];
            _mainWindowContainer.hidden = NO;
        }
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            searchCancelButton.alpha = 0.0;
            searchBox.alpha = 0.0;
            _profileButton.alpha = 1.0;
            _createBoardButton.alpha = 1.0;
            _refreshButton.alpha = 1.0;
            _mainWindowContainer.alpha = 1.0;
            _contactCloud.cloudContainer.alpha = 1.0;
            _contactCloud.cloudSearchResultsContainer.alpha = 0.0;
            
            _searchButton.frame = CGRectMake(_searchButton.frame.origin.x, 30, 35, _searchButton.frame.size.height);
            searchCancelButton.frame = CGRectMake(250, 30, searchCancelButton.frame.size.width, searchCancelButton.frame.size.height);
            
        } completion:^(BOOL finished){
            _contactCloud.isInSearchMode = NO;
            isShowingSearchInterface = NO;
            searchBox.hidden = YES;
            searchCancelButton.hidden = YES;
            _contactCloud.cloudContainer.hidden = NO;
            [_contactCloud jumpToCenter];
            
            searchBox.text = @"";
            [_contactCloud.searchResultsBubbles removeAllObjects];
        }];
    }
}

- (void)showChatCloudCenterJumpButton
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _chatCloudCenterButton.hidden = NO;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _chatCloudCenterButton.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
        } completion:^(BOOL finished){
            
        }];
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _chatCloudCenterButton.frame = CGRectMake(10, _chatCloudCenterButton.frame.origin.y, _chatCloudCenterButton.frame.size.width, _chatCloudCenterButton.frame.size.height);
            _chatCloudCenterButton.alpha = 1.0;
        } completion:^(BOOL finished){
            
        }];
    });
}

- (void)dismissChatCloudCenterJumpButton
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _chatCloudCenterButton.alpha = 0.99;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _chatCloudCenterButton.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
        } completion:^(BOOL finished){
            
        }];
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _chatCloudCenterButton.frame = CGRectMake(-33, _chatCloudCenterButton.frame.origin.y, _chatCloudCenterButton.frame.size.width, _chatCloudCenterButton.frame.size.height);
            _chatCloudCenterButton.alpha = 0.0;
        } completion:^(BOOL finished){
            _chatCloudCenterButton.hidden = YES;
        }];
    });
}

- (void)searchChatCloudForQuery:(NSString *)query
{
    [_contactCloud.searchResultsBubbles removeAllObjects];
    _contactCloud.isInSearchMode = YES;
    
    [[_contactCloud.cloudSearchResultsContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if ( _contactCloud.cloudContainer.alpha == 1.0 )
    {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _contactCloud.cloudContainer.alpha = 0.0;
            _contactCloud.cloudSearchResultsContainer.alpha = 1.0;
        } completion:^(BOOL finished){
            _contactCloud.cloudContainer.hidden = YES;
        }];
    }
    
    if ( _contactCloud.zoomScale != 1.0 )
    {
        [_contactCloud setZoomScale:1.0 animated:YES];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for ( SHChatBubble *bubble in _contactCloud.cloudBubbles )
        {
            /*  Special case:
             When the user types only one character, we only search for
             users whose names/usernames begin with that character, not just any
             users whose names contain that character.
             */
            
            __block NSString *name = [[bubble.metadata objectForKey:@"name"] stringByRemovingEmoji];
            __block NSString *userHandle = [[bubble.metadata objectForKey:@"user_handle"] stringByRemovingEmoji];
            __block NSString *alias = [[bubble.metadata objectForKey:@"alias"] stringByRemovingEmoji];
            __block BOOL userHandleExists = YES;
            __block BOOL aliasExists = YES;
            
            if ( userHandle.length == 0 )
            {
                userHandleExists = NO;
                userHandle = @" "; // Keep this 1 blank character to avoid an exception when matching 1st characters.
            }
            
            if ( alias.length == 0 )
            {
                aliasExists = NO;
                alias = @" ";
            }
            
            if ( query.length == 1 )
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    name = [name stringByReplacingOccurrencesOfString:@"☺" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"☹" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"❤" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"❤️" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"★" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"☆" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"☀" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"☁" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"☂" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"☃" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"☎" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"☏" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"☢" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"☣" withString:@""];
                    name = [name stringByReplacingOccurrencesOfString:@"☯" withString:@""];
                    name = [name stringByTrimmingLeadingWhitespace];
                    
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"☺" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"☹" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"❤" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"❤️" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"★" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"☆" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"☀" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"☁" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"☂" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"☃" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"☎" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"☏" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"☢" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"☣" withString:@""];
                    userHandle = [userHandle stringByReplacingOccurrencesOfString:@"☯" withString:@""];
                    
                    alias = [alias stringByReplacingOccurrencesOfString:@"☺" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"☹" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"❤" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"★" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"☆" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"☀" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"☁" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"☂" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"☃" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"☎" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"☏" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"☢" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"☣" withString:@""];
                    alias = [alias stringByReplacingOccurrencesOfString:@"☯" withString:@""];
                    
                    if ( userHandleExists )
                    {
                        userHandle = [userHandle stringByTrimmingLeadingWhitespace];
                    }
                    
                    if ( aliasExists )
                    {
                        alias = [alias stringByTrimmingLeadingWhitespace];
                    }
                    
                    if ( [name characterAtIndex:0] == [query characterAtIndex:0] ||
                        [userHandle characterAtIndex:0] == [query characterAtIndex:0] ||
                        [alias characterAtIndex:0] == [query characterAtIndex:0] )
                    {
                        UIImage *currentDP = [UIImage imageWithData:[bubble.metadata objectForKey:@"alias_dp"]];
                        
                        if ( !currentDP )
                        {
                            currentDP = [UIImage imageWithData:[bubble.metadata objectForKey:@"dp"]];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            // Put together a new copy of a matching bubble.
                            SHChatBubble *searchResultBubble = [[SHChatBubble alloc] initWithFrame:CGRectMake(0, 0, CHAT_CLOUD_BUBBLE_SIZE, CHAT_CLOUD_BUBBLE_SIZE) andImage:currentDP withMiniModeEnabled:NO];
                            [searchResultBubble setBubbleMetadata:bubble.metadata];
                            
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [_contactCloud insertBubble:searchResultBubble atPoint:CGPointMake(0, 0) animated:YES];
                            });
                        });
                    }
                });
            }
            else
            {
                if ( [name rangeOfString:query].location != NSNotFound ||
                    [userHandle rangeOfString:query].location != NSNotFound ||
                    [alias rangeOfString:query].location != NSNotFound )
                {
                    // Put together a new copy of a matching bubble.
                    UIImage *currentDP = [UIImage imageWithData:[bubble.metadata objectForKey:@"alias_dp"]];
                    
                    if ( !currentDP )
                    {
                        currentDP = [UIImage imageWithData:[bubble.metadata objectForKey:@"dp"]];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        SHChatBubble *searchResultBubble = [[SHChatBubble alloc] initWithFrame:CGRectMake(0, 0, CHAT_CLOUD_BUBBLE_SIZE, CHAT_CLOUD_BUBBLE_SIZE) andImage:currentDP withMiniModeEnabled:NO];
                        [searchResultBubble setBubbleMetadata:bubble.metadata];
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [_contactCloud insertBubble:searchResultBubble atPoint:CGPointMake(0, 0) animated:YES];
                        });
                    });
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_contactCloud endUpdates];
        });
    });
}

- (void)jumpToChatCloudCenter
{
    [_contactCloud jumpToCenter];
}

- (void)setMaxMinZoomScalesForChatCloudBounds
{
    // Reset.
    _contactCloud.maximumZoomScale = 1;
    _contactCloud.minimumZoomScale = 1;
    _contactCloud.zoomScale = 1;
    
    // Reset position.
    _contactCloud.cloudContainer.frame = CGRectMake(0, 0, _contactCloud.cloudContainer.frame.size.width, _contactCloud.cloudContainer.frame.size.height);
    _contactCloud.cloudSearchResultsContainer.frame = CGRectMake(0, 0, _contactCloud.cloudContainer.frame.size.width, _contactCloud.cloudContainer.frame.size.height);
    
    // Sizes.
    CGSize boundsSize = _contactCloud.bounds.size;
    CGSize cloudSize = _contactCloud.cloudContainer.frame.size;
    
    // Calculate Min.
    CGFloat xScale = boundsSize.width / cloudSize.width;    // The scale needed to perfectly fit the cloud width-wise.
    CGFloat yScale = boundsSize.height / cloudSize.height;  // The scale needed to perfectly fit the cloud height-wise.
    CGFloat minScale = MIN(xScale, yScale);                 // Use minimum of these to allow the cloud to become fully visible.
    
    // Calculate Max.
    CGFloat maxScale = 3;
    
    // Image is smaller than screen so no zooming!
    if ( xScale >= 1 && yScale >= 1 )
    {
        minScale = 1.0;
    }
    
    // Set min/max zoom
    _contactCloud.maximumZoomScale = maxScale;
    _contactCloud.minimumZoomScale = minScale;
    
    // If we're zooming to fill then centralise.
    if ( _contactCloud.zoomScale != minScale )
    {
        // Centralize.
        _contactCloud.contentOffset = CGPointMake((cloudSize.width * _contactCloud.zoomScale - boundsSize.width) / 2.0,
                                               (cloudSize.height * _contactCloud.zoomScale - boundsSize.height) / 2.0);
    }
    
    // Layout.
    // Center the cloud as it becomes smaller than the size of the screen.
    CGRect frameToCenter = _contactCloud.cloudContainer.frame;
    
    // Horizontally.
    if ( frameToCenter.size.width < boundsSize.width )
    {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    }
    else
    {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically.
    if ( frameToCenter.size.height < boundsSize.height )
    {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    }
    else
    {
        frameToCenter.origin.y = 0;
    }
    
    // Center.
    if ( !CGRectEqualToRect(_contactCloud.cloudContainer.frame, frameToCenter) )
    {
        _contactCloud.cloudContainer.frame = frameToCenter;
        _contactCloud.cloudSearchResultsContainer.frame = frameToCenter;
    }
}

- (void)textFieldDidChange:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    NSString *textFieldValue = textField.text;
    
    if ( textField.tag == 0 ) // Search box.
    {
        if ( textFieldValue.length > 0 )
        {
            if ( [textFieldValue isEqualToString:@" "] ) // Prevent whitespace searches.
            {
                textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            else
            {
                [self searchChatCloudForQuery:textFieldValue];
            }
        }
        else
        {
            _contactCloud.cloudContainer.hidden = NO;
            
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                _contactCloud.cloudContainer.alpha = 1.0;
                _contactCloud.cloudSearchResultsContainer.alpha = 0.0;
            } completion:^(BOOL finished){
                
            }];
        }
    }
    else if ( textField.tag == 7772 ) // Renaming bubble.
    {
        UIView *renamingOverlay = [self.view viewWithTag:777];
        UILabel *placeholderLabel = (UILabel *)[renamingOverlay viewWithTag:7773];
        
        if ( textFieldValue.length > 0 )
        {
            if ( [textFieldValue isEqualToString:@" "] ) // Prevent whitespace searches.
            {
                placeholderLabel.hidden = NO;
                textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            else
            {
                placeholderLabel.hidden = YES;
            }
        }
        else
        {
            placeholderLabel.hidden = NO;
        }
    }
}

- (void)showEmptyCloud
{
    inviteButton.hidden = NO;
    contactCloudInfoLabel.hidden = NO;
    contactCloudInfoLabel.text = NSLocalizedString(@"CHAT_CLOUD_EMPTY", nil);
}

#pragma mark -
#pragma mark Contacts & Boards

- (void)loadCloud
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    appDelegate.contactManager.delegate = self;
    
    if ( ![appDelegate.currentUser objectForKey:@"user_id"] )
    {
        return;
    }
    
    [_contactCloud beginUpdates];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:appDelegate.modelManager.databasePath];
        [queue inDatabase:^(FMDatabase *db) {
            FMResultSet *s1 = [db executeQuery:@"SELECT * FROM sh_cloud WHERE sh_user_id <> :current_user_id AND temp = 0"
                       withParameterDictionary:@{@"current_user_id": [appDelegate.currentUser objectForKey:@"user_id"]}];
            
            // Read & store each contact's data.
            // NOOOOTE: Some of this data gets overwritten/updated by the contact manager once it refreshes the contacts.
            while ( [s1 next] )
            {
                NSString *alias = [s1 stringForColumn:@"alias"];
                NSString *lastViewTimestamp = [s1 stringForColumn:@"last_view_timestamp"];
                id aliasDP = @"";
                NSData *DP = [s1 dataForColumn:@"dp"];
                NSData *aliasDPData = [s1 dataForColumn:@"alias_dp"];
                
                if ( !alias )
                {
                    alias = @"";
                }
                
                if ( !lastViewTimestamp )
                {
                    lastViewTimestamp = @"";
                }
                
                if ( !DP )
                {
                    DP = UIImageJPEGRepresentation([UIImage imageNamed:@"user_placeholder"], 1.0);
                }
                
                if ( aliasDPData )
                {
                    aliasDP = aliasDPData;
                }
                
                NSMutableDictionary *contactData = [[NSMutableDictionary alloc] initWithObjects:@[[NSString stringWithFormat:@"%d", SHChatBubbleTypeUser],
                                                                                                  [s1 stringForColumn:@"sh_user_id"],
                                                                                                  [s1 stringForColumn:@"name"],
                                                                                                  alias,
                                                                                                  [s1 stringForColumn:@"user_handle"],
                                                                                                  [s1 stringForColumn:@"follows_user"],
                                                                                                  [s1 stringForColumn:@"blocked"],
                                                                                                  [s1 stringForColumn:@"dp_hash"],
                                                                                                  DP,
                                                                                                  aliasDP,
                                                                                                  [s1 stringForColumn:@"email_address"],
                                                                                                  [s1 stringForColumn:@"gender"],
                                                                                                  [s1 stringForColumn:@"birthday"],
                                                                                                  [s1 stringForColumn:@"location_country"],
                                                                                                  [s1 stringForColumn:@"location_state"],
                                                                                                  [s1 stringForColumn:@"location_city"],
                                                                                                  [s1 stringForColumn:@"website"],
                                                                                                  [s1 stringForColumn:@"bio"],
                                                                                                  [s1 stringForColumn:@"view_count"],
                                                                                                  lastViewTimestamp,
                                                                                                  [s1 stringForColumn:@"coordinate_x"],
                                                                                                  [s1 stringForColumn:@"coordinate_y"],
                                                                                                  [s1 stringForColumn:@"rank_score"]]
                                                                                        forKeys:@[@"bubble_type",
                                                                                                  @"user_id",
                                                                                                  @"name",
                                                                                                  @"alias",
                                                                                                  @"user_handle",
                                                                                                  @"follows_user",
                                                                                                  @"blocked",
                                                                                                  @"dp_hash",
                                                                                                  @"dp",
                                                                                                  @"alias_dp",
                                                                                                  @"email_address",
                                                                                                  @"gender",
                                                                                                  @"birthday",
                                                                                                  @"location_country",
                                                                                                  @"location_state",
                                                                                                  @"location_city",
                                                                                                  @"website",
                                                                                                  @"bio",
                                                                                                  @"view_count",
                                                                                                  @"last_view_timestamp",
                                                                                                  @"coordinate_x",
                                                                                                  @"coordinate_y",
                                                                                                  @"rank_score"]];
                
                FMResultSet *s2 = [db executeQuery:@"SELECT message FROM sh_thread WHERE owner_id = :user_id "
                                                @"ORDER BY timestamp_sent DESC LIMIT 1"
                             withParameterDictionary:@{@"user_id": [contactData objectForKey:@"user_id"]}];
                
                while ( [s2 next] )
                {
                    [contactData setObject:[s2 stringForColumn:@"message"] forKey:@"message"];
                }
                
                [s2 close];
                
                UIImage *currentDP = [UIImage imageWithData:[contactData objectForKey:@"alias_dp"]];
                
                if ( !currentDP )
                {
                    currentDP = [UIImage imageWithData:[contactData objectForKey:@"dp"]];
                    
                    if ( !currentDP )
                    {
                        currentDP = [UIImage imageNamed:@"user_placeholder"];
                    }
                }
                
                // Give it a slight delay here to achieve a nice animation effect.
                long double delayInSeconds = 1.0;
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    SHChatBubble *bubble = [[SHChatBubble alloc] initWithFrame:CGRectMake(0, 0, CHAT_CLOUD_BUBBLE_SIZE, CHAT_CLOUD_BUBBLE_SIZE) andImage:currentDP withMiniModeEnabled:NO];
                    [bubble setBubbleMetadata:contactData];
                    [bubble setBlocked:[[contactData objectForKey:@"blocked"] boolValue]];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [_contactCloud insertBubble:bubble atPoint:CGPointMake([[contactData objectForKey:@"coordinate_x"] intValue], [[contactData objectForKey:@"coordinate_y"] intValue]) animated:YES];
                    });
                });
            }
            
            s1 = [db executeQuery:@"SELECT * FROM sh_board"
                    withParameterDictionary:nil];
            
            // Read & store each board's data.
            while ( [s1 next] )
            {
                NSString *lastViewTimestamp = [s1 stringForColumn:@"last_view_timestamp"];
                NSData *DP = [s1 dataForColumn:@"dp"];
                
                if ( !lastViewTimestamp )
                {
                    lastViewTimestamp = @"";
                }
                
                if ( !DP )
                {
                    DP = UIImageJPEGRepresentation([UIImage imageNamed:@"board_placeholder"], 1.0);
                }
                
                NSMutableDictionary *boardData = [[NSMutableDictionary alloc] initWithObjects:@[[NSString stringWithFormat:@"%d", SHChatBubbleTypeBoard],
                                                                                                [s1 stringForColumn:@"board_id"],
                                                                                                [s1 stringForColumn:@"name"],
                                                                                                [s1 stringForColumn:@"description"],
                                                                                                [s1 stringForColumn:@"privacy"],
                                                                                                [s1 stringForColumn:@"cover_hash"],
                                                                                                DP,
                                                                                                [s1 stringForColumn:@"date_created"],
                                                                                                [s1 stringForColumn:@"view_count"],
                                                                                                lastViewTimestamp,
                                                                                                [s1 stringForColumn:@"coordinate_x"],
                                                                                                [s1 stringForColumn:@"coordinate_y"],
                                                                                                [s1 stringForColumn:@"rank_score"]]
                                                                                      forKeys:@[@"bubble_type",
                                                                                                @"board_id",
                                                                                                @"name",
                                                                                                @"description",
                                                                                                @"privacy",
                                                                                                @"cover_hash",
                                                                                                @"dp",
                                                                                                @"date_created",
                                                                                                @"view_count",
                                                                                                @"last_view_timestamp",
                                                                                                @"coordinate_x",
                                                                                                @"coordinate_y",
                                                                                                @"rank_score"]];
                
                UIImage *currentDP = [UIImage imageWithData:[boardData objectForKey:@"dp"]];
                
                // Give it a slight delay here to achieve a nice animation effect.
                long double delayInSeconds = 1.0;
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    SHChatBubble *bubble = [[SHChatBubble alloc] initWithFrame:CGRectMake(0, 0, CHAT_CLOUD_BUBBLE_SIZE, CHAT_CLOUD_BUBBLE_SIZE) andImage:currentDP withMiniModeEnabled:NO];
                    [bubble setBubbleMetadata:boardData];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [_contactCloud insertBubble:bubble atPoint:CGPointMake([[boardData objectForKey:@"coordinate_x"] intValue], [[boardData objectForKey:@"coordinate_y"] intValue]) animated:YES];
                    });
                });
            }
            
            [s1 close]; // Very important that you close this!
            
            long double delayInSeconds = 1.2; // Slightly longer than the delay to insert the first bubble.
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if ( _contactCloud.cloudBubbles.count == 0 )
                {
                    [self showEmptyCloud];
                }
                else
                {
                    inviteButton.hidden = YES;
                    contactCloudInfoLabel.hidden = YES;
                }
                
                [_contactCloud endUpdates];
                
                [self setMaxMinZoomScalesForChatCloudBounds];
                
                // Center the cloud's offset.
                CGFloat centerOffset_x = (_contactCloud.contentSize.width / 2) - (_contactCloud.bounds.size.width / 2);
                CGFloat centerOffset_y = (_contactCloud.contentSize.height / 2) - (_contactCloud.bounds.size.height / 2);
                [_contactCloud setContentOffset:CGPointMake(centerOffset_x, centerOffset_y) animated:YES];
            });
        }];
    });
    
    _contactCloud.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
    [UIView animateWithDuration:0.37 delay:1.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _contactCloud.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // Clear the bubble data.
        
    }];
}

- (void)refreshCloud
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    _refreshButton.enabled = NO;
    
    if ( appDelegate.preference_UseBluetooth )
    {
        // Restart BT services.
        [appDelegate.peerManager stopAdvertising];
        [appDelegate.peerManager stopScanning];
        [appDelegate.peerManager startAdvertising];
        [appDelegate.peerManager startScanning];
    }
    
    [appDelegate.contactManager requestRecommendationListForced:YES];
}

- (void)removeBoard:(NSString *)boardID
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for ( int i = 0; i < _contactCloud.cloudBubbles.count; i++ )
        {
            SHChatBubble *bubble = [_contactCloud.cloudBubbles objectAtIndex:i];
            
            if ( bubble.bubbleType == SHChatBubbleTypeBoard )
            {
                int bubbleID = [[bubble.metadata objectForKey:@"board_id"] intValue];
                
                if ( bubbleID == boardID.intValue )
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [_contactCloud removeBubble:bubble permanently:YES animated:YES];
                    });
                    
                    [_contactCloud.cloudBubbles removeObjectAtIndex:i];
                    
                    break;
                }
            }
        }
        
        if ( _contactCloud.cloudBubbles.count == 0 )
        {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self showEmptyCloud];
            });
        }
    });
}

- (void)confirmContactDeletion
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"CONFIRMATION_DELETE_CONTACT", nil), [activeBubble.metadata objectForKey:@"name"]]
                                                             delegate:self
                                                    cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"GENERIC_CANCEL", nil)]
                                               destructiveButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"OPTION_DELETE_CONTACT", nil)]
                                                    otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = 1;
    [actionSheet showFromRect:CGRectMake(0, appDelegate.screenBounds.size.height - 44, appDelegate.screenBounds.size.width, 44) inView:appDelegate.window animated:YES];
}

#pragma mark -
#pragma mark Media Picker

- (void)showMediaPicker_Camera
{
    _mediaPickerSourceIsCamera = YES;
    photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    photoPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    
    if ( _isPickingAliasDP || _isPickingDP )
    {
        //photoPicker.mediaTypes = @[(NSString *)kUTTypeImage];
        photoPicker.allowsEditing = YES;
    }
    else
    {
        //photoPicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
        photoPicker.allowsEditing = NO;
    }
    
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)showMediaPicker_Library
{
    _mediaPickerSourceIsCamera = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    if ( _isPickingAliasDP || _isPickingDP )
    {
        //photoPicker.mediaTypes = @[(NSString *)kUTTypeImage];
        photoPicker.allowsEditing = YES;
    }
    else
    {
        //photoPicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
        photoPicker.allowsEditing = NO;
    }
    
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)dismissMediaPicker
{
    [photoPicker dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods.

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ( scrollView.tag == 0 ) // Chat Cloud
    {
        [searchBox resignFirstResponder]; // Give the user more viewing space.
        
        _contactCloud.headerLabel.text = [NSString stringWithFormat:@"%d connection%@.", (int)_contactCloud.cloudBubbles.count, _contactCloud.cloudBubbles.count == 1 ? @"" : @"s"];
    }
    
    if ( scrollView.tag != 66 )
    {
        _windowCompositionLayer.scrollEnabled = NO; // Lock this layer so it doesn't scroll once we reach the edges of any other scroll view.
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ( scrollView.tag == 0 ) // Chat Cloud
    {
        CGFloat centerOffset_x = (_contactCloud.contentSize.width / 2) - (_contactCloud.bounds.size.width / 2);
        CGFloat centerOffset_y = (_contactCloud.contentSize.height / 2) - (_contactCloud.bounds.size.height / 2);
        
        // Hide the Center Jump button if we're inside the center.
        if ( !(_contactCloud.contentOffset.x > centerOffset_x + 200 || _contactCloud.contentOffset.x < centerOffset_x - 200 ||
               _contactCloud.contentOffset.y > centerOffset_y + 200 || _contactCloud.contentOffset.y < centerOffset_y - 200) )
        {
            if ( _chatCloudCenterButton.alpha >= 1.0 )
            {
                [self dismissChatCloudCenterJumpButton];
            }
        }
    }
    else if ( scrollView.tag == 66 ) // Composition Layer
    {
        if ( _windowCompositionLayer.contentOffset.x == 0 )
        {
            [self dismissWindow];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if ( scrollView.tag == 0 ) // Chat Cloud
    {
        CGFloat centerOffset_x = (_contactCloud.contentSize.width / 2) - (_contactCloud.bounds.size.width / 2);
        CGFloat centerOffset_y = (_contactCloud.contentSize.height / 2) - (_contactCloud.bounds.size.height / 2);
        
        maskLayer_ChatCloud.position = CGPointMake(_contactCloud.contentOffset.x, _contactCloud.contentOffset.y);
        _contactCloud.headerLabel.frame = CGRectMake(_contactCloud.contentOffset.x + 20, _contactCloud.headerLabel.frame.origin.y, _contactCloud.headerLabel.frame.size.width, _contactCloud.headerLabel.frame.size.height);
        _contactCloud.footerLabel.frame = CGRectMake(_contactCloud.contentOffset.x + 20, _contactCloud.footerLabel.frame.origin.y, _contactCloud.footerLabel.frame.size.width, _contactCloud.footerLabel.frame.size.height);
        
        // Show the Center Jump button only if we're straggling outside the center.
        if ( _contactCloud.contentOffset.x > centerOffset_x + 200 || _contactCloud.contentOffset.x < centerOffset_x - 200 ||
            _contactCloud.contentOffset.y > centerOffset_y + 200 || _contactCloud.contentOffset.y < centerOffset_y - 200 )
        {
            if ( _chatCloudCenterButton.hidden )
            {
                [self showChatCloudCenterJumpButton];
            }
        }
        else
        {
            if ( _chatCloudCenterButton.alpha >= 1.0 )
            {
                [self dismissChatCloudCenterJumpButton];
            }
        }
    }
    else if ( scrollView.tag == 66 ) // Composition Layer
    {
        // We need to fix all these elements in place regardless of how the container is scrolled.
        _contactCloud.frame = CGRectMake(_windowCompositionLayer.contentOffset.x, _contactCloud.frame.origin.y, _contactCloud.frame.size.width, _contactCloud.frame.size.height);
        contactCloudInfoLabel.frame = CGRectMake(_windowCompositionLayer.contentOffset.x + 20, contactCloudInfoLabel.frame.origin.y, contactCloudInfoLabel.frame.size.width, contactCloudInfoLabel.frame.size.height);
        inviteButton.frame = CGRectMake(_windowCompositionLayer.contentOffset.x + 20, inviteButton.frame.origin.y, inviteButton.frame.size.width, inviteButton.frame.size.height);
        _searchButton.frame = CGRectMake(_windowCompositionLayer.contentOffset.x + 10, _searchButton.frame.origin.y, _searchButton.frame.size.width, _searchButton.frame.size.height);
        _profileButton.frame = CGRectMake(_windowCompositionLayer.contentOffset.x + (appDelegate.screenBounds.size.width / 2 - 80), _profileButton.frame.origin.y, _profileButton.frame.size.width, _profileButton.frame.size.height);
        _createBoardButton.frame = CGRectMake(_windowCompositionLayer.contentOffset.x + (appDelegate.screenBounds.size.width / 2 + 45), _createBoardButton.frame.origin.y, _createBoardButton.frame.size.width, _createBoardButton.frame.size.height);
        _refreshButton.frame = CGRectMake(_windowCompositionLayer.contentOffset.x + appDelegate.screenBounds.size.width - 45, _refreshButton.frame.origin.y, _refreshButton.frame.size.width, _refreshButton.frame.size.height);
        _chatCloudCenterButton.frame = CGRectMake(_windowCompositionLayer.contentOffset.x + 10, _chatCloudCenterButton.frame.origin.y, _chatCloudCenterButton.frame.size.width, _chatCloudCenterButton.frame.size.height);
        searchCancelButton.frame = CGRectMake(_windowCompositionLayer.contentOffset.x, searchCancelButton.frame.origin.y, searchCancelButton.frame.size.width, searchCancelButton.frame.size.height);
        
        if ( !_isFullscreen && !isShowingSearchInterface && _windowCompositionLayer.contentOffset.x <= appDelegate.screenBounds.size.width )
        {
            _contactCloud.hidden = NO;
            
            // Animate the alpha values.
            float x = _windowCompositionLayer.contentOffset.x + _windowCompositionLayer.frame.size.width;
            float width = _windowCompositionLayer.contentSize.width;
            
            float alphaValue = (1 - (x / width - 1) * 4) - 1;
            
            contactCloudInfoLabel.alpha = alphaValue;
            inviteButton.alpha = alphaValue;
            _searchButton.alpha = alphaValue;
            _profileButton.alpha = alphaValue;
            _createBoardButton.alpha = alphaValue;
            _refreshButton.alpha = alphaValue;
            _chatCloudCenterButton.alpha = alphaValue;
            _contactCloud.alpha = alphaValue;
            
            _profileView.upperPane.alpha = alphaValue + 1;
        }
        
        if ( _windowCompositionLayer.contentOffset.x >= appDelegate.screenBounds.size.width ) // Fix the main window at this point.
        {
            // Re-enable these.
            _windowCompositionLayer.userInteractionEnabled = YES;
            
            _mainWindowContainer.frame = CGRectMake(_windowCompositionLayer.contentOffset.x, _mainWindowContainer.frame.origin.y, _mainWindowContainer.frame.size.width, _mainWindowContainer.frame.size.height);
        }
    }
    
    [CATransaction commit];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ( scrollView.tag == 0 ) // Chat Cloud
    {
        if ( searchBox.text.length > 0 )
        {
            return _contactCloud.cloudSearchResultsContainer;
        }
        else
        {
            return _contactCloud.cloudContainer;
        }
    }
    else
    {
        return nil;
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ( scrollView.tag == 0 ) // Contact Cloud
    {
        _contactCloud.footerLabel.hidden = YES;
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if ( scrollView.tag == 0 ) // Contact Cloud
    {
        // Remove the mask while zooming to avoid a flickering bug.
        _contactCloud.layer.mask = nil;
    }
    
    [CATransaction commit];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if ( scrollView.tag == 0 ) // Chat Cloud
    {
        scrollView.contentSize = CGSizeMake(MAX(scrollView.contentSize.width, scrollView.frame.size.width + 1), MAX(scrollView.contentSize.height, scrollView.frame.size.height + 1));
        _contactCloud.layer.mask = maskLayer_ChatCloud; // Restore the mask.
        
        if ( scrollView.zoomScale == scrollView.minimumZoomScale )
        {
            _contactCloud.footerLabel.hidden = NO;
        }
    }
}

#pragma mark -
#pragma mark SHChatCloudDelegate methods.

- (void)didSelectBubble:(SHChatBubble *)bubble inCloud:(SHContactCloud *)theCloud
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    BOOL temp = [[bubble.metadata objectForKey:@"temp"] boolValue];
    
    if ( isShowingSearchInterface )
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionStatusBar];
        [self dismissSearchInterface];
    }
    
    if ( bubble.bubbleType == SHChatBubbleTypeUser )
    {
        if ( bubble.isBlocked )
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[bubble.metadata objectForKey:@"name"]
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedString(@"OPTION_UNBLOCK_CONTACT", nil), nil];
            
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            actionSheet.tag = 6;
            
            activeBubble = bubble;
            [actionSheet showFromRect:CGRectMake(0, appDelegate.screenBounds.size.height - 44, appDelegate.screenBounds.size.width, 44) inView:appDelegate.window animated:YES];
        }
        else
        {
            
            // Restore the bubble of the previous profile.
            [self restoreCurrentProfileBubble];
            
            long double delayInSeconds_windowPush = 0.0;
            
            if ( isShowingSearchInterface )
            {
                [self dismissSearchInterface];
                delayInSeconds_windowPush = 0.25; // We need a slight delay here.
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    for ( SHChatBubble *theBubble in theCloud.cloudBubbles )
                    {
                        int activeBubbleUserID = [[bubble.metadata objectForKey:@"user_id"] intValue];
                        int targetBubbleUserID = [[theBubble.metadata objectForKey:@"user_id"] intValue];
                        
                        if ( targetBubbleUserID == activeBubbleUserID )
                        {
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                // Animate the bubble equivalent outside the Chat Cloud search container out of the view.
                                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                                    theBubble.transform = CGAffineTransformMakeScale(1.5, 1.5);
                                } completion:^(BOOL finished){
                                    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                                        theBubble.transform = CGAffineTransformIdentity;
                                    } completion:^(BOOL finished){
                                        
                                    }];
                                }];
                                
                                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                    theBubble.alpha = 0.0;
                                } completion:^(BOOL finished){
                                    theBubble.hidden = YES;
                                }];
                            });
                            
                            break;
                        }
                    }
                });
            }
            
            if ( !temp )
            {
                [appDelegate.contactManager incrementViewCountForUser:[bubble.metadata objectForKey:@"user_id"]];
            }
            
            _profileView.ownerDataChunk = [bubble.metadata mutableCopy];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds_windowPush * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self pushWindow:SHAppWindowTypeProfile];
            });
        }
    }
    else if ( bubble.bubbleType == SHChatBubbleTypeBoard )
    {
        SHBoardViewController *boardView = [[SHBoardViewController alloc] init];
        SHOrientationNavigationController *navigationController = [[SHOrientationNavigationController alloc] initWithRootViewController:boardView];
        navigationController.autoRotates = NO;
        
        boardView.boardID = [bubble.metadata objectForKey:@"board_id"];
        boardView.currentCoverHash = [bubble.metadata objectForKey:@"cover_hash"];
        boardView.currentCover = [UIImage imageWithData:[bubble.metadata objectForKey:@"dp"]];
        appDelegate.mainView.shouldEnterFullscreen = NO;
        [appDelegate.mainView presentViewController:navigationController animated:YES completion:nil];
        
        if ( !temp )
        {
            [appDelegate.contactManager incrementViewCountForBoard:[bubble.metadata objectForKey:@"board_id"]];
        }
    }
    
    // Animate the bubble out of the view.
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        bubble.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            bubble.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            
        }];
    }];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        bubble.alpha = 0.0;
    } completion:^(BOOL finished){
        bubble.hidden = YES;
    }];
    
    if ( bubble.bubbleType == SHChatBubbleTypeBoard )
    {
        // We need a slight delay here.
        long double delayInSeconds = 1.0;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            bubble.hidden = NO;
            
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                bubble.alpha = 1.0;
            } completion:^(BOOL finished){
                
            }];
        });
    }
}

- (void)didTapAndHoldBubble:(SHChatBubble *)bubble inCloud:(SHContactCloud *)theCloud
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    activeBubble = bubble;
    UIActionSheet *actionSheet;
    
    if ( bubble.bubbleType == SHChatBubbleTypeUser )
    {
        NSString *userID = [bubble.metadata objectForKey:@"user_id"];
        
        if ( userID.intValue != [[appDelegate.currentUser objectForKey:@"user_id"] intValue] )
        {
            if ( bubble.isBlocked )
            {
                actionSheet = [[UIActionSheet alloc] initWithTitle:[bubble.metadata objectForKey:@"name"]
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"OPTION_UNBLOCK_CONTACT", nil), nil];
                
                actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                actionSheet.tag = 6;
            }
            else
            {
                UIImage *customDP = [UIImage imageWithData:[bubble.metadata objectForKey:@"alias_dp"]];
                BOOL temp = [[bubble.metadata objectForKey:@"temp"] boolValue];
                
                if ( temp )
                {
                    actionSheet = [[UIActionSheet alloc] initWithTitle:[bubble.metadata objectForKey:@"name"]
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                                destructiveButtonTitle:NSLocalizedString(@"OPTION_REMOVE_CONTACT_RECOMMENDATION", nil)
                                                     otherButtonTitles:NSLocalizedString(@"OPTION_ADD_CONTACT", nil), nil];
                }
                else
                {
                    FMResultSet *s1 = [appDelegate.modelManager executeQuery:@"SELECT * FROM sh_muted WHERE user_id = :user_id"
                                                     withParameterDictionary:@{@"user_id": [bubble.metadata objectForKey:@"user_id"]}];
                    
                    BOOL userIsMuted = NO;
                    
                    while ( [s1 next] )
                    {
                        userIsMuted = YES;
                    }
                    
                    [s1 close];
                    [appDelegate.modelManager.results close];
                    [appDelegate.modelManager.DB close];
                    
                    if ( !customDP ) // No custom pic set.
                    {
                        if ( userIsMuted )
                        {
                            actionSheet = [[UIActionSheet alloc] initWithTitle:[bubble.metadata objectForKey:@"name"]
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                                        destructiveButtonTitle:NSLocalizedString(@"OPTION_DELETE_CONTACT", nil)
                                                             otherButtonTitles:NSLocalizedString(@"OPTION_RENAME_CONTACT", nil), NSLocalizedString(@"OPTION_CHANGE_CONTACT_PICTURE_ADD", nil), NSLocalizedString(@"OPTION_UNMUTE_UPDATES", nil), nil];
                        }
                        else
                        {
                            actionSheet = [[UIActionSheet alloc] initWithTitle:[bubble.metadata objectForKey:@"name"]
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                                        destructiveButtonTitle:NSLocalizedString(@"OPTION_DELETE_CONTACT", nil)
                                                             otherButtonTitles:NSLocalizedString(@"OPTION_RENAME_CONTACT", nil), NSLocalizedString(@"OPTION_CHANGE_CONTACT_PICTURE_ADD", nil), nil];
                        }
                    }
                    else // User has a custom pic set. Add an extra option to remove it.
                    {
                        if ( userIsMuted )
                        {
                            actionSheet = [[UIActionSheet alloc] initWithTitle:[bubble.metadata objectForKey:@"name"]
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                                        destructiveButtonTitle:NSLocalizedString(@"OPTION_DELETE_CONTACT", nil)
                                                             otherButtonTitles:NSLocalizedString(@"OPTION_RENAME_CONTACT", nil), NSLocalizedString(@"OPTION_CHANGE_CONTACT_PICTURE_ADD", nil), NSLocalizedString(@"OPTION_CHANGE_CONTACT_PICTURE_REMOVE", nil), NSLocalizedString(@"OPTION_UNMUTE_UPDATES", nil), nil];
                        }
                        else
                        {
                            actionSheet = [[UIActionSheet alloc] initWithTitle:[bubble.metadata objectForKey:@"name"]
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                                        destructiveButtonTitle:NSLocalizedString(@"OPTION_DELETE_CONTACT", nil)
                                                             otherButtonTitles:NSLocalizedString(@"OPTION_RENAME_CONTACT", nil), NSLocalizedString(@"OPTION_CHANGE_CONTACT_PICTURE_ADD", nil), NSLocalizedString(@"OPTION_CHANGE_CONTACT_PICTURE_REMOVE", nil), nil];
                        }
                    }
                    
                    [activeBubble.metadata setObject:[NSNumber numberWithBool:userIsMuted] forKey:@"is_muted"];
                }
                
                actionSheet.tag = 0;
            }
            
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [actionSheet showFromRect:CGRectMake(0, appDelegate.screenBounds.size.height - 44, appDelegate.screenBounds.size.width, 44) inView:appDelegate.window animated:YES];
        }
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if ( _isPickingAliasDP || _isPickingDP )
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    
    _isPickingAliasDP = NO;
    _isPickingDP = NO;
    _isPickingMedia = NO;
    _mediaPickerSourceIsCamera = NO;
    activeBubble = nil;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ( _isPickingAliasDP || _isPickingDP )
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        
        UIImage *selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        
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
        
        if ( _isPickingAliasDP )
        {
            [_contactCloud setDP:thumbnail forUser:[activeBubble.metadata objectForKey:@"user_id"]];
        }
        else
        {
            [_profileView mediaPickerDidFinishPickingDP:thumbnail];
        }
    }
    else if ( _isPickingMedia )
    {
        __block id selectedMedia;
        
        if ([mediaType isEqualToString:@"public.image"])
        {
            UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            selectedMedia = selectedImage;
        }
        else if ( [mediaType isEqualToString:@"public.movie"] )
        {
            NSURL *movieURL = [info objectForKey:UIImagePickerControllerMediaURL];
            NSData *webData = [NSData dataWithContentsOfURL:movieURL];
            selectedMedia = webData;
        }
    }
    
    _isPickingAliasDP = NO;
    _isPickingDP = NO;
    _isPickingMedia = NO;
    _mediaPickerSourceIsCamera = NO;
    activeBubble = nil;
}

#pragma mark -
#pragma mark SHContactManagerDelegate methods.

- (void)contactManagerDidFetchFollowing:(NSMutableArray *)list
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_contactCloud beginUpdates];
        
        // Read & store each new contact's data.
        for ( NSMutableDictionary *entry in list )
        {
            SHChatBubbleType entryType = [[entry objectForKey:@"entry_type"] intValue];
            NSMutableDictionary *entryData = [entry objectForKey:@"entry_data"];
            int ID;
            BOOL bubbleExists = NO;
            
            if ( entryType == SHChatBubbleTypeUser )
            {
                ID = [[entryData objectForKey:@"user_id"] intValue];
            }
            else
            {
                ID = [[entryData objectForKey:@"board_id"] intValue];
            }
            
            [entryData setObject:[entry objectForKey:@"entry_type"] forKey:@"bubble_type"];
            
            // First make sure this person isn't already in the cloud.
            for ( int i = 0; i < _contactCloud.cloudBubbles.count; i++ )
            {
                SHChatBubble *bubble = [_contactCloud.cloudBubbles objectAtIndex:i];
                int bubbleID;
                
                if ( bubble.bubbleType == SHChatBubbleTypeUser )
                {
                    bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
                }
                else
                {
                    bubbleID = [[bubble.metadata objectForKey:@"board_id"] intValue];
                }
                
                if ( bubbleID == ID )
                {
                    bubbleExists = YES;
                }
            }
            
            if ( bubbleExists )
            {
                continue;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                // Set the image here on the main queue.
                UIImage *currentDP;
                
                if ( entryType == SHChatBubbleTypeUser )
                {
                    currentDP = [UIImage imageWithData:[entryData objectForKey:@"alias_dp"]];
                    
                    if ( !currentDP )
                    {
                        currentDP = [UIImage imageWithData:[entryData objectForKey:@"dp"]];
                    }
                }
                else
                {
                    currentDP = [UIImage imageWithData:[entryData objectForKey:@"dp"]];
                }
                
                SHChatBubble *bubble = [[SHChatBubble alloc] initWithFrame:CGRectMake(0, 0, CHAT_CLOUD_BUBBLE_SIZE, CHAT_CLOUD_BUBBLE_SIZE) andImage:currentDP withMiniModeEnabled:NO];
                [bubble setBubbleMetadata:entryData];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [_contactCloud insertBubble:bubble atPoint:CGPointMake([[entryData objectForKey:@"coordinate_x"] intValue], [[entryData objectForKey:@"coordinate_y"] intValue]) animated:YES];
                });
            });
        }
        
        // We need a slight delay here.
        long double delayInSeconds = 0.45;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if ( _contactCloud.cloudBubbles.count == 0 )
            {
                [self showEmptyCloud];
            }
            else
            {
                inviteButton.hidden = YES;
                contactCloudInfoLabel.hidden = YES;
            }
            
            // Center the cloud's offset.
            CGFloat centerOffset_x = (_contactCloud.contentSize.width / 2) - (_contactCloud.bounds.size.width / 2);
            CGFloat centerOffset_y = (_contactCloud.contentSize.height / 2) - (_contactCloud.bounds.size.height / 2);
            [_contactCloud setContentOffset:CGPointMake(centerOffset_x, centerOffset_y) animated:YES];
            [_contactCloud endUpdates];
            [self setMaxMinZoomScalesForChatCloudBounds];
            
            [appDelegate.contactManager.freshContacts removeAllObjects]; // Clear this out, or it'll get passed to the delegate every time the Magic Numbers are refreshed!
            [appDelegate.contactManager.freshBoards removeAllObjects];
            [self refreshCloud];
        });
    });
}

- (void)contactManagerDidFetchRecommendations:(NSMutableArray *)list
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_contactCloud beginUpdates];
        
        // Read & store each new contact's data.
        for ( NSMutableDictionary *entry in list )
        {
            SHChatBubbleType entryType = [[entry objectForKey:@"entry_type"] intValue];
            NSMutableDictionary *entryData = [entry objectForKey:@"entry_data"];
            int ID;
            BOOL bubbleExists = NO;
            
            if ( entryType == SHChatBubbleTypeUser )
            {
                ID = [[entryData objectForKey:@"user_id"] intValue];
            }
            else
            {
                ID = [[entryData objectForKey:@"board_id"] intValue];
            }
            
            [entryData setObject:[entry objectForKey:@"entry_type"] forKey:@"bubble_type"];
            
            // First make sure this person isn't already in the cloud.
            for ( int i = 0; i < _contactCloud.cloudBubbles.count; i++ )
            {
                SHChatBubble *bubble = [_contactCloud.cloudBubbles objectAtIndex:i];
                int bubbleID;
                
                if ( bubble.bubbleType == SHChatBubbleTypeUser )
                {
                    bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
                }
                else
                {
                    bubbleID = [[bubble.metadata objectForKey:@"board_id"] intValue];
                }
                
                if ( bubbleID == ID )
                {
                    bubbleExists = YES;
                }
            }
            
            if ( bubbleExists )
            {
                continue;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                // Set the image here on the main queue.
                UIImage *currentDP = [UIImage imageWithData:[entryData objectForKey:@"dp"]];
                SHChatBubble *bubble = [[SHChatBubble alloc] initWithFrame:CGRectMake(0, 0, CHAT_CLOUD_BUBBLE_SIZE, CHAT_CLOUD_BUBBLE_SIZE) andImage:currentDP withMiniModeEnabled:NO];
                [bubble setBubbleMetadata:entryData];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [_contactCloud insertBubble:bubble atPoint:CGPointMake([[entryData objectForKey:@"coordinate_x"] intValue], [[entryData objectForKey:@"coordinate_y"] intValue]) animated:YES];
                });
            });
        }
        
        // We need a slight delay here.
        long double delayInSeconds = 0.45;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if ( _contactCloud.cloudBubbles.count == 0 )
            {
                inviteButton.hidden = NO;
                contactCloudInfoLabel.hidden = NO;
                contactCloudInfoLabel.text = NSLocalizedString(@"CHAT_CLOUD_EMPTY", nil);
            }
            else
            {
                inviteButton.hidden = YES;
                contactCloudInfoLabel.hidden = YES;
            }
            
            // Center the cloud's offset.
            CGFloat centerOffset_x = (_contactCloud.contentSize.width / 2) - (_contactCloud.bounds.size.width / 2);
            CGFloat centerOffset_y = (_contactCloud.contentSize.height / 2) - (_contactCloud.bounds.size.height / 2);
            [_contactCloud setContentOffset:CGPointMake(centerOffset_x, centerOffset_y) animated:YES];
            
            _refreshButton.enabled = YES;
            
            [_contactCloud endUpdates];
            [self setMaxMinZoomScalesForChatCloudBounds];
        });
    });
}

- (void)contactManagerDidAddNewContact:(NSMutableDictionary *)userData
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [appDelegate.strobeLight affirmativeStrobeLight];
    
    int userID = [[userData objectForKey:@"user_id"] intValue];
    
    if ( _activeWindow && userID == _profileView.ownerID.intValue )
    {
        [_profileView didAddUser];
    }
    else
    {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_white"]];
        
        // Set custom view mode.
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.dimBackground = YES;
        HUD.delegate = self;
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:2];
        
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for ( int i = 0; i < _contactCloud.cloudBubbles.count; i++ )
        {
            SHChatBubble *bubble = [_contactCloud.cloudBubbles objectAtIndex:i];
            int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
            
            if ( bubbleID == userID )
            {
                [bubble.metadata setObject:@"0" forKey:@"temp"];
                
                break;
            }
        }
        
        if ( isShowingSearchInterface )
        {
            for ( int i = 0; i < _contactCloud.searchResultsBubbles.count; i++ )
            {
                SHChatBubble *bubble = [_contactCloud.searchResultsBubbles objectAtIndex:i];
                int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
                
                if ( bubbleID == userID )
                {
                    [bubble.metadata setObject:@"0" forKey:@"temp"];
                    
                    break;
                }
            }
        }
    });
    
    NSLog(@"added new contact!");
}

- (void)contactManagerDidHideContact:(NSString *)userID
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [appDelegate.strobeLight deactivateStrobeLight];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for ( int i = 0; i < _contactCloud.cloudBubbles.count; i++ )
        {
            SHChatBubble *bubble = [_contactCloud.cloudBubbles objectAtIndex:i];
            int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
            
            if ( bubbleID == userID.intValue )
            {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [_contactCloud removeBubble:bubble permanently:YES animated:YES];
                });
                
                [_contactCloud.cloudBubbles removeObjectAtIndex:i];
                
                break;
            }
        }
        
        if ( isShowingSearchInterface )
        {
            for ( int i = 0; i < _contactCloud.searchResultsBubbles.count; i++ )
            {
                SHChatBubble *bubble = [_contactCloud.searchResultsBubbles objectAtIndex:i];
                int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
                
                if ( bubbleID == userID.intValue )
                {
                    [_contactCloud.searchResultsBubbles removeObjectAtIndex:i];
                    
                    break;
                }
            }
        }
    });
}

- (void)contactManagerDidRemoveContact:(NSString *)userID
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( _activeWindow && userID.intValue == _profileView.ownerID.intValue )
    {
        [_profileView didRemoveUser];
    }
    
    [appDelegate.strobeLight deactivateStrobeLight];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for ( int i = 0; i < _contactCloud.cloudBubbles.count; i++ )
        {
            SHChatBubble *bubble = [_contactCloud.cloudBubbles objectAtIndex:i];
            int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
            
            if ( bubbleID == userID.intValue )
            {
                [bubble.metadata setObject:@"1" forKey:@"temp"];
                
                break;
            }
        }
        
        if ( isShowingSearchInterface )
        {
            for ( int i = 0; i < _contactCloud.searchResultsBubbles.count; i++ )
            {
                SHChatBubble *bubble = [_contactCloud.searchResultsBubbles objectAtIndex:i];
                int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
                
                if ( bubbleID == userID.intValue )
                {
                    [bubble.metadata setObject:@"1" forKey:@"temp"];
                    
                    break;
                }
            }
        }
    });
}

- (void)contactManagerDidBlockContact:(NSString *)userID
{
    [self dismissWindow];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for ( int i = 0; i < _contactCloud.cloudBubbles.count; i++ )
        {
            SHChatBubble *bubble = [_contactCloud.cloudBubbles objectAtIndex:i];
            int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
            
            if ( bubbleID == userID.intValue )
            {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [bubble setBlocked:YES];
                    [bubble.metadata setObject:@"1" forKey:@"blocked"];
                });
                
                break;
            }
        }
        
        if ( isShowingSearchInterface )
        {
            for ( int i = 0; i < _contactCloud.searchResultsBubbles.count; i++ )
            {
                SHChatBubble *bubble = [_contactCloud.searchResultsBubbles objectAtIndex:i];
                int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
                
                if ( bubbleID == userID.intValue )
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [bubble setBlocked:YES];
                        [bubble.metadata setObject:@"1" forKey:@"blocked"];
                    });
                    
                    break;
                }
            }
        }
    });
}

- (void)contactManagerDidUnblockContact:(NSString *)userID
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for ( int i = 0; i < _contactCloud.cloudBubbles.count; i++ )
        {
            SHChatBubble *bubble = [_contactCloud.cloudBubbles objectAtIndex:i];
            int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
            
            if ( bubbleID == userID.intValue )
            {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [bubble setBlocked:NO];
                    [bubble.metadata setObject:@"0" forKey:@"blocked"];
                });
                
                break;
            }
        }
        
        if ( isShowingSearchInterface )
        {
            for ( int i = 0; i < _contactCloud.searchResultsBubbles.count; i++ )
            {
                SHChatBubble *bubble = [_contactCloud.searchResultsBubbles objectAtIndex:i];
                int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
                
                if ( bubbleID == userID.intValue )
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [bubble setBlocked:NO];
                        [bubble.metadata setObject:@"0" forKey:@"blocked"];
                    });
                    
                    break;
                }
            }
        }
    });
}

- (void)contactManagerRequestDidFailWithError:(NSError *)error
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [appDelegate.strobeLight negativeStrobeLight];
    NSLog(@"Contact Manager failed: %@", error);
    
    if ( _activeWindow  )
    {
        [_profileView lastOperationFailedWithError:error];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate methods.

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Monitor keystrokes in the search box.
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField removeTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( textField.tag == 0 ) // Search box.
    {
        [self searchChatCloudForQuery:textField.text];
        [searchBox resignFirstResponder];
    }
    else if ( textField.tag == 7772 ) // Renaming bubble.
    {
        [textField resignFirstResponder];
        [self dismissRenamingInterface];
    }
    
    return NO;
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( actionSheet.tag == 0 ) // Chat Cloud bubble options.
    {
        BOOL temp = [[activeBubble.metadata objectForKey:@"temp"] boolValue];
        
        if ( temp )
        {
            if ( buttonIndex == 0 ) // Hide contact.
            {
                [appDelegate.strobeLight activateStrobeLight];
                [appDelegate.contactManager hideUser:[activeBubble.metadata objectForKey:@"user_id"]];
            }
            else if ( buttonIndex == 1 ) // Add contact.
            {
                [appDelegate.strobeLight activateStrobeLight];
                [appDelegate.contactManager addUser:[activeBubble.metadata objectForKey:@"user_id"]];
            }
            else
            {
                activeBubble = nil;
            }
        }
        else
        {
            if ( buttonIndex == 0 ) // Remove contact.
            {
                [self confirmContactDeletion];
            }
            else if ( buttonIndex == 1 ) // Rename contact.
            {
                [self showRenamingInterfaceForBubble:activeBubble];
            }
            else if ( buttonIndex == 2 ) // Change contact picture.
            {
                _isPickingAliasDP = YES;
                
                [self showMediaPicker_Library];
            }
            else if ( buttonIndex == 3 )
            {
                UIImage *customDP = [UIImage imageWithData:[activeBubble.metadata objectForKey:@"alias_dp"]];
                
                if ( customDP ) // Custom pic set for active contact bubble. Remove the pic.
                {
                    [_contactCloud removeDPForUser:[activeBubble.metadata objectForKey:@"user_id"]];
                }
                else
                {
                    BOOL userIsMuted = [[activeBubble.metadata objectForKey:@"is_muted"] boolValue];
                    
                    if ( userIsMuted )
                    {
                        //[self muteUpdatesForUser:[activeBubble.metadata objectForKey:@"user_id"]];
                    }
                }
                
                activeBubble = nil;
            }
            /*else if ( buttonIndex == 4 )
             {
             BOOL userIsMuted = [[activeBubble.metadata objectForKey:@"is_muted"] boolValue];
             
             if ( userIsMuted )
             {
             [self muteUpdatesForUser:[activeBubble.metadata objectForKey:@"user_id"]];
             }
             
             activeBubble = nil;
             }*/
            else
            {
                activeBubble = nil;
            }
        }
    }
    else if ( actionSheet.tag == 1 ) // Delete contact confirmation.
    {
        if ( buttonIndex == 0 )
        {
            [appDelegate.strobeLight activateStrobeLight];
            [appDelegate.contactManager removeUser:[activeBubble.metadata objectForKey:@"user_id"]];
        }
    }
    /*else if ( actionSheet.tag == 4 ) // Delete status.
    {
        if ( buttonIndex == 0 )
        {
            [self deleteFeedStatus];
        }
    }
    else if ( actionSheet.tag == 5 ) // Mute/unmute user updates.
    {
        if ( buttonIndex == 0 )
        {
            NSString *userID = [[_SHMiniFeedEntries objectAtIndex:activeMiniFeedIndexPath.row] objectForKey:@"owner_id"];
            
            [self muteUpdatesForUser:userID];
        }
    }*/
    else if ( actionSheet.tag == 6 ) // Unblock user.
    {
        if ( buttonIndex == 0 )
        {
            [appDelegate.contactManager unblockContact:[activeBubble.metadata objectForKey:@"user_id"]];
        }
        
        activeBubble = nil;
    }
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
