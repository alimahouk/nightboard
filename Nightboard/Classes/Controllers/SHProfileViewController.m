//
//  SHProfileViewController.m
//  Nightboard
//
//  Created by MachOSX on 2/11/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import "SHProfileViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "AFHTTPRequestOperationManager.h"
#import "AppDelegate.h"
#import "SHRecipientPickerViewController.h"
#import "SHSettingsMainViewController.h"
#import "SHStatusViewController.h"
#import "SHWebViewController.h"

@implementation SHProfileViewController

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        _ownerDataChunk = [NSMutableDictionary dictionary];
        _ownerID = @"";
        _shouldRefreshInfo = YES; // Set initially to YES so the profile loads the initial data.
        
        followingCount = 0;
        followerCount = 0;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    }
    
    return self;
}

- (void)loadView
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UIView *contentView = [[UIView alloc] initWithFrame:appDelegate.screenBounds];
    
    _upperPane = [[UIView alloc] initWithFrame:CGRectMake(0, -20, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height / 2 - 20)];
    
    // Button action added in viewWillAppear.
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(10, 5, 34, 34);
    backButton.showsTouchWhenHighlighted = YES;
    
    settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setBackgroundImage:[[UIImage imageNamed:@"button_round_white_transparent"] stretchableImageWithLeftCapWidth:17 topCapHeight:17] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(presentSettings) forControlEvents:UIControlEventTouchUpInside];
    settingsButton.frame = CGRectMake(appDelegate.screenBounds.size.width - 45, 5, 35, 35);
    settingsButton.showsTouchWhenHighlighted = YES;
    settingsButton.opaque = YES;
    
    statusBubble = [UIButton buttonWithType:UIButtonTypeCustom];
    [statusBubble setBackgroundImage:[[UIImage imageNamed:@"button_round_white_transparent"] stretchableImageWithLeftCapWidth:17 topCapHeight:17] forState:UIControlStateNormal];
    [statusBubble addTarget:self action:@selector(showStatusOptions) forControlEvents:UIControlEventTouchUpInside];
    statusBubble.frame = CGRectMake(55, 5, appDelegate.screenBounds.size.width - (55 * 2), 33);
    statusBubble.alpha = 0.0;
    statusBubble.opaque = YES;
    
    addUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addUserButton addTarget:self action:@selector(addUser) forControlEvents:UIControlEventTouchUpInside];
    [addUserButton setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    [addUserButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    addUserButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MAIN_FONT_SIZE];
    addUserButton.frame = CGRectMake(20, 1, appDelegate.screenBounds.size.width - 40, 50);
    addUserButton.opaque = YES;
    
    declineUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [declineUserButton addTarget:self action:@selector(declineUserRequest) forControlEvents:UIControlEventTouchUpInside];
    [declineUserButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [declineUserButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [declineUserButton setTitle:NSLocalizedString(@"PROFILE_DECLINE_REQUEST", nil) forState:UIControlStateNormal];
    declineUserButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MAIN_FONT_SIZE];
    declineUserButton.frame = CGRectMake((appDelegate.screenBounds.size.width / 2) + 5, 1, (appDelegate.screenBounds.size.width / 2) - 15, 50);
    declineUserButton.opaque = YES;
    
    followingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [followingButton addTarget:self action:@selector(presentFollowing) forControlEvents:UIControlEventTouchUpInside];
    [followingButton setBackgroundImage:[[UIImage imageNamed:@"button_grey_bg"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    followingButton.frame = CGRectMake(0, 0, appDelegate.screenBounds.size.width / 2, 70);
    followingButton.opaque = YES;
    
    followersButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [followersButton addTarget:self action:@selector(presentFollowers) forControlEvents:UIControlEventTouchUpInside];
    [followersButton setBackgroundImage:[[UIImage imageNamed:@"button_grey_bg"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    followersButton.frame = CGRectMake(appDelegate.screenBounds.size.width / 2, 0, appDelegate.screenBounds.size.width / 2, 70);
    followersButton.opaque = YES;
    
    emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emailButton addTarget:self action:@selector(emailUser) forControlEvents:UIControlEventTouchUpInside];
    [emailButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [emailButton setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    emailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    emailButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MAIN_FONT_SIZE];
    emailButton.frame = CGRectMake(20, 1, appDelegate.screenBounds.size.width - 40, 38);
    emailButton.opaque = YES;
    
    websiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [websiteButton addTarget:self action:@selector(gotoWebsite) forControlEvents:UIControlEventTouchUpInside];
    [websiteButton setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    [websiteButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    websiteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    websiteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MAIN_FONT_SIZE];
    websiteButton.frame = CGRectMake(20, 41, appDelegate.screenBounds.size.width - 40, 38);
    websiteButton.opaque = YES;
    
    UIImageView *settingsIcon = [[UIImageView alloc] initWithFrame:CGRectMake(9.5, 9.5, 16, 16)];
    settingsIcon.image = [UIImage imageNamed:@"settings_white"];
    settingsIcon.opaque = YES;
    
    UIImageView *detailIcon_sex = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    detailIcon_sex.image = [UIImage imageNamed:@"profile_sex_male"];
    detailIcon_sex.opaque = YES;
    detailIcon_sex.tag = 91;
    
    UIImageView *detailIcon_location = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    detailIcon_location.image = [UIImage imageNamed:@"profile_location"];
    detailIcon_location.opaque = YES;
    detailIcon_location.tag = 91;
    
    UIImageView *detailIcon_age = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    detailIcon_age.image = [UIImage imageNamed:@"profile_birthday"];
    detailIcon_age.opaque = YES;
    detailIcon_age.tag = 91;
    
    statusBubbleTrail_1 = [[UIImageView alloc] init];
    statusBubbleTrail_1.image = [UIImage imageNamed:@"bubble_trail_white_1"];
    statusBubbleTrail_1.opaque = YES;
    statusBubbleTrail_1.alpha = 0.0;
    
    statusBubbleTrail_2 = [[UIImageView alloc] init];
    statusBubbleTrail_2.image = [UIImage imageNamed:@"bubble_trail_white_2"];
    statusBubbleTrail_2.opaque = YES;
    statusBubbleTrail_2.alpha = 0.0;
    
    detailLine_1 = [[UIImageView alloc] init];
    detailLine_1.image = [[UIImage imageNamed:@"profile_detail_line"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    detailLine_1.opaque = YES;
    detailLine_1.alpha = 0.0;
    
    detailLine_2 = [[UIImageView alloc] init];
    detailLine_2.image = [[UIImage imageNamed:@"profile_detail_line"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    detailLine_2.opaque = YES;
    detailLine_2.alpha = 0.0;
    
    detailLine_3 = [[UIImageView alloc] init];
    detailLine_3.image = [[UIImage imageNamed:@"profile_detail_line"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    detailLine_3.opaque = YES;
    detailLine_3.alpha = 0.0;
    
    userBubble = [[SHChatBubble alloc] initWithFrame:CGRectMake(_upperPane.frame.size.width / 2 - CHAT_CLOUD_BUBBLE_SIZE / 2, _upperPane.frame.size.height / 2 - CHAT_CLOUD_BUBBLE_SIZE / 2, CHAT_CLOUD_BUBBLE_SIZE, CHAT_CLOUD_BUBBLE_SIZE)];
    userBubble.alpha = 0.0;
    userBubble.delegate = self;
    
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, statusBubble.frame.size.width - 20, 17)];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    statusLabel.numberOfLines = 0;
    statusLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    statusLabel.text = @"...";
    
    usernameLabel = [[UILabel alloc] init];
    usernameLabel.backgroundColor = [UIColor clearColor];
    usernameLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    usernameLabel.textAlignment = NSTextAlignmentCenter;
    usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    usernameLabel.minimumScaleFactor = 8.0 / SECONDARY_FONT_SIZE;
    usernameLabel.adjustsFontSizeToFitWidth = YES;
    usernameLabel.numberOfLines = 1;
    usernameLabel.opaque = YES;
    
    lastSeenLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, appDelegate.screenBounds.size.width - 40, 18)];
    lastSeenLabel.backgroundColor = [UIColor clearColor];
    lastSeenLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    lastSeenLabel.numberOfLines = 1;
    lastSeenLabel.minimumScaleFactor = 8.0 / MIN_MAIN_FONT_SIZE;
    lastSeenLabel.adjustsFontSizeToFitWidth = YES;
    lastSeenLabel.textAlignment = NSTextAlignmentCenter;
    lastSeenLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    lastSeenLabel.shadowOffset = CGSizeMake(0, 1);
    
    joinDateLabel = [[UILabel alloc] init];
    joinDateLabel.backgroundColor = [UIColor clearColor];
    joinDateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    joinDateLabel.textColor = [UIColor colorWithRed:144.0/255.0 green:143.0/255.0 blue:149.0/255.0 alpha:1.0];
    joinDateLabel.numberOfLines = 1;
    joinDateLabel.minimumScaleFactor = 8.0 / SECONDARY_FONT_SIZE;
    joinDateLabel.adjustsFontSizeToFitWidth = YES;
    joinDateLabel.textAlignment = NSTextAlignmentCenter;
    joinDateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    joinDateLabel.shadowOffset = CGSizeMake(0, 1);
    
    // These labels' widths are set when assigning their random positions in refreshView.
    detailLabel_locationDescription = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 0, 14)];
    detailLabel_locationDescription.backgroundColor = [UIColor clearColor];
    detailLabel_locationDescription.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:SECONDARY_FONT_SIZE];
    detailLabel_locationDescription.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    detailLabel_locationDescription.tag = 92;
    detailLabel_locationDescription.text = @"Located in";
    
    detailLabel_location = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 0, 14)];
    detailLabel_location.backgroundColor = [UIColor clearColor];
    detailLabel_location.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:SECONDARY_FONT_SIZE];
    detailLabel_location.numberOfLines = 1;
    detailLabel_location.minimumScaleFactor = 8.0 / SECONDARY_FONT_SIZE;
    detailLabel_location.adjustsFontSizeToFitWidth = YES;
    detailLabel_location.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    detailLabel_location.tag = 90;
    
    detailLabel_sex = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 0, 14)];
    detailLabel_sex.backgroundColor = [UIColor clearColor];
    detailLabel_sex.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:SECONDARY_FONT_SIZE];
    detailLabel_sex.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    detailLabel_sex.tag = 90;
    detailLabel_sex.text = @"male.";
    
    detailLabel_age = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 0, 14)];
    detailLabel_age.backgroundColor = [UIColor clearColor];
    detailLabel_age.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:SECONDARY_FONT_SIZE];
    detailLabel_age.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    detailLabel_age.tag = 90;
    
    detail_location = [[UIView alloc] init];
    detail_location.alpha = 0.0;
    
    detail_sex = [[UIView alloc] init];
    detail_sex.alpha = 0.0;
    
    detail_age = [[UIView alloc] init];
    detail_age.alpha = 0.0;
    
    panel_1 = [[UIView alloc] initWithFrame:CGRectMake(0, 10 + lastSeenLabel.frame.origin.y + lastSeenLabel.frame.size.height, appDelegate.screenBounds.size.width, 70)];
    panel_1.backgroundColor = [UIColor whiteColor];
    
    panel_2 = [[UIView alloc] initWithFrame:CGRectMake(0, 35 + panel_1.frame.origin.y + panel_1.frame.size.height, appDelegate.screenBounds.size.width, 90)];
    panel_2.backgroundColor = [UIColor whiteColor];
    
    panel_3 = [[UIView alloc] init];
    panel_3.backgroundColor = [UIColor whiteColor];
    
    windowSideline_left = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"wallpaper_sideline"] stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
    windowSideline_left.opaque = YES;
    
    panel_1_horizontalSeparator_1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenBounds.size.width, 1)];
    panel_1_horizontalSeparator_1.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    panel_1_horizontalSeparator_2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, panel_1.frame.size.height - 1, appDelegate.screenBounds.size.width, 1)];
    panel_1_horizontalSeparator_2.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    panel_1_verticalSeparator_1 = [[UIImageView alloc] initWithFrame:CGRectMake(appDelegate.screenBounds.size.width / 2 - 0.5, 0, 1, panel_1.frame.size.height)];
    panel_1_verticalSeparator_1.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    panel_2_horizontalSeparator_1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenBounds.size.width, 1)];
    panel_2_horizontalSeparator_1.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    panel_2_horizontalSeparator_2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, panel_2.frame.size.height - 1, appDelegate.screenBounds.size.width, 1)];
    panel_2_horizontalSeparator_2.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    panel_3_horizontalSeparator_1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenBounds.size.width, 1)];
    panel_3_horizontalSeparator_1.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    panel_3_horizontalSeparator_2 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 40, appDelegate.screenBounds.size.width - 20, 1)];
    panel_3_horizontalSeparator_2.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    panel_3_horizontalSeparator_3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 82, appDelegate.screenBounds.size.width, 1)];
    panel_3_horizontalSeparator_3.image = [[UIImage imageNamed:@"separator_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    statLabel_following = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, appDelegate.screenBounds.size.width / 2 - 1, 20)];
    statLabel_following.backgroundColor = [UIColor clearColor];
    statLabel_following.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:MAIN_FONT_SIZE];
    statLabel_following.textAlignment = NSTextAlignmentCenter;
    statLabel_following.text = @"…";
    
    statLabel_followers = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, appDelegate.screenBounds.size.width / 2 - 1, 20)];
    statLabel_followers.backgroundColor = [UIColor clearColor];
    statLabel_followers.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:MAIN_FONT_SIZE];
    statLabel_followers.textAlignment = NSTextAlignmentCenter;
    statLabel_followers.text = @"…";
    
    descriptionLabel_following = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, appDelegate.screenBounds.size.width / 2 - 1, 14)];
    descriptionLabel_following.backgroundColor = [UIColor clearColor];
    descriptionLabel_following.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:SECONDARY_FONT_SIZE];
    descriptionLabel_following.textColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    descriptionLabel_following.textAlignment = NSTextAlignmentCenter;
    
    descriptionLabel_followers = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, appDelegate.screenBounds.size.width / 2 - 1, 14)];
    descriptionLabel_followers.backgroundColor = [UIColor clearColor];
    descriptionLabel_followers.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:SECONDARY_FONT_SIZE];
    descriptionLabel_followers.textColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    descriptionLabel_followers.textAlignment = NSTextAlignmentCenter;
    
    bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, appDelegate.screenBounds.size.width - 40, 20)];
    bioLabel.backgroundColor = [UIColor clearColor];
    bioLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MAIN_FONT_SIZE];
    bioLabel.numberOfLines = 0;
    
    _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height)];
    _mainView.delegate = self;
    _mainView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    _mainView.contentSize = CGSizeMake(_mainView.frame.size.width, appDelegate.screenBounds.size.height + 1);
    _mainView.scrollsToTop = NO;
    _mainView.tag = 7;
    
    UIColor *outerColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    UIColor *innerColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    
    // Adding transparency to the top of the main view.
    maskLayer_mainView = [CAGradientLayer layer];
    maskLayer_mainView.colors = [NSArray arrayWithObjects:(__bridge id)innerColor.CGColor, (__bridge id)innerColor.CGColor, (__bridge id)outerColor.CGColor, nil];
    maskLayer_mainView.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                                    [NSNumber numberWithFloat:0.02],
                                    [NSNumber numberWithFloat:0.08], nil];
    
    maskLayer_mainView.bounds = CGRectMake(0, -25, _mainView.frame.size.width, _mainView.frame.size.height);
    maskLayer_mainView.position = CGPointMake(0, _mainView.contentOffset.y);
    maskLayer_mainView.anchorPoint = CGPointZero;
    _mainView.layer.mask = maskLayer_mainView;
    
    _BG = [[UIImageView alloc] initWithFrame:CGRectMake(0, _upperPane.frame.size.height - 9, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height * 2 + 200)];
    _BG.image = [[UIImage imageNamed:@"std_bg_gray"] stretchableImageWithLeftCapWidth:0 topCapHeight:11];
    _BG.userInteractionEnabled = YES;
    
    if ( !(IS_IOS7) ) // Non-iOS 7 fixes.
    {
        statusLabel.frame = CGRectMake(10, 10, statusBubble.frame.size.width - 15, 17);
        _mainView.frame = CGRectMake(0, -20, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height);
    }
    
    // Show the tooltip on tap-and-hold.
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressStatus:)];
    [statusBubble addGestureRecognizer:longPressRecognizer];
    
    [settingsButton addSubview:settingsIcon];
    [statusBubble addSubview:statusLabel];
    [detail_sex addSubview:detailIcon_sex];
    [detail_sex addSubview:detailLabel_sex];
    [detail_location addSubview:detailIcon_location];
    [detail_location addSubview:detailLabel_locationDescription];
    [detail_location addSubview:detailLabel_location];
    [detail_age addSubview:detailIcon_age];
    [detail_age addSubview:detailLabel_age];
    [followingButton addSubview:statLabel_following];
    [followingButton addSubview:descriptionLabel_following];
    [followersButton addSubview:statLabel_followers];
    [followersButton addSubview:descriptionLabel_followers];
    [panel_1 addSubview:followingButton];
    [panel_1 addSubview:followersButton];
    [panel_1 addSubview:panel_1_horizontalSeparator_1];
    [panel_1 addSubview:panel_1_horizontalSeparator_2];
    [panel_1 addSubview:panel_1_verticalSeparator_1];
    [panel_2 addSubview:panel_2_horizontalSeparator_1];
    [panel_2 addSubview:panel_2_horizontalSeparator_2];
    [panel_2 addSubview:bioLabel];
    [panel_3 addSubview:panel_3_horizontalSeparator_1];
    [panel_3 addSubview:panel_3_horizontalSeparator_2];
    [panel_3 addSubview:panel_3_horizontalSeparator_3];
    [panel_3 addSubview:emailButton];
    [panel_3 addSubview:websiteButton];
    [_BG addSubview:addUserButton];
    [_BG addSubview:declineUserButton];
    [_BG addSubview:lastSeenLabel];
    [_BG addSubview:joinDateLabel];
    [_BG addSubview:panel_1];
    [_BG addSubview:panel_2];
    [_BG addSubview:panel_3];
    [_upperPane addSubview:backButton];
    [_upperPane addSubview:settingsButton];
    [_upperPane addSubview:statusBubbleTrail_1];
    [_upperPane addSubview:statusBubbleTrail_2];
    [_upperPane addSubview:statusBubble];
    [_upperPane addSubview:detailLine_1];
    [_upperPane addSubview:detailLine_2];
    [_upperPane addSubview:detailLine_3];
    [_upperPane addSubview:detail_sex];
    [_upperPane addSubview:detail_location];
    [_upperPane addSubview:detail_age];
    [_upperPane addSubview:usernameLabel];
    [_upperPane addSubview:userBubble];
    [_mainView addSubview:_BG];
    [_mainView addSubview:_upperPane];
    [_mainView addSubview:windowSideline_left];
    [contentView addSubview:_mainView];
    
    self.view = contentView;
}

- (void)viewDidLoad
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( (IS_IOS7) )
    {
        [appDelegate registerPrallaxEffectForView:statusBubbleTrail_1 depth:PARALLAX_DEPTH_LIGHT];
        [appDelegate registerPrallaxEffectForView:statusBubbleTrail_2 depth:PARALLAX_DEPTH_LIGHT];
        [appDelegate registerPrallaxEffectForView:userBubble depth:PARALLAX_DEPTH_HEAVY];
        [appDelegate registerPrallaxEffectForView:usernameLabel depth:PARALLAX_DEPTH_HEAVY];
    }
    
    // The "pop" animation the first time you load the view.
    [userBubble setTransform:CGAffineTransformMakeScale(0.1, 0.1)];
    
    [UIView animateWithDuration:0.25 delay:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        userBubble.transform = CGAffineTransformMakeScale(1.2, 1.2);
        detailLine_1.alpha = 1.0;
        detailLine_2.alpha = 1.0;
        detailLine_3.alpha = 1.0;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            userBubble.transform = CGAffineTransformIdentity;
            detail_sex.alpha = 1.0;
            detail_location.alpha = 1.0;
            detail_age.alpha = 1.0;
        } completion:^(BOOL finished){
            
        }];
    }];
    
    [UIView animateWithDuration:0.25 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        userBubble.alpha = 1.0;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            statusBubbleTrail_1.alpha = 1.0;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                statusBubbleTrail_2.alpha = 1.0;
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    statusBubble.alpha = 1.0;
                } completion:^(BOOL finished){
                    
                }];
            }];
        }];
    }];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    _mainView.delegate = self;
    
    if ( viewControllers.count == 1 ) // Top level, meaning current user's profile.
    {
        [backButton addTarget:self action:@selector(presentMainMenu) forControlEvents:UIControlEventTouchUpInside];
        
        [_callbackView enableCompositionLayerScrolling]; // Unlock the layer.
    }
    else
    {
        // Overrides.
        [backButton setBackgroundImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        backButton.frame = CGRectMake(10, 7, 31, 31);
        backButton.showsTouchWhenHighlighted = YES;
    }
    
    if ( _shouldRefreshInfo && [_ownerDataChunk objectForKey:@"user_id"] )
    {
        [self refreshViewWithDP:YES];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionStatusBar];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ( !isCurrentUser )
    {
        _mainView.delegate = nil; // Callbacks get sent to deallocated instance otherwise.
    }
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if ( viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self ) // View is disappearing because a new view controller was pushed onto the stack.
    {
        [_callbackView disableCompositionLayerScrolling]; // Lock the layer.
    }
    else if ( [viewControllers indexOfObject:self] == NSNotFound ) // View is disappearing because it was popped from the stack.
    {
        [_callbackView enableCompositionLayerScrolling]; // Unlock the layer.
    }
    
    [super viewWillDisappear:animated];
}

- (void)refreshViewWithDP:(BOOL)refreshDP
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    BOOL spottedUser = [[_ownerDataChunk objectForKey:@"spotted_user"] boolValue];
    BOOL followsUser = [[_ownerDataChunk objectForKey:@"follows_user"] boolValue];
    BOOL temp = NO;
    BOOL showsEmail = NO;
    
    if ( [[appDelegate.currentUser objectForKey:@"user_id"] intValue] == [[_ownerDataChunk objectForKey:@"user_id"] intValue] )
    {
        isCurrentUser = YES;
    }
    else
    {
        temp = [[_ownerDataChunk objectForKey:@"temp"] boolValue];
        
        isCurrentUser = NO;
    }
    
    _shouldRefreshInfo = NO; // Reset this.
    _ownerID = [_ownerDataChunk objectForKey:@"user_id"];
    
    if ( isCurrentUser )
    {
        showsEmail = YES;
    }
    else
    {
        if ( followsUser )
        {
            showsEmail = YES;
        }
    }
    
    statusLabel.text = [_ownerDataChunk objectForKey:@"message"];
    
    if ( refreshDP )
    {
        UIImage *currentDP = [UIImage imageWithData:[_ownerDataChunk objectForKey:@"alias_dp"]];
        
        if ( !currentDP )
        {
            currentDP = [UIImage imageWithData:[_ownerDataChunk objectForKey:@"dp"]];
            
            if ( !currentDP )
            {
                currentDP = [UIImage imageNamed:@"user_placeholder"];
            }
        }
        
        [userBubble setImage:currentDP];
    }
    
    NSString *nameText = [_ownerDataChunk objectForKey:@"alias"];
    
    if ( nameText.length == 0 )
    {
        nameText = [_ownerDataChunk objectForKey:@"name"];
    }
    
    [userBubble setLabelText:nameText withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:SECONDARY_FONT_SIZE]];
    
    if ( !isCurrentUser )
    {
        if ( _mode == SHProfileViewModeAcceptRequest )
        {
            [addUserButton setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
            [addUserButton setTitle:NSLocalizedString(@"PROFILE_ACCEPT_REQUEST", nil) forState:UIControlStateNormal];
            
            addUserButton.frame = CGRectMake(10, 1, (appDelegate.screenBounds.size.width / 2) - 15, 50);
            addUserButton.hidden = NO;
            declineUserButton.hidden = NO;
        }
        else
        {
            if ( spottedUser )
            {
                if ( temp )
                {
                    [addUserButton setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
                    [addUserButton setTitle:NSLocalizedString(@"PROFILE_ADD_USER", nil) forState:UIControlStateNormal];
                }
                else
                {
                    [addUserButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [addUserButton setTitle:NSLocalizedString(@"PROFILE_REMOVE_USER", nil) forState:UIControlStateNormal];
                }
                
                addUserButton.frame = CGRectMake(20, 1, appDelegate.screenBounds.size.width - 40, 50);
                addUserButton.hidden = NO;
            }
            else
            {
                addUserButton.hidden = YES;
            }
            
            declineUserButton.hidden = YES;
        }
        
        addUserButton.enabled = YES;
        joinDateLabel.text = @"";
        
        settingsButton.hidden = YES;
        
        if ( showsEmail && !isCurrentUser )
        {
            joinDateLabel.text = NSLocalizedString(@"PROFILE_HAS_USER_AS_CONTACT", nil);
        }
        
        /*NSDate *presenceTimestampDate = [dateFormatter dateFromString:[_ownerDataChunk objectForKey:@"presence_timestamp"]];
         NSString *presenceTimestampString = [appDelegate relativeTimefromDate:presenceTimestampDate shortened:NO condensed:NO];
         
         lastSeenLabel.text = [[NSString stringWithFormat:@"last seen %@", presenceTimestampString] uppercaseString];*/
    }
    else
    {
        declineUserButton.hidden = YES;
        settingsButton.hidden = NO;
        
        [addUserButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [addUserButton setTitle:NSLocalizedString(@"PROFILE_CURRENT_USER", nil) forState:UIControlStateNormal];
        addUserButton.enabled = NO;
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *joined = [dateFormatter dateFromString:[_ownerDataChunk objectForKey:@"join_date"]];
        
        [dateFormatter setDateFormat:@"cccc, d MMM, yyyy"];
        
        joinDate = [dateFormatter stringFromDate:joined];
        joinDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PROFILE_JOIN_DATE", nil), joinDate];
    }
    
    CGSize textSize_status = [statusLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(statusLabel.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    if ( !(IS_IOS7) ) // Non-iOS 7 fixes.
    {
        statusBubble.frame = CGRectMake(55, 5, appDelegate.screenBounds.size.width - (55 * 2), textSize_status.height + 15);
        statusLabel.frame = CGRectMake(10, 10, statusLabel.frame.size.width, textSize_status.height - 3);
    }
    else
    {
        statusBubble.frame = CGRectMake(55, 5, appDelegate.screenBounds.size.width - (55 * 2), textSize_status.height + 17);
        statusLabel.frame = CGRectMake(10, 5, statusLabel.frame.size.width, textSize_status.height + 3);
    }
    
    statusBubbleTrail_1.frame = CGRectMake(110, 75 + (statusBubble.frame.size.height - 33), 9, 9);
    statusBubbleTrail_2.frame = CGRectMake(90, 55 + (statusBubble.frame.size.height - 33), 15, 15);
    
    userBubble.frame = CGRectMake(userBubble.frame.origin.x, (_upperPane.frame.size.height / 2 - CHAT_CLOUD_BUBBLE_SIZE / 2) + (statusBubble.frame.size.height - 33), userBubble.frame.size.width, userBubble.frame.size.height);
    usernameLabel.frame = CGRectMake(20, userBubble.frame.origin.y + userBubble.frame.size.height + 17, appDelegate.screenBounds.size.width - 40, 15);
    
    if ( [[[_ownerDataChunk objectForKey:@"gender"] lowercaseString] isEqualToString:@"m"] )
    {
        gender = @"male";
    }
    else if ( [[[_ownerDataChunk objectForKey:@"gender"] lowercaseString] isEqualToString:@"f"] )
    {
        gender = @"female";
    }
    else
    {
        gender = @"";
    }
    
    NSString *birthday = [_ownerDataChunk objectForKey:@"birthday"];
    NSString *country = [_ownerDataChunk objectForKey:@"location_country"];
    NSString *state = [_ownerDataChunk objectForKey:@"location_state"];
    NSString *city = [_ownerDataChunk objectForKey:@"location_city"];
    username = [_ownerDataChunk objectForKey:@"user_handle"];
    bio = [_ownerDataChunk objectForKey:@"bio"];
    email = [_ownerDataChunk objectForKey:@"email_address"];
    website = [_ownerDataChunk objectForKey:@"website"];
    
    if ( !(IS_IOS7) ) // Non-iOS 7 fixes.
    {
        _upperPane.frame = CGRectMake(0, 0, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height / 2 - 20 + (statusBubble.frame.size.height - 33));
    }
    else
    {
        _upperPane.frame = CGRectMake(0, -20, appDelegate.screenBounds.size.width, appDelegate.screenBounds.size.height / 2 - 20 + (statusBubble.frame.size.height - 33));
    }
    
    _BG.frame = CGRectMake(_BG.frame.origin.x, _upperPane.frame.size.height - 9 + (statusBubble.frame.size.height - 33), _BG.frame.size.width, _BG.frame.size.height);
    windowSideline_left.frame = CGRectMake(0, _BG.frame.origin.y + 11, 1, _BG.frame.size.height - 11);
    _mainView.contentSize = CGSizeMake(_mainView.contentSize.width, _upperPane.frame.size.height + 30 + panel_1.frame.origin.y + panel_1.frame.size.height + (statusBubble.frame.size.height - 33));
    
    if ( birthday.length > 0 )
    {
        age = [NSString stringWithFormat:@"%ld", (long)[self ageFromDate:birthday]];
    }
    else
    {
        age = @"";
    }
    
    if ( city.length > 0 )
    {
        location = city;
        
        if ( state.length > 0 )
        {
            location = [location stringByAppendingString:[NSString stringWithFormat:@", %@", state]];
        }
        
        if ( country.length > 0 )
        {
            location = [location stringByAppendingString:[NSString stringWithFormat:@", %@", country]];
        }
    }
    else if ( state.length > 0 )
    {
        location = state;
        
        if ( country.length > 0 )
        {
            location = [location stringByAppendingString:[NSString stringWithFormat:@", %@", country]];
        }
    }
    else if ( country.length > 0 )
    {
        location = country;
    }
    else
    {
        location = @"";
    }
    
    if ( bio.length > 0 )
    {
        panel_2.hidden = NO;
        
        CGSize textSize_bio = [bio sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(280, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        
        bioLabel.text = bio;
        bioLabel.frame = CGRectMake(bioLabel.frame.origin.x, bioLabel.frame.origin.y, bioLabel.frame.size.width, textSize_bio.height + 5);
        panel_2.frame = CGRectMake(0, panel_2.frame.origin.y, panel_2.frame.size.width, textSize_bio.height + 25);
        panel_3.frame = CGRectMake(0, panel_2.frame.origin.y + panel_2.frame.size.height + 35, appDelegate.screenBounds.size.width, 41);
        panel_2_horizontalSeparator_2.frame = CGRectMake(0, panel_2.frame.size.height - 1, appDelegate.screenBounds.size.width, 1);
        
        _mainView.contentSize = CGSizeMake(_mainView.contentSize.width, _mainView.contentSize.height + textSize_bio.height + 35);
    }
    else
    {
        panel_2.hidden = YES;
        panel_2.frame = CGRectMake(0, panel_2.frame.origin.y, panel_2.frame.size.width, 0);
        panel_3.frame = CGRectMake(0, panel_2.frame.origin.y, appDelegate.screenBounds.size.width, 41);
    }
    
    if ( showsEmail )
    {
        [emailButton setTitle:email forState:UIControlStateNormal];
        
        emailButton.hidden = NO;
        panel_3_horizontalSeparator_2.hidden = NO;
        
        websiteButton.frame = CGRectMake(20, 41, websiteButton.frame.size.width, 38);
        panel_3.frame = CGRectMake(0, panel_3.frame.origin.y, appDelegate.screenBounds.size.width, 41);
        panel_3.hidden = NO;
        
        _mainView.contentSize = CGSizeMake(_mainView.contentSize.width, _mainView.contentSize.height + 41 * 2);
    }
    else
    {
        emailButton.hidden = YES;
        panel_3_horizontalSeparator_2.hidden = YES;
        
        websiteButton.frame = CGRectMake(20, 1, websiteButton.frame.size.width, 38);
        panel_3.frame = CGRectMake(0, panel_3.frame.origin.y, appDelegate.screenBounds.size.width, 0);
    }
    
    if ( website.length > 0 )
    {
        panel_3_horizontalSeparator_2.frame = CGRectMake(20, 40, appDelegate.screenBounds.size.width - 20, 1);
        
        panel_3.hidden = NO;
        
        [websiteButton setTitle:website forState:UIControlStateNormal];
        websiteButton.hidden = NO;
        
        if ( showsEmail )
        {
            panel_3_horizontalSeparator_3.hidden = NO;
            
            panel_3.frame = CGRectMake(0, panel_3.frame.origin.y, appDelegate.screenBounds.size.width, 82);
            
            _mainView.contentSize = CGSizeMake(_mainView.contentSize.width, _mainView.contentSize.height + 41);
        }
        else
        {
            panel_3_horizontalSeparator_3.hidden = YES;
            
            panel_3.frame = CGRectMake(0, panel_3.frame.origin.y, appDelegate.screenBounds.size.width, 41);
            
            _mainView.contentSize = CGSizeMake(_mainView.contentSize.width, _mainView.contentSize.height + 41 * 2);
        }
    }
    else
    {
        panel_3_horizontalSeparator_2.frame = CGRectMake(0, 40, appDelegate.screenBounds.size.width, 1);
        panel_3_horizontalSeparator_3.hidden = YES;
        websiteButton.hidden = YES;
        
        if ( showsEmail )
        {
            panel_3.hidden = NO;
            panel_3.frame = CGRectMake(0, panel_3.frame.origin.y, appDelegate.screenBounds.size.width, 41);
        }
        else
        {
            panel_3.hidden = YES;
            panel_3.frame = CGRectMake(0, panel_2.frame.origin.y + panel_2.frame.size.height, appDelegate.screenBounds.size.width, 0);
        }
    }
    
    if ( isCurrentUser || showsEmail )
    {
        joinDateLabel.frame = CGRectMake(20, 35 + panel_3.frame.origin.y + panel_3.frame.size.height, appDelegate.screenBounds.size.width - 40, 15);
    }
    
    // I want the view to always be scrollable. It feels nicer.
    int viewFinalHeight = MAX(appDelegate.screenBounds.size.height + 1, _mainView.contentSize.height);
    _mainView.contentSize = CGSizeMake(_mainView.contentSize.width, viewFinalHeight);
    
    if ( age.length > 0 )
    {
        detailLabel_age.text = [NSString stringWithFormat:@"%@ year%@ old.", age, age.intValue == 1 ? @"" : @"s"];
        detail_age.hidden = NO;
    }
    else
    {
        detail_age.hidden = YES;
    }
    
    if ( gender.length > 0 )
    {
        detailLabel_sex.text = [NSString stringWithFormat:@"%@.", gender];
        detail_sex.hidden = NO;
    }
    else
    {
        detail_sex.hidden = YES;
    }
    
    if ( location.length > 0 )
    {
        detailLabel_location.text = [NSString stringWithFormat:@"%@.", location];
        detail_location.hidden = NO;
    }
    else
    {
        detail_location.hidden = YES;
    }
    
    if ( username.length > 0 )
    {
        usernameLabel.text = [NSString stringWithFormat:@"@%@", username];
    }
    else
    {
        usernameLabel.text = @"";
    }
    
    detailLine_1.hidden = NO;
    detailLine_2.hidden = NO;
    detailLine_3.hidden = NO;
    
    // Reset transforms. Frame drawing gets f'ed up otherwise.
    detailLine_2.transform = CGAffineTransformMakeRotation(0);
    detailLine_3.transform = CGAffineTransformMakeRotation(0);
    
    detailLine_1.frame = CGRectMake(appDelegate.screenBounds.size.width / 2 - 60, _upperPane.frame.size.height / 2 + 10 + (statusBubble.frame.size.height - 33), 70, 1);
    detailLine_2.frame = CGRectMake(appDelegate.screenBounds.size.width / 2 - 10, _upperPane.frame.size.height / 2 - 10 + (statusBubble.frame.size.height - 33), 70, 1);
    detailLine_3.frame = CGRectMake(appDelegate.screenBounds.size.width / 2 - 10, _upperPane.frame.size.height / 2 + 30 + (statusBubble.frame.size.height - 33), 70, 1);
    
    detailLine_2.transform = CGAffineTransformMakeRotation(-0.785398163);
    detailLine_3.transform = CGAffineTransformMakeRotation(0.34906585);
    
    // The detail frames are randomly assigned. (33 is the minimum height of the status bubble)
    CGRect frame_1 = CGRectMake(appDelegate.screenBounds.size.width / 2 - 157, _upperPane.frame.size.height / 2 + (statusBubble.frame.size.height - 33), 94, 14); // MAKE SURE YOU MOD THE CORRESPONDING IF CHECK BELOW FOR THE X CO-ORDINATE VALUE!
    CGRect frame_2 = CGRectMake(appDelegate.screenBounds.size.width / 2 + 53, _upperPane.frame.size.height / 2 - 50 + (statusBubble.frame.size.height - 33), 104, 14);
    CGRect frame_3 = CGRectMake(appDelegate.screenBounds.size.width / 2 + 63, _upperPane.frame.size.height / 2 + 50 + (statusBubble.frame.size.height - 33), 94, 14);
    
    NSMutableArray *frames = [NSMutableArray array];
    [frames addObject:[NSValue valueWithCGRect:frame_1]];
    [frames addObject:[NSValue valueWithCGRect:frame_2]];
    [frames addObject:[NSValue valueWithCGRect:frame_3]];
    
    while ( frames.count > 0 )
    {
        int rand = arc4random_uniform((int)frames.count);
        
        CGRect frame = [[frames objectAtIndex:rand] CGRectValue];
        UIView *targetView;
        
        switch ( frames.count )
        {
            case 1:
            {
                targetView = detail_sex;
                
                if ( detail_sex.hidden )
                {
                    if ( frame.origin.x == appDelegate.screenBounds.size.width / 2 - 157 )
                    {
                        detailLine_1.hidden = YES;
                    }
                    else if ( frame.origin.x == appDelegate.screenBounds.size.width / 2 + 53 )
                    {
                        detailLine_2.hidden = YES;
                    }
                    else
                    {
                        detailLine_3.hidden = YES;
                    }
                }
                
                break;
            }
                
            case 2:
            {
                targetView = detail_age;
                
                if ( detail_age.hidden )
                {
                    if ( frame.origin.x == appDelegate.screenBounds.size.width / 2 - 157 )
                    {
                        detailLine_1.hidden = YES;
                    }
                    else if ( frame.origin.x == appDelegate.screenBounds.size.width / 2 + 53 )
                    {
                        detailLine_2.hidden = YES;
                    }
                    else
                    {
                        detailLine_3.hidden = YES;
                    }
                }
                
                break;
            }
                
            case 3:
            {
                // The location label is taller than the rest.
                frame = CGRectMake(frame.origin.x, frame.origin.y - 11, frame.size.width, 44);
                targetView = detail_location;
                
                if ( detail_location.hidden )
                {
                    if ( frame.origin.x == appDelegate.screenBounds.size.width / 2 - 157 )
                    {
                        detailLine_1.hidden = YES;
                    }
                    else if ( frame.origin.x == appDelegate.screenBounds.size.width / 2 + 53 )
                    {
                        detailLine_2.hidden = YES;
                    }
                    else
                    {
                        detailLine_3.hidden = YES;
                    }
                }
                
                break;
            }
                
            default:
                break;
        }
        
        targetView.frame = frame;
        
        UILabel *label = (UILabel *)[targetView viewWithTag:90];
        UIImageView *icon = (UIImageView *)[targetView viewWithTag:91];
        UILabel *auxiliaryLabel = (UILabel *)[targetView viewWithTag:92];
        
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, frame.size.width - label.frame.origin.x, label.frame.size.height);
        
        if ( frame.origin.x == 3 ) // Left side. Align everything to the right.
        {
            label.textAlignment = NSTextAlignmentRight;
            
            if ( auxiliaryLabel )
            {
                label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, frame.size.width, label.frame.size.height);
                auxiliaryLabel.frame = CGRectMake(auxiliaryLabel.frame.origin.x, auxiliaryLabel.frame.origin.y, frame.size.width - auxiliaryLabel.frame.origin.x, auxiliaryLabel.frame.size.height);
                auxiliaryLabel.textAlignment = NSTextAlignmentRight;
                
                CGSize textSize_auxiliaryLabel = [auxiliaryLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:SECONDARY_FONT_SIZE] constrainedToSize:CGSizeMake(auxiliaryLabel.frame.size.width, 14) lineBreakMode:NSLineBreakByWordWrapping];
                
                icon.frame = CGRectMake(frame.size.width - textSize_auxiliaryLabel.width - icon.frame.size.width - 4, icon.frame.origin.y, icon.frame.size.width, icon.frame.size.height);
            }
            else
            {
                CGSize textSize_label = [label.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:SECONDARY_FONT_SIZE] constrainedToSize:CGSizeMake(label.frame.size.width, 14) lineBreakMode:NSLineBreakByWordWrapping];
                
                icon.frame = CGRectMake(frame.size.width - textSize_label.width - icon.frame.size.width - 2, icon.frame.origin.y, icon.frame.size.width, icon.frame.size.height);
            }
        }
        else
        {
            icon.frame = CGRectMake(0, icon.frame.origin.y, icon.frame.size.width, icon.frame.size.height);
            label.textAlignment = NSTextAlignmentLeft;
            
            if ( auxiliaryLabel )
            {
                label.frame = CGRectMake(0, label.frame.origin.y, frame.size.width, label.frame.size.height);
                auxiliaryLabel.frame = CGRectMake(auxiliaryLabel.frame.origin.x, auxiliaryLabel.frame.origin.y, frame.size.width - auxiliaryLabel.frame.origin.x, auxiliaryLabel.frame.size.height);
                auxiliaryLabel.textAlignment = NSTextAlignmentLeft;
            }
        }
        
        [frames removeObjectAtIndex:rand];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": appDelegate.SHToken,
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                 @"user_id": _ownerID,
                                 @"full": @"0"};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/getuserinfo", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        if ( errorCode == 0 )
        {
            NSDictionary *response = [responseObject objectForKey:@"response"];
            followingCount = [[response objectForKey:@"following_count"] intValue];
            followerCount = [[response objectForKey:@"follower_count"] intValue];
            
            [self updateStats];
        }
        
        //NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", operation.responseString);
    }];
}

- (void)updateStats
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    statLabel_following.text = [formatter stringFromNumber:[NSNumber numberWithLong:followingCount]];
    statLabel_followers.text = [formatter stringFromNumber:[NSNumber numberWithLong:followerCount]];
    
    descriptionLabel_following.text = [NSString stringWithFormat:NSLocalizedString(@"PROFILE_STATS_FOLLOWING", nil), (followingCount == 1 ? @"person" : @"people")];
    descriptionLabel_followers.text = NSLocalizedString(@"PROFILE_STATS_FOLLOWERS", nil);
}

- (void)presentMainMenu
{
    [_callbackView dismissWindow];
}

- (void)presentSettings
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( [[appDelegate.currentUser objectForKey:@"user_id"] intValue] == [[_ownerDataChunk objectForKey:@"user_id"] intValue] )
    {
        SHSettingsMainViewController *settingsView = [[SHSettingsMainViewController alloc] init];
        [self.navigationController pushViewController:settingsView animated:YES];
        
        _shouldRefreshInfo = YES;
    }
    else
    {
        BOOL blocked = [[_ownerDataChunk objectForKey:@"blocked"] boolValue];
        
        UIActionSheet *actionSheet;
        
        if ( blocked )
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:[_ownerDataChunk objectForKey:@"name"]
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:NSLocalizedString(@"OPTION_UNBLOCK_CONTACT", nil), nil];
        }
        else
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:[_ownerDataChunk objectForKey:@"name"]
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                        destructiveButtonTitle:NSLocalizedString(@"OPTION_BLOCK_CONTACT", nil)
                                             otherButtonTitles:nil];
        }
        
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        actionSheet.tag = 1;
        
        [actionSheet showFromRect:CGRectMake(0, appDelegate.screenBounds.size.height - 44, appDelegate.screenBounds.size.width, 44) inView:appDelegate.window animated:YES];
    }
}

- (void)showStatusOptions
{
    SHStatusViewController *statusView = [[SHStatusViewController alloc] init];
    SHOrientationNavigationController *navigationController = [[SHOrientationNavigationController alloc] initWithRootViewController:statusView];
    navigationController.autoRotates = NO;
    
    [_callbackView dismissWindow];
    [_callbackView setShouldEnterFullscreen:NO];
    [_callbackView presentViewController:navigationController animated:YES completion:nil];
}

- (void)addUser
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( !isCurrentUser )
    {
        if ( _mode == SHProfileViewModeAcceptRequest )
        {
            [self acceptUserRequest];
        }
        else
        {
            BOOL temp = [[_ownerDataChunk objectForKey:@"temp"] boolValue];
            
            if ( temp )
            {
                [appDelegate.strobeLight activateStrobeLight];
                [appDelegate.contactManager addUser:_ownerID];
                
                // Show the HUD.
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                
                HUD.customView = [[UIImageView alloc] init];
                HUD.mode = MBProgressHUDModeIndeterminate;
                HUD.dimBackground = YES;
                HUD.delegate = self;
                [HUD show:YES];
                
                addUserButton.enabled = NO;
            }
            else
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[_ownerDataChunk objectForKey:@"name"]
                                                                         delegate:self
                                                                cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL", nil)
                                                           destructiveButtonTitle:NSLocalizedString(@"OPTION_DELETE_CONTACT", nil)
                                                                otherButtonTitles:nil];
                
                actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                actionSheet.tag = 2;
                actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                [actionSheet showFromRect:CGRectMake(0, appDelegate.screenBounds.size.height - 44, appDelegate.screenBounds.size.width, 44) inView:appDelegate.window animated:YES];
            }
        }
    }
}

- (void)removeUser
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [appDelegate.strobeLight activateStrobeLight];
    [appDelegate.contactManager removeUser:_ownerID];
    
    // Show the HUD.
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] init];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.dimBackground = YES;
    HUD.delegate = self;
    [HUD show:YES];
    
    addUserButton.enabled = NO;
}

- (void)acceptUserRequest
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [appDelegate.strobeLight activateStrobeLight];
    
    // Show the HUD.
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] init];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.dimBackground = YES;
    HUD.delegate = self;
    [HUD show:YES];
    
    addUserButton.enabled = NO;
    declineUserButton.enabled = NO;
    
    SHRecipientPickerViewController *recipientPicker = (SHRecipientPickerViewController *)_callbackView;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": appDelegate.SHToken,
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                 @"board_id": recipientPicker.boardID,
                                 @"user_id": _ownerID};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/acceptboardrequest", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        [HUD hide:YES];
         
        if ( errorCode == 0 )
        {
            [addUserButton setTitle:NSLocalizedString(@"PROFILE_REQUEST_ACCEPTED", nil) forState:UIControlStateNormal];
            [addUserButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [recipientPicker removeBubbleForUser:_ownerID];
            [appDelegate.strobeLight affirmativeStrobeLight];
            
            addUserButton.frame = CGRectMake(20, 1, appDelegate.screenBounds.size.width - 40, 50);
            
            declineUserButton.hidden = YES;
            
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
        }
        else
        {
            addUserButton.enabled = YES;
            declineUserButton.enabled = YES;
            
            [appDelegate.strobeLight negativeStrobeLight];
        }
        
        NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [appDelegate.strobeLight negativeStrobeLight];
        addUserButton.enabled = YES;
        declineUserButton.enabled = YES;
        
        NSLog(@"Error: %@", operation.responseString);
    }];
}

- (void)declineUserRequest
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    [appDelegate.strobeLight activateStrobeLight];
    
    // Show the HUD.
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] init];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.dimBackground = YES;
    HUD.delegate = self;
    [HUD show:YES];
    
    addUserButton.enabled = NO;
    declineUserButton.enabled = NO;
    
    SHRecipientPickerViewController *recipientPicker = (SHRecipientPickerViewController *)_callbackView;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": appDelegate.SHToken,
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                 @"board_id": recipientPicker.boardID,
                                 @"user_id": _ownerID};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/declineboardrequest", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        [HUD hide:YES];
        
        if ( errorCode == 0 )
        {
            [addUserButton setTitle:NSLocalizedString(@"PROFILE_REQUEST_DECLINED", nil) forState:UIControlStateNormal];
            [addUserButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [recipientPicker removeBubbleForUser:_ownerID];
            [appDelegate.strobeLight deactivateStrobeLight];
            
            addUserButton.frame = CGRectMake(20, 1, appDelegate.screenBounds.size.width - 40, 50);
            
            declineUserButton.hidden = YES;
        }
        else
        {
            addUserButton.enabled = YES;
            declineUserButton.enabled = YES;
            
            [appDelegate.strobeLight negativeStrobeLight];
        }
        
        NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [appDelegate.strobeLight negativeStrobeLight];
        addUserButton.enabled = YES;
        declineUserButton.enabled = YES;
        
        NSLog(@"Error: %@", operation.responseString);
    }];
}

- (void)presentFollowing
{
    SHRecipientPickerViewController *recipientPicker = [[SHRecipientPickerViewController alloc] init];
    recipientPicker.userID = _ownerID;
    recipientPicker.mode = SHRecipientPickerModeFollowing;
    
    [self.navigationController pushViewController:recipientPicker animated:YES];
}

- (void)presentFollowers
{
    SHRecipientPickerViewController *recipientPicker = [[SHRecipientPickerViewController alloc] init];
    recipientPicker.userID = _ownerID;
    recipientPicker.mode = SHRecipientPickerModeFollowers;
    
    [self.navigationController pushViewController:recipientPicker animated:YES];
}

- (void)emailUser
{
    NSString *preparedEmail = [NSString stringWithFormat:@"mailto:%@", email];
    NSURL *URL = [NSURL URLWithString:preparedEmail];
    
    [[UIApplication sharedApplication] openURL:URL];
}

- (void)gotoWebsite
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionNavigationBar];
    
    SHWebViewController *webBrowser = [[SHWebViewController alloc] init];
    webBrowser.URL = [_ownerDataChunk objectForKey:@"website"];
    
    [self.navigationController pushViewController:webBrowser animated:YES];
}

- (NSInteger)ageFromDate:(NSString *)dateString
{
    if ( dateString.length > 0 )
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *targetDate = [dateFormatter dateFromString:dateString];
        NSDate *today = [NSDate date];
        NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                           components:NSYearCalendarUnit
                                           fromDate:targetDate
                                           toDate:today
                                           options:0];
        return ageComponents.year;
    }
    else
    {
        return -1;
    }
}

#pragma mark -
#pragma mark DP Options

- (void)showDPOptions
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UIActionSheet *actionSheet;
    NSString *currentDPHash = [appDelegate.currentUser objectForKey:@"dp_hash"];
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) // If the device has a camera.
    {
        if ( currentDPHash.length == 0 )
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
        if ( currentDPHash.length == 0 )
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
    
    [actionSheet showFromRect:self.view.frame inView:appDelegate.window animated:YES];
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
                UIImage *selectedImage = [UIImage imageWithCGImage:[representation fullScreenImage]];
                
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
                
                newSelectedDP = thumbnail;
                
                [self uploadDP];
            }
        }];
    } failureBlock: ^(NSError *error){
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}

- (void)uploadDP
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    [appDelegate.strobeLight activateStrobeLight];
    
    NSData *imageData = UIImageJPEGRepresentation(newSelectedDP, 1.0);
    
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
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/dpupload", SH_DOMAIN] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if ( imageData )
        {
            [formData appendPartWithFileData:imageData name:@"image_file" fileName:@"image_file.jpg" mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [HUD hide:YES];
        
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        if ( errorCode == 0 )
        {
            [appDelegate.strobeLight affirmativeStrobeLight];
            
            NSString *newHash = [responseObject objectForKey:@"response"];
            [appDelegate.currentUser setObject:UIImageJPEGRepresentation(newSelectedDP, 1.0) forKey:@"dp"];
            [appDelegate.currentUser setObject:newHash forKey:@"dp_hash"];
            [userBubble setImage:newSelectedDP];
            
            [appDelegate.modelManager executeUpdate:@"UPDATE sh_current_user SET dp_hash = :dp_hash, dp = :dp"
                            withParameterDictionary:@{@"dp_hash": newHash,
                                                      @"dp": UIImageJPEGRepresentation(newSelectedDP, 1.0)}];
            
            [appDelegate.modelManager executeUpdate:@"UPDATE sh_cloud SET dp_hash = :dp_hash, dp = :dp "
                                                    @"WHERE sh_user_id = :user_id"
                            withParameterDictionary:@{@"dp_hash": newHash,
                                                      @"dp": UIImageJPEGRepresentation(newSelectedDP, 1.0),
                                                      @"user_id": [appDelegate.currentUser objectForKey:@"user_id"]}];
            
            //[_callbackView refreshMiniFeed];
            
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

- (void)removeCurrentDP
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
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
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/dpremove", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        if ( errorCode == 0 )
        {
            [appDelegate.strobeLight affirmativeStrobeLight];
            
            newSelectedDP = [UIImage imageNamed:@"user_placeholder"];
            [appDelegate.currentUser setObject:UIImageJPEGRepresentation(newSelectedDP, 1.0) forKey:@"dp"];
            [appDelegate.currentUser setObject:@"" forKey:@"dp_hash"];
            [userBubble setImage:newSelectedDP];
            
            [appDelegate.modelManager executeUpdate:@"UPDATE sh_current_user SET dp_hash = :dp_hash, dp = :dp"
                            withParameterDictionary:@{@"dp_hash": @"",
                                                      @"dp": @""}];
            
            [appDelegate.modelManager executeUpdate:@"UPDATE sh_cloud SET dp_hash = :dp_hash, dp = :dp "
                                                    @"WHERE sh_user_id = :user_id"
                            withParameterDictionary:@{@"dp_hash": @"",
                                                      @"dp": @"",
                                                      @"user_id": [appDelegate.currentUser objectForKey:@"user_id"]}];
            
            //[_callbackView refreshMiniFeed];
            
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

- (void)copyCurrentStatus
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = statusLabel.text;
}

- (void)showDPOverlay
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    NSString *DPHash = [_ownerDataChunk objectForKey:@"dp_hash"];
    
    if ( DPHash.length == 0 ) // Don't show the overlay for people with no pics.
    {
        return;
    }
    
    UIView *overlay = [[UIView alloc] initWithFrame:appDelegate.screenBounds];
    overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.9];
    overlay.opaque = YES;
    overlay.userInteractionEnabled = YES;
    overlay.alpha = 0.0;
    overlay.tag = 777;
    
    UIImageView *preview = [[UIImageView alloc] initWithFrame:userBubble.frame];
    preview.contentMode = UIViewContentModeScaleAspectFit;
    preview.opaque = YES;
    preview.tag = 7771;
    
    UIButton *dismissOverlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dismissOverlayButton setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
    [dismissOverlayButton addTarget:self action:@selector(dismissDPOverlay) forControlEvents:UIControlEventTouchUpInside];
    dismissOverlayButton.frame = CGRectMake(20, overlay.frame.size.height - 53, 33, 33);
    dismissOverlayButton.showsTouchWhenHighlighted = YES;
    
    UIButton *saveDPButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveDPButton setImage:[UIImage imageNamed:@"save_white"] forState:UIControlStateNormal];
    [saveDPButton addTarget:self action:@selector(exportDP) forControlEvents:UIControlEventTouchUpInside];
    saveDPButton.frame = CGRectMake(overlay.frame.size.width - 53, overlay.frame.size.height - 53, 33, 33);
    saveDPButton.showsTouchWhenHighlighted = YES;
    
    UIImage *currentDP = [UIImage imageWithData:[_ownerDataChunk objectForKey:@"alias_dp"]];
    
    if ( !currentDP )
    {
        currentDP = [UIImage imageWithData:[_ownerDataChunk objectForKey:@"dp"]];
    }
    
    preview.image = currentDP;
    [overlay addSubview:preview];
    [overlay addSubview:dismissOverlayButton];
    [overlay addSubview:saveDPButton];
    [self.view addSubview:overlay];
    
    [_callbackView disableCompositionLayerScrolling];
    [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionFullScreen];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        overlay.alpha = 1.0;
        preview.frame = overlay.frame;
    } completion:^(BOOL finished){
        
    }];
}

- (void)dismissDPOverlay
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UIView *overlay = [self.view viewWithTag:777];
    UIImageView *preview = (UIImageView *)[overlay viewWithTag:7771];
    
    NSArray *viewControllers = appDelegate.mainNavigationController.viewControllers;
    
    if ( viewControllers.count == 1 )
    {
        [_callbackView enableCompositionLayerScrolling]; // Unlock the layer.
    }
    
    [appDelegate.strobeLight setStrobeLightPosition:SHStrobeLightPositionStatusBar];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        overlay.alpha = 0.0;
        preview.transform = CGAffineTransformMakeScale(2.0, 2.0);
    } completion:^(BOOL finished){
        [overlay removeFromSuperview];
    }];
}

- (void)exportDP
{
    UIImage *currentDP = [UIImage imageWithData:[_ownerDataChunk objectForKey:@"alias_dp"]];
    
    if ( !currentDP )
    {
        currentDP = [UIImage imageWithData:[_ownerDataChunk objectForKey:@"dp"]];
    }
    
    NSArray *activityItems = @[currentDP];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

- (void)mediaPickerDidFinishPickingDP:(UIImage *)newDP
{
    newSelectedDP = newDP;
    
    [self uploadDP];
}

- (void)loadInfoOverNetwork
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": appDelegate.SHToken,
                                 @"app_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                 @"user_id": _ownerID,
                                 @"full": @"1"};
    
    [manager POST:[NSString stringWithFormat:@"http://%@/theboard/api/getuserinfo", SH_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int errorCode = [[responseObject objectForKey:@"errorCode"] intValue];
        
        if ( errorCode == 0 )
        {
            _ownerDataChunk = [[responseObject objectForKey:@"response"] mutableCopy];
            
            NSString *DPHash = @"";
            
            NSString *lastStatusID = [NSString stringWithFormat:@"%@", [_ownerDataChunk objectForKey:@"thread_id"]];
            [_ownerDataChunk setObject:lastStatusID forKey:@"thread_id"];
            
            if ( [_ownerDataChunk objectForKey:@"user_handle"] && ![[NSNull null] isEqual:[_ownerDataChunk objectForKey:@"user_handle"]] )
            {
                
            }
            else
            {
                [_ownerDataChunk setObject:@"" forKey:@"user_handle"];
            }
            
            if ( [_ownerDataChunk objectForKey:@"dp_hash"] && ![[NSNull null] isEqual:[_ownerDataChunk objectForKey:@"dp_hash"]] )
            {
                DPHash = [_ownerDataChunk objectForKey:@"dp_hash"];
            }
            else
            {
                [_ownerDataChunk setObject:@"" forKey:@"dp_hash"];
            }
            
            if ( [_ownerDataChunk objectForKey:@"email_address"] && ![[NSNull null] isEqual:[_ownerDataChunk objectForKey:@"email_address"]] )
            {
                
            }
            else
            {
                [_ownerDataChunk setObject:@"" forKey:@"email_address"];
            }
            
            if ( [_ownerDataChunk objectForKey:@"gender"] && ![[NSNull null] isEqual:[_ownerDataChunk objectForKey:@"gender"]] )
            {
                
            }
            else
            {
                [_ownerDataChunk setObject:@"" forKey:@"gender"];
            }
            
            if ( [_ownerDataChunk objectForKey:@"location_country"] && ![[NSNull null] isEqual:[_ownerDataChunk objectForKey:@"location_country"]] )
            {
                
            }
            else
            {
                [_ownerDataChunk setObject:@"" forKey:@"location_country"];
            }
            
            if ( [_ownerDataChunk objectForKey:@"location_state"] && ![[NSNull null] isEqual:[_ownerDataChunk objectForKey:@"location_state"]] )
            {
                
            }
            else
            {
                [_ownerDataChunk setObject:@"" forKey:@"location_state"];
            }
            
            if ( [_ownerDataChunk objectForKey:@"location_city"] && ![[NSNull null] isEqual:[_ownerDataChunk objectForKey:@"location_city"]] )
            {
                
            }
            else
            {
                [_ownerDataChunk setObject:@"" forKey:@"location_city"];
            }
            
            if ( [_ownerDataChunk objectForKey:@"website"] && ![[NSNull null] isEqual:[_ownerDataChunk objectForKey:@"website"]] )
            {
                
            }
            else
            {
                [_ownerDataChunk setObject:@"" forKey:@"website"];
            }
            
            if ( [_ownerDataChunk objectForKey:@"bio"] && ![[NSNull null] isEqual:[_ownerDataChunk objectForKey:@"bio"]] )
            {
                
            }
            else
            {
                [_ownerDataChunk setObject:@"" forKey:@"bio"];
            }
            
            if ( [_ownerDataChunk objectForKey:@"location_latitude"] && ![[NSNull null] isEqual:[_ownerDataChunk objectForKey:@"location_latitude"]] )
            {
                
            }
            else
            {
                [_ownerDataChunk setObject:@"" forKey:@"location_latitude"];
                [_ownerDataChunk setObject:@"" forKey:@"location_longitude"];
            }
            
            if ( [_ownerDataChunk objectForKey:@"birthday"] && ![[NSNull null] isEqual:[_ownerDataChunk objectForKey:@"birthday"]] )
            {
                
            }
            else
            {
                [_ownerDataChunk setObject:@"" forKey:@"birthday"];
            }
            
            // DP loading.
            if ( DPHash && DPHash.length > 0 )
            {
                NSURL *DPURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/userphotos/theboard/%@/profile/f_%@.jpg", SH_DOMAIN, _ownerID, DPHash]];
                
                NSURLRequest *request = [NSURLRequest requestWithURL:DPURL];
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    UIImage *DP = [UIImage imageWithData:data];
                    
                    if ( DP )
                    {
                        [_ownerDataChunk setObject:data forKey:@"dp"];
                        
                        [userBubble setImage:DP];
                    }
                }];
            }
            
            FMResultSet *s1 = [appDelegate.modelManager executeQuery:@"SELECT name FROM sh_cloud WHERE sh_user_id = :user_id"
                                             withParameterDictionary:@{@"user_id": _ownerID}];
            
            [_ownerDataChunk setObject:@"1" forKey:@"temp"];
            
            // Check if the contact's already stored.
            while ( [s1 next] )
            {
                [_ownerDataChunk setObject:@"0" forKey:@"temp"];
            }
            
            [s1 close];
            
            long double delayInSeconds = 0.3; // Give it a small delay till everything loads.
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [appDelegate.mainView pushWindow:SHAppWindowTypeProfile];
            });
        }
        
        //NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", operation.responseString);
    }];
}

- (void)didAddUser
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
    
    [addUserButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [addUserButton setTitle:NSLocalizedString(@"PROFILE_REMOVE_USER", nil) forState:UIControlStateNormal];
    addUserButton.enabled = YES;
    
    followerCount++;
    [self updateStats];
    
    [_ownerDataChunk setObject:@"0" forKey:@"temp"];
}

- (void)didRemoveUser
{
    [addUserButton setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    [addUserButton setTitle:NSLocalizedString(@"PROFILE_ADD_USER", nil) forState:UIControlStateNormal];
    addUserButton.enabled = YES;
    
    followerCount--;
    [self updateStats];
    
    [_ownerDataChunk setObject:@"1" forKey:@"temp"];
}

#pragma mark -
#pragma mark Gestures

- (BOOL)canPerformAction:(SEL)selector withSender:(id)sender
{
    if ( selector == @selector(copyCurrentStatus) )
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)didLongPressStatus:(UILongPressGestureRecognizer *)longPress
{
    if ( [longPress state] == UIGestureRecognizerStateBegan )
    {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyCurrentStatus)];
        
        [statusBubble becomeFirstResponder];
        [menuController setMenuItems:[NSArray arrayWithObject:menuItem]];
        [menuController setTargetRect:statusBubble.frame inView:self.view];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (void)lastOperationFailedWithError:(NSError *)error
{
    addUserButton.enabled = YES;
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
#pragma mark UIScrollViewDelegate methods.

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //shouldAdjustWindowSideShadow = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //shouldAdjustWindowSideShadow = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if ( scrollView.tag == 7 ) // Main View.
    {
        int offset = -40;
        
        if ( !(IS_IOS7) )
        {
            offset = -20;
        }
        
        if ( scrollView.contentOffset.y <= offset )
        {
            _upperPane.frame = CGRectMake(0, scrollView.contentOffset.y + 20, _upperPane.frame.size.width, _upperPane.frame.size.height);
        }
        
        maskLayer_mainView.position = CGPointMake(0, scrollView.contentOffset.y);
    }
    
    [CATransaction commit];
}

#pragma mark -
#pragma mark SHChatBubbleDelegate methods.

- (void)didSelectBubble:(SHChatBubble *)bubble
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( [_ownerID intValue] == [[appDelegate.currentUser objectForKey:@"user_id"] intValue] )
    {
        [self showDPOptions];
    }
    else
    {
        [self showDPOverlay];
    }
}

- (void)didTapAndHoldBubble:(SHChatBubble *)bubble
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( _ownerID.intValue == [[appDelegate.currentUser objectForKey:@"user_id"] intValue] )
    {
        [self showDPOptions];
    }
    else
    {
        [self showDPOverlay];
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if ( actionSheet.tag == 0 ) // DP options.
    {
        NSString *currentDPHash = [appDelegate.currentUser objectForKey:@"dp_hash"];
        
        if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) // If the device has a camera.
        {
            if ( currentDPHash.length == 0 )
            {
                if ( buttonIndex == 0 )      // Camera.
                {
                    [_callbackView setIsPickingDP:YES];
                    [_callbackView showMediaPicker_Camera];
                }
                else if ( buttonIndex == 1 ) // Library.
                {
                    [_callbackView setIsPickingDP:YES];
                    [_callbackView showMediaPicker_Library];
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
                    [self removeCurrentDP];
                }
                else if ( buttonIndex == 1 ) // Camera.
                {
                    [_callbackView setIsPickingDP:YES];
                    [_callbackView showMediaPicker_Camera];
                }
                else if ( buttonIndex == 2 ) // Library.
                {
                    [_callbackView setIsPickingDP:YES];
                    [_callbackView showMediaPicker_Library];
                }
                else if ( buttonIndex == 3 ) // Last photo taken.
                {
                    [self DP_UseLastPhotoTaken];
                }
            }
        }
        else
        {
            if ( currentDPHash.length == 0 )
            {
                if ( buttonIndex == 0 ) // Library.
                {
                    [_callbackView setIsPickingDP:YES];
                    [_callbackView showMediaPicker_Library];
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
                    [self removeCurrentDP];
                }
                else if ( buttonIndex == 1 ) // Library.
                {
                    [_callbackView setIsPickingDP:YES];
                    [_callbackView showMediaPicker_Library];
                }
                else if ( buttonIndex == 2 ) // Last photo taken.
                {
                    [self DP_UseLastPhotoTaken];
                }
            }
        }
    }
    else if ( actionSheet.tag == 1 ) // Blocking options.
    {
        if ( buttonIndex == 0 )
        {
            BOOL blocked = [[_ownerDataChunk objectForKey:@"blocked"] boolValue];
            
            if ( blocked )
            {
                [appDelegate.contactManager unblockContact:_ownerID];
            }
            else
            {
                [appDelegate.contactManager blockContact:_ownerID];
            }
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            long double delayInSeconds = 0.25;
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //[_callbackView showMainWindowSide];
            });
        }
    }
    else if ( actionSheet.tag == 2 ) // Delete contact confirmation.
    {
        if ( buttonIndex == 0 )
        {
            [self removeUser];
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
