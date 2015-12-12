//
// Created by Pavel Alexeev on 12.12.15.
// Copyright (c) 2015 Pavel Alexeev. All rights reserved.
//

#import "PANetworkLog.h"

static NSTimeInterval UpdateInterval = 0.5;

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

- (NSString *)logsDirectory
{
	NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
	return cachesDirectory;
}

- (NSString *)newLogPath
{
	NSString *filename = [NSString stringWithFormat:@"PANetworkLog_%lf", CFAbsoluteTimeGetCurrent()];
	return [self.logsDirectory stringByAppendingPathComponent:filename];
}

- (void)forwardLogsToURL:(NSString *)urlString
{
	self.currentLogPath = self.newLogPath;
	self.serverURL = [NSURL URLWithString:urlString];

	//send all old logs (there might be crases from previous launches)
	[self sendAllLogsAtDirectory:self.logsDirectory toURL:self.serverURL];

	NSLog(@"Logging to %@", self.serverURL);

	freopen([self.currentLogPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);

	NSLog(@"---------- Starting session %@ ----------", [NSDate date]);

	self.timer = CreateDispatchTimer(UpdateInterval, ^{
		NSString *contents = [NSString stringWithContentsOfFile:self.currentLogPath encoding:NSUTF8StringEncoding error:NULL];
		if (contents.length > 0) {
			printf("%s", contents.UTF8String);

			[self sendLogAtPath:self.currentLogPath toURL:self.serverURL];

			self.currentLogPath = self.newLogPath;
			freopen([self.currentLogPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
		}
	});
}

- (void)sendAllLogsAtDirectory:(NSString *)directoryPath toURL:(NSURL *)url
{
	NSMutableData *postData = [NSMutableData data];
	[postData appendData:[@"----- Previous logs -----\n" dataUsingEncoding:NSUTF8StringEncoding]];

	//find all existent logs in specified directory
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
	NSMutableArray *logFilePaths = [NSMutableArray array];
	for (NSString *filename in files) {
		if ([filename rangeOfString:@"PANetworkLog"].location != NSNotFound) {
			NSString *filePath = [directoryPath stringByAppendingPathComponent:filename];

			NSData *logData = [NSData dataWithContentsOfFile:filePath];
			if (logData.length > 0) {
				[postData appendData:logData];

				[logFilePaths addObject:filePath];
			} else {
				//remove empty log
				[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
			}
		}
	}
	[postData appendData:[@"-------------------------\n" dataUsingEncoding:NSUTF8StringEncoding]];

	if (logFilePaths.count > 0) {
		[self sendLogData:postData toURL:url completion:^(NSData *data, NSURLResponse *response, NSError *error) {
			if (!error) {
				//remove all old logs
				for (NSString *filePath in logFilePaths) {
					[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
				}
			}
		}];
	}
}

- (void)sendLogAtPath:(NSString *)filePath toURL:(NSURL *)url
{
	NSData *postData = [NSData dataWithContentsOfFile:filePath];
	[self sendLogData:postData toURL:url completion:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (!error) {
			[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
		}
	}];
}

- (void)sendLogData:(NSData *)logData toURL:(NSURL *)url completion:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completion
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:logData];

	NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completion];

	[dataTask resume];
}

@end