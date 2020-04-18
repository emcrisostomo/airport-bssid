//
//  main.m
//  airport-bssid
//
//  Created by Shintaro Tanaka on 6/11/13.
//  Copyright (c) 2013 Shintaro Tanaka. All rights reserved.
//

#import <CoreWLAN/CoreWLAN.h>

void show_help(void);

CWInterface *getActiveInterfaceByName(const char *ifNameArg, NSString *ifName);

void dump_error(NSString *message) {
  printf("%s\n", [message cStringUsingEncoding:NSUTF8StringEncoding]);
  exit(1);
}

char const *phyModeName(enum CWPHYMode n) {
  switch (n) {
    case kCWPHYModeNone:
      return "none";
    case kCWPHYMode11a:
      return "802.11a";
    case kCWPHYMode11b:
      return "802.11b";
    case kCWPHYMode11g:
      return "802.11g";
    case kCWPHYMode11n:
      return "802.11n";
    case kCWPHYMode11ac:
      return "802.11ac";
    default:
      return "other/unknown";
  }
}

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
          return 0;

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

    NSString *ifName = (ifNameArg == nil ? nil : [NSString stringWithUTF8String:ifNameArg]);
    NSString *bssid = (bssidArg == nil ? nil : [NSString stringWithUTF8String:bssidArg]);
    NSString *password = (passwordArg == nil ? nil : [NSString stringWithUTF8String:passwordArg]);

    // interface check
    CWInterface *interface = getActiveInterfaceByName(ifNameArg, ifName);

    // search for target bssid
    NSError *error = nil;
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ssid" ascending:YES];
    NSArray *scan = [[interface scanForNetworksWithSSID:nil error:&error]
                                sortedArrayUsingDescriptors:@[nameDescriptor]];

    if (error)
      dump_error([NSString stringWithFormat:@"An error has been occurred while scanning networks: %@", error]);

    CWNetwork *targetNetwork = nil;

    printf("Interface: %s\n", [interface.interfaceName UTF8String]);
    printf("PHY mode: %s.\n", phyModeName(interface.activePHYMode));
    printf("\x1B[0m***** Scanned networks *****\n");
    printf("%24s, %17s, %3s, RSSI(dBm)\n", "ESSID", "BSSID", "Ch");

    for (CWNetwork *network in scan) {
      if ([network.bssid isEqualToString:bssid]) {
        targetNetwork = network;
        printf("%s%24s, %17s, %3lu, %3ld\n",
               "\x1B[32m",
               [network.ssid cStringUsingEncoding:NSUTF8StringEncoding],
               [network.bssid cStringUsingEncoding:NSUTF8StringEncoding],
               (unsigned long) network.wlanChannel.channelNumber,
               (long) network.rssiValue);
      } else {
        printf("%s%24s, %17s, %3lu, %3ld\n",
               "\x1B[0m",
               [network.ssid cStringUsingEncoding:NSUTF8StringEncoding],
               [network.bssid cStringUsingEncoding:NSUTF8StringEncoding],
               (unsigned long) network.wlanChannel.channelNumber,
               (long) network.rssiValue);
      }
    }

    printf("\x1B[0m****************************\n");

    if (bssid == nil) {
      dump_error(
          [NSString stringWithFormat:@"Network scan completed. If you want to "
                                     "connect to specific BSSID, please enter "
                                     "the command below:\n"
                                     "%@ <ifname> <bssid> [<password>]",
                                     [NSString stringWithUTF8String:argv[0]]]);
    }

    if (targetNetwork == nil)
      dump_error(
          [NSString stringWithFormat:@"The target network \"%@\" could not be found.",
                                     bssid]);

    BOOL result = [interface associateToNetwork:targetNetwork
                                       password:password
                                          error:&error];

    if (error || !result)
      dump_error([NSString stringWithFormat:@"Could not connect to the network: %@",
                                            error]);

    printf("Associated to network \"%s\" (BSSID: %s)\n",
           [targetNetwork.ssid cStringUsingEncoding:NSUTF8StringEncoding],
           [bssid cStringUsingEncoding:NSUTF8StringEncoding]);

    return 0;
  }
}

CWInterface *getActiveInterfaceByName(const char *ifNameArg, NSString *ifName) {
  CWInterface *interface = nil;

  if (ifName)
    interface = [[CWWiFiClient sharedWiFiClient] interfaceWithName:[NSString stringWithUTF8String:ifNameArg]];
  else
    interface = [[CWWiFiClient sharedWiFiClient] interface];

  if (!interface.powerOn)
    dump_error(@"The interface is down. "
               "Please activate the interface before connecting to network!");

  return interface;
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

