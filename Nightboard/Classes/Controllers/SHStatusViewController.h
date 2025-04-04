//
//  SHStatusViewController.h
//  Nightboard
//
//  Created by MachOSX on 2/7/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SHLocationPicker.h"
#import "MBProgressHUD.h"
#import "TTTAttributedLabel.h"

@interface SHStatusViewController : UIViewController <MBProgressHUDDelegate, SHLocationPickerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
{
    MBProgressHUD *HUD;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *doneButton;
    UITableView *statusList;
    UITableViewCell *listCell;
    UIView *lowerWell;
    UIView *lowerWellShadowCopy;
    UIView *statusListOverlay;
    UIImageView *lowerWellSeparator;
    UIImageView *lowerWellIcon;
    UIButton *currentStatusButton;
    TTTAttributedLabel *currentLocationLabel;
    UILabel *currentStatusLabel;
    UILabel *statusLabelShadow;
    UILabel *statusTemplateHelpLabel;
    UILabel *characterCounter;
    UITextView *statusEditor;
    NSMutableArray *statusListEntries;
    NSDictionary *currentVenue;
    NSString *status;
    NSString *statusType;
    CGSize keyboardSize;
    CGFloat keyboardAnimationDuration;
    UIViewAnimationCurve keyboardAnimationCurve;
    CGPoint panCoordinate;
    BOOL keyboardIsShown;
}

- (void)dismissView;
- (void)hideLowerWell;
- (void)showLowerWell;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillBeHidden:(NSNotification *)notification;

- (void)editCurrentStatus;
- (void)setStatus:(NSMutableDictionary *)statusData;
- (void)addToTemplates;
- (void)postStatus;

- (void)showLocationPicker;

// Gestures.
- (void)userDidTapAndHoldRow:(UILongPressGestureRecognizer *)longPress;
- (void)userDidTapAndHoldStatusButton:(UILongPressGestureRecognizer *)longPress;

- (void)showNetworkError;

@end
