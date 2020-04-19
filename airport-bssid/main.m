//
//  main.m
//  airport-bssid
//
//  Created by Shintaro Tanaka on 6/11/13.
//  Copyright (c) 2013 Shintaro Tanaka. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "location_delegate.h"

int main(int argc, char *argv[]) {
  @autoreleasepool {
    location_delegate *ld = [[location_delegate alloc] init];
    [ld setArgc:argc];
    [ld setArgv:argv];

    BOOL lse = [CLLocationManager locationServicesEnabled];

    if (!lse)
      return 2;

    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:ld];
    [locationManager startUpdatingLocation];

    CFRunLoopRun();

    return 0;
  }
}


