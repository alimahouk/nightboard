//
//  Constants.h
//  Nightboard
//
//  Created by Ali Mahouk on 27/1/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#ifndef SHConstants_h
#define SHConstants_h

/*  --------------------------------------------
    ---------- Runtime Environment -------------
    --------------------------------------------
 */

#define SH_DEVELOPMENT_ENVIRONMENT      NO
#define IS_IOS7                         kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1

/*  ---------------------------------------------
    ------------------- API ---------------------
    ---------------------------------------------
 */

#define SH_DOMAIN                               @"alimahouk.com" // Replace domain in production
#define DB_TEMPLATE_NAME                        @"default_template.sqlite"
#define SH_UUID                                 @"51234a40-aead-11e4-891b-0002a5d5c51b"
#define MAX_POST_LENGTH                         4000
#define MAX_BIO_LENGTH                          140
#define MAX_STATUS_UPDATE_LENGTH                140
#define FEED_BATCH_SIZE                         15

/*  ---------------------------------------------
    ---------- Application Interface ------------
    ---------------------------------------------
 */

#define IS_IPHONE_5                             ( fabs( (double)[ [UIScreen mainScreen] bounds].size.height - (double)568 ) < DBL_EPSILON )

#define RADIANS_TO_DEGREES(radians)             ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle)               ((angle) / 180.0 * M_PI)

// Fonts
#define MAIN_FONT_SIZE                          18
#define MIN_MAIN_FONT_SIZE                      15
#define SECONDARY_FONT_SIZE                     12
#define MIN_SECONDARY_FONT_SIZE                 10

// Contact Cloud
#define CHAT_CLOUD_BUBBLE_SIZE                  80
#define CHAT_CLOUD_BUBBLE_SIZE_MINI             36
#define CHAT_CLOUD_BUBBLE_PADDING               10
#define WEIGHT_VIEWS                            0.1
#define PARALLAX_DEPTH_HEAVY                    15.0
#define PARALLAX_DEPTH_LIGHT                    8.0

typedef enum {
    SHStrobeLightPositionFullScreen = 1,
    SHStrobeLightPositionStatusBar,
    SHStrobeLightPositionNavigationBar
} SHStrobeLightPosition;

typedef enum {
    SHNetworkStateConnected = 1,
    SHNetworkStateConnecting,
    SHNetworkStateOffline
} SHNetworkState;

typedef enum {
    SHPeerRangeNear = 1,
    SHPeerRangeFar,
    SHPeerRangeImmediate,
    SHPeerRangeUnknown
} SHPeerRange;

typedef enum {
    SHAppWindowTypeProfile = 1
} SHAppWindowType;

typedef enum {
    SHChatBubbleTypeUser = 1,
    SHChatBubbleTypeBoard
} SHChatBubbleType;

typedef enum {
    SHMediaTypePhoto = 1,
    SHMediaTypeMovie,
    SHMediaTypeNone
} SHMediaType;

typedef enum {
    SHThreadTypeMessage = 1,
    SHThreadTypeStatusText,
    SHThreadTypeStatusLocation,
    SHThreadTypeStatusSong,
    SHThreadTypeStatusDP,
    SHThreadTypeStatusProfileChange,
    SHThreadTypeStatusJoin,
    SHThreadTypeMessageLocation
} SHThreadType;

typedef enum {
    SHPostColorWhite = 1,
    SHPostColorRed,
    SHPostColorGreen,
    SHPostColorBlue,
    SHPostColorPink,
    SHPostColorYellow
} SHPostColor;

typedef enum {
    SHPrivacySettingPublic = 1,
    SHPrivacySettingPrivate
} SHPrivacySetting;

typedef enum {
    SHRecipientPickerModeBoardRequests = 1,
    SHRecipientPickerModeBoardMembers,
    SHRecipientPickerModeFollowing,
    SHRecipientPickerModeFollowers
} SHRecipientPickerMode;

typedef enum {
    SHProfileViewModeViewing = 1,
    SHProfileViewModeAcceptRequest
} SHProfileViewMode;

#endif