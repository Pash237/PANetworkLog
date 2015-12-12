//
// Created by Pavel Alexeev on 12.12.15.
// Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import "PANetworkLog.h"

@interface PANetworkLog ()
@property (nonatomic) dispatch_source_t timer;
@property (nonatomic) NSString *currentLogPath;
@property (nonatomic) NSURL *serverURL;
@end

@implementation PANetworkLog

+ (instancetype)sharedInstance
{
	static dispatch_once_t once;
	static id sharedInstance;
	dispatch_once(&once, ^{
		sharedInstance = [self new];
	});

	return sharedInstance;
}

dispatch_source_t CreateDispatchTimer(double interval, dispatch_block_t block)
{
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
	if (timer)
	{
		dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, (int64_t) (interval * NSEC_PER_SEC)), (uint64_t) (interval * NSEC_PER_SEC), (1ull * NSEC_PER_SEC) / 10);
		dispatch_source_set_event_handler(timer, block);
		dispatch_resume(timer);
	}
	return timer;
}

- (NSString *)newLogPath
{
	NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
	NSString *filename = [NSString stringWithFormat:@"%lf", CFAbsoluteTimeGetCurrent()];
	return [cachesDirectory stringByAppendingPathComponent:filename];
}

- (void)forwardLogsToURL:(NSString *)urlString
{
	self.currentLogPath = self.newLogPath;
	self.serverURL = [NSURL URLWithString:urlString];

	NSLog(@"Logging to %@", self.serverURL);

	freopen([self.currentLogPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);

	NSLog(@"---------- Starting session %@ ----------", [NSDate date]);

	self.timer = CreateDispatchTimer(0.5, ^{
		NSString *contents = [NSString stringWithContentsOfFile:self.currentLogPath encoding:NSUTF8StringEncoding error:NULL];
		if (contents.length > 0) {
			printf("%s", contents.UTF8String);

			[self sendLogAtPath:self.currentLogPath toURL:self.serverURL];

			self.currentLogPath = self.newLogPath;
			freopen([self.currentLogPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
		}
	});
}

- (void)sendLogAtPath:(NSString *)filePath toURL:(NSURL *)url
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	[request setHTTPMethod:@"POST"];
	NSData *postData = [NSData dataWithContentsOfFile:filePath];
	[request setHTTPBody:postData];

	NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
	}];

	[dataTask resume];
}

@end