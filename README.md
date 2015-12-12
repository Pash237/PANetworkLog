# PANetworkLog

[![Version](https://img.shields.io/cocoapods/v/PANetworkLog.svg?style=flat)](http://cocoapods.org/pods/PANetworkLog)
[![License](https://img.shields.io/cocoapods/l/PANetworkLog.svg?style=flat)](http://cocoapods.org/pods/PANetworkLog)
[![Platform](https://img.shields.io/cocoapods/p/PANetworkLog.svg?style=flat)](http://cocoapods.org/pods/PANetworkLog)

Simple iOS library to send all NSLog messages (stderr output) to backend server.
Simple server to display logs is [included](https://github.com/Pash237/PANetworkLog/blob/master/log_server.py) in the repo.

## Installation

PANetworkLog is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PANetworkLog'
```

##Usage

```
NSString *url = [NSString stringWithFormat:@"http://example.com/logs?device_id=%@", [UIDevice currentDevice].identifierForVendor.UUIDString];
[[PANetworkLog sharedInstance] forwardLogsToURL:url];
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.
Don't forget to disable `NSAppTransportSecurity` if your server is not on https.

To run included server, type
```
sudo python log_server.py 
```

## Author

Pavel Alexeev, pasha.alexeev@gmail.com

## License

PANetworkLog is available under the MIT license. See the LICENSE file for more info.
