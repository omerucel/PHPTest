//
//  OUCommander.h
//  PHPTest
//
//  Created by Ömer ÜCEL on 5/25/13.
//  Copyright (c) 2013 Ömer ÜCEL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OUCommanderResponse.h"

@interface OUCommander : NSObject

- (OUCommanderResponse*) run: (NSString*)command properties:(NSArray *)properties;
@end
