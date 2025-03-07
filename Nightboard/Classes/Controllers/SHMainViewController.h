//
//  SHMainViewController.h
//  Theboard
//
//  Created by MachOSX on 1/27/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"
#import "SHContactCloud.h"
#import "SHContactManager.h"
#import "SHOrientationNavigationController.h"
#import "SHProfileViewController.h"

@interface SHMainViewController : UIViewController <MBProgressHUDDelegate, SHContactManagerDelegate, SHContactCloudDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UITextFieldDelegate>
{
    MBProgressHUD *HUD;
    UIImagePickerController *photoPicker;
    UIButton *searchCancelButton;
    UIButton *inviteButton;
    SHChatBubble *activeBubble; // When the user taps & holds one.
    UITextField *searchBox;
    UILabel *contactCloudInfoLabel;
    CAGradientLayer *maskLayer_ChatCloud;
    NSTimer *timer_timeOfDayCheck;
    NSArray *randomQuotes;
    NSString *wallpaperImageName;
    BOOL wallpaperShouldAnimate;
    BOOL wallpaperIsAnimatingRight;
    BOOL wallpaperDidChange_dawn;
    BOOL wallpaperDidChange_day;
    BOOL wallpaperDidChange_dusk;
    BOOL wallpaperDidChange_night;
    BOOL isShowingSearchInterface;
    BOOL isShowingNewPeerNotification;
}

@property (nonatomic) SHOrientationNavigationController *mainWindowNavigationController;
@property (nonatomic) SHProfileViewController *profileView;
@property (nonatomic) SHContactCloud *contactCloud;
@property (nonatomic) UIView *mainWindowContainer;
@property (nonatomic) UIImageView *windowSideShadow;
@property (nonatomic) UIScrollView *windowCompositionLayer;
@property (nonatomic) UIImageView *wallpaper;
@property (nonatomic) UIButton *searchButton;
@property (nonatomic) UIButton *profileButton;
@property (nonatomic) UIButton *createBoardButton;
@property (nonatomic) UIButton *refreshButton;
@property (nonatomic) UIButton *chatCloudCenterButton;
@property (nonatomic) SHAppWindowType activeWindow;
@property (nonatomic) BOOL wallpaperIsAnimating;
@property (nonatomic) BOOL shouldEnterFullscreen;
@property (nonatomic) BOOL isFullscreen;
@property (nonatomic) BOOL mediaPickerSourceIsCamera;
@property (nonatomic) BOOL isRenamingContact;
@property (nonatomic) BOOL isPickingAliasDP;
@property (nonatomic) BOOL isPickingDP;
@property (nonatomic) BOOL isPickingMedia;

// Live Wallpaper
- (void)startWallpaperAnimation;
- (void)resumeWallpaperAnimation;
- (void)stopWallpaperAnimation;
- (void)startTimeOfDayCheck;
- (void)pauseTimeOfDayCheck;
- (void)checkTimeOfDay;

- (void)enableCompositionLayerScrolling;
- (void)disableCompositionLayerScrolling;
- (void)dismissWindow;
- (void)pushWindow:(SHAppWindowType)window;
- (void)restoreCurrentProfileBubble;
- (void)showUserProfile;
- (void)showBoardForID:(NSString *)boardID;
- (void)showBoardCreator;

- (void)showInvitationOptions;
- (void)showNewPeerNotification;

// CHat Cloud
- (void)showRenamingInterfaceForBubble:(SHChatBubble *)bubble;
- (void)dismissRenamingInterface;
- (void)showSearchInterface;
- (void)dismissSearchInterface;
- (void)showChatCloudCenterJumpButton;
- (void)dismissChatCloudCenterJumpButton;
- (void)jumpToChatCloudCenter;
- (void)confirmContactDeletion;
- (void)searchChatCloudForQuery:(NSString *)query;
- (void)showEmptyCloud;

// Contacts & Boards
- (void)loadCloud;
- (void)refreshCloud;
- (void)removeBoard:(NSString *)boardID;

// Media Picker
- (void)showMediaPicker_Camera;
- (void)showMediaPicker_Library;
- (void)dismissMediaPicker;

// For listening to keystrokes on any UITextField.
- (void)textFieldDidChange:(id)sender;

- (void)setMaxMinZoomScalesForChatCloudBounds;

@end

