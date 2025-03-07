//
//  NSString+Utils.h
//  Nightboard
//
//  Created by MachOSX on 8/13/13.
//
//

#import <UIKit/UIKit.h>

@interface NSString (Utils)

- (NSString *)stringByTrimmingLeadingWhitespace;
- (NSString *)stringByRemovingEmoji;

@end
