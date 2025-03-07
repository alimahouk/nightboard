//
//  SHRecipientPickerViewController.h
//  Nightboard
//
//  Created by Ali.cpp on 3/20/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Constants.h"
#import "MBProgressHUD.h"
#import "SHContactCloud.h"
#import "SHOrientationNavigationController.h"
#import "SHProfileViewController.h"

@interface SHRecipientPickerViewController : UIViewController <MBProgressHUDDelegate, SHContactCloudDelegate, UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>
{
    MBProgressHUD *HUD;
    UIImagePickerController *photoPicker;
    UIButton *backButton;
    UIButton *searchCancelButton;
    SHChatBubble *activeBubble; // When the user taps & holds one.
    UITextField *searchBox;
    UILabel *contactCloudInfoLabel;
    CAGradientLayer *maskLayer_ChatCloud;
    NSTimer *timer_timeOfDayCheck;
    NSString *wallpaperImageName;
    BOOL wallpaperShouldAnimate;
    BOOL wallpaperIsAnimatingRight;
    BOOL wallpaperDidChange_dawn;
    BOOL wallpaperDidChange_day;
    BOOL wallpaperDidChange_dusk;
    BOOL wallpaperDidChange_night;
    BOOL isShowingSearchInterface;
}

@property (nonatomic) SHOrientationNavigationController *mainWindowNavigationController;
@property (nonatomic) SHProfileViewController *profileView;
@property (nonatomic) SHContactCloud *contactCloud;
@property (nonatomic) UIView *mainWindowContainer;
@property (nonatomic) UIImageView *windowSideShadow;
@property (nonatomic) UIScrollView *windowCompositionLayer;
@property (nonatomic) UIImageView *wallpaper;
@property (nonatomic) UIButton *searchButton;
@property (nonatomic) UIButton *chatCloudCenterButton;
@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *boardID;
@property (nonatomic) SHRecipientPickerMode mode;
@property (nonatomic) SHAppWindowType activeWindow;
@property (nonatomic) BOOL wallpaperIsAnimating;
@property (nonatomic) BOOL shouldEnterFullscreen;
@property (nonatomic) BOOL isFullscreen;
@property (nonatomic) BOOL mediaPickerSourceIsCamera;
@property (nonatomic) BOOL isPickingAliasDP;
@property (nonatomic) BOOL isPickingDP;

- (void)dismissView;

// Live Wallpaper
- (void)startWallpaperAnimation;
- (void)resumeWallpaperAnimation;
- (void)stopWallpaperAnimation;
- (void)startTimeOfDayCheck;
- (void)pauseTimeOfDayCheck;
- (void)checkTimeOfDay;

- (void)dismissWindow;
- (void)pushWindow:(SHAppWindowType)window;
- (void)restoreCurrentProfileBubble;
- (void)showUserProfile;

// CHat Cloud
- (void)showSearchInterface;
- (void)dismissSearchInterface;
- (void)showChatCloudCenterJumpButton;
- (void)dismissChatCloudCenterJumpButton;
- (void)jumpToChatCloudCenter;
- (void)searchChatCloudForQuery:(NSString *)query;
- (void)showEmptyCloud;

// Contacts & Boards
- (void)loadCloud;
- (void)removeBubbleForUser:(NSString *)userID;

- (void)loadRequests;
- (void)processRequests:(NSArray *)requests;

- (void)loadBoardMembers;
- (void)processBoardMembers:(NSArray *)members;

- (void)loadFollowing;
- (void)loadFollowers;
- (void)processPeople:(NSArray *)people;


// For listening to keystrokes on any UITextField.
- (void)textFieldDidChange:(id)sender;

- (void)setMaxMinZoomScalesForChatCloudBounds;

- (void)showNetworkError;

@end
