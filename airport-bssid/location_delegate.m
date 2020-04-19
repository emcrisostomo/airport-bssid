//
// Created by Enrico Maria Crisostomo on 18/04/2020.
// Copyright (c) 2020 Shintaro Tanaka. All rights reserved.
//

#import "location_delegate.h"
#import "wifi_scanner.h"

@implementation location_delegate {

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  wifi_scanner *scanner = [[wifi_scanner alloc] init];
  [scanner setArgc:self.argc];
  [scanner setArgv:self.argv];

  [scanner scan];
}

@end