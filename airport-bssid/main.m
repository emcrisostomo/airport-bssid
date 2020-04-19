//
//  main.m
//  airport-bssid
//
//  Created by Shintaro Tanaka on 6/11/13.
//  Copyright (c) 2013 Shintaro Tanaka. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "location_delegate.h"

void show_help(void);

int main(int argc, char *argv[]) {
  @autoreleasepool {
    int c;
    char *ifNameArg = nil;
    char *bssidArg = nil;
    char *passwordArg = nil;

    while ((c = getopt(argc, argv, ":b:hi:p:")) != -1)
      switch (c) {
        case 'b':
          bssidArg = optarg;
          break;

        case 'h':
          show_help();
          return 1;

        case 'i':
          ifNameArg = optarg;
          break;

        case 'p':
          passwordArg = optarg;
          break;

        case ':':
          fprintf(stderr, "Option -%c requires an argument.\n", optopt);
          return 1;

        case '?':
          if (isprint(optopt))
            fprintf(stderr, "Unknown option `-%c'.\n", optopt);
          else
            fprintf(stderr,
                "Unknown option character `\\x%x'.\n",
                optopt);
          return 1;
        default:
          abort();
      }

    struct airport_bssid_config config;
    config.ifName = (ifNameArg == nil ? nil : [NSString stringWithUTF8String:ifNameArg]);
    config.bssid = (bssidArg == nil ? nil : [NSString stringWithUTF8String:bssidArg]);
    config.password = (passwordArg == nil ? nil : [NSString stringWithUTF8String:passwordArg]);

    location_delegate *ld = [[location_delegate alloc] init];
    [ld setConfig:config];

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

void show_help() {
  printf("airport-bssid\n");
  printf("\n");
  printf("Usage:\n");
  printf("airport-bssid [-i ifname] [-b bssid] [-p password]\n");
  printf("\n");
  printf("See the man page for more information.\n");
  printf("\n");
  printf("Report bugs to <https://github.com/emcrisostomo/airport-bssid/issues>.\n");
  printf("Home page: <https://github.com/emcrisostomo/airport-bssid>.\n");
}
