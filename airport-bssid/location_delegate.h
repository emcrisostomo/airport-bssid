//
// Created by Enrico Maria Crisostomo on 18/04/2020.
// Copyright (c) 2020 Shintaro Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "airport_bssid_config.h"

@interface location_delegate : NSObject <CLLocationManagerDelegate>

@property(nonatomic) struct airport_bssid_config config;

@end