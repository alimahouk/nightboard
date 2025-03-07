//
//  Sound.m
//  Nightboard
//
//  Created by MachOSX on 8/20/13.
//
//


#import "Sound.h"

@implementation Sound

+ (void)playSoundEffect:(int)soundNumber
{
    NSString *effect = @"";
    NSString *type = @"";
	
	switch ( soundNumber )
    {
        case 1:
			effect = @"radar_1";
			type = @"aif";
			break;
            
		default:
			break;
	}
	
    SystemSoundID soundID;
	
    NSString *path = [[NSBundle mainBundle] pathForResource:effect ofType:type];
    NSURL *url = [NSURL fileURLWithPath:path];
	
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

@end
