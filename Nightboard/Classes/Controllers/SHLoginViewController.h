//
//  SHLoginViewController.h
//  Theboard
//
//  Created by MachOSX on 1/27/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SHLoginViewController : UIViewController <MBProgressHUDDelegate, UITextFieldDelegate>
{
    MBProgressHUD *HUD;
    UIScrollView *welcomeView;
    UIView *verificationView;
    UITextField *emailField;
    UITextField *codeField;
    UIButton *verifyButton;
    UILabel *rulesLabel;
    NSString *verificationCode;
    NSString *email;
    BOOL verificationCodeSent;
    BOOL verified;
    BOOL cheating;
}

- (void)sendVerificationCode;
- (void)verifyCode;
- (void)login;
- (void)showSignup;
- (void)parseLoginResponse:(NSDictionary *)response;
- (void)purgeStaleToken:(NSString *)staleToken;

- (void)showNetworkError;

@end
