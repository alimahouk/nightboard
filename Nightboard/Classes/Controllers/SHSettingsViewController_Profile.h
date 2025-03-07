//
//  SHSettingsViewController_Profile.h
//  Nightboard
//
//  Created by MachOSX on 2/11/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

@interface SHSettingsViewController_Profile : UIViewController <MBProgressHUDDelegate, UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    MBProgressHUD *HUD;
    UIBarButtonItem *doneButton;
    UIScrollView *mainView;
    id activeField;
    UITextField *nameField;
    UITextField *usernameField;
    UITextField *websiteField;
    UITextField *cityField;
    UITextView *bioField;
    UIButton *genderButton;
    UIButton *birthdayButton;
    UIButton *removeBirthdayButton;
    UIButton *stateButton;
    UIButton *countryButton;
    UILabel *nameLabel;
    UILabel *usernameLabel;
    UILabel *genderLabel;
    UILabel *birthdayLabel;
    UILabel *cityLabel;
    UILabel *stateLabel;
    UILabel *countryLabel;
    UILabel *bioLabel;
    UILabel *websiteLabel;
    UILabel *bioFieldPlaceholderLabel;
    UILabel *bioFieldCounterLabel;
    UIImageView *horizontalSeparator_1;
    UIImageView *horizontalSeparator_2;
    UIImageView *horizontalSeparator_3;
    UIImageView *horizontalSeparator_4;
    UIImageView *horizontalSeparator_5;
    UIImageView *horizontalSeparator_6;
    UIImageView *horizontalSeparator_7;
    UIImageView *verticalSeparator_1;
    UIImageView *verticalSeparator_2;
    UIDatePicker *birthdayPicker;
    UIPickerView *detailPicker;
    NSMutableArray *countries;
    NSMutableArray *states;
    NSMutableArray *genders;
    NSMutableArray *activeDataSource;
    NSString *name;
    NSString *username;
    NSString *gender;
    NSString *birthday;
    NSString *location_city;
    NSString *location_state;
    NSString *location_country;
    NSString *bio;
    NSString *website;
    BOOL shouldDismissKeyboard;
}

- (void)save;
- (void)removeBirthday;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillBeHidden:(NSNotification *)notification;
- (void)showBirthdayPicker;
- (void)dismissBirthdayPicker;
- (void)showGenderPicker;
- (void)showStatePicker;
- (void)showCountryPicker;
- (void)dismissDetailPicker;
- (void)datePickerValueChanged;

- (void)showNetworkError;

@end
