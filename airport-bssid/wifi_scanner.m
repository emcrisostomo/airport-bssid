//
// Created by Enrico Maria Crisostomo on 18/04/2020.
// Copyright (c) 2020 Shintaro Tanaka. All rights reserved.
//

#import "wifi_scanner.h"
#import <CoreWLAN/CoreWLAN.h>

@implementation wifi_scanner {

}

CWInterface *getActiveInterfaceByName(NSString *ifName);

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

CWInterface *getActiveInterfaceByName(NSString *ifName) {
  CWInterface *interface = nil;

  if (ifName)
    interface = [[CWWiFiClient sharedWiFiClient] interfaceWithName:ifName];
  else
    interface = [[CWWiFiClient sharedWiFiClient] interface];

  if (!interface.powerOn)
    dump_error(@"The interface is down. "
               "Please activate the interface before connecting to network!");

  return interface;
}

- (void)scan {

  // interface check
  CWInterface *interface = getActiveInterfaceByName(self.config.ifName);

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
    if ([network.bssid isEqualToString:self.config.bssid]) {
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

  if (self.config.bssid == nil) {
    dump_error(@"Network scan completed. If you want to "
               "connect to a specific BSSID, please enter "
               "the command below:\n"
               "airport-bssid <ifname> <bssid> [<password>]");
  }

  if (targetNetwork == nil)
    dump_error(
        [NSString stringWithFormat:@"The target network \"%@\" could not be found.",
                                   self.config.bssid]);

  BOOL result = [interface associateToNetwork:targetNetwork
                                     password:self.config.password
                                        error:&error];

  if (error || !result)
    dump_error([NSString stringWithFormat:@"Could not connect to the network: %@",
                                          error]);

  printf("Associated to network \"%s\" (BSSID: %s)\n",
      [targetNetwork.ssid cStringUsingEncoding:NSUTF8StringEncoding],
      [self.config.bssid cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end