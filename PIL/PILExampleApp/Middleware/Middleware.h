//
//  Middleware.h
//  Copyright © 2016 VoIPGRID. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The Middleware class communicates with the Middleware server.
 */
@interface Middleware : NSObject

/**
 *  Notification which will be posted when the middleware detects a registration
 *  on another device.
 */
extern NSString * const _Nonnull MiddlewareRegistrationOnOtherDeviceNotification;

extern NSString * const _Nonnull MiddlewareAccountRegistrationIsDoneNotification;

- (void)deleteDeviceRegistration: (NSString *_Nonnull) apnsToken;

@end
