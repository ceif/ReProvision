//
//  RPVNotificationManager.m
//  iOS
//
//  Created by Matt Clarke on 26/03/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <objc/runtime.h>

#import "RPVNotificationManager.h"
#import "RPVResources.h"


@implementation RPVNotificationManager

+ (instancetype)sharedInstance {
    static RPVNotificationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RPVNotificationManager alloc] init];
    });
    return sharedInstance;
}

- (void)registerToSendNotifications {
    // TODO: Setup in-app notifications library
}

- (void)sendNotificationWithTitle:(NSString*)title body:(NSString*)body isDebugMessage:(BOOL)isDebug andNotificationID:(NSString*)identifier {
    [self sendNotificationWithTitle:title body:body isDebugMessage:isDebug isUrgentMessage:NO andNotificationID:identifier];
}

- (void)sendNotificationWithTitle:(NSString*)title body:(NSString*)body isDebugMessage:(BOOL)isDebug isUrgentMessage:(BOOL)isUrgent andNotificationID:(NSString*)identifier {
   
    if (isDebug && ![RPVResources shouldShowDebugAlerts]) {
        return;
    }
    if (!isUrgent && ![RPVResources shouldShowNonUrgentAlerts]) {
        return;
    }
    
     // TODO: Display notification via in-app library < -- do this properly.
 
    DDLogInfo(@"send notification with title: %@", title);
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"message"] = body;
    dict[@"title"] = title;
    dict[@"timeout"] = @2;
    UIImage *image = [UIImage imageNamed:@"notifIcon"];
    NSData *imageData = UIImagePNGRepresentation(image);;
    if (imageData){
        dict[@"imageData"] = imageData;
    }
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.nito.bulletinh4x/displayBulletin" object:nil userInfo:dict];
   
}

- (void)_updateBadge {
    
    // Silence compiler warnings
    if (@available(tvOS 10.0, *)) {
        UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
        
        objNotificationContent.badge = @1;
        
        // Update application icon badge number if applicable
        //objNotificationContent.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber]);
        
        // Set time of notification being triggered
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];

        NSString *identifier = [NSString stringWithFormat:@"notif_%f", [[NSDate date] timeIntervalSince1970]];
        
        UNNotificationRequest *request = [UNNotificationRequest
                                          requestWithIdentifier:identifier                                                                content:objNotificationContent trigger:trigger];
        
        // Schedule localNotification
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                DDLogInfo(@"Error: %@", error.localizedDescription);
            }
            
        }];
    }
}

@end
