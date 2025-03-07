//
//  SHSettingsViewController_Corporate.h
//  Nightboard
//
//  Created by MachOSX on 2/11/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

@interface SHSettingsViewController_Corporate : UIViewController <UIWebViewDelegate, MBProgressHUDDelegate>
{
    UIWebView *browser;
    MBProgressHUD *HUD;
}

@property (nonatomic) NSString *type;

@end
