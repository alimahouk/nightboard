//
//  AppDelegate.h
//  Theboard
//
//  Created by MachOSX on 1/27/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Constants.h"
#import "KeychainItemWrapper.h"
#import "SHMainViewController.h"
#import "SHContactManager.h"
#import "SHLocationManager.h"
#import "SHModelManager.h"
#import "SHPeerManager.h"
#import "SHStrobeLight.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) SHContactManager *contactManager;
@property (strong, nonatomic) SHLocationManager *locationManager;
@property (strong, nonatomic) SHModelManager *modelManager;
@property (strong, nonatomic) SHPeerManager *peerManager;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) UINavigationController *mainNavigationController;
@property (nonatomic) SHMainViewController *mainView;
@property (nonatomic) SHStrobeLight *strobeLight;
@property (nonatomic) KeychainItemWrapper *credsKeychainItem;
@property (nonatomic) NSMutableDictionary *currentUser;
@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) NSString *deviceToken;
@property (nonatomic) NSString *SHToken;
@property (nonatomic) NSString *SHTokenID;
@property (nonatomic) CGRect screenBounds;
@property (nonatomic) BOOL preference_UseBluetooth;

+ (AppDelegate *)sharedDelegate;

- (void)refreshCurrentUserData;
- (void)lockdownApp;
- (void)logout;

// For checking the currently selected system language.
- (BOOL)isDeviceLanguageRTL;

// Push Notifications.
- (void)handlePushNotification:(NSDictionary *)notification withApplicationState:(UIApplicationState)applicationState;

// Time.
- (NSString *)relativeTimefromDate:(NSDate *)targetDate shortened:(BOOL)shortened condensed:(BOOL)condensed;
- (NSString *)dayForTime:(NSDate *)targetDate relative:(BOOL)relative condensed:(BOOL)condensed;

// Parallax.
- (void)registerPrallaxEffectForView:(UIView *)aView depth:(CGFloat)depth;
- (void)registerPrallaxEffectForBackground:(UIView *)aView depth:(CGFloat)depth;
- (void)unregisterPrallaxEffectForView:(UIView *)aView;

// Images.
- (UIImage *)imageFilledWith:(UIColor *)color using:(UIImage *)startImage;
- (UIColor *)colorForCode:(SHPostColor)code;

@end

