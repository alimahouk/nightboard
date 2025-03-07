//
//  SHSettingsMainViewController.h
//  Nightboard
//
//  Created by MachOSX on 2/11/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHSettingsMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *settingsTableView;
    NSDictionary *tableContents;
    NSArray *sortedKeys;
    BOOL shouldDisplayBluetoothMessage;
}

- (void)didToggleSwitch:(id)sender;

@end
