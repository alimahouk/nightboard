//
//  SHProfileViewController.h
//  Nightboard
//
//  Created by MachOSX on 2/11/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"
#import "SHChatBubble.h"

@interface SHProfileViewController : UIViewController <MBProgressHUDDelegate, UIScrollViewDelegate, SHChatBubbleDelegate, UIActionSheetDelegate>
{
    MBProgressHUD *HUD;
    UIView *detail_location;
    UIView *detail_sex;
    UIView *detail_age;
    UIView *panel_1;
    UIView *panel_2;
    UIView *panel_3;
    UIImageView *windowSideline_left;
    UIImageView *statusBubbleTrail_1;
    UIImageView *statusBubbleTrail_2;
    UIImageView *detailLine_1;
    UIImageView *detailLine_2;
    UIImageView *detailLine_3;
    UIImageView *panel_1_horizontalSeparator_1;
    UIImageView *panel_1_horizontalSeparator_2;
    UIImageView *panel_1_verticalSeparator_1;
    UIImageView *panel_2_horizontalSeparator_1;
    UIImageView *panel_2_horizontalSeparator_2;
    UIImageView *panel_3_horizontalSeparator_1;
    UIImageView *panel_3_horizontalSeparator_2;
    UIImageView *panel_3_horizontalSeparator_3;
    SHChatBubble *userBubble;
    UIButton *backButton;
    UIButton *settingsButton;
    UIButton *statusBubble;
    UIButton *addUserButton;
    UIButton *declineUserButton;
    UIButton *followersButton;
    UIButton *followingButton;
    UIButton *emailButton;
    UIButton *websiteButton;
    UILabel *backButtonBadgeLabel;
    UILabel *statusLabel;
    UILabel *detailLabel_locationDescription;
    UILabel *detailLabel_location;
    UILabel *detailLabel_sex;
    UILabel *detailLabel_age;
    UILabel *usernameLabel;
    UILabel *lastSeenLabel;
    UILabel *statLabel_following;
    UILabel *statLabel_followers;
    UILabel *descriptionLabel_following;
    UILabel *descriptionLabel_followers;
    UILabel *bioLabel;
    UILabel *joinDateLabel;
    UIImage *newSelectedDP;
    NSString *username;
    NSString *gender;
    NSString *age;
    NSString *location;
    NSString *email;
    NSString *bio;
    NSString *website;
    NSString *joinDate;
    NSDateFormatter *dateFormatter;
    CAGradientLayer *maskLayer_mainView;
    BOOL viewDidLoad;
    BOOL isCurrentUser;
    long followingCount;
    long followerCount;
}

@property (nonatomic) id callbackView;
@property (nonatomic) SHProfileViewMode mode;
@property (nonatomic) UIView *upperPane;
@property (nonatomic) UIScrollView *mainView;
@property (nonatomic) UIImageView *BG;
@property (nonatomic) NSMutableDictionary *ownerDataChunk;
@property (nonatomic) NSString *ownerID;
@property (nonatomic) BOOL shouldRefreshInfo;

- (void)refreshViewWithDP:(BOOL)refreshDP;
- (void)updateStats;
- (void)presentMainMenu;
- (void)presentSettings;
- (void)showStatusOptions;
- (void)addUser;
- (void)removeUser;
- (void)acceptUserRequest;
- (void)presentFollowing;
- (void)presentFollowers;
- (void)emailUser;
- (void)gotoWebsite;
- (NSInteger)ageFromDate:(NSString *)dateString;

- (void)showDPOptions;
- (void)DP_UseLastPhotoTaken;
- (void)uploadDP;
- (void)removeCurrentDP;
- (void)copyCurrentStatus;
- (void)showDPOverlay;
- (void)dismissDPOverlay;
- (void)exportDP;
- (void)mediaPickerDidFinishPickingDP:(UIImage *)newDP;

// Gestures.
- (void)didLongPressStatus:(UILongPressGestureRecognizer *)longPress;

- (void)loadInfoOverNetwork;
- (void)didAddUser;
- (void)didRemoveUser;

- (void)lastOperationFailedWithError:(NSError *)error;
- (void)showNetworkError;

@end
