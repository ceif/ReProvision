//
//  RPVNotificationManager.h
//  iOS
//
//  Created by Matt Clarke on 26/03/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter

+ (id)defaultCenter;
- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
- (void)postNotificationName:(NSNotificationName)name object:(NSString *)object userInfo:(NSDictionary *)userInfo deliverImmediately:(BOOL)deliverImmediately;
- (void)removeObserver:(id)observer name:(nullable NSNotificationName)aName object:(nullable NSString *)anObject;
@end

@interface RPVNotificationManager : NSObject <UNUserNotificationCenterDelegate>

+ (instancetype)sharedInstance;

- (void)registerToSendNotifications;

- (void)sendNotificationWithTitle:(NSString*)title body:(NSString*)body isDebugMessage:(BOOL)isDebug isUrgentMessage:(BOOL)isUrgent andNotificationID:(NSString*)identifier;
- (void)sendNotificationWithTitle:(NSString*)title body:(NSString*)body isDebugMessage:(BOOL)isDebug andNotificationID:(NSString*)identifier;

@end
