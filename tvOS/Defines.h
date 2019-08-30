//
//  Defines.h
//  tvOS
//
//  Created by Kevin Bradley on 8/26/19.
//  Copyright © 2019 Matt Clarke. All rights reserved.
//

#ifdef __OBJC__

#import "PureLayout.h"
#import "UIViewController+Additions.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "UIView+RecursiveFind.h"

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#define DLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__])
#define LOG_SELF        DDLogInfo(@"%@ %@", self, NSStringFromSelector(_cmd))

#endif
