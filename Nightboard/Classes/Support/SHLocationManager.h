//
//  SHLocationManager.h
//  Theboard
//
//  Created by MachOSX on 1/27/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class SHLocationManager;

@protocol SHLocationManagerDelegate<NSObject>
@optional

- (void)locationManagerDidUpdateLocation;
- (void)locationManagerUpdateDidFail;

@end

@interface SHLocationManager : NSObject <CLLocationManagerDelegate>
{
    
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic, weak) id <SHLocationManagerDelegate> delegate;

- (void)updateLocation;

@end
