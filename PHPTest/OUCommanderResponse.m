//
//  OUCommanderResponse.m
//  PHPTest
//
//  Created by Ömer ÜCEL on 5/26/13.
//  Copyright (c) 2013 Ömer ÜCEL. All rights reserved.
//

#import "OUCommanderResponse.h"

@implementation OUCommanderResponse

- (id) init:(NSString *)output error:(NSString *)error{
    if (self = [super init])
    {
        _hasError = error != nil && error.length > 0;
        _output = output;
        _error = error;
    }

    return self;
}

- (BOOL)hasError{
    return _hasError;
}

- (NSString *)getError{
    return _error;
}

- (NSString *)getOutput{
    return _output;
}
@end
