//
// Created by Enrico Maria Crisostomo on 18/04/2020.
// Copyright (c) 2020 Shintaro Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface location_delegate : NSObject <CLLocationManagerDelegate>

@property(nonatomic) int argc;
@property(nonatomic) char **argv;

@end