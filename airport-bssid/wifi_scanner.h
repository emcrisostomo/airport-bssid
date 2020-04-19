//
// Created by Enrico Maria Crisostomo on 18/04/2020.
// Copyright (c) 2020 Shintaro Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "airport_bssid_config.h"


@interface wifi_scanner : NSObject

@property(nonatomic) struct airport_bssid_config config;

- (void)scan;

@end