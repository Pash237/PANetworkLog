//
//  AppDelegate.m
//  NetworkLogExample
//
//  Created by Pavel Alexeev on 12/12/15.
//  Copyright © 2015 Pavel Alexeev. All rights reserved.
//

#import "AppDelegate.h"
#import "PANetworkLog.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *url = [NSString stringWithFormat:@"http://192.168.1.109?device_id=%@", [UIDevice currentDevice].identifierForVendor.UUIDString];
    [[PANetworkLog sharedInstance] forwardLogsToURL:url];

    NSLog(@"Hello world!");

    return YES;
}

@end
