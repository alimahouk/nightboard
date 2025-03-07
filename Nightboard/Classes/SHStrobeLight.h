//
//  SHStrobeLight.h
//  Nightboard
//
//  Created by MachOSX on 2/7/15.
//
//

#import <UIKit/UIKit.h>

#import "Constants.h"

@interface SHStrobeLight : UIImageView
{
    
}

@property (nonatomic) SHStrobeLightPosition oldPosition;
@property (nonatomic) SHStrobeLightPosition position;

- (void)activateStrobeLight;
- (void)affirmativeStrobeLight;
- (void)negativeStrobeLight;
- (void)defaultStrobeLight;
- (void)deactivateStrobeLight;
- (void)setStrobeLightPosition:(SHStrobeLightPosition)position;
- (void)restoreOldPosition;

@end
