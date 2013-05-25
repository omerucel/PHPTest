//
//  OUCommander.m
//  PHPTest
//
//  Created by Ömer ÜCEL on 5/25/13.
//  Copyright (c) 2013 Ömer ÜCEL. All rights reserved.
//

#import "OUCommander.h"
#import "OUCommanderResponse.h"

@implementation OUCommander

- (OUCommanderResponse*)run:(NSString *)command properties:(NSArray *)properties
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];

    // Checking if command is executable
    if ([fileManager isExecutableFileAtPath:command] == FALSE)
        return [[OUCommanderResponse alloc] init:@"" error:[NSString stringWithFormat:@"Executable path required : %@", command]];

    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:command];
    [task setArguments:properties];

    // stdout & stderr
    NSPipe *stdout = [NSPipe pipe];
    NSPipe *stderr = [NSPipe pipe];

    // execute command
    [task setStandardOutput:stdout];
    [task setStandardError:stderr];
    [task launch];

    NSData *outputData = [[stdout fileHandleForReading] readDataToEndOfFile];
    NSData *errorData = [[stderr fileHandleForReading] readDataToEndOfFile];

    [task waitUntilExit];

    // capture response
    NSString *output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    NSString *error = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];

    return [[OUCommanderResponse alloc] init:output error:error];
}

@end
