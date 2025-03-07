//
//  SHLocationManager.m
//  Theboard
//
//  Created by MachOSX on 1/27/15.
//  Copyright (c) 2015 Scapehouse. All rights reserved.
//

#import "SHLocationManager.h"

#import "AppDelegate.h"

@implementation SHLocationManager

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.delegate = self;
        
        _geoCoder = [[CLGeocoder alloc] init];
    }
    
    return self;
}

- (void)updateLocation
{
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ( [_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)] )
    {
        [_locationManager requestWhenInUseAuthorization];
    }
    
    [_locationManager startUpdatingLocation];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _currentLocation = newLocation.coordinate;
    
    NSString *timeNow = [appDelegate.modelManager dateTodayString];
    
    [appDelegate.currentUser setObject:timeNow forKey:@"last_location_check"];
    
    [appDelegate.modelManager executeUpdate:@"UPDATE sh_current_user SET last_location_check = :last_location_check"
                    withParameterDictionary:@{@"last_location_check": timeNow}];
    
    [_locationManager stopUpdatingLocation];
    [self locationManagerDidUpdateLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ( status != kCLAuthorizationStatusAuthorized || ![CLLocationManager locationServicesEnabled] )
    {
        _currentLocation = CLLocationCoordinate2DMake(9999, 9999);
        
        [self locationManagerUpdateDidFail];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    _currentLocation = CLLocationCoordinate2DMake(9999, 9999);
    
    [self locationManagerUpdateDidFail];
}

#pragma mark -
#pragma mark LocationManagerDelegate methods

- (void)locationManagerDidUpdateLocation
{
    if ( [_delegate respondsToSelector:@selector(locationManagerDidUpdateLocation)] )
    {
        [_delegate locationManagerDidUpdateLocation];
    }
}

- (void)locationManagerUpdateDidFail
{
    if ( [_delegate respondsToSelector:@selector(locationManagerDidUpdateLocation)] )
    {
        [_delegate locationManagerUpdateDidFail];
    }
}

@end
