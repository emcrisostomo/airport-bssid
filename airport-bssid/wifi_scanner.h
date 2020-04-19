//
// Created by Enrico Maria Crisostomo on 18/04/2020.
// Copyright (c) 2020 Shintaro Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface wifi_scanner : NSObject
@property(nonatomic) int argc;

@property(nonatomic) char **argv;

- (void)scan;
@end