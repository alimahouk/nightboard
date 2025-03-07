//
//  SHRecipientPickerViewController.m
//  Nightboard
//
//  Created by Ali.cpp on 3/20/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import "SHRecipientPickerViewController.h"

#import "NSString+Utils.h"

#import "AFHTTPRequestOperationManager.h"
#import "AppDelegate.h"
#import "SHBoardViewController.h"

@implementation SHRecipientPickerViewController

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
        _isFullscreen = NO;
        _isPickingAliasDP = NO;
        _isPickingDP = NO;
        _shouldEnterFullscreen = YES;
        _mediaPickerSourceIsCamera = NO;
        
        _profileView = [[SHProfileViewController alloc] init];
        
        _mainWindowNavigationController = [[SHOrientationNavigationController alloc] initWithRootViewController:_profileView];
        _mainWindowNavigationController.autoRotates = NO;
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
    _contactCloud.makeRoomForBubbles = YES;
    _contactCloud.delegate = self;
    _contactCloud.cloudDelegate = self;
    _contactCloud.tag = 0;
    
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
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
    backButton.showsTouchWhenHighlighted = YES;
    backButton.frame = CGRectMake(10, 25, 32, 32);
    
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_searchButton setBackgroundImage:[[UIImage imageNamed:@"button_round_white_transparent"] stretchableImageWithLeftCapWidth:18 topCapHeight:18] forState:UIControlStateNormal];
    [_searchButton addTarget:self action:@selector(showSearchInterface) forControlEvents:UIControlEventTouchUpInside];
    _searchButton.frame = CGRectMake(appDelegate.screenBounds.size.width - 45, 25, 35, 35);
    _searchButton.adjustsImageWhenDisabled = NO;
    _searchButton.showsTouchWhenHighlighted = YES;
    _searchButton.opaque = YES;
    
    _chatCloudCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_chatCloudCenterButton setBackgroundImage:[[UIImage imageNamed:@"button_round_white_transparent"] stretchableImageWithLeftCapWidth:18 topCapHeight:18] forState:UIControlStateNormal];
    [_chatCloudCenterButton addTarget:self action:@selector(jumpToChatCloudCenter) forControlEvents:UIControlEventTouchUpInside];
    _chatCloudCenterButton.frame = CGRectMake(-33, appDelegate.screenBounds.size.height - 45, 35, 35);
    _chatCloudCenterButton.showsTouchWhenHighlighted = YES;
    _chatCloudCenterButton.alpha = 0.0;
    _chatCloudCenterButton.opaque = YES;
    _chatCloudCenterButton.hidden = YES;
    
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
    [_chatCloudCenterButton addSubview:chatCloudCenterIcon];
    [_searchButton addSubview:searchBox];
    [_mainWindowContainer addSubview:_windowSideShadow];
    [_mainWindowContainer addSubview:_mainWindowNavigationController.view];
    [_windowCompositionLayer addSubview:_contactCloud];
    [_windowCompositionLayer addSubview:contactCloudInfoLabel];
    [_windowCompositionLayer addSubview:backButton];
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
    [self loadCloud];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionStatusBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if ( viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self ) // View is disappearing because a new view controller was pushed onto the stack.
    {
        
    }
    else if ( [viewControllers indexOfObject:self] == NSNotFound ) // View is disappearing because it was popped from the stack.
    {
        [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionNavigationBar];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    [super viewWillDisappear:animated];
}

- (void)dismissView
{
    if ( _mode == SHRecipientPickerModeBoardRequests )
    {
        NSArray *viewControllers = self.navigationController.viewControllers;
        SHBoardViewController *boardView = [viewControllers objectAtIndex:0];
        
        [boardView loadBoardBatch:0];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
            _mainWindowContainer.alpha = 0.0;
            backButton.alpha = 0.0;
            
            if ( _isFullscreen )
            {
                _searchButton.frame = CGRectMake(_searchButton.frame.origin.x - 220 / 2, 10, 220, _searchButton.frame.size.height);
                searchCancelButton.frame = CGRectMake(_searchButton.frame.origin.x + _searchButton.frame.size.width + 10, 10, searchCancelButton.frame.size.width, searchCancelButton.frame.size.height);
            }
            else
            {
                _searchButton.frame = CGRectMake(10, 10, appDelegate.screenBounds.size.width - searchCancelButton.frame.size.width - 20, _searchButton.frame.size.height);
                searchCancelButton.frame = CGRectMake(appDelegate.screenBounds.size.width - searchCancelButton.frame.size.width - _searchButton.frame.origin.x + 5, 10, searchCancelButton.frame.size.width, searchCancelButton.frame.size.height);
            }
        } completion:^(BOOL finished){
            _mainWindowContainer.hidden = YES;
            backButton.hidden = YES;
            
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
        
        backButton.hidden = NO;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            searchCancelButton.alpha = 0.0;
            searchBox.alpha = 0.0;
            _mainWindowContainer.alpha = 1.0;
            backButton.alpha = 1.0;
            _contactCloud.cloudContainer.alpha = 1.0;
            _contactCloud.cloudSearchResultsContainer.alpha = 0.0;
            
            _searchButton.frame = CGRectMake(appDelegate.screenBounds.size.width - 45, 30, 35, _searchButton.frame.size.height);
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
    contactCloudInfoLabel.hidden = NO;
    contactCloudInfoLabel.text = NSLocalizedString(@"CHAT_CLOUD_EMPTY", nil);
}

#pragma mark -
#pragma mark Loading the Cloud

- (void)loadCloud
{
    if ( _mode == SHRecipientPickerModeBoardRequests )
    {
        [self loadRequests];
    }
    else if ( _mode == SHRecipientPickerModeBoardMembers )
    {
        [self loadBoardMembers];
    }
    else if ( _mode == SHRecipientPickerModeFollowing )
    {
        [self loadFollowing];
    }
    else if ( _mode == SHRecipientPickerModeFollowers )
    {
        [self loadFollowers];
    }
}

- (void)removeBubbleForUser:(NSString *)userID
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for ( int i = 0; i < _contactCloud.cloudBubbles.count; i++ )
        {
            SHChatBubble *bubble = [_contactCloud.cloudBubbles objectAtIndex:i];
            
            if ( bubble.bubbleType == SHChatBubbleTypeUser )
            {
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
        }
        
        if ( _contactCloud.cloudBubbles.count == 0 )
        {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self showEmptyCloud];
            });
        }
    });
}

- (void)loadRequests
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [appDelegate.strobeLight activateStrobeLight];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": appDelegate.SHToken,
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                 @"board_id": _boardID};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/getboardrequests", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        if ( errorCode == 0 )
        {
            NSArray *response = [responseObject objectForKey:@"response"];
            
            [self processRequests:response];
            [appDelegate.strobeLight deactivateStrobeLight];
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

- (void)processRequests:(NSArray *)requests
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_contactCloud beginUpdates];
        
        // Read & store each new contact's data.
        for ( int i = 0; i < requests.count; i++ )
        {
            __block NSMutableDictionary *boardRequest = [[requests objectAtIndex:i] mutableCopy];
            NSString *userID = [boardRequest objectForKey:@"user_id"];
            NSString *DPHash = @"";
            
            [boardRequest setObject:[NSString stringWithFormat:@"%d", SHChatBubbleTypeUser] forKey:@"bubble_type"];
            
            if ( [boardRequest objectForKey:@"user_handle"] && ![[NSNull null] isEqual:[boardRequest objectForKey:@"user_handle"]] )
            {
                
            }
            else
            {
                [boardRequest setObject:@"" forKey:@"user_handle"];
            }
            
            if ( [boardRequest objectForKey:@"dp_hash"] && ![[NSNull null] isEqual:[boardRequest objectForKey:@"dp_hash"]] )
            {
                DPHash = [boardRequest objectForKey:@"dp_hash"];
            }
            else
            {
                [boardRequest setObject:@"" forKey:@"dp_hash"];
            }
            
            if ( [boardRequest objectForKey:@"email_address"] && ![[NSNull null] isEqual:[boardRequest objectForKey:@"email_address"]] )
            {
                
            }
            else
            {
                [boardRequest setObject:@"" forKey:@"email_address"];
            }
            
            if ( [boardRequest objectForKey:@"gender"] && ![[NSNull null] isEqual:[boardRequest objectForKey:@"gender"]] )
            {
                
            }
            else
            {
                [boardRequest setObject:@"" forKey:@"gender"];
            }
            
            if ( [boardRequest objectForKey:@"location_country"] && ![[NSNull null] isEqual:[boardRequest objectForKey:@"location_country"]] )
            {
                
            }
            else
            {
                [boardRequest setObject:@"" forKey:@"location_country"];
            }
            
            if ( [boardRequest objectForKey:@"location_state"] && ![[NSNull null] isEqual:[boardRequest objectForKey:@"location_state"]] )
            {
                
            }
            else
            {
                [boardRequest setObject:@"" forKey:@"location_state"];
            }
            
            if ( [boardRequest objectForKey:@"location_city"] && ![[NSNull null] isEqual:[boardRequest objectForKey:@"location_city"]] )
            {
                
            }
            else
            {
                [boardRequest setObject:@"" forKey:@"location_city"];
            }
            
            if ( [boardRequest objectForKey:@"website"] && ![[NSNull null] isEqual:[boardRequest objectForKey:@"website"]] )
            {
                
            }
            else
            {
                [boardRequest setObject:@"" forKey:@"website"];
            }
            
            if ( [boardRequest objectForKey:@"bio"] && ![[NSNull null] isEqual:[boardRequest objectForKey:@"bio"]] )
            {
                
            }
            else
            {
                [boardRequest setObject:@"" forKey:@"bio"];
            }
            
            if ( [boardRequest objectForKey:@"location_latitude"] && ![[NSNull null] isEqual:[boardRequest objectForKey:@"location_latitude"]] )
            {
                
            }
            else
            {
                [boardRequest setObject:@"" forKey:@"location_latitude"];
                [boardRequest setObject:@"" forKey:@"location_longitude"];
            }
            
            if ( [boardRequest objectForKey:@"birthday"] && ![[NSNull null] isEqual:[boardRequest objectForKey:@"birthday"]] )
            {
                
            }
            else
            {
                [boardRequest setObject:@"" forKey:@"birthday"];
            }
            
            CGFloat centerOffset_x = (_contactCloud.contentSize.width / 2);
            CGFloat centerOffset_y = (_contactCloud.contentSize.height / 2);
            
            NSInteger pos_x = arc4random_uniform(20) + centerOffset_x;
            NSInteger pos_y = arc4random_uniform(20) + centerOffset_y;
            
            UIImage *currentDP = [UIImage imageNamed:@"user_placeholder"];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                SHChatBubble *bubble = [[SHChatBubble alloc] initWithFrame:CGRectMake(0, 0, CHAT_CLOUD_BUBBLE_SIZE, CHAT_CLOUD_BUBBLE_SIZE) andImage:currentDP withMiniModeEnabled:NO];
                [bubble setBubbleMetadata:boardRequest];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [_contactCloud insertBubble:bubble atPoint:CGPointMake(pos_x, pos_y) animated:YES];
                });
            });
            
            // DP loading.
            if ( DPHash && DPHash.length > 0 )
            {
                NSURL *DPURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/userphotos/theboard/%@/profile/f_%@.jpg", SH_DOMAIN, userID, DPHash]];
                
                NSURLRequest *request = [NSURLRequest requestWithURL:DPURL];
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    UIImage *testDP = [UIImage imageWithData:data];
                    
                    if ( testDP )
                    {
                        [boardRequest setObject:data forKey:@"dp"];
                        
                        // Now we update the Cloud directly.
                        for ( int j = 0; j < _contactCloud.cloudBubbles.count; j++ )
                        {
                            if ( _contactCloud.cloudBubbles.count > j )
                            {
                                SHChatBubble *bubble = [_contactCloud.cloudBubbles objectAtIndex:j];
                                
                                if ( bubble.bubbleType == SHChatBubbleTypeUser )
                                {
                                    int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
                                    
                                    if ( bubbleID == userID.intValue )
                                    {
                                        dispatch_async(dispatch_get_main_queue(), ^(void){
                                            [bubble.metadata setObject:data forKey:@"dp"];
                                            [bubble setImage:[UIImage imageWithData:data]];
                                        });
                                        
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }];
            }
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
                contactCloudInfoLabel.hidden = YES;
            }
            
            // Center the cloud's offset.
            CGFloat centerOffset_x = (_contactCloud.contentSize.width / 2) - (_contactCloud.bounds.size.width / 2);
            CGFloat centerOffset_y = (_contactCloud.contentSize.height / 2) - (_contactCloud.bounds.size.height / 2);
            [_contactCloud setContentOffset:CGPointMake(centerOffset_x, centerOffset_y) animated:YES];
            [_contactCloud endUpdates];
            [self setMaxMinZoomScalesForChatCloudBounds];
        });
    });
}

- (void)loadBoardMembers
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [appDelegate.strobeLight activateStrobeLight];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": appDelegate.SHToken,
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                 @"board_id": _boardID};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/getboardmembers", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        if ( errorCode == 0 )
        {
            NSArray *response = [responseObject objectForKey:@"response"];
            
            [self processBoardMembers:response];
            [appDelegate.strobeLight deactivateStrobeLight];
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

- (void)processBoardMembers:(NSArray *)members
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:appDelegate.modelManager.databasePath];
        [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [_contactCloud beginUpdates];
            
            // Read each members's data.
            for ( int i = 0; i < members.count; i++ )
            {
                __block NSMutableDictionary *member = [[members objectAtIndex:i] mutableCopy];
                NSString *userID = [member objectForKey:@"user_id"];
                NSString *DPHash = @"";
                
                FMResultSet *s1 = [db executeQuery:@"SELECT name FROM sh_cloud WHERE sh_user_id = :user_id"
                           withParameterDictionary:@{@"user_id": userID}];
                
                BOOL exists = NO;
                
                // Check if the contact's already stored.
                while ( [s1 next] )
                {
                    exists = YES;
                }
                
                [s1 close];
                
                if ( exists )
                {
                    [member setObject:@"0" forKey:@"temp"];
                }
                else
                {
                    [member setObject:@"1" forKey:@"temp"];
                }
                
                [member setObject:[NSString stringWithFormat:@"%d", SHChatBubbleTypeUser] forKey:@"bubble_type"];
                
                if ( [member objectForKey:@"user_handle"] && ![[NSNull null] isEqual:[member objectForKey:@"user_handle"]] )
                {
                    
                }
                else
                {
                    [member setObject:@"" forKey:@"user_handle"];
                }
                
                if ( [member objectForKey:@"dp_hash"] && ![[NSNull null] isEqual:[member objectForKey:@"dp_hash"]] )
                {
                    DPHash = [member objectForKey:@"dp_hash"];
                }
                else
                {
                    [member setObject:@"" forKey:@"dp_hash"];
                }
                
                if ( [member objectForKey:@"email_address"] && ![[NSNull null] isEqual:[member objectForKey:@"email_address"]] )
                {
                    
                }
                else
                {
                    [member setObject:@"" forKey:@"email_address"];
                }
                
                if ( [member objectForKey:@"gender"] && ![[NSNull null] isEqual:[member objectForKey:@"gender"]] )
                {
                    
                }
                else
                {
                    [member setObject:@"" forKey:@"gender"];
                }
                
                if ( [member objectForKey:@"location_country"] && ![[NSNull null] isEqual:[member objectForKey:@"location_country"]] )
                {
                    
                }
                else
                {
                    [member setObject:@"" forKey:@"location_country"];
                }
                
                if ( [member objectForKey:@"location_state"] && ![[NSNull null] isEqual:[member objectForKey:@"location_state"]] )
                {
                    
                }
                else
                {
                    [member setObject:@"" forKey:@"location_state"];
                }
                
                if ( [member objectForKey:@"location_city"] && ![[NSNull null] isEqual:[member objectForKey:@"location_city"]] )
                {
                    
                }
                else
                {
                    [member setObject:@"" forKey:@"location_city"];
                }
                
                if ( [member objectForKey:@"website"] && ![[NSNull null] isEqual:[member objectForKey:@"website"]] )
                {
                    
                }
                else
                {
                    [member setObject:@"" forKey:@"website"];
                }
                
                if ( [member objectForKey:@"bio"] && ![[NSNull null] isEqual:[member objectForKey:@"bio"]] )
                {
                    
                }
                else
                {
                    [member setObject:@"" forKey:@"bio"];
                }
                
                if ( [member objectForKey:@"location_latitude"] && ![[NSNull null] isEqual:[member objectForKey:@"location_latitude"]] )
                {
                    
                }
                else
                {
                    [member setObject:@"" forKey:@"location_latitude"];
                    [member setObject:@"" forKey:@"location_longitude"];
                }
                
                if ( [member objectForKey:@"birthday"] && ![[NSNull null] isEqual:[member objectForKey:@"birthday"]] )
                {
                    
                }
                else
                {
                    [member setObject:@"" forKey:@"birthday"];
                }
                
                CGFloat centerOffset_x = (_contactCloud.contentSize.width / 2);
                CGFloat centerOffset_y = (_contactCloud.contentSize.height / 2);
                
                NSInteger pos_x = arc4random_uniform(20) + centerOffset_x;
                NSInteger pos_y = arc4random_uniform(20) + centerOffset_y;
                
                UIImage *currentDP = [UIImage imageNamed:@"user_placeholder"];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    SHChatBubble *bubble = [[SHChatBubble alloc] initWithFrame:CGRectMake(0, 0, CHAT_CLOUD_BUBBLE_SIZE, CHAT_CLOUD_BUBBLE_SIZE) andImage:currentDP withMiniModeEnabled:NO];
                    [bubble setBubbleMetadata:member];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [_contactCloud insertBubble:bubble atPoint:CGPointMake(pos_x, pos_y) animated:YES];
                    });
                });
                
                // DP loading.
                if ( DPHash && DPHash.length > 0 )
                {
                    NSURL *DPURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/userphotos/theboard/%@/profile/f_%@.jpg", SH_DOMAIN, userID, DPHash]];
                    
                    NSURLRequest *request = [NSURLRequest requestWithURL:DPURL];
                    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                        UIImage *testDP = [UIImage imageWithData:data];
                        
                        if ( testDP )
                        {
                            [member setObject:data forKey:@"dp"];
                            
                            // Now we update the Cloud directly.
                            for ( int j = 0; j < _contactCloud.cloudBubbles.count; j++ )
                            {
                                if ( _contactCloud.cloudBubbles.count > j )
                                {
                                    SHChatBubble *bubble = [_contactCloud.cloudBubbles objectAtIndex:j];
                                    
                                    if ( bubble.bubbleType == SHChatBubbleTypeUser )
                                    {
                                        int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
                                        
                                        if ( bubbleID == userID.intValue )
                                        {
                                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                                [bubble.metadata setObject:data forKey:@"dp"];
                                                [bubble setImage:[UIImage imageWithData:data]];
                                            });
                                            
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }];
                }
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
                    contactCloudInfoLabel.hidden = YES;
                }
                
                // Center the cloud's offset.
                CGFloat centerOffset_x = (_contactCloud.contentSize.width / 2) - (_contactCloud.bounds.size.width / 2);
                CGFloat centerOffset_y = (_contactCloud.contentSize.height / 2) - (_contactCloud.bounds.size.height / 2);
                [_contactCloud setContentOffset:CGPointMake(centerOffset_x, centerOffset_y) animated:YES];
                [_contactCloud endUpdates];
                [self setMaxMinZoomScalesForChatCloudBounds];
            });
        }];
    });
}

- (void)loadFollowing
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [appDelegate.strobeLight activateStrobeLight];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": appDelegate.SHToken,
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                 @"user_id": _userID};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/getfollowingforuser", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        if ( errorCode == 0 )
        {
            NSArray *response = [responseObject objectForKey:@"response"];
            
            [self processPeople:response];
            [appDelegate.strobeLight deactivateStrobeLight];
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

- (void)loadFollowers
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [appDelegate.strobeLight activateStrobeLight];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": appDelegate.SHToken,
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                 @"user_id": _userID};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/getfollowersforuser", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        if ( errorCode == 0 )
        {
            NSArray *response = [responseObject objectForKey:@"response"];
            
            [self processPeople:response];
            [appDelegate.strobeLight deactivateStrobeLight];
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

- (void)processPeople:(NSArray *)people
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:appDelegate.modelManager.databasePath];
        [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [_contactCloud beginUpdates];
            
            // Read each person's data.
            for ( int i = 0; i < people.count; i++ )
            {
                __block NSMutableDictionary *user = [[people objectAtIndex:i] mutableCopy];
                NSString *userID = [user objectForKey:@"user_id"];
                NSString *DPHash = @"";
                
                FMResultSet *s1 = [db executeQuery:@"SELECT name FROM sh_cloud WHERE sh_user_id = :user_id"
                           withParameterDictionary:@{@"user_id": userID}];
                
                BOOL exists = NO;
                
                // Check if the contact's already stored.
                while ( [s1 next] )
                {
                    exists = YES;
                }
                
                [s1 close];
                
                if ( exists )
                {
                    [user setObject:@"0" forKey:@"temp"];
                }
                else
                {
                    [user setObject:@"1" forKey:@"temp"];
                }
                
                [user setObject:[NSString stringWithFormat:@"%d", SHChatBubbleTypeUser] forKey:@"bubble_type"];
                
                if ( [user objectForKey:@"user_handle"] && ![[NSNull null] isEqual:[user objectForKey:@"user_handle"]] )
                {
                    
                }
                else
                {
                    [user setObject:@"" forKey:@"user_handle"];
                }
                
                if ( [user objectForKey:@"dp_hash"] && ![[NSNull null] isEqual:[user objectForKey:@"dp_hash"]] )
                {
                    DPHash = [user objectForKey:@"dp_hash"];
                }
                else
                {
                    [user setObject:@"" forKey:@"dp_hash"];
                }
                
                if ( [user objectForKey:@"email_address"] && ![[NSNull null] isEqual:[user objectForKey:@"email_address"]] )
                {
                    
                }
                else
                {
                    [user setObject:@"" forKey:@"email_address"];
                }
                
                if ( [user objectForKey:@"gender"] && ![[NSNull null] isEqual:[user objectForKey:@"gender"]] )
                {
                    
                }
                else
                {
                    [user setObject:@"" forKey:@"gender"];
                }
                
                if ( [user objectForKey:@"location_country"] && ![[NSNull null] isEqual:[user objectForKey:@"location_country"]] )
                {
                    
                }
                else
                {
                    [user setObject:@"" forKey:@"location_country"];
                }
                
                if ( [user objectForKey:@"location_state"] && ![[NSNull null] isEqual:[user objectForKey:@"location_state"]] )
                {
                    
                }
                else
                {
                    [user setObject:@"" forKey:@"location_state"];
                }
                
                if ( [user objectForKey:@"location_city"] && ![[NSNull null] isEqual:[user objectForKey:@"location_city"]] )
                {
                    
                }
                else
                {
                    [user setObject:@"" forKey:@"location_city"];
                }
                
                if ( [user objectForKey:@"website"] && ![[NSNull null] isEqual:[user objectForKey:@"website"]] )
                {
                    
                }
                else
                {
                    [user setObject:@"" forKey:@"website"];
                }
                
                if ( [user objectForKey:@"bio"] && ![[NSNull null] isEqual:[user objectForKey:@"bio"]] )
                {
                    
                }
                else
                {
                    [user setObject:@"" forKey:@"bio"];
                }
                
                if ( [user objectForKey:@"location_latitude"] && ![[NSNull null] isEqual:[user objectForKey:@"location_latitude"]] )
                {
                    
                }
                else
                {
                    [user setObject:@"" forKey:@"location_latitude"];
                    [user setObject:@"" forKey:@"location_longitude"];
                }
                
                if ( [user objectForKey:@"birthday"] && ![[NSNull null] isEqual:[user objectForKey:@"birthday"]] )
                {
                    
                }
                else
                {
                    [user setObject:@"" forKey:@"birthday"];
                }
                
                CGFloat centerOffset_x = (_contactCloud.contentSize.width / 2);
                CGFloat centerOffset_y = (_contactCloud.contentSize.height / 2);
                
                NSInteger pos_x = arc4random_uniform(20) + centerOffset_x;
                NSInteger pos_y = arc4random_uniform(20) + centerOffset_y;
                
                UIImage *currentDP = [UIImage imageNamed:@"user_placeholder"];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    SHChatBubble *bubble = [[SHChatBubble alloc] initWithFrame:CGRectMake(0, 0, CHAT_CLOUD_BUBBLE_SIZE, CHAT_CLOUD_BUBBLE_SIZE) andImage:currentDP withMiniModeEnabled:NO];
                    [bubble setBubbleMetadata:user];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [_contactCloud insertBubble:bubble atPoint:CGPointMake(pos_x, pos_y) animated:YES];
                    });
                });
                
                // DP loading.
                if ( DPHash && DPHash.length > 0 )
                {
                    NSURL *DPURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/userphotos/theboard/%@/profile/f_%@.jpg", SH_DOMAIN, userID, DPHash]];
                    
                    NSURLRequest *request = [NSURLRequest requestWithURL:DPURL];
                    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                        UIImage *testDP = [UIImage imageWithData:data];
                        
                        if ( testDP )
                        {
                            [user setObject:data forKey:@"dp"];
                            
                            // Now we update the Cloud directly.
                            for ( int j = 0; j < _contactCloud.cloudBubbles.count; j++ )
                            {
                                if ( _contactCloud.cloudBubbles.count > j )
                                {
                                    SHChatBubble *bubble = [_contactCloud.cloudBubbles objectAtIndex:j];
                                    
                                    if ( bubble.bubbleType == SHChatBubbleTypeUser )
                                    {
                                        int bubbleID = [[bubble.metadata objectForKey:@"user_id"] intValue];
                                        
                                        if ( bubbleID == userID.intValue )
                                        {
                                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                                [bubble.metadata setObject:data forKey:@"dp"];
                                                [bubble setImage:[UIImage imageWithData:data]];
                                            });
                                            
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }];
                }
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
                    contactCloudInfoLabel.hidden = YES;
                }
                
                // Center the cloud's offset.
                CGFloat centerOffset_x = (_contactCloud.contentSize.width / 2) - (_contactCloud.bounds.size.width / 2);
                CGFloat centerOffset_y = (_contactCloud.contentSize.height / 2) - (_contactCloud.bounds.size.height / 2);
                [_contactCloud setContentOffset:CGPointMake(centerOffset_x, centerOffset_y) animated:YES];
                [_contactCloud endUpdates];
                [self setMaxMinZoomScalesForChatCloudBounds];
            });
        }];
    });
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
        photoPicker.allowsEditing = YES;
    }
    else
    {
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
        
        //_contactCloud.headerLabel.text = [NSString stringWithFormat:@"%d connection%@.", (int)_contactCloud.cloudBubbles.count, _contactCloud.cloudBubbles.count == 1 ? @"" : @"s"];
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
        backButton.frame = CGRectMake(_windowCompositionLayer.contentOffset.x + 10, backButton.frame.origin.y, backButton.frame.size.width, backButton.frame.size.height);
        _searchButton.frame = CGRectMake(_windowCompositionLayer.contentOffset.x + appDelegate.screenBounds.size.width - _searchButton.frame.size.width - 10, _searchButton.frame.origin.y, _searchButton.frame.size.width, _searchButton.frame.size.height);
        _chatCloudCenterButton.frame = CGRectMake(_windowCompositionLayer.contentOffset.x + 10, _chatCloudCenterButton.frame.origin.y, _chatCloudCenterButton.frame.size.width, _chatCloudCenterButton.frame.size.height);
        searchCancelButton.frame = CGRectMake(_windowCompositionLayer.contentOffset.x, searchCancelButton.frame.origin.y, searchCancelButton.frame.size.width, searchCancelButton.frame.size.height);
        
        if ( !_isFullscreen && !isShowingSearchInterface && _windowCompositionLayer.contentOffset.x <= appDelegate.screenBounds.size.width )
        {
            _contactCloud.hidden = NO;
            
            // Animate the alpha values.
            float y = _windowCompositionLayer.contentOffset.x + _windowCompositionLayer.frame.size.width;
            float width = _windowCompositionLayer.contentSize.width;
            
            float alphaValue = (1 - (y / width - 1) * 4) - 1;
            
            contactCloudInfoLabel.alpha = alphaValue;
            backButton.alpha = alphaValue;
            _searchButton.alpha = alphaValue;
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
            _profileView.mode = SHProfileViewModeViewing;
            _profileView.callbackView = self;
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds_windowPush * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self pushWindow:SHAppWindowTypeProfile];
            });
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
    SHChatBubbleType bubbleType = bubble.bubbleType;
    UIActionSheet *actionSheet;
    
    if ( bubbleType == SHChatBubbleTypeUser )
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
                                                destructiveButtonTitle:nil
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
    _mediaPickerSourceIsCamera = NO;
    activeBubble = nil;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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
            int delta = abs(newHeight - container.frame.size.height);
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
    
    _isPickingAliasDP = NO;
    _isPickingDP = NO;
    _mediaPickerSourceIsCamera = NO;
    activeBubble = nil;
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
    
    return NO;
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( actionSheet.tag == 0 ) // Chat Cloud bubble options.
    {
        
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
