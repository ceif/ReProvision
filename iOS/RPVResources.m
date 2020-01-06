//
//  RPVResources.m
//  
//
//  Created by Matt Clarke on 09/01/2018.
//

#import "RPVResources.h"
#import "AppDelegate.h"
#import "SAMKeychain.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#include <notify.h>
#include <dlfcn.h>

// For Apple Watch support
@interface NRDevice : NSObject
- (id)valueForProperty:(id)arg1;
@end

@interface NRPairedDeviceRegistry : NSObject
+ (instancetype)sharedInstance;
- (NRDevice*)getActivePairedDevice;
- (bool)isPaired;
@end

static dispatch_once_t nanoRegistryOnceToken;

#define SERVICENAME @"com.matchstic.ReProvision"

@implementation RPVResources

/////////////////////////////////////////////////////////////////////////////////////////////////
// User Settings
/////////////////////////////////////////////////////////////////////////////////////////////////

+ (BOOL)shouldShowDebugAlerts {
    id value = [self preferenceValueForKey:@"showDebugAlerts"];
    return value ? [value boolValue] : NO;
}

+ (BOOL)shouldShowAlerts {
    id value = [self preferenceValueForKey:@"showAlerts"];
    return value ? [value boolValue] : YES;
}

+ (BOOL)shouldShowNonUrgentAlerts {
    id value = [self preferenceValueForKey:@"showNonUrgentAlerts"];
    return value ? [value boolValue] : NO;
}

// How many days left until expiry.
+ (int)thresholdForResigning {
    id value = [self preferenceValueForKey:@"thresholdForResigning"];
    return value ? [value intValue] : 2;
}

+ (BOOL)shouldAutomaticallyResign {
    id value = [self preferenceValueForKey:@"resign"];
    return value ? [value boolValue] : YES;
}

+ (BOOL)shouldResignInLowPowerMode {
    id value = [self preferenceValueForKey:@"resignInLowPowerMode"];
    return value ? [value boolValue] : NO;
}

+ (BOOL)shouldAutoRevokeIfNeeded {
    id value = [self preferenceValueForKey:@"shouldAutoRevokeIfNeeded"];
    return value ? [value boolValue] : NO;
}

+ (NSTimeInterval)heartbeatTimerInterval {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"heartbeatTimerInterval"];
    int time = value ? [value intValue] : 2;
    
    NSTimeInterval interval = 3600;
    interval *= time;
    
    return interval;
}

+ (id)preferenceValueForKey:(NSString*)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)setPreferenceValue:(id)value forKey:(NSString*)key withNotification:(NSString*)notification {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    
    // Write to CFPreferences
    CFPreferencesSetValue ((__bridge CFStringRef)key, (__bridge CFPropertyListRef)value, CFSTR("com.matchstic.reprovision.ios"), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
    CFPreferencesAppSynchronize(CFSTR("com.matchstic.reprovision.ios"));
    
    // Notify daemon of new preferences.
    [(AppDelegate*)[UIApplication sharedApplication].delegate requestPreferencesUpdate];
    
    // Broadcast notification as Darwin
    [self _broadcastNotification:notification withUserInfo:nil];
}

+ (void)_broadcastNotification:(NSString*)notifiation withUserInfo:(NSDictionary*)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:notifiation object:nil userInfo:userInfo];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// User Account
/////////////////////////////////////////////////////////////////////////////////////////////////

+ (NSString*)getUsername {
    NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:@"cachedUsername"];
    NSArray* components = [username componentsSeparatedByString:@"|"];
    if([components count] < 2) return nil;
    return username;
}

+ (NSString*)getPassword {
    return [SAMKeychain passwordForService:SERVICENAME account:[self getUsername]];
}

+ (NSString*)getCertID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"certID"];
}

+ (NSString*)getDeviceID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceID"];
}


+ (NSString*)getTeamID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"cachedTeamID"];
}

+ (NSString*)getCredentialsVersion {
    NSString* version = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentialsVersion"];
    return version ? version : @"0";
}

+ (BOOL)hasDismissedAccountView {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hasDismissedAccountView"];
}

+ (void)setHasDismissedAccountView:(BOOL)accoutViewDisplay {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:accoutViewDisplay forKey:@"hasDismissedAccountView"];
    [ud synchronize];
}

+ (void)storeUsername:(NSString*)username password:(NSString*)password andTeamID:(NSString*)teamId {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"cachedUsername"];
    
    [SAMKeychain setPassword:password forService:SERVICENAME account:username];
    
    [[NSUserDefaults standardUserDefaults] setObject:teamId forKey:@"cachedTeamID"];
    [[NSUserDefaults standardUserDefaults] setObject:CURRENT_CREDENTIALS_VERSION forKey:@"credentialsVersion"];
}

+ (void)userDidRequestAccountSignIn {
    [self _broadcastNotification:@"RPVDisplayAccountSignInController" withUserInfo:nil];
}

+ (void)userDidRequestAccountSignOut {
    NSString *username = [self getUsername];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cachedUsername"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cachedTeamID"];
    
    // Remove password from Keychain
    [SAMKeychain deletePasswordForService:SERVICENAME account:username];
    
    [self _broadcastNotification:@"RPVDisplayAccountSignInController" withUserInfo:nil];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// Apple Watch
/////////////////////////////////////////////////////////////////////////////////////////////////

+ (BOOL)hasActivePairedWatch {
#if TARGET_OS_SIMULATOR
    return NO;
#else
    // Load NanoRegistry if needed.
    dispatch_once(&nanoRegistryOnceToken, ^{
        dlopen("/System/Library/PrivateFrameworks/NanoRegistry.framework/NanoRegistry", RTLD_NOW);
    });
    
    NRPairedDeviceRegistry *sharedRegistry = [objc_getClass("NRPairedDeviceRegistry") sharedInstance];
    return [sharedRegistry isPaired];
#endif
}

+ (NSString*)activePairedWatchUDID {
    return [self _valueForActivePairedWatchWithProperty:@"UDID"];
}

+ (NSString*)activePairedWatchName {
    return [self _valueForActivePairedWatchWithProperty:@"name"];
}

+ (id)_valueForActivePairedWatchWithProperty:(NSString*)property {
#if TARGET_OS_SIMULATOR
    return @"";
#else
    // Load NanoRegistry if needed.
    dispatch_once(&nanoRegistryOnceToken, ^{
        dlopen("/System/Library/PrivateFrameworks/NanoRegistry.framework/NanoRegistry", RTLD_NOW);
    });
    
    NRPairedDeviceRegistry *sharedRegistry = [objc_getClass("NRPairedDeviceRegistry") sharedInstance];
    NRDevice *currentWatchDevice = [sharedRegistry getActivePairedDevice];
    return [currentWatchDevice valueForProperty:property];
#endif
}

//////////////////////////////////////////////////////////////////////////////////
// Helper methods.
//////////////////////////////////////////////////////////////////////////////////

+ (NSString*)getFormattedTimeRemainingForExpirationDate:(NSDate*)expirationDate {
    NSDate *now = [NSDate date];
    
    NSTimeInterval distanceBetweenDates = [expirationDate timeIntervalSinceDate:now];
    double secondsInAnHour = 3600;
    NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
    
    int days = (int)floor((CGFloat)hoursBetweenDates / 24.0);
    int minutes = distanceBetweenDates / 60;
    
    if (days > 0) {
        // round up days to make more sense to the user
        return [NSString stringWithFormat:@"%d day%@, %d hour%@", days, days == 1 ? @"" : @"s", (int)hoursBetweenDates - (days * 24), hoursBetweenDates == 1 ? @"" : @"s"];
    } else if (hoursBetweenDates > 0) {
        // less than 24 hours, warning time.
        return [NSString stringWithFormat:@"%d hour%@", (int)hoursBetweenDates, hoursBetweenDates == 1 ? @"" : @"s"];
    } else if (minutes > 0){
        // less than 1 hour, warning time. (!!)
        return [NSString stringWithFormat:@"%d minute%@", minutes, minutes == 1 ? @"" : @"s"];
    } else {
        return @"Expired";
    }
}

+ (CGRect)boundedRectForFont:(UIFont*)font andText:(NSString*)text width:(CGFloat)width {
    if (!text || !font) {
        return CGRectZero;
    }
    
    if (![text isKindOfClass:[NSAttributedString class]]) {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font}];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        return rect;
    } else {
        return [(NSAttributedString*)text boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
    }
}

@end
