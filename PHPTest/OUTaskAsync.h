//
//  OUTaskAsync.h
//  PHPTest
//
//  Created by Ömer ÜCEL on 5/26/13.
//  Copyright (c) 2013 Ömer ÜCEL. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const OUTaskAsyncDataAvailableNotification;
FOUNDATION_EXPORT NSString * const OUTaskAsyncTaskTerminatedNotification;

@interface OUTaskAsync : NSObject{
    NSTask *task;
    NSMutableString *outputBuffer;
    NSNumber *startTime;
    NSNumber *completedTime;
}

- (void)launch: (NSString*)command properties:(NSArray *)properties;
- (void)stop;
- (void)notificationTaskTerminated:(NSNotification *)notification;
- (void)notificationOutputAvailable:(NSNotification *)notification;
- (double)getCompletedTime;
@end