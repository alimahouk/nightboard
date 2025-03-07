//
//  SHSettingsViewController_Corporate.h
//  Nightboard
//
//  Created by MachOSX on 2/11/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHSettingsViewController_Account : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
    UITableView *settingsTableView;
    NSDictionary *tableContents;
    NSArray *sortedKeys;
}

@end