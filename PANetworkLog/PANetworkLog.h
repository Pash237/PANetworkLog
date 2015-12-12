//
// Created by Pavel Alexeev on 12.12.15.
// Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PANetworkLog : NSObject

/**
 * Returns the shared instance for the PANetworkLog class.
 */
+ (instancetype)sharedInstance;

/**
 * Call to forward all stderr output (with NSLogs) to the specified URL.
 * Logs will be sent in POST body.
 * stderr output will be sent to stdout, so you can see it in console.
 *
 * @param url URL to send logs to. You may with to include a device or user identifier in this URL.
 */
- (void)forwardLogsToURL:(NSString *)url;

@end