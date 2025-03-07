//
//  SHWebViewController.h
//  Nightboard
//
//  Created by MachOSX on 2/11/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "MBProgressHUD.h"

@interface SHWebViewController : UIViewController <UIWebViewDelegate, MBProgressHUDDelegate, UIActionSheetDelegate>
{
    MBProgressHUD *HUD;
    UIWebView *browser;
    UIToolbar *lowerToolbar;
    UIBarItem *backButton;
    UIBarItem *forwardButton;
    UIBarItem *refreshButton;
    UIBarItem *actionButton;
    UIBarItem *flexibleWidth_1;
    UIBarItem *flexibleWidth_2;
    UIBarItem *flexibleWidth_3;
    BOOL loading;
}

@property (nonatomic) NSString *URL;
@property (nonatomic) BOOL resetsViewWhenPopped;

- (void)goBack;
- (void)goForward;
- (void)reloadPage;
- (void)showBrowserOptions;

@end
