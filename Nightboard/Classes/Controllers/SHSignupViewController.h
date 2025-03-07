//
//  SHSignupViewController.h
//  Nightboard
//
//  Created by MachOSX on 2/7/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"
#import "SHChatBubble.h"

@interface SHSignupViewController : UIViewController <MBProgressHUDDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SHChatBubbleDelegate, UITextFieldDelegate, UIActionSheetDelegate>
{
    MBProgressHUD *HUD;
    UIImagePickerController *photoPicker;
    UIImageView *wallpaper;
    UIImageView *nameFieldBG;
    UILabel *welcomeLabel;
    UILabel *nameFieldPlaceholderLabel;
    UITextField *nameField;
    SHChatBubble *DPPreview;
    UIImage *selectedImage;
    NSTimer *timer_timeOfDayCheck;
    NSString *wallpaperImageName;
    NSString *userID; // The newly-created user ID.
    BOOL wallpaperShouldAnimate;
    BOOL wallpaperIsAnimatingRight;
    BOOL wallpaperDidChange_dawn;
    BOOL wallpaperDidChange_day;
    BOOL wallpaperDidChange_dusk;
    BOOL wallpaperDidChange_night;
}

@property (nonatomic) NSString *email;

// Live Wallpaper
- (void)startWallpaperAnimation;
- (void)stopWallpaperAnimation;
- (void)checkTimeOfDay;

// Account Creation
- (void)createAccount;

// DP Options
- (void)showDPOptions;
- (void)DP_Camera;
- (void)DP_Library;
- (void)DP_UseLastPhotoTaken;

- (void)showNetworkError;

@end
