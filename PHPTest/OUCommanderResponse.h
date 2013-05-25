//
//  OUCommanderResponse.h
//  PHPTest
//
//  Created by Ömer ÜCEL on 5/26/13.
//  Copyright (c) 2013 Ömer ÜCEL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OUCommanderResponse : NSObject{
    BOOL _hasError;
    NSString *_output;
    NSString *_error;
}

- (id)init: (NSString*)output error:(NSString*)error;
- (BOOL)hasError;
- (NSString *)getError;
- (NSString *)getOutput;
@end
