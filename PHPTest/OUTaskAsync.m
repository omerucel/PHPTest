//
//  OUTaskAsync.m
//  PHPTest
//
//  Created by Ömer ÜCEL on 5/26/13.
//  Copyright (c) 2013 Ömer ÜCEL. All rights reserved.
//

#import "OUTaskAsync.h"

NSString * const OUTaskAsyncDataAvailableNotification = @"OUTaskAsyncDataAvailableNotification";
NSString * const OUTaskAsyncTaskTerminatedNotification = @"OUTaskAsyncTaskTerminatedNotification";

@implementation OUTaskAsync

- (id) init{
    if (self = [super init])
        completedTime = [NSNumber numberWithInt:0];

    return self;
}

- (void) dealloc{
    [self stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) stop{
    if ([task isRunning])
        [task terminate];
}

- (void)launch:(NSString *)command properties:(NSArray *)properties{
    [self stop];

    outputBuffer = [[NSMutableString alloc] init];

    task = [[NSTask alloc] init];
    [task setLaunchPath:command];
    [task setArguments:properties];

    NSPipe *stdout = [NSPipe pipe];
    NSPipe *stderr = [NSPipe pipe];

    NSFileHandle *stdoutFileHandle = [stdout fileHandleForReading];
    NSFileHandle *stderrFileHandle = [stderr fileHandleForReading];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationOutputAvailable:) name:NSFileHandleDataAvailableNotification object:stdoutFileHandle];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationOutputAvailable:) name:NSFileHandleDataAvailableNotification object:stderrFileHandle];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationTaskTerminated:) name:NSTaskDidTerminateNotification object:task];

    [stdoutFileHandle waitForDataInBackgroundAndNotify];
    [stderrFileHandle waitForDataInBackgroundAndNotify];

    [task setStandardOutput:stdout];
    [task setStandardError:stderr];

    startTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    [task launch];
}

- (void)notificationOutputAvailable:(NSNotification *)notification{
    NSFileHandle *fileHandle = (NSFileHandle *)[notification object];
    NSData *data = [fileHandle availableData];

    if ([data length])
    {
        [outputBuffer appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        [fileHandle waitForDataInBackgroundAndNotify];

        [[NSNotificationCenter defaultCenter] postNotificationName:OUTaskAsyncDataAvailableNotification object:outputBuffer];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:fileHandle];
    }
};

- (void)notificationTaskTerminated:(NSNotification *)notification{
    completedTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    completedTime = [NSNumber numberWithDouble:([completedTime doubleValue] - [startTime doubleValue])];

    [[NSNotificationCenter defaultCenter] postNotificationName:OUTaskAsyncTaskTerminatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:task];
}

- (double)getCompletedTime{
    return [completedTime doubleValue];
}

@end
